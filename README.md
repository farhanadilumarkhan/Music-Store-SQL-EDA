# 🎵 Music Store EDA & Business Insights (SQL)

An exploratory data analysis project on a digital music store's relational database (Chinook-style schema), using advanced SQL to answer real business questions around revenue, customer behavior, and catalog performance.

---

## 📌 Problem Statement

A digital music store has years of transactional data spread across customers, invoices, tracks, albums, artists, and genres — but no consolidated reporting. Management wants data-driven answers to questions like:
- Who are our best customers, and where are they located?
- Which genres and artists perform best, and does that vary by country?
- How is revenue trending year over year?
- Which tracks in our catalog have never sold, and should we drop them?

This project uses pure SQL — JOINs, subqueries, CTEs, and window functions — to turn raw relational data into these business answers.

---

## 🗂️ Dataset

A relational music store database with the following key tables:
- `customer`, `invoice`, `invoiceline` — customer purchase and billing data
- `track`, `album`, `artist`, `genre` — music catalog data
- `employee` — staff hierarchy data
---
![ER Diagram](/Database ERD.png)

![ER Diagram](/Database ERD.png)

## 🛠️ Tools & Tech Stack

| Tool | Purpose |
|------|---------|
| **SQL (MySQL)** | Data querying, aggregation, business analysis |
| **Window Functions** | Ranking, year-over-year growth, handling tied results |
| **CTEs** | Breaking complex multi-step logic into readable queries |

---

## ⚙️ Approach

1. Imported the relational music store schema into MySQL
2. Explored the data with foundational queries (filtering, sorting, grouping)
3. Progressed to multi-table JOINs to connect customers, purchases, and catalog data
4. Used subqueries and CTEs to answer layered business questions
5. Applied window functions (`ROW_NUMBER`, `LAG`) for ranking, per-group "top N" results, and time-based growth analysis
6. Handled edge cases explicitly — e.g., tied rankings return all tied records instead of an arbitrary single row

---

## 🔑 Key Business Questions Answered

| # | Business Question | SQL Technique Used |
|---|---|---|
| 1 | Who is the most senior employee by title? | Filtering (`WHERE ReportsTo IS NULL`) |
| 2 | Which countries generate the most invoices? | `GROUP BY`, `ORDER BY` |
| 3 | What are the top 3 invoice totals? | `ORDER BY` + `LIMIT` |
| 4 | Which city should host a promotional music festival (highest revenue)? | Aggregation + `GROUP BY` |
| 5 | Who is the single best customer by lifetime spend? | `JOIN` + `SUM` |
| 6 | Which customers listen to Rock, alphabetically by email? | Multi-table `JOIN` + subquery |
| 7 | Who are the top 10 Rock artists by track count? | `JOIN` across 4 tables + aggregation |
| 8 | Which tracks are longer than average song length? | Subquery in `WHERE` |
| 9 | How much does each customer spend on the top 3 best-selling artists? | CTE + multi-table `JOIN` |
| 10 | What's the most popular genre per country (handling ties)? | CTE + `ROW_NUMBER() OVER (PARTITION BY ...)` |
| 11 | Who is the top-spending customer per country (handling ties)? | CTE + `ROW_NUMBER() OVER (PARTITION BY ...)` |
| 12 | How do we segment customers into VIP / Regular / Occasional tiers? | `CASE WHEN` + aggregation |
| 13 | What is the store's year-over-year revenue growth? | CTE + `LAG() OVER (ORDER BY ...)` |
| 14 | Which tracks have never sold (for catalog/licensing cleanup)? | `LEFT JOIN` + `IS NULL` |

---

## 📊 Notable Findings

- A small number of countries account for a disproportionate share of total invoices, suggesting where marketing spend would be most effective
- The top 3 best-selling artists drive a significant share of per-customer spend, highlighting the value of artist-based promotions
- Year-over-year revenue growth reveals clear periods of acceleration and decline, useful for forecasting
- A meaningful portion of the catalog has generated zero sales — a direct opportunity to cut licensing/storage costs
- Customer tiering (VIP / Regular / Occasional) shows that a small VIP segment contributes the majority of lifetime revenue — a classic 80/20 pattern

---

## 🚀 How to Run This Project

1. Set up a MySQL instance and import the Music Store (Chinook-style) schema and data
2. Run `Music_Store_EDA_SQL_Query.sql` — each query is labeled with the business question it answers
3. Review results query by query, or adapt them for a BI tool (Power BI/Tableau) connection

---

## 📁 Repository Structure

```
├── Database ERD
├── Music Store Analysis-Questions
└── Music Store Database Schema.sql  
├── Music_Store_EDA_SQL_Query.sql     # All 14 business-question queries, documented inline
└── README.md
```

---

## 👤 Author

**Farhan Adil**
Data Scientist | Python Developer
