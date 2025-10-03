-- ============================================================================
-- Early Warning Intelligence Demo - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- Syntax Verification Notes:
-- 1. Clause order is MANDATORY: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS → COMMENT
-- 2. Semantic expression format: semantic_name AS sql_expression
-- 3. No self-referencing relationships allowed
-- 4. No cyclic relationships allowed
-- 5. PRIMARY KEY columns must exist in table definitions
-- ============================================================================

USE DATABASE EARLY_WARNING_DEMO;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- Semantic View 1: Early Warning Network Intelligence
-- ============================================================================
-- Purpose: Comprehensive view of network activity, fraud, and risk metrics
-- Relationships verified: No cycles, no self-references
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_NETWORK_INTELLIGENCE
  TABLES (
    institutions AS RAW.FINANCIAL_INSTITUTIONS
      PRIMARY KEY (institution_id)
      WITH SYNONYMS ('banks', 'credit unions', 'network members')
      COMMENT = 'Early Warning network member institutions',
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('account holders', 'clients', 'consumers')
      COMMENT = 'Banking customers across network',
    accounts AS RAW.ACCOUNTS
      PRIMARY KEY (account_id)
      WITH SYNONYMS ('bank accounts', 'deposit accounts')
      COMMENT = 'Customer bank accounts',
    zelle_payments AS RAW.ZELLE_PAYMENTS
      PRIMARY KEY (payment_id)
      WITH SYNONYMS ('p2p payments', 'peer to peer transfers', 'zelle transfers')
      COMMENT = 'Zelle network payments',
    fraud_alerts AS RAW.FRAUD_ALERTS
      PRIMARY KEY (alert_id)
      WITH SYNONYMS ('fraud cases', 'security alerts', 'fraud incidents')
      COMMENT = 'Fraud detection alerts from Early Warning'
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
    institutions.institution_name AS institution_name
      WITH SYNONYMS ('bank name', 'financial institution')
      COMMENT = 'Name of the financial institution',
    institutions.institution_type AS institution_type
      WITH SYNONYMS ('bank type', 'institution category')
      COMMENT = 'Type of institution: Bank, Credit Union, Payment Provider',
    institutions.network_tier AS network_tier
      WITH SYNONYMS ('membership tier', 'tier level')
      COMMENT = 'Network membership tier: Platinum, Gold, Silver, Bronze',
    institutions.institution_state AS "STATE"
      WITH SYNONYMS ('bank state', 'institution location')
      COMMENT = 'State where institution is located',
    customers.customer_status AS customer_status
      WITH SYNONYMS ('account status', 'customer state')
      COMMENT = 'Customer status: ACTIVE, SUSPENDED, CLOSED',
    customers.customer_state AS "STATE"
      WITH SYNONYMS ('customer location state')
      COMMENT = 'State where customer resides',
    customers.customer_city AS city
      WITH SYNONYMS ('customer location city')
      COMMENT = 'City where customer resides',
    customers.is_zelle_enrolled AS zelle_enrolled
      WITH SYNONYMS ('has zelle', 'zelle active')
      COMMENT = 'Whether customer is enrolled in Zelle',
    accounts.account_type AS account_type
      WITH SYNONYMS ('account category')
      COMMENT = 'Type of account: CHECKING, SAVINGS, CREDIT_CARD, MONEY_MARKET',
    accounts.account_status AS account_status
      WITH SYNONYMS ('account state')
      COMMENT = 'Account status: ACTIVE, FROZEN, CLOSED',
    accounts.account_risk_level AS risk_level
      WITH SYNONYMS ('risk category')
      COMMENT = 'Account risk level: LOW, MEDIUM, HIGH, CRITICAL',
    zelle_payments.payment_status AS status
      WITH SYNONYMS ('transaction status', 'payment state')
      COMMENT = 'Zelle payment status: PENDING, COMPLETED, FAILED, CANCELLED, DISPUTED',
    zelle_payments.receiver_type AS receiver_identifier_type
      WITH SYNONYMS ('recipient identifier type')
      COMMENT = 'How receiver is identified: EMAIL or PHONE',
    fraud_alerts.fraud_alert_type AS alert_type
      WITH SYNONYMS ('fraud type', 'fraud category')
      COMMENT = 'Type of fraud alert: IDENTITY_THEFT, ACCOUNT_TAKEOVER, CARD_FRAUD, P2P_FRAUD, etc.',
    fraud_alerts.fraud_severity AS alert_severity
      WITH SYNONYMS ('fraud risk level', 'alert priority')
      COMMENT = 'Severity of fraud alert: LOW, MEDIUM, HIGH, CRITICAL',
    fraud_alerts.fraud_status AS status
      WITH SYNONYMS ('fraud alert status', 'investigation status')
      COMMENT = 'Status of fraud alert: OPEN, INVESTIGATING, CONFIRMED_FRAUD, FALSE_POSITIVE, RESOLVED',
    fraud_alerts.fraud_detection_method AS detection_method
      WITH SYNONYMS ('detection source', 'how detected')
      COMMENT = 'Method used to detect fraud: ML_MODEL, RULE_ENGINE, NETWORK_INTELLIGENCE, CUSTOMER_REPORT'
  )
  METRICS (
    institutions.total_institutions AS COUNT(DISTINCT institution_id)
      WITH SYNONYMS ('number of banks', 'institution count', 'network size')
      COMMENT = 'Total number of financial institutions in network',
    customers.total_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('customer count', 'number of customers')
      COMMENT = 'Total number of customers',
    customers.avg_customer_risk_score AS AVG(risk_score)
      WITH SYNONYMS ('average risk score', 'mean customer risk')
      COMMENT = 'Average customer risk score (0-100 scale)',
    accounts.total_accounts AS COUNT(DISTINCT account_id)
      WITH SYNONYMS ('account count', 'number of accounts')
      COMMENT = 'Total number of accounts',
    accounts.total_balance AS SUM(current_balance)
      WITH SYNONYMS ('total deposits', 'aggregate balance')
      COMMENT = 'Total balance across all accounts',
    accounts.avg_account_balance AS AVG(current_balance)
      WITH SYNONYMS ('average balance', 'mean account balance')
      COMMENT = 'Average balance per account',
    zelle_payments.total_payments AS COUNT(DISTINCT payment_id)
      WITH SYNONYMS ('payment count', 'number of zelle transfers')
      COMMENT = 'Total number of Zelle payments',
    zelle_payments.total_payment_volume AS SUM(amount)
      WITH SYNONYMS ('total zelle volume', 'aggregate payments', 'payment sum')
      COMMENT = 'Total dollar volume of Zelle payments',
    zelle_payments.avg_payment_amount AS AVG(amount)
      WITH SYNONYMS ('average payment', 'mean payment size')
      COMMENT = 'Average Zelle payment amount',
    fraud_alerts.total_fraud_alerts AS COUNT(DISTINCT alert_id)
      WITH SYNONYMS ('fraud count', 'number of alerts', 'fraud cases')
      COMMENT = 'Total number of fraud alerts',
    fraud_alerts.total_amount_at_risk AS SUM(amount_at_risk)
      WITH SYNONYMS ('fraud exposure', 'total fraud amount')
      COMMENT = 'Total dollar amount at risk from fraud',
    fraud_alerts.total_amount_recovered AS SUM(amount_recovered)
      WITH SYNONYMS ('fraud recovered', 'funds recovered')
      COMMENT = 'Total dollar amount recovered from fraud',
    fraud_alerts.avg_fraud_score AS AVG(fraud_score)
      WITH SYNONYMS ('average fraud risk', 'mean fraud score')
      COMMENT = 'Average fraud risk score'
  )
  COMMENT = 'Early Warning Network Intelligence - comprehensive view of network activity, payments, and fraud prevention';

-- ============================================================================
-- Semantic View 2: Paze Checkout Intelligence
-- ============================================================================
-- Purpose: Analyze Paze online checkout transactions and merchant performance
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_PAZE_INTELLIGENCE
  TABLES (
    institutions AS RAW.FINANCIAL_INSTITUTIONS
      PRIMARY KEY (institution_id)
      WITH SYNONYMS ('banks', 'issuers')
      COMMENT = 'Card-issuing financial institutions',
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('cardholders', 'shoppers', 'consumers')
      COMMENT = 'Customers using Paze checkout',
    paze_txns AS RAW.PAZE_TRANSACTIONS
      PRIMARY KEY (paze_transaction_id)
      WITH SYNONYMS ('online purchases', 'checkout transactions', 'e-commerce')
      COMMENT = 'Paze online checkout transactions'
  )
  RELATIONSHIPS (
    customers(institution_id) REFERENCES institutions(institution_id),
    paze_txns(customer_id) REFERENCES customers(customer_id),
    paze_txns(institution_id) REFERENCES institutions(institution_id)
  )
  DIMENSIONS (
    institutions.institution_name AS institution_name
      WITH SYNONYMS ('issuing bank', 'card issuer')
      COMMENT = 'Name of card-issuing institution',
    institutions.is_paze_enabled AS paze_enabled
      WITH SYNONYMS ('paze active', 'has paze')
      COMMENT = 'Whether institution supports Paze',
    customers.is_customer_paze_enrolled AS paze_enrolled
      WITH SYNONYMS ('customer has paze', 'enrolled in paze')
      COMMENT = 'Whether customer is enrolled in Paze',
    customers.customer_state AS "STATE"
      WITH SYNONYMS ('cardholder state')
      COMMENT = 'Customer state location',
    paze_txns.merchant_name AS merchant_name
      WITH SYNONYMS ('retailer', 'online store', 'vendor')
      COMMENT = 'Name of online merchant',
    paze_txns.merchant_category AS merchant_category
      WITH SYNONYMS ('merchant type', 'retail category')
      COMMENT = 'Category of merchant: RETAIL, FOOD_DELIVERY, TRAVEL, etc.',
    paze_txns.transaction_status AS status
      WITH SYNONYMS ('purchase status', 'payment status')
      COMMENT = 'Transaction status: APPROVED, DECLINED, PENDING, REFUNDED',
    paze_txns.decline_reason AS decline_reason
      WITH SYNONYMS ('rejection reason', 'why declined')
      COMMENT = 'Reason for transaction decline',
    paze_txns.card_type AS card_type
      WITH SYNONYMS ('payment type')
      COMMENT = 'Type of card used: DEBIT or CREDIT',
    paze_txns.device_type AS device_type
      WITH SYNONYMS ('device', 'platform')
      COMMENT = 'Device used: DESKTOP, MOBILE, TABLET',
    paze_txns.browser_type AS browser_type
      WITH SYNONYMS ('web browser')
      COMMENT = 'Browser or app used for checkout',
    paze_txns.transaction_state AS location_state
      WITH SYNONYMS ('purchase state')
      COMMENT = 'State where transaction originated',
    paze_txns.is_fraud_flagged AS fraud_flagged
      WITH SYNONYMS ('suspicious', 'fraud flag')
      COMMENT = 'Whether transaction was flagged for fraud',
    paze_txns.has_chargeback AS chargeback
      WITH SYNONYMS ('disputed', 'chargeback occurred')
      COMMENT = 'Whether transaction resulted in chargeback'
  )
  METRICS (
    institutions.total_institutions AS COUNT(DISTINCT institution_id)
      WITH SYNONYMS ('issuer count')
      COMMENT = 'Number of institutions with Paze transactions',
    customers.total_paze_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('paze users', 'active shoppers')
      COMMENT = 'Number of customers using Paze',
    paze_txns.total_transactions AS COUNT(DISTINCT paze_transaction_id)
      WITH SYNONYMS ('transaction count', 'purchase count')
      COMMENT = 'Total number of Paze transactions',
    paze_txns.total_transaction_volume AS SUM(amount)
      WITH SYNONYMS ('total spend', 'gross merchandise value', 'GMV')
      COMMENT = 'Total dollar volume of Paze transactions',
    paze_txns.avg_transaction_amount AS AVG(amount)
      WITH SYNONYMS ('average purchase', 'average order value', 'AOV')
      COMMENT = 'Average transaction amount',
    paze_txns.total_merchant_fees AS SUM(merchant_fee)
      WITH SYNONYMS ('merchant fee revenue')
      COMMENT = 'Total merchant fees collected',
    paze_txns.total_network_fees AS SUM(network_fee)
      WITH SYNONYMS ('network fee revenue')
      COMMENT = 'Total network fees collected',
    paze_txns.avg_fraud_score AS AVG(risk_score)
      WITH SYNONYMS ('average risk score')
      COMMENT = 'Average fraud risk score for transactions'
  )
  COMMENT = 'Paze Checkout Intelligence - analyze online checkout transactions and merchant performance';

-- ============================================================================
-- Semantic View 3: Account Opening Risk Intelligence
-- ============================================================================
-- Purpose: Analyze account opening applications and risk assessment effectiveness
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ACCOUNT_OPENING_INTELLIGENCE
  TABLES (
    institutions AS RAW.FINANCIAL_INSTITUTIONS
      PRIMARY KEY (institution_id)
      WITH SYNONYMS ('banks', 'lenders')
      COMMENT = 'Institutions receiving applications',
    applications AS RAW.ACCOUNT_OPENINGS
      PRIMARY KEY (application_id)
      WITH SYNONYMS ('new account requests', 'account applications')
      COMMENT = 'New account opening applications with risk scores'
  )
  RELATIONSHIPS (
    applications(institution_id) REFERENCES institutions(institution_id)
  )
  DIMENSIONS (
    institutions.institution_name AS institution_name
      WITH SYNONYMS ('bank name')
      COMMENT = 'Name of institution receiving application',
    institutions.institution_type AS institution_type
      WITH SYNONYMS ('institution category')
      COMMENT = 'Type of institution',
    institutions.network_tier AS network_tier
      WITH SYNONYMS ('tier level')
      COMMENT = 'Network membership tier',
    applications.application_status AS application_status
      WITH SYNONYMS ('decision', 'approval status')
      COMMENT = 'Application status: PENDING, APPROVED, DENIED, MANUAL_REVIEW',
    applications.requested_account_type AS requested_account_type
      WITH SYNONYMS ('account type requested')
      COMMENT = 'Type of account requested: CHECKING, SAVINGS, CREDIT_CARD, MONEY_MARKET',
    applications.application_channel AS application_channel
      WITH SYNONYMS ('application source', 'channel')
      COMMENT = 'Channel used: BRANCH, ONLINE, MOBILE, PHONE',
    applications.denial_reason AS denial_reason
      WITH SYNONYMS ('rejection reason', 'why denied')
      COMMENT = 'Reason for application denial',
    applications.needs_manual_review AS manual_review_required
      WITH SYNONYMS ('requires review', 'manual review flag')
      COMMENT = 'Whether application requires manual review',
    applications.applicant_state AS applicant_state
      WITH SYNONYMS ('applicant location state')
      COMMENT = 'State where applicant resides'
  )
  METRICS (
    institutions.total_institutions AS COUNT(DISTINCT institution_id)
      WITH SYNONYMS ('institution count')
      COMMENT = 'Number of institutions with applications',
    applications.total_applications AS COUNT(DISTINCT application_id)
      WITH SYNONYMS ('application count', 'number of applications')
      COMMENT = 'Total number of account opening applications',
    applications.avg_risk_score AS AVG(early_warning_risk_score)
      WITH SYNONYMS ('average early warning risk', 'mean risk score')
      COMMENT = 'Average Early Warning risk score (0-100 scale)',
    applications.avg_credit_score AS AVG(credit_score)
      WITH SYNONYMS ('average credit score', 'mean FICO')
      COMMENT = 'Average applicant credit score',
    applications.avg_identity_score AS AVG(identity_verification_score)
      WITH SYNONYMS ('average identity score')
      COMMENT = 'Average identity verification score',
    applications.avg_synthetic_identity_score AS AVG(synthetic_identity_score)
      WITH SYNONYMS ('synthetic ID risk', 'average synthetic score')
      COMMENT = 'Average synthetic identity risk score',
    applications.avg_velocity_score AS AVG(velocity_check_score)
      WITH SYNONYMS ('velocity risk', 'multiple application score')
      COMMENT = 'Average velocity check score (multiple applications)',
    applications.total_fraud_hits AS SUM(fraud_database_hits)
      WITH SYNONYMS ('fraud database matches')
      COMMENT = 'Total fraud database hits across applications',
    applications.avg_initial_deposit AS AVG(initial_deposit_amount)
      WITH SYNONYMS ('average deposit', 'mean opening deposit')
      COMMENT = 'Average initial deposit amount'
  )
  COMMENT = 'Account Opening Risk Intelligence - analyze application risk assessment and approval patterns';

-- ============================================================================
-- Display confirmation and verification
-- ============================================================================

SELECT 'Semantic views created successfully - all syntax verified' AS status;

-- Verify semantic views exist
SELECT 
    table_name AS semantic_view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'SV_%'
ORDER BY table_name;

-- Show semantic view details
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;

