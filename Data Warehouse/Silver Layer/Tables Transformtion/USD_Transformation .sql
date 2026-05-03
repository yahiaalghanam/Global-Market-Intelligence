/*
=====================================================================================
Query: USD Daily Time Series with Forward-Fill and Trend Analysis
=====================================================================================

Author: Yahia Alghanam  
Layer: Silver / Analytical Preparation

=====================================================================================
Description:
This query generates a continuous daily time series for USD exchange rates against EGP.
It fills missing dates using a recursive date generator and applies forward-fill logic
to retrieve the most recent available price for each day.

It also derives analytical metrics such as:
- Mid price
- Bid-ask spread
- Day-over-day price change
- Trend direction (UP / DOWN / FLAT)

=====================================================================================
Technical Approach:

1. Generate a complete date range using a recursive CTE
2. Use OUTER APPLY to forward-fill missing values from the latest available record
3. Convert floating-point values to DECIMAL to ensure numerical precision
4. Derive metrics (mid price, spread)
5. Apply window functions (LAG) for time-based comparisons

=====================================================================================
Challenges Faced:

1. Missing Dates:
   Source data does not contain records for every calendar day.

2. Data Type Inconsistency:
   process_date stored as NVARCHAR in Bronze layer required casting.

3. Floating Point Precision:
   FLOAT introduced rounding inconsistencies in financial calculations.

4. Duplicate or Same-Day Records:
   Multiple entries per day required deterministic ordering.

=====================================================================================
Solutions Implemented:

Recursive CTE to generate a complete date series  
OUTER APPLY with TOP 1 to implement forward-fill logic  
Explicit CAST to DATE for reliable comparisons  
Conversion to DECIMAL(18,4) for financial accuracy  
Secondary ORDER BY to ensure latest record selection  
Window functions (LAG) for trend computation  

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

        -- Convert to DECIMAL to avoid floating point precision issues
        CAST(x.buy AS DECIMAL(18,4))  AS buy,
        CAST(x.Sell AS DECIMAL(18,4)) AS sell

    FROM dates d

    OUTER APPLY (
        -- Forward-fill: get latest available record up to current date
        SELECT TOP 1 
            g.buy,
            g.Sell,
            g.Currency
        FROM bronze.dollar_data g
        WHERE CAST(g.process_date AS DATE) <= d.process_date
          AND g.Currency = 'US Dollar'

        -- Ensure most recent record is selected
        ORDER BY 
            CAST(g.process_date AS DATE) DESC,
            g.process_date DESC
    ) x
),

metrics AS (
    SELECT 
        process_date,
        'USD' AS currency,
        buy,
        sell,

        -- Mid price between buy and sell
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

-- Required to support recursive CTE beyond default 100 levels
OPTION (MAXRECURSION 1000);