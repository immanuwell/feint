-- Same shape as deferred_hard_subcycle_unsatisfiable.sql (a Deferred
-- group whose non-deferrable edges alone form a hard cycle), except
-- b.a_id is nullable here -- so instead of being genuinely unsatisfiable,
-- it should resolve via the same null-then-backfill trick
-- InsertGroup::Backfill already uses, just applied to the non-deferrable
-- subset of a Deferred group's edges.
CREATE TABLE a (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    b_id uuid NOT NULL,
    c_id uuid NOT NULL
);

CREATE TABLE b (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    a_id uuid
);

CREATE TABLE c (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    b_id uuid NOT NULL
);

ALTER TABLE a ADD CONSTRAINT a_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
ALTER TABLE b ADD CONSTRAINT b_a_id_fkey FOREIGN KEY (a_id) REFERENCES a(id);
ALTER TABLE a ADD CONSTRAINT a_c_id_fkey FOREIGN KEY (c_id) REFERENCES c(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE c ADD CONSTRAINT c_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
