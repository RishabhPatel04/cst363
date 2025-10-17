-- 1. Find the customer(s) with the most orders. Return customer name and order_count.
SELECT c.first_name, c.last_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY order_count DESC
LIMIT 1;

--2. Find products that have never been ordered. Return product_id. (Use NOT IN with subquery, as opposed to a join.)
SELECT product_id
FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items);

--3. Do #2 using a LEFT JOIN.
SELECT p.product_id
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

--4. Find products purchased by customers whose lifetime spend > 500. Return product_id and name; list each product only once.
-- (Lifetime spend = SUM(oi.price * oi.quantity) across all orders)
SELECT p.product_id, p.name
FROM products p
WHERE (SELECT SUM(oi.price * oi.quantity) FROM order_items oi WHERE oi.product_id = p.product_id) > 500;

--5. Find customers who purchased any single item priced at $100 or more 
--(using the price captured at purchase time in order_items). Return customer_id and full name ordered by name.
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id IN (
        SELECT product_id
        FROM products
        WHERE price >= 100
    )
    AND oi.order_id IN (
        SELECT order_id
        FROM orders
        WHERE customer_id = c.customer_id
    )
)
ORDER BY c.first_name, c.last_name;

--6. Find the product(s) ordered the most times. Return product_id, name, order_count (count of order_items rows).
SELECT p.product_id, p.name, COUNT(oi.order_item_id) AS order_count
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY order_count DESC;

--7. Create a view "vproduct" showing product_id, name, current price, order_count. If a product has never been ordered, order_count should be 0.
CREATE VIEW vproduct AS
SELECT p.product_id, p.name, p.price, COALESCE(order_count, 0) AS order_count
FROM products p
LEFT JOIN (
    SELECT product_id, COUNT(order_item_id) AS order_count
    FROM order_items
    GROUP BY product_id
) oi ON p.product_id = oi.product_id;

--8. List all rows in the view "vproduct".
SELECT * FROM vproduct;

--9. Use the view to display the product(s) with the highest order_count. Return product_id, name, order_count.
SELECT product_id, name, order_count
FROM vproduct
ORDER BY order_count DESC
LIMIT 1;

--10 List the product(s) purchased by the largest number of DISTINCT customers. Return product_id, name, distinct_customers.
SELECT p.product_id, p.name, COUNT(DISTINCT o.customer_id) AS distinct_customers
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.name
ORDER BY distinct_customers DESC;

--11. List the product_id and name for products ordered BOTH in 2024 and in 2025.
SELECT p.product_id, p.name
FROM products p
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date BETWEEN '2024-01-01' AND '2024-12-31'
)
AND EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date BETWEEN '2025-01-01' AND '2025-12-31'
);