/*
=====================================================================================
View: gold.view_market_master
=====================================================================================

Author: Yahia Alghanam
Layer: Gold (Analytical Master Layer)

Description:
This is the master analytical view that integrates all economic indicators 
into a single daily time series. It joins Currencies (USD, EUR, SAR), 
Gold Prices, and Inflation metrics.

Business Logic:
- Joins all silver layer tables on 'process_date'.
- Calculates the Local Gold Price (24K Gold multiplied by USD/EGP rate).
- Provides a comprehensive view for correlation analysis between 
  exchange rates, commodity prices, and inflation levels.

=====================================================================================
*/

CREATE OR ALTER VIEW gold.view_market_master AS
SELECT
    -- Date Reference
    g.process_date,

    -- USD Metrics
    d.egp_price        AS usd_price,
    d.spread           AS usd_spread,
    d.price_change     AS usd_price_change,
    d.trend            AS usd_trend,

    -- EUR Metrics
    e.egp_price        AS eur_price,
    e.spread           AS eur_spread,
    e.price_change     AS eur_price_change,
    e.trend            AS eur_trend,

    -- SAR Metrics
    s.egp_price        AS sar_price,
    s.spread           AS sar_spread,
    s.price_change     AS sar_price_change,
    s.trend            AS sar_trend,

    -- Gold Metrics (Local & Global)
    ROUND((g.Gold_24K * d.egp_price), 2) AS egp_gold_24k_price, -- Calculated Local Price
    g.gold_price_benchmark               AS global_gold_ounce_usd,
    g.price_change                       AS gold_price_change,
    g.trend                              AS gold_trend,
    g.volatility                         AS gold_volatility,

    -- Inflation Metrics
    CASE WHEN i.headline IS NULL THEN '3.2'
         ELSE ABS(i.headline)
         END AS headline_inflation,

    CASE WHEN i.fruits_and_vegetables IS NULL THEN 16.8 
         ELSE ABS(i.fruits_and_vegetables)
         END AS food_inflation,
        CASE 
        WHEN headline >= 3 THEN 'HIGH'
        WHEN headline >= 1 THEN 'MEDIUM'
        When headline IS NULL THEN 'HIGH' -- Default to HIGH if data is missing
        ELSE 'LOW'
    END AS inflation_level,
    COALESCE (i.food_shock, 'SHOCK') AS food_shock

FROM silver.gold_data g
LEFT JOIN silver.dollar_data d 
    ON g.process_date = d.process_date
LEFT JOIN silver.euro_data e
    ON g.process_date = e.process_date
LEFT JOIN silver.saudi_riyal_data s
    ON g.process_date = s.process_date
LEFT JOIN silver.inflation_data i
    ON g.process_date = i.process_date;
GO
