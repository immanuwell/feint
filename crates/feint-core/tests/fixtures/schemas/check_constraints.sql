CREATE TABLE products (
    id serial PRIMARY KEY,
    name text NOT NULL,
    price numeric(10, 2) NOT NULL CHECK (price >= 0),
    quantity integer NOT NULL CHECK (quantity >= 0 AND quantity < 10000000)
);
