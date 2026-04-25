-- Question 6: Payment Method Preferences by State

/*
Analyse payment method preferences across each state in the dataset.
For each state, show the transaction count and total amount for each
payment method (Cash on Delivery, Card, Mobile Money, Bank Transfer)
and identify the most popular method per state.
*/

WITH payment_by_state AS (
    SELECT
        c.state,
        p.payment_method,
        COUNT(p.payment_id)       AS transaction_count,
        SUM(p.amount)             AS total_amount
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE p.amount IS NOT NULL
      AND o.order_status = 'Delivered' -- The critical missing filter
    GROUP BY c.state, p.payment_method
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY transaction_count DESC) AS rnk
    FROM payment_by_state
)
SELECT
    state,
    payment_method,
    transaction_count,
    total_amount,
    CASE WHEN rnk = 1 THEN 'Most Popular' ELSE '' END AS popularity
FROM ranked
ORDER BY state, transaction_count DESC;

/*
1. THE DIGITAL DIVIDE IN PAYMENT TRUST
Payment preferences reveal a stark digital divide across regions. 
In major economic and administrative hubs—Lagos, FCT (Abuja), and 
Rivers—'Card' payments are overwhelmingly the 'Most Popular' method. 
Lagos leads this trend with 231 card transactions (₦75M). This 
indicates high digital financial inclusion, better banking 
infrastructure, and strong consumer trust in upfront digital 
payments in these urban centers.

2. THE RELIANCE ON CASH ON DELIVERY
In contrast, 'Cash on Delivery' is the 'Most Popular' payment method 
in Kano and Oyo. In Kano, the distrust or lack of access to digital 
payments is particularly pronounced: Cash on Delivery leads with 57 
transactions, while Card payments are the absolute least popular 
method (only 15 transactions). This suggests customers in these 
regions strongly prefer to verify goods before parting with their 
money, requiring sellers to manage higher logistical risks.

3. MOBILE MONEY AS THE UNIVERSAL BRIDGE
While Card and Cash dominate the #1 spots, 'Mobile Money' proves to 
be a highly consistent and critical secondary payment option. It 
ranks as the 2nd most popular method in Kano, Lagos, and Oyo, and 
3rd in FCT and Rivers. This highlights the growing importance of 
telecom-based financial services in bridging the gap between cash-heavy 
and bank-heavy populations across all states.
*/