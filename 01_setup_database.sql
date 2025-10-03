-- ============================================================================
-- Early Warning Intelligence Demo - Database Setup
-- ============================================================================
-- Purpose: Create database and schemas for Early Warning banking intelligence
-- Company: Early Warning Services, LLC
-- Focus: Payment network, fraud prevention, and risk intelligence
-- ============================================================================

-- Create database
CREATE DATABASE IF NOT EXISTS EARLY_WARNING_DEMO;

USE DATABASE EARLY_WARNING_DEMO;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS RAW
    COMMENT = 'Raw banking and payment data from Early Warning network';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
    COMMENT = 'Curated views and semantic models for AI agents';

-- Set default schema
USE SCHEMA RAW;

-- Create warehouse for processing
CREATE WAREHOUSE IF NOT EXISTS EARLY_WARNING_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Early Warning intelligence processing';

-- Use the warehouse
USE WAREHOUSE EARLY_WARNING_WH;

-- Display confirmation
SELECT 
    'Early Warning Intelligence Demo database created successfully' AS status,
    CURRENT_DATABASE() AS database_name,
    CURRENT_SCHEMA() AS schema_name,
    CURRENT_WAREHOUSE() AS warehouse_name;

