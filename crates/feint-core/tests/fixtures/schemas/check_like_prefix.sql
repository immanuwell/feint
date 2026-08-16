CREATE TABLE credentials (
    id serial PRIMARY KEY,
    "encryptedValue" text NOT NULL,
    CONSTRAINT encrypted_value_prefix_check CHECK ("encryptedValue" LIKE 'enc:v2:%')
);
