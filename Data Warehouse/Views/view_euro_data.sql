DROP VIEW IF EXISTS silver.view_euro_data;

GO

CREATE OR ALTER VIEW silver.view_euro_data AS
WITH dates AS (
    -- توليد التواريخ بطريقة الـ Numbers Table لتجنب الـ Recursion
    SELECT TOP (DATEDIFF(DAY, '2025-01-02', '2026-04-26') + 1)
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2025-01-02') AS process_date
    FROM master.sys.all_columns a CROSS JOIN master.sys.all_columns b
),
base AS (
    SELECT 
        d.process_date,
        CAST(x.buy AS DECIMAL(18,4))  AS buy_val,
        CAST(x.Sell AS DECIMAL(18,4)) AS sell_val
    FROM dates d
    OUTER APPLY (
        -- Forward-fill لليورو
        SELECT TOP 1 g.buy, g.Sell
        FROM bronze.euro_data g
        WHERE CAST(g.process_date AS DATE) <= d.process_date
          AND g.Currency = 'Euro'
        ORDER BY 
            CAST(g.process_date AS DATE) DESC, 
            g.process_date DESC
    ) x
),
metrics AS (
    SELECT 
        process_date,
        'EUR' AS currency_code,
        buy_val,
        sell_val,
        (buy_val + sell_val) / 2.0 AS mid_p,
        (sell_val - buy_val) AS raw_s
    FROM base
)
SELECT 
    process_date,
    currency_code AS currency,
    buy_val AS buy,
    sell_val AS sell,
    ROUND(mid_p, 3) AS egp_price,
    ROUND(raw_s, 3) AS spread,
    ROUND(mid_p - LAG(mid_p, 1, mid_p) OVER (ORDER BY process_date), 3) AS price_change,
    CASE 
        WHEN mid_p > LAG(mid_p, 1, mid_p) OVER (ORDER BY process_date) THEN 'UP'
        WHEN mid_p < LAG(mid_p, 1, mid_p) OVER (ORDER BY process_date) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend
FROM metrics;