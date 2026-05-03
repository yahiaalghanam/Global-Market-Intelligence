/*
=====================================================================================
Script: Clean and Enrich Inflation Data
=====================================================================================

Author: Yahia Alghanam  
Layer: Silver (Data Transformation)

=====================================================================================
Description:
This script transforms raw inflation data by cleaning percentage values,
converting them into numeric format, and deriving key economic indicators.

The output is structured for analytical use in dashboards and downstream modeling.

=====================================================================================
Transformation Goals:

1. Remove percentage symbols and convert values to numeric format
2. Compute month-over-month inflation changes
3. Classify inflation intensity levels
4. Detect food price shocks (volatile category analysis)

=====================================================================================
Challenges Addressed:

1. Mixed Data Types:
   Inflation values stored as text with '%' symbols.

2. Analytical Readiness:
   Raw data not directly usable for numeric computation.

3. Volatility Detection:
   Need to identify abnormal movements in food inflation.

=====================================================================================
Solutions Implemented:

Used REPLACE() to remove '%' characters  
Converted values to FLOAT for numeric operations  
Applied LAG() for time-series change calculation  
Introduced categorical classification logic  
Added volatility indicator for food components  

=====================================================================================
*/

WITH cleaned AS (
    SELECT 
        process_date,

        -- Convert percentage strings to numeric values
        CAST(REPLACE(headline, '%', '') AS FLOAT) AS headline,
        CAST(REPLACE(core, '%', '') AS FLOAT) AS core,
        CAST(REPLACE(regulated_items, '%', '') AS FLOAT) AS regulated_items,
        CAST(REPLACE(fruits_and_vegetables, '%', '') AS FLOAT) AS fruits_and_vegetables

    FROM Economic_Indicator.bronze.inflation_data
)

SELECT 
    process_date,

    headline,
    core,
    regulated_items,
    fruits_and_vegetables,

    /* =======================================================
       Month-over-Month Headline Inflation Change
    ======================================================= */
    ROUND(
        headline - LAG(headline) OVER (ORDER BY process_date)
    , 2) AS headline_change,

    /* =======================================================
       Inflation Level Classification
    ======================================================= */
    CASE 
        WHEN headline >= 3 THEN 'HIGH'
        WHEN headline >= 1 THEN 'MEDIUM'
        When headline IS NULL THEN 'HIGH' -- Default to HIGH if data is missing
        ELSE 'LOW'
    END AS inflation_level,

    /* =======================================================
       Food Price Shock Detection
    ======================================================= */
    CASE 
        WHEN ABS(fruits_and_vegetables) >= 10 THEN 'SHOCK'
        WHEN fruits_and_vegetables IS NULL THEN 'SHOCK' -- Default to SHOCK if data is missing
        ELSE 'NORMAL'
    END AS food_shock

FROM cleaned

ORDER BY process_date;