/*
=====================================================================================
Script: Create Database and Schemas
=====================================================================================

Author: Yahia Alghanam

=====================================================================================
Description:
This script initializes the data warehouse environment by recreating the target
database and defining the required schema layers.

The database is dropped and recreated to guarantee a clean and consistent state,
which is suitable for development and testing scenarios.

=====================================================================================
Database:
- Economic_Indicator

=====================================================================================
Schema Layers:

1. bronze:
   Stores raw, unprocessed data ingested directly from source systems.

2. silver:
   Stores cleansed and standardized data after applying transformations.

3. gold:
   Stores curated, business-ready datasets optimized for analytics and reporting.

=====================================================================================
Technical Approach:

- Validate database existence using sys.databases
- Force disconnect active sessions using SINGLE_USER mode
- Drop and recreate the database
- Define schema layers explicitly

=====================================================================================
Known Risks:

1. Data Loss:
   The database is dropped unconditionally if it exists.

2. Active Connections:
   Existing sessions are terminated using ROLLBACK IMMEDIATE.

3. Environment Limitation:
   This script is not suitable for production environments.

=====================================================================================
Mitigation Strategies:

- Use only in development or controlled environments
- Ensure backups are available before execution
- Replace DROP strategy with migration approach in production

=====================================================================================
*/

USE master;
GO

/* =======================================================
   Drop Existing Database
======================================================= */
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Economic_Indicator')
BEGIN
    -- Force disconnect all active connections
    ALTER DATABASE Economic_Indicator 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Drop database
    DROP DATABASE Economic_Indicator;
END;
GO


/* =======================================================
   Create Database
======================================================= */
CREATE DATABASE Economic_Indicator;
GO


/* =======================================================
   Switch Context
======================================================= */
USE Economic_Indicator;
GO


/* =======================================================
   Create Schema: bronze
   Purpose: Raw data ingestion layer
======================================================= */
CREATE SCHEMA bronze;
GO


/* =======================================================
   Create Schema: silver
   Purpose: Cleansed and transformed data layer
======================================================= */
CREATE SCHEMA silver;
GO


/* =======================================================
   Create Schema: gold
   Purpose: Aggregated and analytics-ready data layer
======================================================= */
CREATE SCHEMA gold;
GO