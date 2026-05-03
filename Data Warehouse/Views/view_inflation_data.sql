
DROP VIEW IF EXISTS silver.view_inflation_data;
GO
CREATE OR ALTER VIEW silver.view_inflation_data AS
WITH daily_dates AS (
    -- 1. توليد سلسلة تواريخ يومية مستمرة
    SELECT TOP (DATEDIFF(DAY, '2025-01-01', '2026-04-26') + 1)
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2025-01-01') AS process_date
    FROM master.sys.all_columns a CROSS JOIN master.sys.all_columns b
),
inflation_cleaned AS (
    -- 2. تنظيف بيانات التضخم الشهرية الأصلية
    SELECT 
        process_date AS original_month_date,
        YEAR(process_date) AS inf_year,
        MONTH(process_date) AS inf_month,
        CAST(REPLACE(headline, '%', '') AS FLOAT) AS headline,
        CAST(REPLACE(core, '%', '') AS FLOAT) AS core,
        CAST(REPLACE(regulated_items, '%', '') AS FLOAT) AS regulated_items,
        CAST(REPLACE(fruits_and_vegetables, '%', '') AS FLOAT) AS fruits_and_vegetables
    FROM Economic_Indicator.bronze.inflation_data
)
-- 3. عملية الـ Forward Fill عن طريق ربط كل يوم ببيانات شهره
SELECT 
    CAST(d.process_date AS DATE) AS process_date,
    i.headline,
    i.core,
    i.regulated_items,
    i.fruits_and_vegetables,
    -- إضافة تصنيف المستوى والصدمة الغذائية على المستوى اليومي
    CASE 
        WHEN i.headline >= 3 THEN 'HIGH'
        WHEN i.headline >= 1 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS inflation_level,
    CASE 
        WHEN ABS(fruits_and_vegetables) >= 10 THEN 'SHOCK'
        WHEN fruits_and_vegetables IS NULL THEN 'SHOCK' -- Default to SHOCK if data is missing
        ELSE 'NORMAL'
    END AS food_shock
    FROM daily_dates d
LEFT JOIN inflation_cleaned i 
    ON YEAR(d.process_date) = i.inf_year 
    AND MONTH(d.process_date) = i.inf_month;
