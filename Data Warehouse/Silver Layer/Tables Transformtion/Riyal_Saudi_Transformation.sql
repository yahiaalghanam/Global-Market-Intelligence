/*
=====================================================================================
Query: SAR Daily Time Series with Forward-Fill and Trend Analysis
=====================================================================================

Author: Yahia Alghanam  
Layer: Silver / Analytical Preparation

=====================================================================================
Description:
This query generates a continuous daily time series for SAR exchange rates against EGP.
It fills missing dates using a recursive date generator and applies forward-fill logic
to retrieve the most recent available price for each day.

Derived analytical metrics include:
- Mid price
- Bid-ask spread
- Day-over-day price change
- Trend direction (UP / DOWN / FLAT)

=====================================================================================
Technical Approach:

1. Generate a complete date range using a recursive CTE
2. Use OUTER APPLY to forward-fill missing values
3. Convert FLOAT values to DECIMAL for numerical precision
4. Calculate derived financial metrics
5. Use window functions (LAG) for time-based comparison

=====================================================================================
Challenges Faced:

1. Missing Dates:
   Source data does not provide a complete daily time series.

2. Data Type Inconsistency:
   process_date stored as NVARCHAR in Bronze layer requires casting.

3. Floating Point Precision:
   FLOAT data type introduces rounding inaccuracies.

4. Multiple Records per Day:
   Requires deterministic logic to select the latest record.

=====================================================================================
Solutions Implemented:

Recursive CTE to generate full date coverage  
OUTER APPLY with TOP 1 for forward-fill logic  
CAST to DATE for reliable filtering  
Conversion to DECIMAL(18,4) for financial accuracy  
Secondary ORDER BY to ensure correct record selection  
Window functions for trend and delta calculations  

=====================================================================================
*/

WITH dates AS (
    -- Generate continuous date range
    SELECT CAST('2025-01-02' AS DATE) AS process_date

    UNION ALL

    SELECT DATEADD(DAY, 1, process_date)
    FROM dates
    WHERE process_date < '2026-04-26'
),

base AS (
    SELECT 
        d.process_date,
        x.Currency,

        -- Convert to DECIMAL to ensure precision
        CAST(x.buy AS DECIMAL(18,4))  AS buy,
        CAST(x.Sell AS DECIMAL(18,4)) AS sell

    FROM dates d

    OUTER APPLY (
        -- Forward-fill: retrieve latest available SAR record
        SELECT TOP 1 
            g.buy,
            g.Sell,
            g.Currency
        FROM bronze.saudi_riyal_data g
        WHERE CAST(g.process_date AS DATE) <= d.process_date
          AND g.Currency = 'Saudi Riyal'

        -- Ensure most recent record is selected
        ORDER BY 
            CAST(g.process_date AS DATE) DESC,
            g.process_date DESC
    ) x
),

metrics AS (
    SELECT 
        process_date,
        'SAR' AS currency,
        buy,
        sell,

        -- Mid price calculation
        (buy + sell) / 2.0 AS mid_price,

        -- Bid-ask spread
        (sell - buy) AS raw_spread
    FROM base
)

SELECT 
    process_date,
    currency,
    buy,
    sell,

    -- Rounded mid price
    ROUND(mid_price, 3) AS egp_price,

    -- Rounded spread
    ROUND(raw_spread, 3) AS spread,

    /* =======================================================
       Day-over-Day Price Change
    ======================================================= */
    ROUND(
        mid_price - LAG(mid_price, 1, mid_price)
        OVER (ORDER BY process_date)
    , 3) AS price_change,

    /* =======================================================
       Trend Classification
    ======================================================= */
    CASE 
        WHEN mid_price > LAG(mid_price, 1, mid_price) OVER (ORDER BY process_date) THEN 'UP'
        WHEN mid_price < LAG(mid_price, 1, mid_price) OVER (ORDER BY process_date) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend

FROM metrics

ORDER BY process_date

OPTION (MAXRECURSION 1000);