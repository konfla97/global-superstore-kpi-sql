/* ============================================================
   TASK 4 — Product & Category KPIs
   Requires: fct_orders_enriched
   Outputs: Multiple KPI result sets
   ============================================================ */

-- ------------------------------------------------------------
-- KPI 4.1: Category performance (gross + net)
-- ------------------------------------------------------------
SELECT
  category,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(*)                 AS line_items,
  ROUND(SUM(sales), 2)      AS gross_revenue,
  ROUND(SUM(net_sales), 2)  AS net_revenue,
  ROUND(SUM(profit), 2)     AS gross_profit,
  ROUND(SUM(net_profit), 2) AS net_profit,
  ROUND(SUM(net_profit) / NULLIF(SUM(net_sales), 0), 3) AS net_profit_margin,
  ROUND(AVG(discount), 3) AS avg_discount,
  ROUND(AVG(is_returned), 3) AS return_rate
FROM fct_orders_enriched
GROUP BY category
ORDER BY net_revenue DESC;


-- ------------------------------------------------------------
-- KPI 4.2: Sub-category performance (net focus)
-- ------------------------------------------------------------
SELECT
  category,
  sub_category,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(*)                 AS line_items,
  ROUND(SUM(net_sales), 2)  AS net_revenue,
  ROUND(SUM(net_profit), 2) AS net_profit,
  ROUND(SUM(net_profit) / NULLIF(SUM(net_sales), 0), 3) AS net_profit_margin,
  ROUND(AVG(discount), 3) AS avg_discount,
  ROUND(AVG(is_returned), 3) AS return_rate
FROM fct_orders_enriched
GROUP BY category, sub_category
ORDER BY net_revenue DESC;


-- ------------------------------------------------------------
-- KPI 4.3: Category revenue share (% of total net revenue)
-- ------------------------------------------------------------
WITH totals AS (
  SELECT SUM(net_sales) AS total_net_revenue
  FROM fct_orders_enriched
),
cat AS (
  SELECT
    category,
    SUM(net_sales) AS net_revenue
  FROM fct_orders_enriched
  GROUP BY category
)
SELECT
  c.category,
  ROUND(c.net_revenue, 2) AS net_revenue,
  ROUND(1.0 * c.net_revenue / NULLIF(t.total_net_revenue, 0), 4) AS revenue_share
FROM cat c
CROSS JOIN totals t
ORDER BY net_revenue DESC;


-- ------------------------------------------------------------
-- KPI 4.4: Top 20 products by net revenue
-- ------------------------------------------------------------
SELECT
  product_id,
  product_name,
  category,
  sub_category,
  ROUND(SUM(net_sales), 2)  AS net_revenue,
  ROUND(SUM(net_profit), 2) AS net_profit,
  ROUND(SUM(net_profit) / NULLIF(SUM(net_sales), 0), 3) AS net_profit_margin,
  ROUND(AVG(discount), 3) AS avg_discount,
  ROUND(AVG(is_returned), 3) AS return_rate
FROM fct_orders_enriched
GROUP BY product_id, product_name, category, sub_category
ORDER BY net_revenue DESC
LIMIT 20;


-- ------------------------------------------------------------
-- KPI 4.5: Bottom 20 products by net profit (loss-makers)
-- (require some revenue so we don’t pick tiny/noise items)
-- ------------------------------------------------------------
WITH prod AS (
  SELECT
    product_id,
    product_name,
    category,
    sub_category,
    SUM(net_sales)  AS net_revenue,
    SUM(net_profit) AS net_profit,
    AVG(discount)   AS avg_discount,
    AVG(is_returned) AS return_rate
  FROM fct_orders_enriched
  GROUP BY product_id, product_name, category, sub_category
)
SELECT
  product_id,
  product_name,
  category,
  sub_category,
  ROUND(net_revenue, 2) AS net_revenue,
  ROUND(net_profit, 2)  AS net_profit,
  ROUND(net_profit / NULLIF(net_revenue, 0), 3) AS net_profit_margin,
  ROUND(avg_discount, 3) AS avg_discount,
  ROUND(return_rate, 3)  AS return_rate
FROM prod
WHERE net_revenue >= 100
ORDER BY net_profit ASC
LIMIT 20;


-- ------------------------------------------------------------
-- KPI 4.6: Return rate by category + sub-category
-- ------------------------------------------------------------
SELECT
  category,
  sub_category,
  COUNT(DISTINCT order_id) AS orders,
  SUM(is_returned) AS returned_orders,
  ROUND(1.0 * SUM(is_returned) / NULLIF(COUNT(DISTINCT order_id), 0), 3) AS return_rate
FROM fct_orders_enriched
GROUP BY category, sub_category
ORDER BY return_rate DESC, orders DESC;


-- ------------------------------------------------------------
-- KPI 4.7: Discount bands by category (does discount hurt margin?)
-- ------------------------------------------------------------
WITH banded AS (
  SELECT
    category,
    CASE
      WHEN discount = 0 THEN '0%'
      WHEN discount <= 0.10 THEN '0-10%'
      WHEN discount <= 0.20 THEN '10-20%'
      WHEN discount <= 0.30 THEN '20-30%'
      ELSE '30%+'
    END AS discount_band,
    net_sales,
    net_profit
  FROM fct_orders_enriched
)
SELECT
  category,
  discount_band,
  COUNT(*) AS line_items,
  ROUND(SUM(net_sales), 2)  AS net_revenue,
  ROUND(SUM(net_profit), 2) AS net_profit,
  ROUND(SUM(net_profit) / NULLIF(SUM(net_sales), 0), 3) AS net_profit_margin
FROM banded
GROUP BY category, discount_band
ORDER BY
  category,
  CASE discount_band
    WHEN '0%' THEN 1
    WHEN '0-10%' THEN 2
    WHEN '10-20%' THEN 3
    WHEN '20-30%' THEN 4
    ELSE 5
  END;


-- ------------------------------------------------------------
-- KPI 4.8 (Bonus): Top 10 sub-categories by net profit margin
-- (only where net revenue is meaningful)
-- ------------------------------------------------------------
WITH subcat AS (
  SELECT
    category,
    sub_category,
    SUM(net_sales)  AS net_revenue,
    SUM(net_profit) AS net_profit
  FROM fct_orders_enriched
  GROUP BY category, sub_category
)
SELECT
  category,
  sub_category,
  ROUND(net_revenue, 2) AS net_revenue,
  ROUND(net_profit, 2)  AS net_profit,
  ROUND(net_profit / NULLIF(net_revenue, 0), 3) AS net_profit_margin
FROM subcat
WHERE net_revenue >= 1000
ORDER BY net_profit_margin DESC
LIMIT 10;
