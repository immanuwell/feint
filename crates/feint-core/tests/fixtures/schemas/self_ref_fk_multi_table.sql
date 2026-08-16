CREATE TABLE users (
    id serial PRIMARY KEY,
    created_by_id integer NOT NULL REFERENCES users(id),
    updated_by_id integer NOT NULL REFERENCES users(id),
    organization_id integer,
    name text NOT NULL
);

CREATE TABLE organizations (
    id serial PRIMARY KEY,
    created_by_id integer NOT NULL REFERENCES users(id),
    updated_by_id integer NOT NULL REFERENCES users(id),
    name text NOT NULL
);

ALTER TABLE users
    ADD CONSTRAINT users_organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organizations(id);
