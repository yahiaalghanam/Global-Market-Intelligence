/*
===============================================================================
DDL Script: Create Bronze Layer Tables
===============================================================================

Author: Yahia Alghanam
Layer: Bronze (Raw Data Layer)

===============================================================================
Business Purpose:
This script initializes the Bronze layer in the Data Warehouse, which stores
raw economic data including:
- Gold prices
- Foreign exchange rates (USD, EUR, SAR)
- Inflation indicators

The data is ingested directly from external CSV/API sources without applying
any transformations.

===============================================================================
Technical Purpose:
- Ensure consistent schema for raw ingestion
- Allow reprocessing by dropping and recreating tables
- Prepare data for transformation into Silver layer

===============================================================================
Challenges Faced:

1. Date Format Issues:
   - Source data contained inconsistent date formats (e.g., YYYY-MM-DD vs text)
   - Caused errors during BULK INSERT

2. Data Type Mismatch:
   - Inflation data sometimes includes % symbols or text values
   - Caused conversion errors when using numeric types

3. Bulk Insert Failures:
   - Errors like:
     "Bulk load data conversion error"
     "Cannot obtain IID_IColumnsInfo from OLE DB provider BULK"

4. Inconsistent Source Structures:
   - Different APIs/files return slightly different schemas

===============================================================================
Solutions Implemented:

Used NVARCHAR for most Bronze columns:
   - Prevents ingestion failure due to dirty or malformed data
   - Defers data cleaning to Silver layer

Used FLOAT only for clearly numeric fields (gold, currency):
   - Balances flexibility with usability

Standardized process_date as NVARCHAR:
   - Avoids load failure, parsing will happen later in Silver

Drop & Recreate Strategy:
   - Ensures schema consistency during development/testing

===============================================================================
*/

-- =========================================================
-- Table: gold_prices_2025_to_today
-- Description: Stores daily gold prices in multiple units and karats
-- =========================================================
IF OBJECT_ID('bronze.gold_prices_2025_to_today', 'U') IS NOT NULL
    DROP TABLE bronze.gold_prices_2025_to_today;
GO

CREATE TABLE bronze.gold_prices_2025_to_today (
    process_date        NVARCHAR(50),   -- Raw date from source
    Gold_Ounce_USD      FLOAT,          -- Gold price per ounce in USD
    Gold_Gram_USD       FLOAT,          -- Gold price per gram in USD
    Gold_24K            FLOAT,          -- 24K gold price (local currency)
    Gold_21K            FLOAT,          -- 21K gold price
    Gold_18K            FLOAT           -- 18K gold price
);
GO

-- =========================================================
-- Table: dollar_data
-- Description: USD to EGP exchange rates
-- =========================================================
IF OBJECT_ID('bronze.dollar_data', 'U') IS NOT NULL
    DROP TABLE bronze.dollar_data;
GO

CREATE TABLE bronze.dollar_data (
    process_date   NVARCHAR(50),   -- Raw date
    Currency       NVARCHAR(50),   -- Currency name (USD)
    Buy            FLOAT,          -- Buying price
    Sell           FLOAT           -- Selling price
);
GO

-- =========================================================
-- Table: euro_data
-- Description: EUR to EGP exchange rates
-- =========================================================
IF OBJECT_ID('bronze.euro_data', 'U') IS NOT NULL
    DROP TABLE bronze.euro_data;
GO

CREATE TABLE bronze.euro_data (
    process_date   NVARCHAR(50),
    Currency       NVARCHAR(50),
    Buy            FLOAT,
    Sell           FLOAT
);
GO

-- =========================================================
-- Table: saudi_riyal_data
-- Description: SAR to EGP exchange rates
-- =========================================================
IF OBJECT_ID('bronze.saudi_riyal_data', 'U') IS NOT NULL
    DROP TABLE bronze.saudi_riyal_data;
GO

CREATE TABLE bronze.saudi_riyal_data (
    process_date   NVARCHAR(50),
    Currency       NVARCHAR(50),
    Buy            FLOAT,
    Sell           FLOAT
);
GO

-- =========================================================
-- Table: inflation_data
-- Description: Monthly inflation indicators in Egypt
-- =========================================================
IF OBJECT_ID('bronze.inflation_data', 'U') IS NOT NULL
    DROP TABLE bronze.inflation_data;
GO

CREATE TABLE bronze.inflation_data (
    process_date            NVARCHAR(50),   -- Raw date (may contain text like "Mar 2026")
    headline                NVARCHAR(50),   -- Headline inflation (may include %)
    core                    NVARCHAR(50),   -- Core inflation
    regulated_items         NVARCHAR(50),   -- Government-regulated items
    fruits_and_vegetables   NVARCHAR(50)    -- Volatile food category
);
GO