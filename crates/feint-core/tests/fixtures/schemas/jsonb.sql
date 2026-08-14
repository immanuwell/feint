CREATE TABLE events (
    id serial PRIMARY KEY,
    payload jsonb NOT NULL DEFAULT '{}',
    legacy_payload json NOT NULL DEFAULT '{}'
);
