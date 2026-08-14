CREATE TABLE a (
    id serial PRIMARY KEY,
    b_id integer
);
CREATE TABLE b (
    id serial PRIMARY KEY,
    a_id integer REFERENCES a(id)
);
ALTER TABLE a ADD CONSTRAINT a_b_id_fkey FOREIGN KEY (b_id) REFERENCES b(id);
