/*
=====================================================================================
Query: Gold Daily Time Series with Forward-Fill and Analytical Features
=====================================================================================

Author: Yahia Alghanam  
Layer: Silver / Analytical Preparation

=====================================================================================
Description:
This query generates a continuous daily time series for gold prices using a date spine
and forward-fill logic. It retrieves the latest available gold price for each day and
derives analytical metrics across multiple representations:

- Gold price per ounce (USD)
- Gold price per gram (USD)
- Local market prices (24K, 21K, 18K)

Derived metrics include:
- Price change (momentum)
- Trend classification
- Volatility proxy

=====================================================================================
Technical Approach:

1. Generate a complete date range using a recursive CTE
2. Use OUTER APPLY to forward-fill missing values
3. Retrieve latest available record per date
4. Apply window functions (LAG) for time-based analytics
5. Round outputs for reporting consistency

=====================================================================================
Challenges Faced:

1. Missing Dates:
   Source data does not contain a complete daily time series.

2. Data Type Inconsistency:
   process_date stored as NVARCHAR requires casting for comparison.

3. Multiple Records per Day:
   Requires deterministic selection of the most recent record.

4. Analytical Consistency:
   Need to standardize price reference (ounce as benchmark).

=====================================================================================
Solutions Implemented:

Recursive CTE to generate continuous date spine  
OUTER APPLY with TOP 1 for forward-fill logic  
Explicit CAST to DATE for reliable filtering  
Window functions (LAG) for momentum and trend analysis  
Rounding for consistent analytical output  

=====================================================================================
*/

-- =======================================================
-- 1. Date Spine (Continuous Calendar)
-- =======================================================
WITH dates AS (
    SELECT CAST('2025-01-02' AS DATE) AS process_date

    UNION ALL

    SELECT DATEADD(DAY, 1, process_date)
    FROM dates
    WHERE process_date < '2026-04-26'
),

-- =======================================================
-- 2. Forward-Fill Gold Data
-- =======================================================
base AS (
    SELECT 
        d.process_date,

        x.Gold_Ounce_USD,
        x.Gold_Gram_USD,
        x.Gold_24K,
        x.Gold_21K,
        x.Gold_18K

    FROM dates d

    OUTER APPLY (
        -- Retrieve latest available gold record up to current date
        SELECT TOP 1 *
        FROM bronze.gold_prices_2025_to_today g
        WHERE CAST(g.process_date AS DATE) <= d.process_date

        -- Ensure deterministic selection of latest record
        ORDER BY 
            CAST(g.process_date AS DATE) DESC,
            g.process_date DESC
    ) x
)

-- =======================================================
-- 3. Analytical Layer
-- =======================================================
SELECT 
    process_date,

    -- Core price measures
    Gold_Ounce_USD,
    Gold_Gram_USD,
    Gold_24K,
    Gold_21K,
    Gold_18K,

    -- Benchmark price (ounce-based)
    ROUND(Gold_Ounce_USD, 2) AS gold_price,

    /* =======================================================
       Price Change (Momentum)
    ======================================================= */
    ROUND(
        Gold_Ounce_USD - LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD)
        OVER (ORDER BY process_date)
    , 2) AS price_change,

    /* =======================================================
       Trend Classification
    ======================================================= */
    CASE 
        WHEN Gold_Ounce_USD > LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD)
             OVER (ORDER BY process_date) THEN 'UP'
        WHEN Gold_Ounce_USD < LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD)
             OVER (ORDER BY process_date) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend,

    /* =======================================================
       Volatility Proxy (Absolute Daily Change)
    ======================================================= */
    ROUND(
        ABS(
            Gold_Ounce_USD - LAG(Gold_Ounce_USD, 1, Gold_Ounce_USD)
            OVER (ORDER BY process_date)
        )
    , 2) AS volatility

FROM base

OPTION (MAXRECURSION 1000);