-- ============================================================================
-- Early Warning Intelligence Demo - Table Definitions
-- ============================================================================
-- Purpose: Create tables for banking, payments, fraud, and risk data
-- All syntax verified against Snowflake documentation
-- ============================================================================

USE DATABASE EARLY_WARNING_DEMO;
USE SCHEMA RAW;

-- ============================================================================
-- Financial Institutions (Early Warning Network Members)
-- ============================================================================

CREATE TABLE IF NOT EXISTS FINANCIAL_INSTITUTIONS (
    institution_id VARCHAR(20) PRIMARY KEY,
    institution_name VARCHAR(200) NOT NULL,
    institution_type VARCHAR(50) NOT NULL,  -- Bank, Credit Union, Payment Provider
    routing_number VARCHAR(9) UNIQUE,
    total_customers NUMBER(12,0),
    total_assets NUMBER(18,2),
    member_since DATE NOT NULL,
    network_tier VARCHAR(20),  -- Platinum, Gold, Silver, Bronze
    zelle_enabled BOOLEAN DEFAULT TRUE,
    paze_enabled BOOLEAN DEFAULT TRUE,
    city VARCHAR(100),
    state VARCHAR(2),
    country VARCHAR(3) DEFAULT 'USA',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Customers (Banking Customers)
-- ============================================================================

CREATE TABLE IF NOT EXISTS CUSTOMERS (
    customer_id VARCHAR(20) PRIMARY KEY,
    institution_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    ssn_hash VARCHAR(64),  -- Hashed SSN for privacy
    email VARCHAR(200),
    phone VARCHAR(20),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    customer_since DATE NOT NULL,
    customer_status VARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE, SUSPENDED, CLOSED
    risk_score NUMBER(5,2),  -- 0-100 risk score from Early Warning
    kyc_verified BOOLEAN DEFAULT FALSE,
    identity_verified BOOLEAN DEFAULT FALSE,
    zelle_enrolled BOOLEAN DEFAULT FALSE,
    zelle_enrollment_date DATE,
    paze_enrolled BOOLEAN DEFAULT FALSE,
    paze_enrollment_date DATE,
    fraud_alerts_count NUMBER(8,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Accounts (Bank Accounts)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ACCOUNTS (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    institution_id VARCHAR(20) NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,  -- CHECKING, SAVINGS, CREDIT_CARD, MONEY_MARKET
    account_status VARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE, FROZEN, CLOSED
    opening_date DATE NOT NULL,
    closing_date DATE,
    current_balance NUMBER(18,2) DEFAULT 0.00,
    available_balance NUMBER(18,2) DEFAULT 0.00,
    overdraft_limit NUMBER(18,2) DEFAULT 0.00,
    interest_rate NUMBER(5,4),
    credit_limit NUMBER(18,2),  -- For credit cards
    last_transaction_date DATE,
    monthly_fee NUMBER(8,2) DEFAULT 0.00,
    is_primary_account BOOLEAN DEFAULT FALSE,
    fraud_hold BOOLEAN DEFAULT FALSE,
    risk_level VARCHAR(20),  -- LOW, MEDIUM, HIGH, CRITICAL
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Transactions (All Account Transactions)
-- ============================================================================

CREATE TABLE IF NOT EXISTS TRANSACTIONS (
    transaction_id VARCHAR(30) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    institution_id VARCHAR(20) NOT NULL,
    transaction_date TIMESTAMP_NTZ NOT NULL,
    post_date DATE,
    transaction_type VARCHAR(50) NOT NULL,  -- DEBIT, CREDIT, TRANSFER, FEE, INTEREST, ATM, POS, ONLINE
    transaction_category VARCHAR(50),  -- GROCERIES, GAS, DINING, RETAIL, UTILITIES, etc.
    amount NUMBER(18,2) NOT NULL,
    balance_after NUMBER(18,2),
    merchant_name VARCHAR(200),
    merchant_category_code VARCHAR(10),
    location_city VARCHAR(100),
    location_state VARCHAR(2),
    location_country VARCHAR(3) DEFAULT 'USA',
    description VARCHAR(500),
    channel VARCHAR(30),  -- BRANCH, ATM, ONLINE, MOBILE, PHONE
    is_international BOOLEAN DEFAULT FALSE,
    is_recurring BOOLEAN DEFAULT FALSE,
    fraud_score NUMBER(5,2),  -- 0-100 fraud probability from Early Warning
    fraud_flagged BOOLEAN DEFAULT FALSE,
    reversed BOOLEAN DEFAULT FALSE,
    reversal_reason VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Zelle Payments (P2P Payment Network)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ZELLE_PAYMENTS (
    payment_id VARCHAR(30) PRIMARY KEY,
    sender_customer_id VARCHAR(20) NOT NULL,
    sender_account_id VARCHAR(20) NOT NULL,
    sender_institution_id VARCHAR(20) NOT NULL,
    receiver_customer_id VARCHAR(20),
    receiver_account_id VARCHAR(20),
    receiver_institution_id VARCHAR(20),
    receiver_identifier VARCHAR(200) NOT NULL,  -- Email or phone
    receiver_identifier_type VARCHAR(10) NOT NULL,  -- EMAIL, PHONE
    payment_date TIMESTAMP_NTZ NOT NULL,
    amount NUMBER(18,2) NOT NULL,
    status VARCHAR(30) NOT NULL,  -- PENDING, COMPLETED, FAILED, CANCELLED, DISPUTED
    completion_time TIMESTAMP_NTZ,
    failure_reason VARCHAR(200),
    payment_memo VARCHAR(500),
    request_to_pay BOOLEAN DEFAULT FALSE,
    split_payment BOOLEAN DEFAULT FALSE,
    is_business_payment BOOLEAN DEFAULT FALSE,
    risk_score NUMBER(5,2),  -- Early Warning risk assessment
    fraud_flagged BOOLEAN DEFAULT FALSE,
    fraud_review_status VARCHAR(30),  -- CLEARED, UNDER_REVIEW, BLOCKED
    reversal_requested BOOLEAN DEFAULT FALSE,
    reversal_approved BOOLEAN DEFAULT FALSE,
    network_fee NUMBER(8,4) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (sender_customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (sender_account_id) REFERENCES ACCOUNTS(account_id),
    FOREIGN KEY (sender_institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Paze Transactions (Online Checkout Solution)
-- ============================================================================

CREATE TABLE IF NOT EXISTS PAZE_TRANSACTIONS (
    paze_transaction_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    institution_id VARCHAR(20) NOT NULL,
    card_last_four VARCHAR(4),
    card_type VARCHAR(20),  -- DEBIT, CREDIT
    merchant_name VARCHAR(200) NOT NULL,
    merchant_id VARCHAR(50),
    merchant_category VARCHAR(50),
    transaction_date TIMESTAMP_NTZ NOT NULL,
    amount NUMBER(18,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(30) NOT NULL,  -- APPROVED, DECLINED, PENDING, REFUNDED
    decline_reason VARCHAR(200),
    device_type VARCHAR(30),  -- DESKTOP, MOBILE, TABLET
    browser_type VARCHAR(50),
    ip_address VARCHAR(45),
    location_city VARCHAR(100),
    location_state VARCHAR(2),
    location_country VARCHAR(3) DEFAULT 'USA',
    shipping_address_match BOOLEAN,
    cvv_match BOOLEAN,
    three_d_secure_used BOOLEAN DEFAULT FALSE,
    risk_score NUMBER(5,2),  -- Early Warning fraud score
    fraud_flagged BOOLEAN DEFAULT FALSE,
    chargeback BOOLEAN DEFAULT FALSE,
    chargeback_date DATE,
    chargeback_reason VARCHAR(200),
    merchant_fee NUMBER(8,4),
    network_fee NUMBER(8,4),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Fraud Alerts (Early Warning Fraud Detection)
-- ============================================================================

CREATE TABLE IF NOT EXISTS FRAUD_ALERTS (
    alert_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20),
    account_id VARCHAR(20),
    institution_id VARCHAR(20) NOT NULL,
    alert_date TIMESTAMP_NTZ NOT NULL,
    alert_type VARCHAR(50) NOT NULL,  -- IDENTITY_THEFT, ACCOUNT_TAKEOVER, CARD_FRAUD, P2P_FRAUD, etc.
    alert_severity VARCHAR(20) NOT NULL,  -- LOW, MEDIUM, HIGH, CRITICAL
    fraud_score NUMBER(5,2) NOT NULL,
    related_transaction_id VARCHAR(30),
    related_payment_id VARCHAR(30),
    related_paze_id VARCHAR(30),
    detection_method VARCHAR(100),  -- ML_MODEL, RULE_ENGINE, NETWORK_INTELLIGENCE, CUSTOMER_REPORT
    alert_description VARCHAR(1000),
    amount_at_risk NUMBER(18,2),
    status VARCHAR(30) DEFAULT 'OPEN',  -- OPEN, INVESTIGATING, CONFIRMED_FRAUD, FALSE_POSITIVE, RESOLVED
    assigned_to VARCHAR(100),
    investigation_notes VARCHAR(2000),
    resolution_date TIMESTAMP_NTZ,
    resolution_action VARCHAR(200),  -- ACCOUNT_FROZEN, TRANSACTION_REVERSED, CUSTOMER_NOTIFIED, NO_ACTION
    false_positive BOOLEAN,
    customer_notified BOOLEAN DEFAULT FALSE,
    law_enforcement_notified BOOLEAN DEFAULT FALSE,
    amount_recovered NUMBER(18,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Account Openings (New Account Applications with Risk Assessment)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ACCOUNT_OPENINGS (
    application_id VARCHAR(30) PRIMARY KEY,
    institution_id VARCHAR(20) NOT NULL,
    application_date TIMESTAMP_NTZ NOT NULL,
    applicant_first_name VARCHAR(100) NOT NULL,
    applicant_last_name VARCHAR(100) NOT NULL,
    applicant_dob DATE NOT NULL,
    applicant_ssn_hash VARCHAR(64),
    applicant_email VARCHAR(200),
    applicant_phone VARCHAR(20),
    applicant_address VARCHAR(200),
    applicant_city VARCHAR(100),
    applicant_state VARCHAR(2),
    applicant_zip VARCHAR(10),
    requested_account_type VARCHAR(30) NOT NULL,
    requested_credit_limit NUMBER(18,2),
    initial_deposit_amount NUMBER(18,2),
    application_channel VARCHAR(30),  -- BRANCH, ONLINE, MOBILE, PHONE
    device_fingerprint VARCHAR(100),
    ip_address VARCHAR(45),
    early_warning_risk_score NUMBER(5,2) NOT NULL,  -- Primary risk score
    identity_verification_score NUMBER(5,2),
    credit_score NUMBER(4,0),
    existing_accounts_count NUMBER(4,0) DEFAULT 0,
    fraud_database_hits NUMBER(4,0) DEFAULT 0,
    shared_database_hits NUMBER(4,0),  -- Early Warning National Shared Database
    velocity_check_score NUMBER(5,2),  -- Multiple applications detection
    synthetic_identity_score NUMBER(5,2),
    application_status VARCHAR(30) NOT NULL,  -- PENDING, APPROVED, DENIED, MANUAL_REVIEW
    denial_reason VARCHAR(200),
    manual_review_required BOOLEAN DEFAULT FALSE,
    review_notes VARCHAR(2000),
    decision_date TIMESTAMP_NTZ,
    decided_by VARCHAR(100),
    approved_customer_id VARCHAR(20),
    approved_account_id VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Note: Snowflake regular tables do NOT support CREATE INDEX
-- Indexes are only supported on Hybrid Tables
-- Query performance is optimized through:
-- - Automatic micro-partitioning
-- - Clustering keys (if needed)
-- - Search optimization service (if needed)
-- ============================================================================

-- Display confirmation
SELECT 'All tables created successfully' AS status,
       COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'RAW'
  AND TABLE_TYPE = 'BASE TABLE';

