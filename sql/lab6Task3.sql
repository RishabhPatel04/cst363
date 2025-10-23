
-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100)
);

-- Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

-- Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) 
    REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Intermediary Between Orders and Products
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL, 
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

INSERT INTO products (name, description, price)
SELECT 
    'Geothermal_' || gs AS name,
    CASE floor(random() * 5)
        WHEN 0 THEN 'High-efficiency geothermal heat pump.'
        WHEN 1 THEN 'Advanced ground loop system for geothermal heating.'
        WHEN 2 THEN 'Commercial-grade geothermal compressor unit.'
        WHEN 3 THEN 'Smart fan coil unit with heat recovery technology.'
        ELSE 'Energy-efficient geothermal cooling solution.'
    END AS description,
    ROUND((1000 + random() * 19000)::NUMERIC, 2) AS price  -- Explicit cast to NUMERIC
FROM generate_series(1, 100_000) AS gs;

-- 1. Perform the query: SELECT * FROM customers WHERE last_name = 'Ortiz';
SELECT * FROM customers WHERE last_name = 'Ortiz';

-- 2. Use EXPLAIN to view the query execution plan. You should see Seq Scan, which means that
-- the DBMS reads the entire table to find the rows that satisfy the query.
EXPLAIN SELECT * FROM customers WHERE last_name = 'Ortiz';
-- Create a default (B-tree) index on the last_name column.
CREATE INDEX IF NOT EXISTS idx_customers_last_name_btree ON customers(last_name);
-- Repeat the query and view the execution plan. Compare the two query plans.
EXPLAIN SELECT * FROM customers WHERE last_name = 'Ortiz';

-- 3. Drop the previous index and replace it with a hash index.
DROP INDEX IF EXISTS idx_customers_last_name_btree;
CREATE INDEX IF NOT EXISTS idx_customers_last_name_hash ON customers USING hash (last_name);
-- Repeat the query and view the execution plan. Compare the B-tree and hash plans.
EXPLAIN SELECT * FROM customers WHERE last_name = 'Ortiz';

-- 4. Perform the query
--SELECT * FROM orders
--WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Use EXPLAIN to view the query execution plan. You should see Seq Scan, which means that
-- the DBMS reads the entire table to find the rows that satisfy the query.
EXPLAIN SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';
-- Create an index and review the query plan.
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
EXPLAIN SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- 5. Try out the JOIN from the lecture slides:
--SELECT c.first_name, c.last_name, p.name AS product_name,
--oi.quantity, o.order_date
--FROM customers c
--JOIN orders o ON c.customer_id = o.customer_id
--JOIN order_items oi ON o.order_id = oi.order_id
--JOIN products p ON oi.product_id = p.product_id
--WHERE c.last_name LIKE '%z';
EXPLAIN
SELECT c.first_name, c.last_name, p.name AS product_name,
       oi.quantity, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE c.last_name LIKE '%z';

--Note: A DBMS executes joins internally using one of several algorithms — most commonly
--nested loop join, hash join, or merge join. In a nested loop join, the database examines each
--row in the outer (left) table and looks for matching rows in the inner (right) table.
--What is the query plan? What type of join algorithm is used?
--Create indexes on the foreign keys. Compare the two query plans.
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

EXPLAIN
SELECT c.first_name, c.last_name, p.name AS product_name,
       oi.quantity, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE c.last_name LIKE '%z';