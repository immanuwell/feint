CREATE TABLE tenants (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL
);

CREATE TABLE tenant_users (
    tenant_id uuid NOT NULL REFERENCES tenants(id),
    user_id integer NOT NULL,
    role text NOT NULL,
    PRIMARY KEY (tenant_id, user_id)
);

CREATE TABLE memberships (
    tenant_id uuid NOT NULL,
    user_id integer NOT NULL,
    joined_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (tenant_id, user_id) REFERENCES tenant_users(tenant_id, user_id)
);
