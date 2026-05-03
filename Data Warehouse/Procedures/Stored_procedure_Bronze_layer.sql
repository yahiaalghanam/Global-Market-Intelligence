/*
=====================================================================================
Procedure: bronze.load_bronze
=====================================================================================

Author: Yahia Alghanam  
Layer: Bronze (Raw Data Ingestion)

=====================================================================================
Description:
This stored procedure performs a full reload of the Bronze layer by truncating
existing tables and ingesting fresh raw data from CSV files using BULK INSERT.

The Bronze layer stores unprocessed data and serves as the source for downstream
transformations in the Silver layer.

=====================================================================================
Data Sources:
- Gold prices
- Currency exchange rates (USD, EUR, SAR)
- Inflation indicators

=====================================================================================
Technical Approach:
- Full refresh strategy using TRUNCATE + BULK INSERT
- High-performance ingestion using TABLOCK
- UTF-8 encoding support using CODEPAGE = 65001
- Error handling using TRY...CATCH
- Logging using PRINT statements

=====================================================================================
Known Challenges:

1. Encoding Issues:
   Some CSV files contain UTF-8 encoded characters which may cause load failures.

2. Row Terminator Inconsistency:
   CSV files may use '\n' or '\r\n' depending on the source system.

3. File Path Dependency:
   Hardcoded file paths reduce portability across environments.

4. Data Quality Issues:
   Missing or malformed rows may interrupt bulk loading.

=====================================================================================
Mitigation Strategies:

- Enforced UTF-8 support using CODEPAGE = 65001
- Added ERRORFILE to capture rejected rows
- Standardized FIELDTERMINATOR and ROWTERMINATOR
- Structured logging for traceability
- Centralized error handling

=====================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        PRINT '===============================================';
        PRINT 'Starting Bronze Layer Load';
        PRINT '===============================================';

        /* =======================================================
           GOLD PRICES
        ======================================================= */
        PRINT 'Loading table: bronze.gold_prices_2025_to_today';

        TRUNCATE TABLE bronze.gold_prices_2025_to_today;

        BULK INSERT bronze.gold_prices_2025_to_today
        FROM 'C:\Users\Yahia Alghanam\Desktop\project\gold_prices_2025_to_today.csv'
        WITH (
            FIRSTROW = 2,                  -- Skip header row
            FIELDTERMINATOR = ',',         -- CSV delimiter
            ROWTERMINATOR = '\n',          -- Adjust to '\r\n' if required
            CODEPAGE = '65001',            -- UTF-8 encoding
            TABLOCK,                       -- Improves load performance
            ERRORFILE = 'C:\Temp\gold_error.log'  -- Capture failed rows
        );

        PRINT 'Completed: bronze.gold_prices_2025_to_today';


        /* =======================================================
           CURRENCY DATA
        ======================================================= */
        PRINT 'Loading currency tables';

        -- USD
        PRINT 'Loading table: bronze.dollar_data';

        TRUNCATE TABLE bronze.dollar_data;

        BULK INSERT bronze.dollar_data
        FROM 'C:\Users\Yahia Alghanam\Desktop\project\Data\USD_Data.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            CODEPAGE = '65001',
            TABLOCK,
            ERRORFILE = 'C:\Temp\usd_error.log'
        );

        PRINT 'Completed: bronze.dollar_data';


        -- EUR
        PRINT 'Loading table: bronze.euro_data';

        TRUNCATE TABLE bronze.euro_data;

        BULK INSERT bronze.euro_data
        FROM 'C:\Users\Yahia Alghanam\Desktop\project\Data\Euro_Data.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            CODEPAGE = '65001',
            TABLOCK,
            ERRORFILE = 'C:\Temp\euro_error.log'
        );

        PRINT 'Completed: bronze.euro_data';


        -- SAR
        PRINT 'Loading table: bronze.saudi_riyal_data';

        TRUNCATE TABLE bronze.saudi_riyal_data;

        BULK INSERT bronze.saudi_riyal_data
        FROM 'C:\Users\Yahia Alghanam\Desktop\project\Data\Saudi_Riyal_Data.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            CODEPAGE = '65001',
            TABLOCK,
            ERRORFILE = 'C:\Temp\sar_error.log'
        );

        PRINT 'Completed: bronze.saudi_riyal_data';


        /* =======================================================
           INFLATION DATA
        ======================================================= */
        PRINT 'Loading table: bronze.inflation_data';

        TRUNCATE TABLE bronze.inflation_data;

        BULK INSERT bronze.inflation_data
        FROM 'C:\Users\Yahia Alghanam\Desktop\project\Data\Inflation_Data.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            CODEPAGE = '65001',
            TABLOCK,
            ERRORFILE = 'C:\Temp\inflation_error.log'
        );

        PRINT 'Completed: bronze.inflation_data';


        /* =======================================================
           COMPLETION
        ======================================================= */
        PRINT '===============================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT '===============================================';

    END TRY
    BEGIN CATCH
        PRINT '===============================================';
        PRINT 'Bronze Load Failed';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '===============================================';
    END CATCH
END;
GO


-- Execute Procedure
EXEC bronze.load_bronze;