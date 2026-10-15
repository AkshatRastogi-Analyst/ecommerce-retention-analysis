# Customer Retention & Repeat Revenue Analysis (FY 2025-26)

**Author:** Akshat Rastogi | **Tools:** PostgreSQL, HTML/CSS/JavaScript | **Data:** simulated (see below)

**Live Dashboard:** https://akshatrastogi-analyst.github.io/ecommerce-retention-analysis/

## What this project answers
1. Which customers come back, and which are slipping away? (cohort retention + RFM segments)
2. Which marketing channel brings customers worth keeping?
3. Where do returns hurt revenue the most?
4. How much extra revenue could we get by winning back one-time buyers?

## Data (honest note)
The data is **simulated**: I generated it with fixed assumptions (for example, Email and Referral customers are set to repeat more than Instagram customers) so I could practise a real analysis end to end. So the *patterns* are built in. What this project shows is the method: the tables, the SQL, and the way of turning numbers into actions.
* 4 tables: customers (2,674 with a delivered order), products (40), orders, order_items. Orders run 1 Apr 2025 to 31 Mar 2026.
* Revenue counts only Delivered orders. Return rate = Returned / (Delivered + Returned).

## Results from the simulated data
* Revenue: Rs 9,023,880 from 3,893 delivered orders (average order Rs 2,318). Return rate 11.4%.
* 28.7% of customers ordered 2+ times; 71% ordered only once.
* Repeat rate by channel: Email 39.3%, Referral 35.6%, Google Search 28.8%, Instagram 21.6%.
* Top 10% of customers bring 29% of revenue; repeat customers are 29% of customers but bring 51% of revenue.
* Returns cost Rs 1,253,630 (13.9% of revenue).
* 74% of repeat orders arrive within 60 days of the previous order.
* RFM: 122 Champions, 287 Loyal, 358 At Risk, 238 New, 1669 Lost customers.

## Files
* `index.html` - interactive dashboard (open in a browser; no install). Click KPI cards, cohort cells and RFM segments; filter by channel, sort the channel scorecard, try the what-if slider.
* `queries.sql` - table creation, CSV loading steps, and 12 queries.
* `customers.csv, products.csv, orders.csv, order_items.csv` - the dataset.

## The 12 queries in simple words
1. Headline numbers: total revenue, orders, customers, average order value.
2. Revenue by month.
3. Revenue and return rate by category.
4. Repeat rate by channel: customers with 2+ orders divided by all customers.
5. Top 10 customers by spend.
6. RFM: Recency (days since last order), Frequency (number of orders), Monetary (total spend). A CASE WHEN puts each customer into Champions, Loyal, At Risk, New or Lost.
7. Cohort retention: group customers by the month of their first order, then count how many ordered again 1, 2, 3... months later.
8. Month-on-month growth using LAG (looks at the previous row).
9. Channel scorecard: customers, orders, revenue per customer and return rate for each channel.
10. Top 10% of customers: NTILE(10) splits customers into 10 equal groups by spend, so we see how much the biggest spenders bring.
11. Reorder timing: LAG gives the previous order date, so we can count how many days customers wait before ordering again.
12. One-time vs repeat customers: how many of each, and how much revenue each type brings.

## Interview answers (short)
* **Why RFM?** It is a simple way to group customers by how recently, how often and how much they buy, so each group gets a different action.
* **What is a cohort?** Customers who started in the same month. Tracking them shows if retention is improving.
* **What does NTILE do?** It splits customers into equal-size groups (here 10), ranked by spend.
* **Why only Delivered orders?** Cancelled and returned orders did not bring in money.
* **What does CTE (WITH) do?** It gives a name to a step so a long query reads top to bottom.
* **Is the data real?** No, it is simulated, and I say so. The value is the method and the SQL.
* **What would you do next?** Run the same queries on real order data and test the WhatsApp or email win-back offers with a small A/B test.

## Resume lines
* Built a retention analysis on a simulated e-commerce dataset (2,674 customers, 4,395+ orders) using PostgreSQL: cohort retention, RFM segments and repeat rate by channel.
* Wrote 12 PostgreSQL queries using JOINs, CTEs, CASE WHEN, NTILE and LAG to find that 71% of customers ordered only once, then built an interactive dashboard with a win-back what-if calculator.
* Turned each customer segment into a plain action (reward, cross-sell, win-back) for a marketing team.
