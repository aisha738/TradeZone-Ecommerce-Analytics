-- ============================================================
-- DATA CLEANING: CUSTOMERS TABLE
-- ============================================================

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get a brief preview of customers table
SELECT * 
FROM customers
LIMIT 5;
-- The customers table has 8 columns

-- Check for the records count in customers table
SELECT COUNT(*) records_count
FROM customers;
-- There are 865 records (rows) in customers table.

SELECT 
    COUNT(*) AS total_records,
    COUNT(*) - COUNT(customer_id) AS missing_ids,
    COUNT(*) - COUNT(first_name) AS missing_first_names,
    COUNT(*) - COUNT(email) AS missing_emails,
    COUNT(*) - COUNT(city) AS missing_cities,
	COUNT(*) - COUNT(signup_date) AS missing_signup_dates,
	COUNT(*) - COUNT(account_status) AS missing_acc_statuses
FROM customers;
-- There are 16 null values in the customer table, all under the 'email' column

-- Get a closer look of the null records in email column
SELECT * 
FROM customers
WHERE email 
IS NULL;
-- 12 of the null email records have active account status

/*
DECISION: 16 records have no email address, 12 of which belong to Active accounts
that likely have order history. Since these represent less than 2% of the table,
deletion would cause unnecessary data loss. A placeholder value of 'Not Available'
is assigned instead, keeping all records intact and preventing NULL-related query
failures while clearly marking the gap for any email-specific analysis.
*/

-- Use 'Not Available' as a placeholder for missing emails
UPDATE customers 
SET email = 'Not Available' 
WHERE email IS NULL;

-------------------------------------------------------------
-- 2. Checking and Removing Duplicate Records
--------------------------------------------------------------

-- Use a Common Table Expression (CTE) to check for duplicates
-- customer_id is the column of focus, because it is the primary key (unique identifier)
WITH CustomerDuplicates AS (
    SELECT customer_id, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY signup_date) as rn
    FROM customers
)
SELECT * FROM customers 
WHERE customer_id 
IN (SELECT customer_id FROM CustomerDuplicates WHERE rn > 1);
-- There are no duplicate customer_ids in the customers table

-------------------------------------------------------------
-- 3. Inconsistent Formatting
--------------------------------------------------------------

-- Standardize City Names
-- Problem: cities have mixed case (LAGOS, lagos, Lagos),
--          extra spaces ('Lagos ', ' Lagos', 'Lago s'),
--          and variant spellings (PortHarcourt, Port-Harcourt,
--          port harcourt → should all be 'Port Harcourt')
 
-- Fix city names inconsistencies 
UPDATE customers
SET city = INITCAP(TRIM(REPLACE(city, '-', ' ')));
 
-- Fix the 'PortHarcourt' and 'Lago s' style typos
UPDATE customers 
SET city = 'Port Harcourt' 
	WHERE LOWER(REPLACE(city, ' ', '')) = 'portharcourt';
UPDATE customers SET city = 'Lagos'          
	WHERE LOWER(REPLACE(city, ' ', '')) = 'lagos';

-- Verify changes
SELECT DISTINCT city 
FROM customers 
ORDER BY city;

-- Date Format Check
SELECT customer_id, signup_date
FROM customers
WHERE signup_date::TEXT NOT LIKE '____-__-__%';
-- All the signup_date records are consistate with the (YYYY-MM-DD) format

-- ============================================================
-- DATA CLEANING: SELLERS TABLE
-- ============================================================

-- Preview the table
SELECT * FROM sellers LIMIT 5;
-- The table has 7 columns

-- Get the row count
SELECT COUNT(*) 
AS total_records 
FROM sellers;
-- The table has 90 records

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get the null count for each column
SELECT
    COUNT(*)                           AS total_records,
    COUNT(*) - COUNT(seller_id)        AS missing_ids,
    COUNT(*) - COUNT(seller_name)      AS missing_names,
    COUNT(*) - COUNT(product_category) AS missing_categories,
    COUNT(*) - COUNT(city)             AS missing_cities,
    COUNT(*) - COUNT(account_status)   AS missing_acc_statuses
FROM sellers;
-- The sellers table has no null values

---------------------------------------------------------------
-- 2. Handling Duplicate Records
---------------------------------------------------------------
-- Check for duplicate seller_ids
WITH SellerDuplicates AS (
    SELECT seller_id,
           ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY onboarding_date) AS rn
    FROM sellers
)
SELECT *
FROM sellers
WHERE seller_id IN (
    SELECT seller_id FROM SellerDuplicates WHERE rn > 1
);
-- There are no duplicate seller_id records in this table.

---------------------------------------------------------------
-- 3. Inconsistent Formatting
---------------------------------------------------------------

-- Check for inconsistent city names
SELECT  DISTINCT city
FROM sellers
ORDER BY city;
-- Inconsistencies in city naming exists

-- Fix inconsistencies
UPDATE sellers
SET city = INITCAP(TRIM(REPLACE(city, '-', ' ')));
 
UPDATE sellers SET city = 'Port Harcourt' 
WHERE LOWER(REPLACE(city, ' ', '')) = 'portharcourt';

UPDATE sellers SET city = 'Lagos'          
WHERE LOWER(REPLACE(city, ' ', '')) = 'lagos';

-- Verify changes
SELECT  DISTINCT city
FROM sellers
ORDER BY city;

-- Check for inconsistencies product category names
SELECT  DISTINCT product_category
FROM sellers
ORDER BY product_category;
-- Inconsistencies exist

-- Normalize product category names
UPDATE sellers SET product_category = 'Fashion'
WHERE LOWER(REPLACE(product_category, ' ', '')) IN ('fashion', 'fashon');
 
UPDATE sellers SET product_category = 'Electronics'
WHERE LOWER(REPLACE(product_category, ' ', '')) IN ('electronics', 'electronis');
 
UPDATE sellers SET product_category = 'Food & Beverages'
WHERE LOWER(product_category) IN ('food & beverages', 'food and beverages', 'food');
 
UPDATE sellers SET product_category = 'Books & Stationery'
WHERE LOWER(product_category) IN ('books & stationery', 'books and stationery', 'books');
 
UPDATE sellers SET product_category = 'Beauty & Personal Care'
WHERE LOWER(product_category) IN ('beauty & personal care', 'beauty and personal care', 'beauty');
 
UPDATE sellers SET product_category = 'Sports & Fitness'
WHERE LOWER(product_category) IN ('sports & fitness', 'sports and fitness', 'sports');
 
UPDATE sellers SET product_category = 'Home & Garden'
WHERE LOWER(product_category) IN ('home & garden', 'home and garden');
 
-- Verify: should return exactly 7 distinct values
SELECT DISTINCT product_category FROM sellers ORDER BY product_category;

-- Verify changes
SELECT DISTINCT product_category
FROM sellers
ORDER BY product_category;

-- ============================================================
-- DATA CLEANING: SELLERS TABLE
-- ============================================================

-- preview the table
 SELECT * 
 FROM products;
 -- The table has 5 columns

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get the null count from each column
SELECT
    COUNT(*)                       AS total_records,
    COUNT(*) - COUNT(product_id)   AS missing_product_ids,
    COUNT(*) - COUNT(product_name) AS missing_names,
    COUNT(*) - COUNT(category)     AS missing_categories,
    COUNT(*) - COUNT(unit_price)   AS missing_prices
FROM products;
-- The products table has 280 records with 4 null values in the unit_price column 

/*
DECISION: 4 records have no unit_price, representing just over 1% of the
products table. Deletion is not possible as these products are referenced
in order_items table. Since price is essential for revenue calculations, these
records are excluded from analysis by flagging rather than removing.

STRATEGY: Flag for exclusion in analysis queries using 'WHERE unit_price IS NOT NULL'.
*/


---------------------------------------------------------------
-- 3 Normalise Category Names
---------------------------------------------------------------
 
UPDATE products SET category = 'Fashion'
WHERE LOWER(REPLACE(category, ' ', '')) IN ('fashion', 'fashon');
 
UPDATE products SET category = 'Electronics'
WHERE LOWER(REPLACE(category, ' ', '')) IN ('electronics', 'electronis');
 
UPDATE products SET category = 'Food & Beverages'
WHERE LOWER(category) IN ('food & beverages', 'food and beverages', 'food');
 
UPDATE products SET category = 'Books & Stationery'
WHERE LOWER(category) IN ('books & stationery', 'books and stationery', 'books');
 
UPDATE products SET category = 'Beauty & Personal Care'
WHERE LOWER(category) IN ('beauty & personal care', 'beauty and personal care', 'beauty');
 
UPDATE products SET category = 'Sports & Fitness'
WHERE LOWER(category) IN ('sports & fitness', 'sports and fitness', 'sports');
 
UPDATE products SET category = 'Home & Garden'
WHERE LOWER(category) IN ('home & garden', 'home and garden');
 
-- Verify changes
SELECT DISTINCT category 
FROM products 
ORDER BY category;

---------------------------------------------------------------
-- 4 Validate Product Prices
---------------------------------------------------------------
 
-- Check for negative prices
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price < 0;
-- No negative prices detected

-- ============================================================
-- DATA CLEANING: ORDERS TABLE
-- ============================================================

-- Preview the table
SELECT * 
FROM orders;
-- The table has 7 columns

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get the null count for each column
SELECT
    COUNT(*)                          AS total_records,
    COUNT(*) - COUNT(order_id)        AS missing_order_ids,
    COUNT(*) - COUNT(customer_id)     AS missing_customer_ids,
    COUNT(*) - COUNT(order_date)      AS missing_order_dates,
    COUNT(*) - COUNT(order_status)    AS missing_statuses,
    COUNT(*) - COUNT(total_amount)    AS missing_amounts
FROM orders;
-- The orders table has 150 nulls out of 3015 records. 
-- All the null values are in total_amount column\.

/*
DECISION: 150 records have no total_amount, representing about 5% of the
orders table. Since orders are referenced by order_items and payments,
deletion risks breaking foreign key constraints. Instead, these records
are excluded from any revenue or sales analysis using a WHERE filter.

STRATEGY: Flag for exclusion in analysis queries using 'WHERE total_amount IS NOT NULL'.
*/

-------------------------------------------------------------
-- 2. Checking and Removing Duplicate Records
--------------------------------------------------------------

-- A duplicate here is the same order_id placed by the same customer on the same date
WITH OrderDuplicates AS (
    SELECT order_id,
           ROW_NUMBER() OVER (
               PARTITION BY order_id, customer_id, order_date
               ORDER BY order_id
           ) AS rn
    FROM orders
)
SELECT *
FROM orders
WHERE order_id IN (
    SELECT order_id FROM OrderDuplicates WHERE rn > 1
);
-- The table has no duplicate orders

---------------------------------------------------------------
-- 3. Date Format Check
---------------------------------------------------------------
 
SELECT order_id, order_date, delivery_date
FROM orders
WHERE order_date::TEXT NOT LIKE '____-__-__%'
   OR (delivery_date IS NOT NULL AND delivery_date::TEXT NOT LIKE '____-__-__%');
 -- All the order dates are consistent with the YYYY-MM-DD format.

 ---------------------------------------------------------------
-- 4 Validate Order Total Amounts
---------------------------------------------------------------

-- Verify that total_amount matches the sum of line items.
-- Flag orders where the difference exceeds ₦10.
SELECT
    o.order_id,
    o.total_amount AS recorded_total,
    SUM(oi.line_total) AS calculated_total,
    ABS(o.total_amount - SUM(oi.line_total))   AS difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY difference DESC;

/*
DECISION: 124 orders (about 4% of the orders table) have a discrepancy
between recorded_total and the sum of their line items, ranging from
₦99.63 to ₦326,748.16. The large magnitude of most differences rules
out rounding as the cause. It is more likely that order_items records
were updated or added after the total_amount was recorded, or that some
line items are missing entirely.

No automatic correction is applied. However, the calculated total from order_items
is more reliable and should be used in revenue analysis. These 124 orders 
could be flagged and excluded from financial reporting until reviewed.
*/

-- ============================================================
-- DATA CLEANING: ORDER_ITEMS TABLE
-- ============================================================

-- preview the table
SELECT * 
FROM order_items
LIMIT 5;
-- The table has 6 columns

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get total row count, and nulls in each column
SELECT
    COUNT(*)                      AS total_records,
	COUNT(*) - COUNT(item_id)     AS missing_item_ids,
    COUNT(*) - COUNT(order_id)    AS missing_order_ids,
    COUNT(*) - COUNT(product_id)  AS missing_product_ids,
    COUNT(*) - COUNT(quantity)    AS missing_quantities,
    COUNT(*) - COUNT(unit_price) AS missing_prices,
	COUNT(*) - COUNT(line_total)     AS missing_totals
FROM order_items;
-- order_items table has 6426 records, with 97 nulls each in unit_price and line_total columns

-- Confirm nulls in unit_price and line_total are on the same rows
SELECT item_id, order_id, product_id, quantity, unit_price, line_total
FROM order_items
WHERE unit_price IS NULL OR line_total IS NULL;
-- The nulls in these columns are on the same rows

-- Try populating null unit_price records using products table
UPDATE order_items oi
SET 
    unit_price = p.unit_price,
    line_total = oi.quantity * p.unit_price
FROM products p
WHERE oi.product_id = p.product_id
  AND oi.unit_price IS NULL
  AND p.unit_price IS NOT NULL;
  -- No changes detected
  -- Inference: The null values belong to the 4 products with no price in the products table.

  /*
DECISION: 97 rows in order_items have null unit_price and line_total,
all belonging to the 4 products with no price in the products table.
Since the source price is unknown, these values cannot be recovered.
Deletion is not possible as the rows are tied to existing orders.
These records are excluded from any price or revenue analysis using
'WHERE unit_price IS NOT NULL'.
*/

---------------------------------------------------------------
-- 2. Check for Invalid Line Totals in Order Items
---------------------------------------------------------------
 -- A line_total should equal quantity × unit_price.
SELECT
    item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    line_total,
    ROUND((quantity * unit_price), 2)              AS expected_total,
    ROUND(line_total - (quantity * unit_price), 2) AS discrepancy
FROM order_items
WHERE line_total > (quantity * unit_price)
	OR line_total < (quantity * unit_price)
   OR line_total < 0;
-- All line totals exactly match quantity × unit_price (none above or below expected value)
-- No negative line_total records
-- No discounts were applied to any order

-- ============================================================
-- DATA CLEANING: REVIEWS TABLE
-- ============================================================

-- Preview table
SELECT * 
FROM reviews 
LIMIT 5;
-- The table has 6 columns

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get the total row count, and null count for each column
SELECT
    COUNT(*)                        AS total_records,
    COUNT(*) - COUNT(review_id)     AS missing_review_ids,
    COUNT(*) - COUNT(product_id)    AS missing_product_ids,
    COUNT(*) - COUNT(customer_id)   AS missing_customer_ids,
	COUNT(*) - COUNT(order_id)      AS missing_order_ids,
    COUNT(*) - COUNT(rating)        AS missing_ratings,
    COUNT(*) - COUNT(review_date)   AS missing_dates
FROM reviews;
-- The table has 817 records, and no null values

---------------------------------------------------------------
-- 2. Check Date Format for Inconsistencies
---------------------------------------------------------------
SELECT review_id, review_date
FROM reviews
WHERE review_date::TEXT NOT LIKE '____-__-__%';
-- All review_date records are consistent with YYYY-MM-DD format

---------------------------------------------------------------
-- 3. Validate Ratings (must be between 1 and 5)
---------------------------------------------------------------

-- Check for out-of-range ratings
SELECT *
FROM reviews
WHERE rating < 1 OR rating > 5;
-- 5 invalid ratings detected

/*
DECISION: 5 records have invalid ratings (-1, 0, and 7), all outside the
accepted 1–5 scale. Since the intended rating cannot be inferred for any
of them, all 5 rows will be deleted.
*/

-- Delete rows with invalid ratings
DELETE FROM reviews
WHERE rating < 1 OR rating > 5;

-- ============================================================
-- DATA CLEANING: PAYMENTS TABLE
-- ============================================================

-- Preview the table
SELECT *
FROM payments
LIMIT 5;
-- The table has 5 columns

---------------------------------------------------------------
-- 1. Handling Null Values
---------------------------------------------------------------

-- Get the total row count, and null count in each column
SELECT
    COUNT(*)                          AS total_records,
    COUNT(*) - COUNT(payment_id)      AS missing_payment_ids,
    COUNT(*) - COUNT(order_id)        AS missing_order_ids,
    COUNT(*) - COUNT(payment_method)  AS missing_methods,
    COUNT(*) - COUNT(amount)          AS missing_amounts,
    COUNT(*) - COUNT(payment_date)    AS missing_dates
FROM payments;
-- The table has 2262 records, and 155 null values in the amount column

-- Check for duplicate order_ids in payments table
SELECT order_id, COUNT(*) AS occurrences
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
-- 13 order_id records have double (2) occurences each

/*
DECISION: 155 records have no payment amount. Recovery from the orders
table was considered but 13 order_ids appear twice in the payments table,
meaning total_amount cannot be reliably assigned to individual payment
rows without risk of double-counting. All 155 records are excluded from
revenue and payment analysis using 'WHERE amount IS NOT NULL' flag.
*/

---------------------------------------------------------------
-- 2 Handling Duplicate Records
---------------------------------------------------------------

-- check for duplicates
WITH PaymentDuplicates AS (
    SELECT payment_id,
           ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY payment_date) AS rn
    FROM payments
)
SELECT *
FROM payments
WHERE payment_id IN (
    SELECT payment_id FROM PaymentDuplicates WHERE rn > 1
);
-- No duplicate payment_id record detected

---------------------------------------------------------------
-- 3. Date Format Check
---------------------------------------------------------------
 
SELECT payment_id, payment_date
FROM payments
WHERE payment_date::TEXT NOT LIKE '____-__-__%';
-- All date records are consistent with YYYY-MM-DD format

---------------------------------------------------------------
-- 4. Validate Payment Amounts
---------------------------------------------------------------
 
-- Check for negative or zero amounts
SELECT payment_id, order_id, amount
FROM payments
WHERE amount <= 0;
-- No negetaive or zero (0) payment amount