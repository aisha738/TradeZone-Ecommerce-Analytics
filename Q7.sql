-- Question 7: Review Ratings and Sales Performance

/*
Group products based on their average review rating into three categories:
- High Rated: 4.0 and above
- Mid Rated: 3.0 – 3.99
- Low Rated: Below 3.0
For each category, calculate the product count, total revenue and average unit price.
*/

WITH product_ratings AS (
    SELECT
        p.product_id,
        p.unit_price,
        -- Use COALESCE to treat unreviewed products as 0
        COALESCE(AVG(r.rating), 0) AS raw_avg_rating
    FROM products p
    LEFT JOIN reviews r ON p.product_id = r.product_id
    GROUP BY p.product_id, p.unit_price
),
product_revenue AS (
    SELECT
        oi.product_id,
        SUM(oi.line_total) AS total_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered' -- Only count successful revenue
    GROUP BY oi.product_id
),
combined AS (
    SELECT
        pr.product_id,
        pr.unit_price,
        COALESCE(rev.total_revenue, 0) AS total_revenue,
        -- Evaluate raw average before rounding
        CASE
            WHEN pr.raw_avg_rating >= 4.0 THEN 'High Rated'
            WHEN pr.raw_avg_rating >= 3.0 THEN 'Mid Rated'
            ELSE                               'Low Rated'
        END AS rating_group
    FROM product_ratings pr
    LEFT JOIN product_revenue rev ON pr.product_id = rev.product_id
)
SELECT
    rating_group,
    COUNT(product_id)               AS product_count,
    ROUND(SUM(total_revenue), 2)    AS total_revenue,
    ROUND(AVG(unit_price), 2)       AS avg_unit_price
FROM combined
GROUP BY rating_group
ORDER BY total_revenue DESC;
/*
1. MID-RATED PRODUCTS DRIVE THE MOST REVENUE
Counterintuitively, 'High Rated' products are not the primary revenue 
driver. The 'Mid Rated' category (3.0 - 3.99) leads the platform 
both in product variety (121 products) and total revenue (₦243M). 
This suggests that customers are highly tolerant of average ratings, 
likely because these products offer better overall value or fulfill 
essential needs where absolute top-tier quality isn't required.

2. HIGH-RATED PRODUCTS ARE CHEAPER
The data reveals an interesting price dynamic: the 'High Rated' 
tier has the lowest average unit price (₦45,791). In contrast, 
'Mid Rated' products are significantly more expensive on average 
(₦64,079). This indicates that customers are much more critical and 
harsher in their reviews for expensive items, while it is easier 
for sellers to maintain a 4.0+ rating on cheaper, lower-stakes 
purchases.

3. LOW RATED PRODUCTS UNDERPERFORM BUT SURVIVE
The 'Low Rated' tier (below 3.0) represents the smallest product 
portfolio (45 products) and generates the least revenue (₦82.8M). 
However, their average unit price (₦54,285) remains relatively high. 
This suggests that some expensive products continue to generate 
sales despite poor reception, possibly due to a lack of better 
alternatives or strong marketing, though their total volume is 
rightfully stunted.
*/