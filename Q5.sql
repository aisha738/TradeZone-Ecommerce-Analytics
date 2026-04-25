-- Question 5: Customer Spend Segmentation

/*
Segment customers based on their total spend in 2024 into three groups:
- High Spenders: >= ₦100,000
- Medium Spenders: ₦50,000 - ₦99,999
- Low Spenders: < ₦50,000
*/

WITH customer_revenue AS (
    SELECT 
        c.customer_id, 
        COALESCE(SUM(o.total_amount), 0) AS total_spend
    FROM customers c
    LEFT JOIN orders o 
           ON c.customer_id = o.customer_id 
          AND EXTRACT(YEAR FROM o.order_date) = 2024
          AND o.order_status = 'Delivered'
    GROUP BY c.customer_id
),
segments AS (
    SELECT 
        customer_id,
        total_spend,
        CASE 
            WHEN total_spend >= 100000 THEN 'High Spender'
            WHEN total_spend >= 50000 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spend_segment
    FROM customer_revenue
)
SELECT 
    spend_segment,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_customer,
    ROUND(SUM(total_spend), 2) AS total_revenue_contribution
FROM segments
GROUP BY spend_segment
ORDER BY total_revenue_contribution DESC;

/*
1. THE POLARIZED CUSTOMER BASE (THE MISSING MIDDLE)
The platform's customer base is heavily polarized into two massive 
cohorts: High Spenders (409 customers) and Low Spenders (406 
customers). Together, they account for over 94% of the total 
customer base. Meanwhile, the Medium Spender tier is virtually 
non-existent, containing only 50 customers (less than 6%). This 
"hollow middle" suggests that customers either test the platform 
with very small purchases or fully commit to bulk/frequent buying, 
with very few transitioning linearly between the two.

2. EXTREME REVENUE CONCENTRATION
The platform's financial health is almost exclusively dependent on 
its High Spenders. While they represent 47% of the user base, they 
generate a staggering 98.6% of the total revenue (₦402.9 million). 
This demonstrates an extreme version of the Pareto principle, where 
almost all business value is concentrated in a single cohort.

3. LOW SPENDERS LACK ENGAGEMENT
Despite making up nearly 47% of the total user base (406 customers), 
Low Spenders contribute less than 0.5% to the total revenue (₦1.78 
million). Their average spend is extremely low (₦4,393), indicating 
that this cohort likely consists of dormant users, failed conversions, 
or customers who made a single, very cheap test purchase and never 
returned.
*/