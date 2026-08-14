CREATE TABLE access_log (
    id serial PRIMARY KEY,
    client_ip inet NOT NULL,
    allowed_range cidr NOT NULL DEFAULT '0.0.0.0/0'
);
