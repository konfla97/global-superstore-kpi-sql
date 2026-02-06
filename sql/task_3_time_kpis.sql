/* ============================================================
   TASK 3 — Time-based KPIs (Monthly trends & growth)
   Requires: fct_orders_enriched
   Outputs: Multiple KPI result sets

   Notes:
   - Uses returns assumption: returned orders => net_sales/net_profit = 0
   - Uses month key: strftime('%Y-%m', order_date)
   ============================================================ */

-- ------------------------------------------------------------
-- KPI 3.1: Monthly Gross vs Net Revenue & Profit
-- ------------------------------------------------------------
SELECT
  strftime('%Y-%m', order_date) AS month,
  ROUND(SUM(sales), 2)      AS gross_revenue,
  ROUND(SUM(net_sales), 2)  AS net_revenue,
  ROUND(SUM(profit), 2)     AS gross_profit,
  ROUND(SUM(net_profit), 2) AS net_profit
FROM fct_orders_enriched
GROUP BY month
ORDER BY month;


-- ------------------------------------------------------------
-- KPI 3.2: Monthly Orders + AOV (Average Order Value)
-- AOV = net_revenue / distinct_orders
-- ------------------------------------------------------------
SELECT
  strftime('%Y-%m', order_date) AS month,
  COUNT(DISTINCT order_id)      AS orders,
  ROUND(SUM(net_sales), 2)      AS net_revenue,
  ROUND(
    SUM(net_sales) / NULLIF(COUNT(DISTINCT order_id), 0),
    2
  ) AS aov
FROM fct_orders_enriched
GROUP BY month
ORDER BY month;


-- ------------------------------------------------------------
-- KPI 3.3: Monthly MoM Growth % (Net Revenue)
-- mom_growth_rate = (this_month - last_month) / last_month
-- ------------------------------------------------------------
WITH monthly AS (
  SELECT
    strftime('%Y-%m', order_date) AS month,
    SUM(net_sales) AS net_revenue
  FROM fct_orders_enriched
  GROUP BY month
)
SELECT
  month,
  ROUND(net_revenue, 2) AS net_revenue,
  ROUND(
    (net_revenue - LAG(net_revenue) OVER (ORDER BY month))
    / NULLIF(LAG(net_revenue) OVER (ORDER BY month), 0),
    3
  ) AS mom_growth_rate
FROM monthly
ORDER BY month;


-- ------------------------------------------------------------
-- KPI 3.4: Rolling 3-Month Net Revenue (trend smoothing)
-- ------------------------------------------------------------
WITH monthly AS (
  SELECT
    strftime('%Y-%m', order_date) AS month,
    SUM(net_sales) AS net_revenue
  FROM fct_orders_enriched
  GROUP BY month
)
SELECT
  month,
  ROUND(net_revenue, 2) AS net_revenue,
  ROUND(
    SUM(net_revenue) OVER (
      ORDER BY month
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ),
    2
  ) AS rolling_3m_net_revenue
FROM monthly
ORDER BY month;


-- ------------------------------------------------------------
-- KPI 3.5: Monthly Return Rate Trend
-- return_rate = returned_orders / total_orders
-- ------------------------------------------------------------
WITH monthly AS (
  SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(DISTINCT order_id) AS orders,
    SUM(is_returned) AS returned_orders
  FROM fct_orders_enriched
  GROUP BY month
)
SELECT
  month,
  orders,
  returned_orders,
  ROUND(1.0 * returned_orders / NULLIF(orders, 0), 3) AS return_rate
FROM monthly
ORDER BY month;


-- ------------------------------------------------------------
-- KPI 3.6 (Bonus): Monthly Net Profit Margin
-- net_profit_margin = net_profit / net_revenue
-- ------------------------------------------------------------
WITH monthly AS (
  SELECT
    strftime('%Y-%m', order_date) AS month,
    SUM(net_sales)  AS net_revenue,
    SUM(net_profit) AS net_profit
  FROM fct_orders_enriched
  GROUP BY month
)
SELECT
  month,
  ROUND(net_revenue, 2) AS net_revenue,
  ROUND(net_profit, 2)  AS net_profit,
  ROUND(net_profit / NULLIF(net_revenue, 0), 3) AS net_profit_margin
FROM monthly
ORDER BY month;
