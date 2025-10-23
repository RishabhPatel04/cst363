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