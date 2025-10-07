-- 1.Show products purchased per customer. (Only show customers who have purchased products.)
SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  o.product_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.product_name;


-- 2.Show customers with no purchases. (Hint: Use a LEFT JOIN and IS NULL)
SELECT 
  c.customer_id, 
  c.first_name, 
  c.last_name
FROM customers c
LEFT JOIN orders o 
  ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 3.Find the total number of orders per customer. (Hint: Use COUNT and GROUP BY)
SELECT 
  c.customer_id, 
  c.first_name, 
  c.last_name, 
  COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o 
  ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;


-- 4.Find the average order value per customer, where the average order is over $2,500. (Hint: Use AVG , GROUP BY, and HAVING)
SELECT 
  c.customer_id, 
  c.first_name, 
  c.last_name, 
  AVG(o.price) AS average_order_value
FROM customers c
JOIN orders o 
  ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING AVG(o.price) > 2500;
