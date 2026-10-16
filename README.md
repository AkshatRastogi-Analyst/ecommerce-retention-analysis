# Customer Retention & Repeat Revenue Analysis

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQL%20Analysis-4169E1?logo=postgresql&logoColor=white)
![Dashboard](https://img.shields.io/badge/Dashboard-HTML%20%7C%20CSS%20%7C%20JavaScript-f5c451)
![Data](https://img.shields.io/badge/Data-Simulated-lightgrey)

An end-to-end analytics project that studies **who comes back, who is slipping away, and which acquisition channels bring customers worth keeping** for an online retailer. The analysis is written in PostgreSQL and presented in an interactive dashboard.

**[Live Dashboard](https://akshatrastogi-analyst.github.io/ecommerce-retention-analysis/)** | **[SQL Queries](queries.sql)** | **[Dataset](#dataset)**

## Table of Contents
1. [Business Problem](#business-problem)
2. [Dataset](#dataset)
3. [Approach](#approach)
4. [Key Findings](#key-findings)
5. [SQL Highlights](#sql-highlights)
6. [Dashboard](#dashboard)
7. [Recommendations](#recommendations)
8. [Repository Structure](#repository-structure)
9. [How to Run](#how-to-run)
10. [Assumptions and Limitations](#assumptions-and-limitations)
11. [Author](#author)

## Business Problem
Most online stores spend heavily to acquire a customer and then lose them after one order. This project answers four practical questions:
* How many customers buy again, and how much revenue do they bring?
* Which acquisition channel produces the most loyal, highest-spending customers?
* Which product categories have the highest return rates, and what do returns cost?
* How much extra revenue is possible if some one-time customers are won back?

## Dataset
The dataset covers **1 April 2025 to 31 March 2026** and has four related tables.

| Table | Rows | Description |
|---|---|---|
| `customers` | 3,000 | Customer ID, signup date, city and acquisition channel |
| `products` | 40 | Product ID, name, category and price |
| `orders` | 4,589 | Order ID, customer, date and status (Delivered, Returned, Cancelled) |
| `order_items` | 6,941 | Products, quantity and unit price in each order |

Revenue counts **Delivered** orders only. Return rate is Returned orders divided by Delivered plus Returned orders. The data is simulated; see [Assumptions and Limitations](#assumptions-and-limitations).

## Approach
1. **Model the data** in PostgreSQL with primary and foreign keys.
2. **Define the metrics** (revenue, average order value, repeat rate, return rate) so every number has one clear meaning.
3. **Analyse** revenue trends, channel quality, customer value, RFM segments and monthly cohorts using 12 SQL queries.
4. **Validate** each query result against an independent calculation of the same metric.
5. **Present** the results in an interactive dashboard and turn them into recommended actions.

## Key Findings
Results from the simulated dataset:

| Metric | Result |
|---|---|
| Revenue (delivered orders) | Rs 9,023,880 from 3,893 orders |
| Average order value | Rs 2,318 |
| Customers | 2,674, of whom 71% bought only once |
| Repeat customers | 28.7% of customers bring 51% of revenue |
| Customer concentration | The top 10% of customers bring 29% of revenue |
| Best and weakest channel by repeat rate | Email (39.3%) and Instagram (21.6%) |
| Return rate | 11.4%; returned orders were worth Rs 1,253,630 (13.9% of revenue) |
| Highest return category | Fashion (15.6%) |
| Reorder timing | 74% of repeat orders arrive within 60 days of the previous order |
| Month-1 retention | 13.5% of customers order again in the month after their first order (average of the first six monthly cohorts) |
| RFM segments | Champions 122, Loyal 287, New 238, At Risk 358, Lost 1,669 |

## SQL Highlights
All queries are in [`queries.sql`](queries.sql) and use standard PostgreSQL.

| # | Business question | Techniques |
|---|---|---|
| 1 | What are the headline revenue and order numbers? | JOIN, COUNT DISTINCT, SUM |
| 2 | How does revenue change month by month? | TO_CHAR, GROUP BY |
| 3 | Which categories earn the most and have the most returns? | Conditional aggregation (CASE WHEN) |
| 4 | Which channel brings customers who come back? | CTE, CASE WHEN |
| 5 | Who are the top 10 customers? | GROUP BY, ORDER BY, LIMIT |
| 6 | How can customers be segmented by recency, frequency and spend (RFM)? | CTEs, date arithmetic, CASE WHEN |
| 7 | What share of each monthly cohort orders again? | CTEs, DATE_PART, cohort logic |
| 8 | What is the month-on-month revenue growth? | LAG window function |
| 9 | How do channels compare on value and returns? | Multi-table JOIN, conditional aggregation |
| 10 | How concentrated is revenue among top customers? | NTILE window function, subquery |
| 11 | How long do customers wait before ordering again? | LAG with PARTITION BY, bucketing |
| 12 | How much revenue do one-time and repeat customers bring? | CTE, CASE WHEN, subquery |

## Dashboard
`index.html` is a self-contained interactive dashboard (no installation needed) with five views:
* **Overview:** KPI cards with trend lines, an interactive monthly revenue chart, and category revenue with return losses. A channel filter updates every figure.
* **Channels:** a sortable scorecard and a bubble chart comparing repeat rate against revenue per customer.
* **Customer value:** a revenue concentration curve, one-time versus repeat comparison, reorder timing, and RFM segment cards with suggested actions.
* **Retention:** a monthly cohort heatmap and a win-back what-if calculator.
* **Insights and actions:** an automatic summary, key findings and recommended actions.

All figures are calculated in the browser from the dataset, so they always match the SQL results.

## Recommendations
1. **Win back At Risk customers.** 358 customers ordered at least twice but have been quiet for over 120 days. If 20% ordered once more, revenue would rise by about Rs 165,967.
2. **Shift spend towards the channels with the highest repeat rate.** Email customers repeat 39% of the time, against 22% for Instagram.
3. **Reduce returns in Fashion.** It has the highest return rate (15.6%) and the largest value lost (Rs 462,010). Review product descriptions, size guides and packaging.
4. **Time reminders inside 60 days.** Most repeat orders happen within that window.

## Repository Structure
```
.
├── index.html        # Interactive dashboard
├── queries.sql       # Table creation, data loading steps and 12 analysis queries
├── customers.csv     # Dataset
├── products.csv
├── orders.csv
├── order_items.csv
└── README.md
```

## How to Run
**SQL analysis (PostgreSQL)**
1. Create a database and run the `CREATE TABLE` statements at the top of `queries.sql`.
2. Load the four CSV files with `\copy` (commands are in `queries.sql`) or the pgAdmin import tool.
3. Run queries 1 to 12.

**Dashboard**
Open `index.html` in any modern browser, or use the live link above.

## Assumptions and Limitations
* **The data is simulated.** It was generated with fixed assumptions (for example, repeat-purchase tendency per channel and return probability per category), so the patterns reflect those assumptions. The project demonstrates the analytical method, the SQL and the reporting; the queries can be run unchanged on real order data.
* Each order contains products from a single category.
* Cancelled orders are excluded from revenue and from the return rate.
* The what-if calculator is an estimate based on the average order value, not a forecast.

## Author
**Akshat Rastogi** | Business Analyst
Portfolio: [akshat-portfolio-wine.vercel.app](https://akshat-portfolio-wine.vercel.app) | GitHub: [AkshatRastogi-Analyst](https://github.com/AkshatRastogi-Analyst) | Email: akshatrastogi0425@gmail.com
