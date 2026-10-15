-- ============================================================================
-- PROJECT : Customer Retention & Repeat Revenue Analysis (FY 2025-26, simulated data)
-- AUTHOR  : Akshat Rastogi          DATABASE: PostgreSQL
-- Order of work: 1) create tables  2) load the 4 CSV files  3) run queries 1-12
-- Only "Delivered" orders count as revenue. Each order contains products of ONE category.
-- ============================================================================

CREATE TABLE customers   (customer_id INT PRIMARY KEY, signup_date DATE, city VARCHAR(30), channel VARCHAR(30));
CREATE TABLE products    (product_id INT PRIMARY KEY, product_name VARCHAR(60), category VARCHAR(30), price NUMERIC(10,2));
CREATE TABLE orders      (order_id INT PRIMARY KEY, customer_id INT REFERENCES customers(customer_id), order_date DATE, status VARCHAR(20));
CREATE TABLE order_items (order_item_id INT PRIMARY KEY, order_id INT REFERENCES orders(order_id), product_id INT REFERENCES products(product_id), quantity INT, unit_price NUMERIC(10,2));

-- Load the files in psql (run from the folder that holds the CSVs), in this order:
-- \copy customers   FROM 'customers.csv'   CSV HEADER
-- \copy products    FROM 'products.csv'    CSV HEADER
-- \copy orders      FROM 'orders.csv'      CSV HEADER
-- \copy order_items FROM 'order_items.csv' CSV HEADER
-- (pgAdmin: right-click the table > Import/Export Data > choose the CSV, Header = on)

-- QUERY 1. Headline numbers (revenue, orders, customers, average order value)
SELECT COUNT(DISTINCT o.order_id)  AS delivered_orders,
       COUNT(DISTINCT o.customer_id) AS customers,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 0) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered';

-- QUERY 2. Revenue by month
SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

-- QUERY 3. Revenue and return rate by category
SELECT p.category,
       SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue,
       COUNT(DISTINCT CASE WHEN o.status = 'Returned' THEN o.order_id END) AS returned_orders,
       SUM(CASE WHEN o.status = 'Returned' THEN oi.quantity * oi.unit_price ELSE 0 END) AS returned_value,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.status = 'Returned' THEN o.order_id END)
             / COUNT(DISTINCT CASE WHEN o.status IN ('Delivered','Returned') THEN o.order_id END), 1) AS return_rate_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- QUERY 4. Which channel brings customers who come back? (repeat rate)
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS orders_placed
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT c.channel,
       COUNT(*) AS customers,
       SUM(CASE WHEN co.orders_placed >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN co.orders_placed >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM customer_orders co
JOIN customers c ON c.customer_id = co.customer_id
GROUP BY c.channel
ORDER BY repeat_rate_pct DESC;

-- QUERY 5. Top 10 customers by spend
SELECT o.customer_id,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- QUERY 6. RFM segments (Recency, Frequency, Monetary) - last data date is 31 Mar 2026
WITH rfm AS (
    SELECT o.customer_id,
           (DATE '2026-03-31' - MAX(o.order_date)) AS recency_days,        -- days since last order
           COUNT(DISTINCT o.order_id) AS frequency,      -- number of orders
           SUM(oi.quantity * oi.unit_price) AS monetary  -- total spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
),
segments AS (
    SELECT *,
           CASE WHEN frequency >= 3 AND recency_days <= 60  THEN 'Champions'
                WHEN frequency >= 2 AND recency_days <= 120 THEN 'Loyal'
                WHEN frequency >= 2                         THEN 'At Risk'
                WHEN recency_days <= 60                     THEN 'New'
                ELSE 'Lost' END AS segment
    FROM rfm
)
SELECT segment, COUNT(*) AS customers, SUM(monetary) AS revenue, ROUND(AVG(monetary), 0) AS avg_spend
FROM segments
GROUP BY segment
ORDER BY customers DESC;

-- QUERY 7. Cohort retention: of customers who started in a month, how many ordered again in month 1, 2, 3...
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
),
activity AS (
    SELECT DISTINCT f.customer_id,
           TO_CHAR(f.first_date, 'YYYY-MM') AS cohort_month,
           (DATE_PART('year', o.order_date) - DATE_PART('year', f.first_date)) * 12
             + (DATE_PART('month', o.order_date) - DATE_PART('month', f.first_date)) AS month_number
    FROM first_order f
    JOIN orders o ON o.customer_id = f.customer_id
    WHERE o.status = 'Delivered'
)
SELECT cohort_month, month_number, COUNT(*) AS customers
FROM activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;

-- QUERY 8. Month-on-month revenue growth (uses LAG)
WITH monthly AS (
    SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT month, revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly
ORDER BY month;

-- QUERY 9. Channel scorecard (customers, orders, revenue per customer, return rate)
SELECT c.channel,
       COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.customer_id END) AS customers,
       COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.order_id END) AS delivered_orders,
       SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue,
       ROUND(SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity * oi.unit_price ELSE 0 END)
             / COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.customer_id END), 0) AS revenue_per_customer,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.status = 'Returned' THEN o.order_id END)
             / COUNT(DISTINCT CASE WHEN o.status IN ('Delivered','Returned') THEN o.order_id END), 1) AS return_rate_pct
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.channel
ORDER BY revenue_per_customer DESC;

-- QUERY 10. How much do the biggest spenders bring? (NTILE splits customers into 10 equal groups)
WITH spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
),
ranked AS (
    SELECT total_spent,
           NTILE(10) OVER (ORDER BY total_spent DESC) AS decile   -- decile 1 = top 10% spenders
    FROM spend
)
SELECT decile,
       COUNT(*) AS customers,
       SUM(total_spent) AS revenue,
       ROUND(100.0 * SUM(total_spent) / (SELECT SUM(total_spent) FROM spend), 1) AS pct_of_revenue
FROM ranked
GROUP BY decile
ORDER BY decile;

-- QUERY 11. How many days do customers wait before ordering again? (LAG = previous row)
WITH ordered AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
    WHERE status = 'Delivered'
),
gaps AS (
    SELECT (order_date - prev_date) AS days_since_last
    FROM ordered
    WHERE prev_date IS NOT NULL      -- the first order of a customer has no previous order
)
SELECT CASE WHEN days_since_last <= 30 THEN '0-30 days'
            WHEN days_since_last <= 60 THEN '31-60 days'
            WHEN days_since_last <= 90 THEN '61-90 days'
            ELSE '91+ days' END AS gap_bucket,
       COUNT(*) AS repeat_orders
FROM gaps
GROUP BY gap_bucket
ORDER BY MIN(days_since_last);

-- QUERY 12. One-time vs repeat customers: how much revenue does each type bring?
WITH customer_totals AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.order_id) AS orders,
           SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers,
       SUM(total_spent) AS revenue,
       ROUND(AVG(total_spent), 0) AS avg_spend,
       ROUND(100.0 * SUM(total_spent) / (SELECT SUM(total_spent) FROM customer_totals), 1) AS pct_of_revenue
FROM customer_totals
GROUP BY customer_type
ORDER BY customers DESC;
