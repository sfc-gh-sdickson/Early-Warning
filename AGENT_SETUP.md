<img src="Snowflake_Logo.svg" width="200">

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

### 1.6 Create Cortex Search Services (Unstructured Data)
```sql
-- Execute: 06_create_cortex_search.sql
-- Creates tables for unstructured text data:
--   - FRAUD_INVESTIGATION_NOTES (50,000 investigation notes)
--   - CUSTOMER_SUPPORT_TRANSCRIPTS (25,000 customer interactions)
--   - POLICY_DOCUMENTS (5 policy/training documents)
-- Creates Cortex Search services for semantic search:
--   - FRAUD_NOTES_SEARCH
--   - SUPPORT_TRANSCRIPTS_SEARCH
--   - POLICY_DOCUMENTS_SEARCH
-- Execution time: 3-5 minutes (data generation + index building)
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

## Step 5: Cortex Search for Unstructured Data

### 5.1 Overview

Cortex Search enables semantic search over unstructured text data, powering:
- **RAG (Retrieval Augmented Generation)**: Provide context to AI agents from fraud investigation notes
- **Enterprise Search**: Find relevant customer support cases by meaning, not just keywords
- **Knowledge Base**: Search policy documents and training materials

The Early Warning demo includes three Cortex Search services:

1. **FRAUD_NOTES_SEARCH**: 50,000 fraud investigation notes
2. **SUPPORT_TRANSCRIPTS_SEARCH**: 25,000 customer support transcripts
3. **POLICY_DOCUMENTS_SEARCH**: Policy and training documents

### 5.2 Querying Cortex Search Services

#### Query via SQL (Using CORTEX_SEARCH Function)

```sql
-- Search fraud investigation notes for account takeover cases
SELECT 
    result.note_id,
    result.note_text,
    result.case_status,
    result.fraud_confirmed
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'account takeover phishing credentials'
    )
) AS result
LIMIT 10;

-- Search support transcripts about Zelle scams
SELECT 
    result.transcript_id,
    result.transcript_text,
    result.category,
    result.resolution_status
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
        'Zelle scam grandparent fraud'
    )
) AS result
WHERE result.fraud_related = TRUE
LIMIT 10;

-- Search policy documents for synthetic identity guidelines
SELECT 
    result.document_title,
    result.document_text,
    result.document_category
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH',
        'synthetic identity detection methods'
    )
) AS result
WHERE result.is_active = TRUE
LIMIT 5;
```

#### Query via REST API

```bash
# Set your Snowflake account and credentials
ACCOUNT="your_account"
TOKEN="your_oauth_token"

# Search fraud investigation notes
curl -X POST \
  "https://${ACCOUNT}.snowflakecomputing.com/api/v2/cortex/search/query" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "service": "EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH",
    "query": "account takeover phishing credentials",
    "columns": ["note_id", "note_text", "case_status", "fraud_confirmed"],
    "limit": 10
  }'
```

#### Query via Snowpark Python

```python
from snowflake.snowpark import Session
from snowflake.cortex import search

# Create Snowflake session
session = Session.builder.configs(connection_parameters).create()

# Search fraud investigation notes
results = session.sql("""
    SELECT *
    FROM TABLE(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
            'elder fraud romance scam'
        )
    )
    LIMIT 10
""").to_pandas()

print(results)
```

### 5.3 Filtering Results

Use the ATTRIBUTES to filter search results:

```sql
-- Search fraud notes for specific institution
SELECT 
    result.note_id,
    result.note_text,
    result.investigation_date
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'phishing attack'
    )
) AS result
WHERE result.institution_id = 'FI00001'
  AND result.case_status = 'OPEN'
  AND result.investigation_date >= DATEADD('day', -30, CURRENT_DATE())
ORDER BY result.investigation_date DESC
LIMIT 20;

-- Search support transcripts by channel and date range
SELECT 
    result.transcript_id,
    result.transcript_text,
    result.sentiment_score,
    result.support_date
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
        'payment declined fraud alert'
    )
) AS result
WHERE result.channel = 'PHONE'
  AND result.category = 'FRAUD_REPORT'
  AND result.support_date >= '2024-01-01'
LIMIT 15;
```

### 5.4 Use Cases and Examples

#### Use Case 1: RAG for Fraud Investigation
**Scenario**: Agent needs context about similar fraud cases

```sql
-- Agent query: "Find similar account takeover cases in the past 6 months"
SELECT 
    result.note_id,
    result.note_text,
    result.amount_involved,
    result.tags,
    result.investigation_date
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'account takeover unauthorized access password reset'
    )
) AS result
WHERE result.fraud_confirmed = TRUE
  AND result.investigation_date >= DATEADD('month', -6, CURRENT_DATE())
ORDER BY result.investigation_date DESC
LIMIT 10;
```

**Agent Integration**: The agent can use these results to:
- Identify common fraud patterns
- Recommend investigation procedures
- Estimate potential loss amounts
- Suggest prevention measures

#### Use Case 2: Customer Support Knowledge Base
**Scenario**: Agent needs to help customer with Zelle dispute

```sql
-- Agent query: "How do we handle Zelle scam disputes?"
-- Step 1: Search policy documents for procedures
SELECT 
    result.document_title,
    result.document_text
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH',
        'Zelle payment reversal dispute scam policy'
    )
) AS result
WHERE result.document_type IN ('POLICY', 'PROCEDURE')
  AND result.is_active = TRUE
LIMIT 3;

-- Step 2: Search support transcripts for similar cases
SELECT 
    result.transcript_id,
    result.transcript_text,
    result.resolution_status
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
        'Zelle scam unauthorized payment dispute'
    )
) AS result
WHERE result.resolution_status = 'RESOLVED'
  AND result.fraud_related = TRUE
LIMIT 5;
```

#### Use Case 3: Synthetic Identity Pattern Analysis
**Scenario**: Investigate suspected synthetic identity fraud ring

```sql
-- Search investigation notes for synthetic identity patterns
SELECT 
    result.note_id,
    result.note_text,
    result.customer_id,
    result.tags
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'synthetic identity fake documents altered SSN fraud ring'
    )
) AS result
WHERE result.tags LIKE '%synthetic_identity%'
   OR result.tags LIKE '%fraud_ring%'
ORDER BY result.investigation_date DESC
LIMIT 20;

-- Get policy guidance on synthetic identity detection
SELECT 
    result.document_title,
    result.document_text
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH',
        'synthetic identity detection indicators prevention'
    )
) AS result
WHERE result.document_category = 'FRAUD_PREVENTION'
LIMIT 5;
```

#### Use Case 4: Training and Knowledge Discovery
**Scenario**: New fraud analyst needs training on Paze checkout fraud

```sql
-- Search training materials
SELECT 
    result.document_title,
    result.document_text
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH',
        'Paze checkout fraud detection training chargeback'
    )
) AS result
WHERE result.document_type = 'TRAINING'
LIMIT 5;
```

### 5.5 Integrating Cortex Search with Intelligence Agent

Add Cortex Search services to your existing Snowflake Intelligence agent to enable RAG (Retrieval Augmented Generation) over unstructured data.

#### Prerequisites

Before adding Cortex Search to your agent, ensure:

1. You have executed `06_create_cortex_search.sql` successfully
2. The three Cortex Search services exist:
   - `EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH`
   - `EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH`
   - `EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH`

3. Grant necessary privileges:

```sql
-- Grant privileges on the database and schema
GRANT USAGE ON DATABASE EARLY_WARNING_DEMO TO ROLE <your_role>;
GRANT USAGE ON SCHEMA EARLY_WARNING_DEMO.RAW TO ROLE <your_role>;

-- Grant usage on the Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH TO ROLE <your_role>;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE EARLY_WARNING_WH TO ROLE <your_role>;
```

#### Add Cortex Search Services via Snowsight UI

**Step 1: Navigate to Your Agent**

1. Sign in to Snowsight
2. In the left navigation menu, select **AI & ML** » **Agents**
3. Click on your existing agent (`EARLY_WARNING_INTELLIGENCE_AGENT`)
4. Click the **Edit** button

**Step 2: Add First Cortex Search Service (Fraud Investigation Notes)**

1. Click on **Tools** in the configuration menu
2. Find **Cortex Search** in the tools list
3. Click the **+ Add** button next to Cortex Search
4. Configure as follows:
   - **Name**: `Fraud Investigation Notes Search`
   - **Search service**: Select `EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH`
   - **Warehouse**: Select `EARLY_WARNING_WH`
   - **Query timeout (seconds)**: `60`
   - **Description**: 
     ```
     Search 50,000 fraud investigation notes to find similar cases, 
     investigation patterns, and resolution outcomes. Use this for 
     questions about past fraud investigations, account takeover cases, 
     synthetic identity patterns, and fraud resolution procedures.
     ```
5. Click **Add**

**Step 3: Add Second Cortex Search Service (Customer Support Transcripts)**

1. Click the **+ Add** button again for Cortex Search
2. Configure as follows:
   - **Name**: `Customer Support Transcripts Search`
   - **Search service**: Select `EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH`
   - **Warehouse**: Select `EARLY_WARNING_WH`
   - **Query timeout (seconds)**: `60`
   - **Description**:
     ```
     Search 25,000 customer support transcripts to find similar customer 
     issues, resolution examples, and support patterns. Use this for 
     questions about customer service cases, Zelle disputes, Paze issues, 
     and fraud-related support interactions.
     ```
3. Click **Add**

**Step 4: Add Third Cortex Search Service (Policy Documents)**

1. Click the **+ Add** button again for Cortex Search
2. Configure as follows:
   - **Name**: `Policy Documents Search`
   - **Search service**: Select `EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH`
   - **Warehouse**: Select `EARLY_WARNING_WH`
   - **Query timeout (seconds)**: `30`
   - **Description**:
     ```
     Search fraud prevention policies, procedures, training materials, and 
     FAQs. Use this for questions about company policies, fraud detection 
     guidelines, synthetic identity procedures, and compliance requirements.
     ```
3. Click **Add**

**Step 5: Update Orchestration Instructions**

1. Click on **Orchestration** in the configuration menu
2. **Orchestration model**: Select `Claude 4.0` (or your preferred model)
3. **Planning instructions**: Add tool selection guidance:
   ```
   When answering questions:
   - For questions about past fraud cases or investigation patterns, use the Fraud Investigation Notes Search
   - For questions about customer support issues or resolution examples, use the Customer Support Transcripts Search
   - For questions about policies, procedures, or guidelines, use the Policy Documents Search
   - For questions about current data metrics and analytics, use the Cortex Analyst semantic views
   - You can use multiple tools together to provide comprehensive answers
   ```

**Step 6: Update Agent Instructions**

1. Click on **Instructions** in the configuration menu
2. **Response instruction**: Update to mention RAG capabilities:
   ```
   You are an AI intelligence agent for Early Warning Services with access to both 
   structured data (via semantic views) and unstructured data (via Cortex Search).
   
   When answering questions:
   - Provide specific metrics and data-driven insights from structured data
   - Reference similar past cases from investigation notes when relevant
   - Cite specific policy guidance when applicable
   - Show examples from customer support transcripts for best practices
   - Always cite your sources (note IDs, transcript IDs, or document titles)
   - Combine insights from multiple data sources for comprehensive answers
   ```

**Step 7: Save Changes**

1. Click **Save** at the top right
2. Your agent now has RAG capabilities over 75,000+ unstructured records

#### Test the Enhanced Agent

1. Navigate to **AI & ML** or the Snowflake Intelligence landing page
2. Select **Snowflake Intelligence**
3. Select your agent from the dropdown
4. Test with questions that require unstructured data:
   - "Find similar account takeover cases from the last 6 months"
   - "What does our policy say about handling Zelle payment disputes?"
   - "Show me customer support cases involving elder fraud scams"
   - "How do we detect synthetic identity fraud according to our guidelines?"
   - "What investigation procedures were used for fraud ring cases?"

#### Verify Services Are Accessible

If you encounter errors, verify the services are accessible:

```sql
-- Check services exist
SHOW CORTEX SEARCH SERVICES IN SCHEMA EARLY_WARNING_DEMO.RAW;

-- Test search functionality
SELECT COUNT(*) AS result_count
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'account takeover'
    )
);
```

**Common Issues:**
- **"service does not exist"**: Verify privileges were granted correctly
- **"warehouse does not exist"**: Ensure EARLY_WARNING_WH is accessible to your role
- **No results returned**: Wait a few minutes for initial indexing to complete after service creation

### 5.6 Monitoring Cortex Search Services

#### Check Service Status

```sql
-- View all Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Describe specific service
DESCRIBE CORTEX SEARCH SERVICE FRAUD_NOTES_SEARCH;
```

#### Monitor Search Usage

```sql
-- View search query history
SELECT
    query_text,
    execution_time,
    rows_produced,
    warehouse_name
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text LIKE '%CORTEX.SEARCH_PREVIEW%'
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 100;
```

#### Monitor Index Refresh Status

```sql
-- Check when services were last refreshed
-- (Services automatically refresh based on TARGET_LAG setting)
SELECT 
    name,
    created_on,
    comment
FROM INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES
WHERE schema_name = 'RAW';
```

### 5.7 Maintenance and Best Practices

#### Updating Search Services

To modify a Cortex Search service, use CREATE OR REPLACE:

```sql
-- Example: Update FRAUD_NOTES_SEARCH with new attributes
CREATE OR REPLACE CORTEX SEARCH SERVICE FRAUD_NOTES_SEARCH
  ON note_text
  ATTRIBUTES alert_id, customer_id, institution_id, note_type, case_status, fraud_confirmed, tags, investigation_date, investigator_id
  WAREHOUSE = EARLY_WARNING_WH
  TARGET_LAG = '30 minutes'  -- Changed from 1 hour to 30 minutes
  COMMENT = 'Updated: Added investigator_id attribute and reduced target lag'
AS (
  SELECT
    note_id,
    note_text,
    alert_id,
    customer_id,
    institution_id,
    note_type,
    case_status,
    fraud_confirmed,
    amount_involved,
    tags,
    investigation_date,
    investigator_id,
    created_at
  FROM RAW.FRAUD_INVESTIGATION_NOTES
);
```

#### Cost Optimization

1. **Target Lag**: Longer TARGET_LAG = Lower cost
   - Real-time updates: 5-15 minutes
   - Near real-time: 1 hour
   - Periodic: 24 hours (like policy documents)

2. **Warehouse Sizing**: 
   - Small datasets (<100K rows): SMALL warehouse
   - Medium datasets (100K-1M rows): MEDIUM warehouse
   - Large datasets (>1M rows): LARGE warehouse

3. **Attribute Selection**: 
   - Only include attributes you'll filter on
   - Too many attributes = larger index = higher cost

#### Data Quality

```sql
-- Verify data quality before search indexing
SELECT 
    COUNT(*) AS total_notes,
    COUNT(CASE WHEN note_text IS NULL OR LENGTH(note_text) < 50 THEN 1 END) AS poor_quality_notes,
    AVG(LENGTH(note_text)) AS avg_note_length
FROM RAW.FRAUD_INVESTIGATION_NOTES;

-- Check for empty search results
SELECT 
    COUNT(*) AS total_transcripts,
    COUNT(CASE WHEN transcript_text IS NULL THEN 1 END) AS null_transcripts
FROM RAW.CUSTOMER_SUPPORT_TRANSCRIPTS;
```

### 5.8 Advanced: Custom Embedding Models

To use a different embedding model (e.g., for domain-specific terminology):

```sql
-- Recreate service with specific embedding model
CREATE OR REPLACE CORTEX SEARCH SERVICE FRAUD_NOTES_SEARCH
  ON note_text
  ATTRIBUTES alert_id, customer_id, institution_id, note_type, case_status, fraud_confirmed, tags, investigation_date
  WAREHOUSE = EARLY_WARNING_WH
  TARGET_LAG = '1 hour'
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'  -- Larger model for better accuracy
  COMMENT = 'Using large embedding model for enhanced fraud terminology understanding'
AS (
  SELECT
    note_id,
    note_text,
    alert_id,
    customer_id,
    institution_id,
    note_type,
    case_status,
    fraud_confirmed,
    amount_involved,
    tags,
    investigation_date,
    created_at
  FROM RAW.FRAUD_INVESTIGATION_NOTES
);
```

**Available Embedding Models** (as of October 2025):
- `snowflake-arctic-embed-m-v1.5` (default) - Balanced performance
- `snowflake-arctic-embed-l-v2.0` - Higher accuracy, higher cost

Refer to [Snowflake Cortex Search Regional Availability](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview#regional-availability) for model availability by region.

### 5.9 Troubleshooting Cortex Search

#### Issue: Search returns no results

**Solution**:
```sql
-- Verify service exists and is active
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Check if data exists in source table
SELECT COUNT(*) FROM RAW.FRAUD_INVESTIGATION_NOTES;

-- Verify change tracking is enabled
SHOW TABLES LIKE 'FRAUD_INVESTIGATION_NOTES';
-- Check CHANGE_TRACKING column shows TRUE
```

#### Issue: Search results not updated

**Solution**:
```sql
-- Check TARGET_LAG setting
DESCRIBE CORTEX SEARCH SERVICE FRAUD_NOTES_SEARCH;

-- Recent data may not be indexed yet if within TARGET_LAG window
-- Wait for next scheduled refresh or reduce TARGET_LAG
```

#### Issue: Poor search quality

**Solution**:
1. Use more specific search terms
2. Include multiple related terms
3. Consider using larger embedding model
4. Verify source data quality (no empty or very short text)

#### Issue: High costs

**Solution**:
1. Increase TARGET_LAG (reduce refresh frequency)
2. Use smaller warehouse for indexing
3. Reduce number of ATTRIBUTES
4. Consider archiving old data

---

## Step 6: Monitoring and Maintenance

### 6.1 Query Performance Monitoring

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

### 6.2 Semantic View Usage

```sql
-- Check which semantic views are being used
SHOW SEMANTIC VIEWS IN SCHEMA EARLY_WARNING_DEMO.ANALYTICS;

-- View semantic metrics
SHOW SEMANTIC METRICS IN VIEW SV_NETWORK_INTELLIGENCE;
```

### 6.3 Data Refresh

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

## Step 7: Advanced Features

### 7.1 Custom Metrics

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

### 7.2 Additional Semantic Views

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

### 7.3 Integration with BI Tools

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

✅ All 6 SQL scripts execute without errors  
✅ All semantic views are created and validated  
✅ All 3 Cortex Search services are created and indexed  
✅ Agent can answer simple test questions  
✅ Agent can answer complex analytical questions from questions.md  
✅ Cortex Search returns relevant results for unstructured data queries  
✅ Query performance is acceptable (< 30 seconds for complex queries)  
✅ Results are accurate and match expected business logic  

### Testing Cortex Search

After executing `06_create_cortex_search.sql`, verify the services are working:

```sql
-- Test 1: Search fraud investigation notes
SELECT COUNT(*) AS result_count
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.FRAUD_NOTES_SEARCH',
        'account takeover'
    )
);
-- Expected: Returns multiple results (should be > 0)

-- Test 2: Search customer support transcripts
SELECT COUNT(*) AS result_count
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
        'Zelle scam'
    )
);
-- Expected: Returns multiple results (should be > 0)

-- Test 3: Search policy documents
SELECT COUNT(*) AS result_count
FROM TABLE(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'EARLY_WARNING_DEMO.RAW.POLICY_DOCUMENTS_SEARCH',
        'fraud prevention'
    )
);
-- Expected: Returns multiple results (should be > 0)
```

### Sample Questions for Agent with Cortex Search

Once Cortex Search is integrated with your agent, try these questions:

1. **"Find similar account takeover cases from the last 6 months"**
   - Should search FRAUD_NOTES_SEARCH
   - Expected: Returns relevant fraud investigation notes with account takeover patterns

2. **"What does our policy say about handling Zelle payment disputes?"**
   - Should search POLICY_DOCUMENTS_SEARCH
   - Expected: Returns relevant policy text about Zelle dispute procedures

3. **"Show me customer support cases involving elder fraud scams"**
   - Should search SUPPORT_TRANSCRIPTS_SEARCH
   - Expected: Returns customer transcripts related to elder fraud

4. **"How do we detect synthetic identity fraud according to our guidelines?"**
   - Should search POLICY_DOCUMENTS_SEARCH
   - Expected: Returns policy/FAQ content about synthetic identity detection

5. **"Find investigation notes about fraud rings and organized crime"**
   - Should search FRAUD_NOTES_SEARCH with tag filtering
   - Expected: Returns notes tagged with fraud_ring or organized_crime

---

**Version:** 2.0  
**Last Updated:** October 2025  
**Maintained By:** Early Warning Intelligence Team  
**Change Log:**
- v2.0 (Oct 2025): Added Cortex Search for unstructured data (Step 1.6, Step 5)
- v1.0 (Oct 2025): Initial release with semantic views and Intelligence Agent

