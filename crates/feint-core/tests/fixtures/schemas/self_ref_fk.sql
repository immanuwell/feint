CREATE TABLE employees (
    id serial PRIMARY KEY,
    manager_id integer REFERENCES employees(id),
    name text NOT NULL
);
