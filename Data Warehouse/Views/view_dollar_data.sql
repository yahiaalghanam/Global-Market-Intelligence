DROP VIEW IF EXISTS silver.view_dollar_data;
GO 
CREATE VIEW silver.view_dollar_data AS
WITH dates AS (
    SELECT TOP (DATEDIFF(DAY, '2025-01-02', '2026-04-26') + 1)
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2025-01-02') AS process_date
    FROM master.sys.all_columns a CROSS JOIN master.sys.all_columns b
),
base AS (
    SELECT 
        d.process_date,
        CAST(x.buy AS DECIMAL(18,4))  AS buy,
        CAST(x.Sell AS DECIMAL(18,4)) AS sell
    FROM dates d
    OUTER APPLY (
        SELECT TOP 1 g.buy, g.Sell
        FROM bronze.dollar_data g
        WHERE CAST(g.process_date AS DATE) <= d.process_date
          AND g.Currency = 'US Dollar'
        ORDER BY CAST(g.process_date AS DATE) DESC, g.process_date DESC
    ) x
),
metrics AS (
    SELECT 
        process_date,
        'USD' AS currency,
        buy,
        sell,
        (buy + sell) / 2.0 AS mid_price,
        (sell - buy) AS raw_spread
    FROM base
)
SELECT 
    CAST(process_date AS DATE) AS process_date,
    currency,
    buy,
    sell,
    ROUND(mid_price, 3) AS egp_price,
    ROUND(raw_spread, 3) AS spread,
    ROUND(mid_price - LAG(mid_price, 1, mid_price) OVER (ORDER BY process_date), 3) AS price_change,
    CASE 
        WHEN mid_price > LAG(mid_price, 1, mid_price) OVER (ORDER BY process_date) THEN 'UP'
        WHEN mid_price < LAG(mid_price, 1, mid_price) OVER (ORDER BY process_date) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend
FROM metrics;