-- Question 4: Quarterly Revenue Trends

/*
Compare quarterly revenue across 2023 and 2024. For each quarter,
calculate total revenue, average order value and total number of orders.
Identify which single quarter showed the strongest revenue growth from 2023 to 2024.
*/

WITH quarterly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)     AS year,
        EXTRACT(QUARTER FROM order_date)  AS quarter,
        COUNT(DISTINCT order_id)          AS total_orders,
        SUM(total_amount)                 AS total_revenue,
        ROUND(AVG(total_amount), 2)       AS avg_order_value
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) IN (2023, 2024)
      AND total_amount IS NOT NULL
    GROUP BY year, quarter
),
growth AS (
    SELECT
        q1.quarter,
        ROUND((q2.total_revenue - q1.total_revenue)
              * 100.0 / q1.total_revenue, 2) AS growth_pct
    FROM quarterly q1
    JOIN quarterly q2
      ON q1.quarter = q2.quarter
     AND q1.year = 2023
     AND q2.year = 2024
)
SELECT
    q.year,
    q.quarter,
    q.total_orders,
    q.total_revenue,
    q.avg_order_value,
    g.growth_pct,
    CASE
        WHEN g.growth_pct = MAX(g.growth_pct) OVER () THEN 'Strongest Growth'
        ELSE ''
    END AS growth_flag
FROM quarterly q
LEFT JOIN growth g ON q.quarter = g.quarter
ORDER BY q.year, q.quarter;

/*
1. EXPLOSIVE YEAR-OVER-YEAR GROWTH
The platform experienced massive, uninterrupted growth across all 
metrics between 2023 and 2024. Total orders and total revenue surged 
significantly in every quarter. By Q4 2024, the platform achieved 
nearly 350 million in revenue from 983 orders, compared to just under 
72 million from 224 orders in Q4 2023.

2. STRONGEST GROWTH IN QUARTER 1
Q1 stands out as the period of most extreme relative expansion. Total 
revenue skyrocketed from roughly 7.04 million in Q1 2023 to 115.79 
million in Q1 2024, representing an extraordinary year-over-year 
growth rate of 1,544.12%, earning it the 'Strongest Growth' flag.

3. CONSISTENCY IN AVERAGE ORDER VALUE
Despite the staggering increases in order volume (scaling from 21 
orders in Q1 2023 to 983 orders by Q4 2024) and total revenue, the 
average order value remained remarkably stable. It consistently 
hovered between roughly 321k and 360k in nearly every quarter (with 
a brief dip to 250k in Q2 2023). This indicates that revenue growth 
was driven entirely by acquiring more customers and volume, rather 
than increasing prices or upselling.

Note on Data Output: The SQL query joined the growth percentage back 
to the main table using only the quarter column, which is why the 
YOY growth figures duplicate across both the 2023 and 2024 rows.
*/
