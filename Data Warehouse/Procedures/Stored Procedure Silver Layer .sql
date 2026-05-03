/*
=====================================================================================
Stored Procedure: silver.load_silver
=====================================================================================

Author: Yahia Alghanam
Layer: Silver (Data Transformation & Persistence)

Description:
This procedure orchestrates the materialization of silver-layer tables from their 
respective analytical views. It follows the 'Drop and Recreate' pattern to ensure 
that table schemas and data are perfectly synchronized with the underlying 
transformation logic (Currencies, Gold, and Inflation).

Workflow:
1. Logs execution start time.
2. Refreshes Currency tables (USD, EUR, SAR).
3. Refreshes Gold analytical data.
4. Refreshes Inflation daily forward-filled data.
5. Logs completion status and final timestamp.

=====================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    -- Suppress 'n rows affected' messages for cleaner logs and optimal performance
    SET NOCOUNT ON;

    PRINT '==========================================================';
    PRINT 'Execution Started: Silver Layer Load';
    PRINT 'Start Time: ' + CAST(GETDATE() AS VARCHAR(30));
    PRINT '==========================================================';

    ----------------------------------------------------------
    -- 1. Load USD (US Dollar) Data
    ----------------------------------------------------------
    PRINT 'Step 1/5: Processing [silver.dollar_data]...';
    
    DROP TABLE IF EXISTS silver.dollar_data; 
    SELECT * INTO silver.dollar_data FROM silver.view_dollar_data;
    
    PRINT 'Status: [silver.dollar_data] successfully loaded.';

    ----------------------------------------------------------
    -- 2. Load EUR (Euro) Data
    ----------------------------------------------------------
    PRINT 'Step 2/5: Processing [silver.euro_data]...';
    
    DROP TABLE IF EXISTS silver.euro_data;
    SELECT * INTO silver.euro_data FROM silver.view_euro_data;
    
    PRINT 'Status: [silver.euro_data] successfully loaded.';

    ----------------------------------------------------------
    -- 3. Load SAR (Saudi Riyal) Data
    ----------------------------------------------------------
    PRINT 'Step 3/5: Processing [silver.saudi_riyal_data]...';
    
    DROP TABLE IF EXISTS silver.saudi_riyal_data;
    SELECT * INTO silver.saudi_riyal_data FROM silver.view_saudi_riyal_data;
    
    PRINT 'Status: [silver.saudi_riyal_data] successfully loaded.';

    ----------------------------------------------------------
    -- 4. Load Gold Prices Data
    ----------------------------------------------------------
    PRINT 'Step 4/5: Processing [silver.gold_data]...';
    
    DROP TABLE IF EXISTS silver.gold_data;
    SELECT * INTO silver.gold_data FROM silver.view_gold_data;
    
    PRINT 'Status: [silver.gold_data] successfully loaded.';

    ----------------------------------------------------------
    -- 5. Load Inflation (Daily Forward-Fill) Data
    ----------------------------------------------------------
    PRINT 'Step 5/5: Processing [silver.inflation_data]...';
    
    DROP TABLE IF EXISTS silver.inflation_data;
    SELECT * INTO silver.inflation_data FROM silver.view_inflation_data;
    
    PRINT 'Status: [silver.inflation_data] successfully loaded.';

    PRINT '==========================================================';
    PRINT 'Execution Completed Successfully';
    PRINT 'End Time: ' + CAST(GETDATE() AS VARCHAR(30));
    PRINT '==========================================================';
END;
GO

EXECUTE silver.load_silver