CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE accounts (
    id serial PRIMARY KEY,
    username citext NOT NULL
);
