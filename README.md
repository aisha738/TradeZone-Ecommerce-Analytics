# TradeZone E-commerce Data Analysis

## Project Overview
This project involves a comprehensive data analysis for **TradeZone**, a fast-growing Nigerian e-commerce platform operating across major cities including Lagos, Abuja, Kano, Port Harcourt, and Ibadan. The analysis focuses on identifying operational inefficiencies, customer retention trends, and seller performance issues during the 2023 to 2024 period to inform strategic planning for 2025.

## Skills and Tools Showcased
* **Database Management**: SQL (PostgreSQL).
* **Data Engineering**: ETL-like cleaning processes, data validation, and standardization.
* **Business Intelligence**: Customer segmentation, cohort analysis, and revenue trend forecasting.
* **Strategic Communication**: Translating technical SQL outputs into actionable executive memos.

## Repository Structure
* **`cleaning.sql`**: Contains the full script for data preparation, including handling NULL occurrences, deduplication, and city name standardization.
* **`Q1.sql` to `Q8.sql`**: Individual SQL scripts answering specific business questions:
    1. **Q1**: Customer Acquisition and 30-Day Conversion.
    2. **Q2**: Top 10 Products by Revenue.
    3. **Q3**: Seller Fulfillment Efficiency.
    4. **Q4**: Quarterly Revenue Growth Trends (2023 vs. 2024).
    5. **Q5**: Customer Spend Segmentation.
    6. **Q6**: Regional Payment Method Preferences.
    7. **Q7**: Review Ratings vs. Sales Performance.
    8. **Q8**: Top Seller Bonus Qualification.
* **`Analyst_Memo.pdf`**: A professional report addressed to the Head of Growth and Head of Seller Operations, synthesizing the data findings into strategic recommendations.

## Key Business Insights
* **Regional Disparity**: Lagos leads in customer acquisition and maintains the highest 30-day conversion rate at 49.32%, while northern markets like Kano and Oyo show significantly lower conversion levels.
* **Revenue Concentration**: The platform is heavily reliant on a small "High Spender" segment (591 customers) and the Electronics category, which dominates the top 10 products by revenue.
* **The Quality Gap**: Faster delivery times do not currently correlate with higher customer satisfaction; none of the top 20 fastest sellers achieved a rating above 4.0 in 2024.

## Data Cleaning and Validation Notes
* Addressed 124 orders with price discrepancies and 150 orders missing total amounts by recalculating values from line items to ensure financial accuracy.
* Standardized city names and normalized product categories to title case for cleaner reporting.
* Flagged orders where the total amount and line item sums differed by more than 10 Naira to maintain data integrity.

## Future Work
* Integrate Customer Support and Churn data to perform root-cause analysis on retention drops.
* Develop a predictive model to identify high-potential customers in lagging regions like Kano and Oyo.
