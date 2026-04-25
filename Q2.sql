-- Question 2: Product Performance

/*
Identify the top 10 products by total revenue in 2024. 
Include product name, category, total revenue and total 
number of orders. Sort by revenue descending.
*/

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT oi.order_id)       AS total_orders,
    SUM(oi.line_total)                AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
  AND oi.unit_price IS NOT NULL
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;

/*
All top 10 products by revenue in 2024 are Electronics, 
with HP Pavilion 15 Laptop leading at ₦26.7M across 25 orders. 
Revenue across the top 10 ranges from ₦17.7M to ₦26.7M, 
suggesting fairly even demand. The dominance of Electronics 
across all 10 spots indicates it is by far the strongest 
performing category on the platform in 2024.
*/