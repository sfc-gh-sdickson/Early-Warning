# Early Warning Intelligence Agent - Setup Guide

This guide walks through configuring a Snowflake Intelligence agent for Early Warning's banking data intelligence solution.

---

## Prerequisites

1. **Snowflake Account** with:
   - Snowflake Intelligence (Cortex) enabled
   - Appropriate warehouse size (recommended: MEDIUM or larger)
   - Permissions to create databases, schemas, tables, and semantic views

2. **Roles and Permissions**:
   - `ACCOUNTADMIN` role or equivalent for initial setup
   - `CREATE DATABASE` privilege
   - `CREATE SEMANTIC VIEW` privilege
   - `USAGE` on warehouses

---

## Step 1: Execute SQL Scripts in Order

Execute the SQL files in the following sequence:

### 1.1 Database Setup
```sql
-- Execute: 01_setup_database.sql
-- Creates database, schemas, and warehouse
-- Execution time: < 1 second
```

### 1.2 Create Tables
```sql
-- Execute: 02_create_tables.sql
-- Creates all table structures with proper relationships
-- Tables: FINANCIAL_INSTITUTIONS, CUSTOMERS, ACCOUNTS, TRANSACTIONS,
--         ZELLE_PAYMENTS, PAZE_TRANSACTIONS, FRAUD_ALERTS, ACCOUNT_OPENINGS
-- Execution time: < 5 seconds
```

### 1.3 Generate Sample Data
```sql
-- Execute: 03_generate_sample_data.sql
-- Generates realistic sample data:
--   - 50 financial institutions
--   - 100,000 customers
--   - 150,000 accounts
--   - 2,000,000 transactions
--   - 500,000 Zelle payments
--   - 300,000 Paze transactions
--   - 50,000 fraud alerts
--   - 75,000 account opening applications
-- Execution time: 5-10 minutes (depending on warehouse size)
```

### 1.4 Create Analytical Views
```sql
-- Execute: 04_create_views.sql
-- Creates curated analytical views:
--   - V_CUSTOMER_360
--   - V_FRAUD_ANALYTICS
--   - V_ZELLE_NETWORK_ANALYTICS
--   - V_PAZE_CHECKOUT_ANALYTICS
--   - V_ACCOUNT_OPENING_ANALYTICS
--   - V_INSTITUTION_PERFORMANCE
-- Execution time: < 5 seconds
```

### 1.5 Create Semantic Views
```sql
-- Execute: 05_create_semantic_views.sql
-- Creates semantic views for AI agents (VERIFIED SYNTAX):
--   - SV_NETWORK_INTELLIGENCE
--   - SV_PAZE_INTELLIGENCE
--   - SV_ACCOUNT_OPENING_INTELLIGENCE
-- Execution time: < 5 seconds
```

---

## Step 2: Create Snowflake Intelligence Agent

### 2.1 Via Snowsight UI

1. Navigate to **Snowsight** (Snowflake Web UI)
2. Go to **Data** → **Databases** → `EARLY_WARNING_DEMO` → `ANALYTICS`
3. Click **Create** → **Agent**
4. Configure the agent:

**Basic Settings:**
```yaml
Name: Early_Warning_Intelligence_Agent
Description: AI agent for analyzing Early Warning network data, fraud prevention, and payment intelligence
```

**Data Sources:**
Add the following semantic views:
- `EARLY_WARNING_DEMO.ANALYTICS.SV_NETWORK_INTELLIGENCE`
- `EARLY_WARNING_DEMO.ANALYTICS.SV_PAZE_INTELLIGENCE`
- `EARLY_WARNING_DEMO.ANALYTICS.SV_ACCOUNT_OPENING_INTELLIGENCE`

**Warehouse:**
- Select: `EARLY_WARNING_WH`

**Instructions (System Prompt):**
```
You are an AI intelligence agent for Early Warning Services, a financial technology leader 
providing fraud prevention and payment network solutions.

Your role is to analyze:
1. Network Intelligence: Activity across 2,500+ financial institutions
2. Fraud Prevention: Detection, prevention, and recovery metrics
3. Payment Networks: Zelle ($1T annual volume) and Paze checkout analytics
4. Risk Assessment: Customer risk scores, account opening intelligence
5. Network Performance: Cross-institutional payment flows and fraud patterns

When answering questions:
- Provide specific metrics and data-driven insights
- Compare trends over time and across dimensions
- Highlight fraud patterns and risk indicators
- Benchmark performance across institutions and network tiers
- Calculate rates, percentages, and derived metrics
- Identify actionable recommendations

Data Context:
- Zelle: P2P payment network with real-time transfers
- Paze: Online checkout solution for e-commerce
- Early Warning Risk Scores: 0-100 scale (higher = more risky)
- Network Tiers: Platinum, Gold, Silver, Bronze membership levels
- Fraud Detection Methods: ML_MODEL, RULE_ENGINE, NETWORK_INTELLIGENCE, CUSTOMER_REPORT
```

5. Click **Create Agent**

### 2.2 Via SQL (Alternative)

```sql
-- Create agent using SQL
CREATE AGENT EARLY_WARNING_INTELLIGENCE_AGENT
  SEMANTIC_VIEWS = (
    'EARLY_WARNING_DEMO.ANALYTICS.SV_NETWORK_INTELLIGENCE',
    'EARLY_WARNING_DEMO.ANALYTICS.SV_PAZE_INTELLIGENCE',
    'EARLY_WARNING_DEMO.ANALYTICS.SV_ACCOUNT_OPENING_INTELLIGENCE'
  )
  WAREHOUSE = EARLY_WARNING_WH
  COMMENT = 'AI agent for Early Warning network intelligence, fraud prevention, and payment analytics';
```

---

## Step 3: Test the Agent

### 3.1 Simple Test Questions

Start with simple questions to verify connectivity:

1. **"How many financial institutions are in the Early Warning network?"**
   - Should query SV_NETWORK_INTELLIGENCE
   - Expected: ~50 institutions

2. **"What is the total Zelle payment volume?"**
   - Should query SV_NETWORK_INTELLIGENCE
   - Expected: Aggregate sum of all completed Zelle payments

3. **"How many fraud alerts are currently open?"**
   - Should query SV_NETWORK_INTELLIGENCE with status filter
   - Expected: Count of alerts with status = 'OPEN'

### 3.2 Complex Test Questions

Test with the 10 complex questions provided in `questions.md`:

1. Network Fraud Prevention Effectiveness
2. Cross-Institutional Zelle Payment Flows
3. Customer Risk Segmentation with Payment Behavior
4. Account Opening Risk Model Performance
5. Paze Merchant Fraud Patterns
6. Seasonal Payment Trends with Fraud Correlation
7. Institution Performance Benchmarking
8. Synthetic Identity Detection Patterns
9. Chargeback Cost Analysis
10. Network Intelligence ROI Analysis

---

## Step 4: Agent Configuration Best Practices

### 4.1 Warehouse Sizing

**Recommended:**
- Development/Testing: `SMALL` or `MEDIUM`
- Production: `MEDIUM` or `LARGE`
- High-concurrency: `X-LARGE` with auto-scaling

### 4.2 Timeout Settings

```sql
-- Set appropriate timeout for complex queries
ALTER WAREHOUSE EARLY_WARNING_WH SET
  STATEMENT_TIMEOUT_IN_SECONDS = 300;
```

### 4.3 Query Optimization

The semantic views include:
- Indexed columns for common filters (institution_id, customer_id, date ranges)
- Pre-aggregated metrics in analytical views
- Efficient relationships (no cycles, proper foreign keys)

### 4.4 Access Control

```sql
-- Create role for agent users
CREATE ROLE IF NOT EXISTS EARLY_WARNING_AGENT_USER;

-- Grant necessary privileges
GRANT USAGE ON DATABASE EARLY_WARNING_DEMO TO ROLE EARLY_WARNING_AGENT_USER;
GRANT USAGE ON SCHEMA EARLY_WARNING_DEMO.ANALYTICS TO ROLE EARLY_WARNING_AGENT_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA EARLY_WARNING_DEMO.ANALYTICS TO ROLE EARLY_WARNING_AGENT_USER;
GRANT USAGE ON WAREHOUSE EARLY_WARNING_WH TO ROLE EARLY_WARNING_AGENT_USER;

-- Grant to specific user
GRANT ROLE EARLY_WARNING_AGENT_USER TO USER your_username;
```

---

## Step 5: Monitoring and Maintenance

### 5.1 Query Performance Monitoring

```sql
-- View query history for the agent
SELECT
    query_text,
    execution_time,
    rows_produced,
    bytes_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name = 'EARLY_WARNING_WH'
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 100;
```

### 5.2 Semantic View Usage

```sql
-- Check which semantic views are being used
SHOW SEMANTIC VIEWS IN SCHEMA EARLY_WARNING_DEMO.ANALYTICS;

-- View semantic metrics
SHOW SEMANTIC METRICS IN VIEW SV_NETWORK_INTELLIGENCE;
```

### 5.3 Data Refresh

Sample data is static. For production:

```sql
-- Schedule regular data refresh (example)
CREATE OR REPLACE TASK REFRESH_ANALYTICS
  WAREHOUSE = EARLY_WARNING_WH
  SCHEDULE = 'USING CRON 0 2 * * * America/Los_Angeles'  -- Daily at 2 AM
AS
  -- Add your data refresh logic here
  -- This could involve loading new data, refreshing views, etc.
  SELECT 'Data refresh completed' AS status;
```

---

## Step 6: Advanced Features

### 6.1 Custom Metrics

To add custom metrics to semantic views, use CREATE OR REPLACE with the complete definition:

**Note:** ALTER SEMANTIC VIEW can only rename or modify comments. To add metrics, dimensions, or change other properties, you must use CREATE OR REPLACE SEMANTIC VIEW. [Snowflake Documentation](https://docs.snowflake.com/en/sql-reference/sql/alter-semantic-view)

```sql
-- Example: Add new metric for fraud prevention rate
-- Must recreate the entire semantic view with CREATE OR REPLACE
CREATE OR REPLACE SEMANTIC VIEW SV_NETWORK_INTELLIGENCE
  TABLES (
    institutions AS RAW.FINANCIAL_INSTITUTIONS PRIMARY KEY (institution_id),
    customers AS RAW.CUSTOMERS PRIMARY KEY (customer_id),
    accounts AS RAW.ACCOUNTS PRIMARY KEY (account_id),
    zelle_payments AS RAW.ZELLE_PAYMENTS PRIMARY KEY (payment_id),
    fraud_alerts AS RAW.FRAUD_ALERTS PRIMARY KEY (alert_id)
  )
  RELATIONSHIPS (
    customers(institution_id) REFERENCES institutions(institution_id),
    accounts(customer_id) REFERENCES customers(customer_id),
    accounts(institution_id) REFERENCES institutions(institution_id),
    zelle_payments(sender_customer_id) REFERENCES customers(customer_id),
    zelle_payments(sender_institution_id) REFERENCES institutions(institution_id),
    fraud_alerts(customer_id) REFERENCES customers(customer_id),
    fraud_alerts(institution_id) REFERENCES institutions(institution_id)
  )
  DIMENSIONS (
    -- All existing dimensions from 05_create_semantic_views.sql
    institutions.institution_name AS institution_name,
    -- ... (include all other dimensions)
    fraud_alerts.fraud_detection_method AS detection_method
  )
  METRICS (
    -- All existing metrics from 05_create_semantic_views.sql
    institutions.total_institutions AS COUNT(DISTINCT institution_id),
    -- ... (include all other metrics)
    -- NEW METRIC:
    fraud_alerts.fraud_prevention_rate AS 
      (SUM(CASE WHEN status = 'RESOLVED' AND false_positive = FALSE THEN 1 ELSE 0 END)::FLOAT / 
       COUNT(DISTINCT alert_id) * 100)
      WITH SYNONYMS ('prevention effectiveness', 'detection success rate')
      COMMENT = 'Percentage of fraud alerts that were confirmed and resolved'
  )
  COMMENT = 'Early Warning Network Intelligence';
```

### 6.2 Additional Semantic Views

Create domain-specific semantic views:

```sql
-- Example: Transaction-focused semantic view
CREATE OR REPLACE SEMANTIC VIEW SV_TRANSACTION_INTELLIGENCE
  TABLES (
    accounts AS RAW.ACCOUNTS PRIMARY KEY (account_id),
    transactions AS RAW.TRANSACTIONS PRIMARY KEY (transaction_id)
  )
  RELATIONSHIPS (
    transactions(account_id) REFERENCES accounts(account_id)
  )
  DIMENSIONS (
    transactions.transaction_type AS transaction_type
      WITH SYNONYMS ('payment type', 'transaction category')
      COMMENT = 'Type of transaction: DEBIT, CREDIT, TRANSFER, etc.',
    accounts.account_type AS account_type
      WITH SYNONYMS ('account category')
      COMMENT = 'Type of account'
  )
  METRICS (
    transactions.total_transactions AS COUNT(DISTINCT transaction_id)
      WITH SYNONYMS ('transaction count', 'number of transactions')
      COMMENT = 'Total number of transactions',
    transactions.total_transaction_volume AS SUM(amount)
      WITH SYNONYMS ('total amount', 'transaction volume')
      COMMENT = 'Total transaction amount',
    transactions.avg_transaction_amount AS AVG(amount)
      WITH SYNONYMS ('average transaction', 'mean transaction amount')
      COMMENT = 'Average transaction amount'
  )
  COMMENT = 'Transaction-level intelligence for spending pattern analysis';
```

### 6.3 Integration with BI Tools

Connect Tableau, Power BI, or other tools:
- Use semantic views as data sources
- Leverage pre-calculated metrics
- Enable natural language queries through agent API

---

## Troubleshooting

### Issue: Agent cannot find semantic views

**Solution:**
```sql
-- Verify semantic views exist
SHOW SEMANTIC VIEWS IN SCHEMA EARLY_WARNING_DEMO.ANALYTICS;

-- Check permissions
SHOW GRANTS ON SEMANTIC VIEW SV_NETWORK_INTELLIGENCE;
```

### Issue: Slow query performance

**Solution:**
- Increase warehouse size
- Check for missing filters on date columns
- Review query execution plan
- Consider materializing frequently-used aggregations

### Issue: Syntax errors in semantic views

**Solution:**
- Verify clause order: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS → COMMENT
- Check that all PRIMARY KEY columns exist in tables
- Ensure no circular relationships
- Verify semantic expression format: `name AS expression`

---

## Support Resources

- **Snowflake Documentation**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **Early Warning Website**: https://www.earlywarning.com
- **Snowflake Community**: https://community.snowflake.com
- **GitHub Repository**: Reference Cathay Bank template for similar patterns

---

## Success Metrics

Your agent is successfully configured when:

✅ All 5 SQL scripts execute without errors  
✅ All semantic views are created and validated  
✅ Agent can answer simple test questions  
✅ Agent can answer complex analytical questions from questions.md  
✅ Query performance is acceptable (< 30 seconds for complex queries)  
✅ Results are accurate and match expected business logic  

---

**Version:** 1.0  
**Last Updated:** October 2025  
**Maintained By:** Early Warning Intelligence Team

