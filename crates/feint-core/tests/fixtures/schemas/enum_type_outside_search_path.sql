-- Twenty's real shape, minimized: the table lives in the schema that's on
-- search_path (the harness's own `test_<name>` schema, put there first by
-- TestDb::setup), but the enum type it uses is declared in a *different*
-- schema that is never on search_path at all. A bare, unqualified
-- `::status_enum` cast (built without knowing the type's own schema)
-- fails with "type does not exist" here even though the type genuinely
-- exists -- Postgres just never looks in `enum_outside_search_path_types` for it.
CREATE SCHEMA enum_outside_search_path_types;

CREATE TYPE enum_outside_search_path_types.status_enum AS ENUM ('active', 'inactive');

CREATE TABLE items (
    id serial PRIMARY KEY,
    status enum_outside_search_path_types.status_enum NOT NULL
);
