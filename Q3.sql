-- Question 3: Seller Fulfilment Efficiency

/*
Calculate the average time in hours between order placement and delivery
for each seller. Return the top 20 sellers with the fastest average
fulfilment times among sellers who have completed at least 20 orders. 
Include their total completed orders and average customer rating.
*/

WITH seller_orders AS (
    SELECT
        o.seller_id,
        o.order_id,
        (o.delivery_date - o.order_date) * 24 AS fulfilment_hours
    FROM orders o
    WHERE o.order_status = 'Delivered'
      AND o.delivery_date IS NOT NULL
),
seller_summary AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS completed_orders,
        ROUND(AVG(fulfilment_hours), 2) AS avg_fulfilment_hours
    FROM seller_orders
    GROUP BY seller_id
    HAVING COUNT(DISTINCT order_id) >= 20
),
seller_ratings AS (
    SELECT
        o.seller_id,
        ROUND(AVG(r.rating), 2) AS avg_rating
    FROM orders o
    JOIN reviews r ON o.order_id = r.order_id
    GROUP BY o.seller_id
)
SELECT
    s.seller_id,
    s.seller_name,
    ss.completed_orders,
    ss.avg_fulfilment_hours,
    sr.avg_rating
FROM seller_summary ss
JOIN sellers s ON s.seller_id = ss.seller_id
LEFT JOIN seller_ratings sr ON ss.seller_id = sr.seller_id
ORDER BY ss.avg_fulfilment_hours ASC
LIMIT 20;

/*
The data reveals that while fulfilment speed ranges from 91 to 129 
hours among the top 20 sellers, being the absolute fastest does not 
guarantee the highest customer satisfaction or order volume.

1. SPEED VERSUS VOLUME TRADEOFFS
RunFast NG claims the top spot for speed at 91.20 hours but only 
meets the minimum threshold of 20 completed orders. In contrast, 
SportNation NG fulfills orders just one hour slower at 92.69 hours 
but successfully manages a significantly higher volume of 29 orders. 
This indicates a much more scalable and robust operational process.

2. THE EFFICIENCY AND QUALITY SWEET SPOT
Several sellers prove businesses can balance rapid delivery times 
with exceptional customer satisfaction. AllFashion NG and TechHub 
Nigeria maintain excellent ratings of 4.56 and 4.13 while keeping 
average delivery times under 113 hours. VogueNG handles 27 orders 
with a 4.18 rating at 126.22 hours, showing that customers reward 
quality even if delivery takes slightly longer.

3. FAST DELIVERY WITH POOR SATISFACTION
Fulfilment speed alone cannot rescue a poor customer experience. 
GadgetKing NG delivers fast at 110.61 hours but holds the lowest 
rating on the list at 1.85. Similarly, AgriMart NG ranks sixth 
in speed but suffers from a poor 2.50 rating, suggesting product 
quality or accuracy issues are severely impacting their scores.
*/
