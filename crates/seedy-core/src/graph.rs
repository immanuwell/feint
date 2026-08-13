//! Foreign-key dependency graph and insertion planning.
//!
//! Builds a DAG (parent -> child, i.e. "must be inserted before") from the
//! schema's FK edges, finds strongly connected components to isolate
//! cyclic groups of tables, and decides — per group — whether the cycle is
//! satisfiable via deferred constraints, null-then-backfill, or is a hard
//! error the user needs to fix in their schema.

use std::collections::HashMap;

use petgraph::algo::{tarjan_scc, toposort};
use petgraph::graph::{DiGraph, NodeIndex};

use crate::error::{Result, SeedyError};
use crate::introspect::{ForeignKey, Schema, TableId};

#[derive(Debug, Clone)]
pub struct FkRef {
    /// The table that owns the FK column(s) — i.e. the referencing side.
    pub table: TableId,
    pub fk: ForeignKey,
}

#[derive(Debug, Clone)]
pub enum InsertGroup {
    /// Single table, no cyclic FK dependency on itself.
    Simple(TableId),
    /// Tables forming a cycle where every cyclic edge is `DEFERRABLE` —
    /// insert in any order within the group; `SET CONSTRAINTS ALL
    /// DEFERRED` (issued once per transaction) defers checking to COMMIT.
    Deferred(Vec<TableId>),
    /// Tables forming a cycle, resolved by inserting the cyclic FK
    /// column(s) as NULL first, then backfilling via UPDATE once every row
    /// in the group exists.
    Backfill {
        tables: Vec<TableId>,
        null_then_backfill: Vec<FkRef>,
    },
}

impl InsertGroup {
    pub fn tables(&self) -> &[TableId] {
        match self {
            InsertGroup::Simple(t) => std::slice::from_ref(t),
            InsertGroup::Deferred(ts) => ts,
            InsertGroup::Backfill { tables, .. } => tables,
        }
    }
}

#[derive(Debug, Clone)]
pub struct InsertPlan {
    pub groups: Vec<InsertGroup>,
}

pub fn plan_insertion(schema: &Schema) -> Result<InsertPlan> {
    let mut node_of: HashMap<TableId, NodeIndex> = HashMap::new();
    let mut graph: DiGraph<TableId, ()> = DiGraph::new();

    for table in &schema.tables {
        let idx = graph.add_node(table.id.clone());
        node_of.insert(table.id.clone(), idx);
    }

    for table in &schema.tables {
        let Some(&child_idx) = node_of.get(&table.id) else {
            continue;
        };
        for fk in &table.foreign_keys {
            let Some(&parent_idx) = node_of.get(&fk.ref_table) else {
                // FK targets a table outside the introspected set (e.g. a
                // different, unscanned schema) — nothing seedy can do
                // about ordering it, so skip rather than fail the whole run.
                continue;
            };
            graph.add_edge(parent_idx, child_idx, ());
        }
    }

    let sccs = tarjan_scc(&graph);
    let mut scc_of: HashMap<NodeIndex, usize> = HashMap::new();
    for (scc_id, members) in sccs.iter().enumerate() {
        for &n in members {
            scc_of.insert(n, scc_id);
        }
    }

    let mut condensation: DiGraph<usize, ()> = DiGraph::new();
    let condensation_node: Vec<NodeIndex> = (0..sccs.len())
        .map(|scc_id| condensation.add_node(scc_id))
        .collect();
    for edge in graph.raw_edges() {
        let src_scc = scc_of[&edge.source()];
        let dst_scc = scc_of[&edge.target()];
        if src_scc != dst_scc {
            condensation.add_edge(condensation_node[src_scc], condensation_node[dst_scc], ());
        }
    }

    let scc_order = toposort(&condensation, None).map_err(|_| {
        SeedyError::Config("internal error: SCC condensation graph was not acyclic".to_string())
    })?;

    let mut groups = Vec::with_capacity(sccs.len());
    for cond_node in scc_order {
        let scc_id = condensation[cond_node];
        let members = &sccs[scc_id];
        let tables: Vec<TableId> = members.iter().map(|&n| graph[n].clone()).collect();
        let table_set: std::collections::HashSet<&TableId> = tables.iter().collect();

        let has_self_loop = members.len() == 1 && graph.contains_edge(members[0], members[0]);

        if members.len() == 1 && !has_self_loop {
            groups.push(InsertGroup::Simple(tables[0].clone()));
            continue;
        }

        // Cyclic group: gather every FK edge whose owning table and
        // referenced table are both inside this SCC.
        let mut internal: Vec<FkRef> = Vec::new();
        for table_id in &tables {
            let table = schema
                .table(table_id)
                .expect("table id came from the graph built off this schema");
            for fk in &table.foreign_keys {
                if table_set.contains(&fk.ref_table) {
                    internal.push(FkRef {
                        table: table_id.clone(),
                        fk: fk.clone(),
                    });
                }
            }
        }

        if internal.iter().any(|r| r.fk.deferrable) {
            groups.push(InsertGroup::Deferred(tables));
            continue;
        }

        let all_nullable = internal.iter().all(|r| {
            let table = schema.table(&r.table).expect("table exists");
            r.fk.columns
                .iter()
                .all(|col| table.column(col).map(|c| c.nullable).unwrap_or(false))
        });

        if all_nullable {
            groups.push(InsertGroup::Backfill {
                tables,
                null_then_backfill: internal,
            });
        } else {
            let table_names = tables
                .iter()
                .map(|t| t.qualified())
                .collect::<Vec<_>>()
                .join(", ");
            let constraint_names = internal
                .iter()
                .filter(|r| {
                    let table = schema.table(&r.table).expect("table exists");
                    !r.fk
                        .columns
                        .iter()
                        .all(|col| table.column(col).map(|c| c.nullable).unwrap_or(false))
                })
                .map(|r| format!("{}.{}", r.table.qualified(), r.fk.name))
                .collect::<Vec<_>>()
                .join(", ");
            return Err(SeedyError::UnsatisfiableCycle {
                tables: table_names,
                constraints: constraint_names,
            });
        }
    }

    Ok(InsertPlan { groups })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::introspect::{Column, Identity, Table, TypeKind, UniqueConstraint};

    fn tid(name: &str) -> TableId {
        TableId {
            schema: "public".to_string(),
            name: name.to_string(),
        }
    }

    fn simple_column(name: &str, nullable: bool) -> Column {
        Column {
            name: name.to_string(),
            position: 1,
            type_name: "int4".to_string(),
            type_kind: TypeKind::Scalar,
            nullable,
            identity: Identity::None,
            is_stored_generated: false,
            has_default: false,
            is_serial_default: false,
        }
    }

    fn table(name: &str, columns: Vec<Column>, fks: Vec<ForeignKey>) -> Table {
        Table {
            id: tid(name),
            columns,
            primary_key: Some(vec!["id".to_string()]),
            foreign_keys: fks,
            unique_constraints: vec![UniqueConstraint {
                name: format!("{name}_pkey"),
                is_primary: true,
                columns: vec!["id".to_string()],
            }],
            check_constraints: vec![],
        }
    }

    fn fk(
        name: &str,
        columns: &[&str],
        ref_table: &str,
        ref_columns: &[&str],
        deferrable: bool,
    ) -> ForeignKey {
        ForeignKey {
            name: name.to_string(),
            columns: columns.iter().map(|s| s.to_string()).collect(),
            ref_table: tid(ref_table),
            ref_columns: ref_columns.iter().map(|s| s.to_string()).collect(),
            deferrable,
            initially_deferred: false,
        }
    }

    #[test]
    fn simple_chain_orders_parent_before_child() {
        let users = table("users", vec![simple_column("id", false)], vec![]);
        let orders = table(
            "orders",
            vec![simple_column("id", false), simple_column("user_id", false)],
            vec![fk(
                "orders_user_id_fkey",
                &["user_id"],
                "users",
                &["id"],
                false,
            )],
        );
        let schema = Schema {
            tables: vec![orders, users],
        };
        let plan = plan_insertion(&schema).unwrap();
        let order: Vec<String> = plan
            .groups
            .iter()
            .flat_map(|g| g.tables().iter().map(|t| t.name.clone()))
            .collect();
        assert_eq!(order, vec!["users".to_string(), "orders".to_string()]);
    }

    #[test]
    fn nullable_self_reference_becomes_backfill_group() {
        let employees = table(
            "employees",
            vec![
                simple_column("id", false),
                simple_column("manager_id", true),
            ],
            vec![fk(
                "employees_manager_id_fkey",
                &["manager_id"],
                "employees",
                &["id"],
                false,
            )],
        );
        let schema = Schema {
            tables: vec![employees],
        };
        let plan = plan_insertion(&schema).unwrap();
        assert_eq!(plan.groups.len(), 1);
        match &plan.groups[0] {
            InsertGroup::Backfill {
                tables,
                null_then_backfill,
            } => {
                assert_eq!(tables, &[tid("employees")]);
                assert_eq!(null_then_backfill.len(), 1);
            }
            other => panic!("expected Backfill group, got {other:?}"),
        }
    }

    #[test]
    fn deferrable_cycle_becomes_deferred_group() {
        let a = table(
            "a",
            vec![simple_column("id", false), simple_column("b_id", false)],
            vec![fk("a_b_id_fkey", &["b_id"], "b", &["id"], true)],
        );
        let b = table(
            "b",
            vec![simple_column("id", false), simple_column("a_id", false)],
            vec![fk("b_a_id_fkey", &["a_id"], "a", &["id"], false)],
        );
        let schema = Schema { tables: vec![a, b] };
        let plan = plan_insertion(&schema).unwrap();
        assert_eq!(plan.groups.len(), 1);
        assert!(matches!(&plan.groups[0], InsertGroup::Deferred(_)));
    }

    #[test]
    fn hard_non_nullable_non_deferrable_cycle_errors() {
        let a = table(
            "a",
            vec![simple_column("id", false), simple_column("b_id", false)],
            vec![fk("a_b_id_fkey", &["b_id"], "b", &["id"], false)],
        );
        let b = table(
            "b",
            vec![simple_column("id", false), simple_column("a_id", false)],
            vec![fk("b_a_id_fkey", &["a_id"], "a", &["id"], false)],
        );
        let schema = Schema { tables: vec![a, b] };
        let err = plan_insertion(&schema).unwrap_err();
        assert!(matches!(err, SeedyError::UnsatisfiableCycle { .. }));
    }
}
