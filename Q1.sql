-- Question 1: Customer Acquisition & 30-Day Conversion
/*
Find the top 5 states by number of new customer sign-ups in 2024. 
For each state, calculate what percentage of these new customers 
made at least one purchase within their first 30 days of signing up.
*/

WITH new_customers_2024 AS (
    SELECT customer_id, state, signup_date
    FROM customers
    WHERE EXTRACT(YEAR FROM signup_date) = 2024
),
converted AS (
    SELECT DISTINCT nc.customer_id, nc.state
    FROM new_customers_2024 nc
    JOIN orders o ON nc.customer_id = o.customer_id
    WHERE o.order_date BETWEEN nc.signup_date AND nc.signup_date + INTERVAL '30 days'
)
SELECT
    nc.state,
    COUNT(DISTINCT nc.customer_id)       AS new_customers,
    COUNT(DISTINCT c.customer_id)        AS converted_customers,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0
          / COUNT(DISTINCT nc.customer_id), 2)  AS conversion_pct
FROM new_customers_2024 nc
LEFT JOIN converted c ON nc.customer_id = c.customer_id
GROUP BY nc.state
ORDER BY new_customers DESC
LIMIT 5;

/*
Lagos led 2024 customer acquisition with 146 new sign-ups, 
nearly double the next state, and also had the highest 30-day 
conversion rate at 49.32%. FCT and Rivers followed in sign-ups
with conversion rates of 41.30% and 42.42% respectively. 
Oyo and Kano had the lowest conversions, with just 1 in 3 new
customers making a purchase within their first 30 days.
*/
