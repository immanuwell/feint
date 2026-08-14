CREATE TABLE posts (
    id serial PRIMARY KEY,
    tags text[] NOT NULL DEFAULT '{}',
    scores integer[] NOT NULL DEFAULT '{}'
);
