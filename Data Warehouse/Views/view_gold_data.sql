/*
=====================================================================================
View: silver.view_gold_data
=====================================================================================

Author: Yahia Alghanam
Layer: Silver (Analytical Transformation)

Description:
This view generates a continuous daily time series for gold prices. It uses 
a date spine logic to ensure no missing dates and applies a forward-fill mechanism
via OUTER APPLY to propagate the last known price.

Analytical Features:
- Multi-unit pricing (Ounce, Gram, 24K, 21K, 18K)
- Momentum Tracking (Daily Price Change)
- Trend Classification (UP, DOWN, FLAT)
- Volatility Proxy (Absolute Daily Delta)

=====================================================================================
*/

CREATE OR ALTER VIEW silver.view_gold_data AS
WITH dates AS (
    -- Generate a continuous date range using a cross-join number generator
    SELECT TOP (DATEDIFF(DAY, '2025-01-02', '2026-04-26') + 1)
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2025-01-02') AS process_date
    FROM master.sys.all_columns a CROSS JOIN master.sys.all_columns b
),
base AS (
    -- Apply Forward-Fill logic to retrieve the latest available record per day
    SELECT 
        d.process_date,
        x.Gold_Ounce_USD,
        x.Gold_Gram_USD,
        x.Gold_24K,
        x.Gold_21K,
        x.Gold_18K
    FROM dates d
    OUTER APPLY (
        SELECT TOP 1 *
        FROM bronze.gold_prices_2025_to_today g
        WHERE CAST(g.process_date AS DATE) <= d.process_date
        ORDER BY 
            CAST(g.process_date AS DATE) DESC, 
            g.process_date DESC
    ) x
)
SELECT 
    CAST(process_date AS DATE) AS process_date,
    Gold_Ounce_USD,
    Gold_Gram_USD,
    Gold_24K,
    Gold_21K,
    Gold_18K,
    ROUND(Gold_Ounce_USD, 2) AS gold_price_benchmark,
    
    -- Momentum: Calculated as the difference between current and previous day's benchmark price
    ROUND(
        Gold_Ounce_USD - LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD) 
        OVER (ORDER BY process_date)
    , 2) AS price_change,
    
    -- Trend: Classifies price movement direction based on momentum
    CASE 
        WHEN Gold_Ounce_USD > LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD) OVER (ORDER BY process_date) THEN 'UP'
        WHEN Gold_Ounce_USD < LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD) OVER (ORDER BY process_date) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend,
    
    -- Volatility Proxy: Represents the magnitude of price fluctuation regardless of direction
    ROUND(
        ABS(Gold_Ounce_USD - LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD) OVER (ORDER BY process_date))
    , 2) AS volatility
FROM base;
GO
