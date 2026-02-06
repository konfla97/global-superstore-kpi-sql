# Global Superstore – KPI Analytics with SQL

## 📊 Project Overview
This project analyzes the **Global Superstore** dataset to build **business KPIs** using **SQL**.

It simulates a real-world analytics workflow:
- ingesting raw operational data
- staging and cleaning it
- modeling analytics-ready tables
- producing decision-focused KPIs

The project is **SQL-first**, using **SQLite** for portability and clarity, with optional **Python** used only for data preparation.

---

## 🎯 Business Questions Answered
- How do **sales, profit, and margins** vary by region?
- How do KPIs **evolve over time** (monthly trends and growth)?
- Which **products and categories** drive revenue vs. losses?
- What is the **impact of returns** on net revenue and profitability?

---

## 🗂 Dataset
- **Source:** Kaggle – Global Superstore
- **Original format:** Excel (`.xlsx`)
- **Tables used:**
  - `Orders`
  - `Returns`
  - `People`

⚠️ **Raw data files are not included** in this repository to respect dataset licensing.  
The SQL scripts assume the data has been imported into SQLite tables.

---


---

## 🧱 Data Modeling Approach

### 1️⃣ Staging Layer
- Cleans raw imported columns (`C1…C24`)
- Renames fields to business-friendly names
- Casts numeric measures (sales, profit, discount, quantity)
- Prepares data for analytics use

### 2️⃣ Analytics Fact Table
- Central fact table: `fct_orders_enriched`
- Includes:
  - Parsed order & ship dates
  - Net sales & net profit
  - Return flags
  - Region manager attribution

---

## 📈 KPIs Implemented

### Regional Performance
- Total revenue
- Total profit
- Profit margin
- Order volume

### Returns Analysis
- Return rate by region
- Net revenue after returns
- Profit impact of returned orders

### Time-Based KPIs
- Monthly revenue and profit
- Month-over-month growth
- Trend analysis

### Product & Category KPIs
- Revenue and profit by category & sub-category
- Best and worst performing products
- Discount vs. profitability analysis

---

## ▶️ How to Run the Project

1. Import CSV data into SQLite tables:
   - `Orders`
   - `Returns`
   - `People`

2. Run SQL scripts **in order**:

   1. `sql/task_1_orders_staging.sql`
   2. `sql/task_2_enriched_fact.sql`
   3. `sql/task_3_time_kpis.sql`
   4. `sql/task_4_product_category_kpis.sql`

3. Review KPI query outputs directly in SQLite.

---

## 🛠 Tools & Technologies
- **SQLite** – analytics database
- **SQL** – data modeling and KPI logic
- **Python (optional)** – data preparation (pandas, KaggleHub)
- **GitHub** – version control and portfolio presentation

---

## Project Structure

```text
global-superstore-kpi-sql/
├── README.md
├── .gitignore
├── LICENSE
├── sql/
│   └── task_1_orders_staging.sql
│   └── task_2_enriched_fact.sql
│   └── task_3_time_kpis.sql
│   └── task_4_product_category_kpis.sql
└── src/
    └── download_and_convert_kagglehub.ipynb
