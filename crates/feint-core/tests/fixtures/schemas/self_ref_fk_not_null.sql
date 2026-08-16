CREATE TABLE users (
    id serial PRIMARY KEY,
    created_by_id integer NOT NULL REFERENCES users(id),
    name text NOT NULL
);
