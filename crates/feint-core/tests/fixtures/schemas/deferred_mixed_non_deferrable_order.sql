-- Twenty's real shape, minimized: a 3-table cycle where most edges are
-- DEFERRABLE (routing the whole group to InsertGroup::Deferred), but one
-- edge is not -- SET CONSTRAINTS ALL DEFERRED can't defer a constraint
-- that was never declared DEFERRABLE, so the tables must still be
-- *written* in an order that satisfies every non-deferrable edge.
-- Non-deferrable edges alone give a valid order here: c, then b, then a.
CREATE TABLE a (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    b_id uuid NOT NULL
);

CREATE TABLE b (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    c_id uuid NOT NULL
);

CREATE TABLE c (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    a_id uuid NOT NULL
);

ALTER TABLE a ADD CONSTRAINT a_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
ALTER TABLE b ADD CONSTRAINT b_c_id_fkey FOREIGN KEY (c_id) REFERENCES c(id);
ALTER TABLE c ADD CONSTRAINT c_a_id_fkey FOREIGN KEY (a_id) REFERENCES a(id) DEFERRABLE INITIALLY DEFERRED;
