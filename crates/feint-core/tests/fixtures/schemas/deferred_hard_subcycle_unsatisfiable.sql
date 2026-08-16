-- A cyclic group that lands in InsertGroup::Deferred (c.a_id is
-- DEFERRABLE, so plan_insertion's "any edge deferrable" check routes the
-- whole 3-table group there), but whose non-deferrable edges alone form
-- a genuine hard 2-table cycle (a <-> b) that no write order can
-- satisfy -- SET CONSTRAINTS ALL DEFERRED can't defer a and b's own
-- constraints, since neither was declared DEFERRABLE. This must fail at
-- plan/generate time with a clear error, not a raw FK-violation from
-- Postgres partway through a batch.
CREATE TABLE a (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    b_id uuid NOT NULL,
    c_id uuid NOT NULL
);

CREATE TABLE b (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    a_id uuid NOT NULL
);

CREATE TABLE c (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    b_id uuid NOT NULL
);

ALTER TABLE a ADD CONSTRAINT a_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
ALTER TABLE b ADD CONSTRAINT b_a_id_fkey FOREIGN KEY (a_id) REFERENCES a(id);
ALTER TABLE a ADD CONSTRAINT a_c_id_fkey FOREIGN KEY (c_id) REFERENCES c(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE c ADD CONSTRAINT c_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
