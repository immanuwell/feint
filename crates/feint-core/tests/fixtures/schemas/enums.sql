CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');

CREATE TABLE people (
    id serial PRIMARY KEY,
    name text NOT NULL,
    current_mood mood NOT NULL
);
