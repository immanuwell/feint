CREATE DOMAIN username AS text;
CREATE DOMAIN non_negative_int AS integer CHECK (VALUE >= 0);

CREATE TABLE accounts (
    id serial PRIMARY KEY,
    handle username NOT NULL,
    balance non_negative_int NOT NULL
);
