-- ============================================================================
-- Early Warning Intelligence Demo - Sample Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for Early Warning network
-- Patterns: Fraud detection, payment flows, risk scores, seasonal trends
-- All syntax verified against Snowflake documentation
-- ============================================================================

USE DATABASE EARLY_WARNING_DEMO;
USE SCHEMA RAW;

-- ============================================================================
-- Clean up existing data (reverse dependency order)
-- ============================================================================

TRUNCATE TABLE IF EXISTS FRAUD_ALERTS;
TRUNCATE TABLE IF EXISTS ACCOUNT_OPENINGS;
TRUNCATE TABLE IF EXISTS PAZE_TRANSACTIONS;
TRUNCATE TABLE IF EXISTS ZELLE_PAYMENTS;
TRUNCATE TABLE IF EXISTS TRANSACTIONS;
TRUNCATE TABLE IF EXISTS ACCOUNTS;
TRUNCATE TABLE IF EXISTS CUSTOMERS;
TRUNCATE TABLE IF EXISTS FINANCIAL_INSTITUTIONS;

-- ============================================================================
-- Financial Institutions (50 institutions)
-- ============================================================================

INSERT INTO FINANCIAL_INSTITUTIONS
SELECT
    'FI' || LPAD(seq4(), 5, '0') AS institution_id,
    CASE (ABS(RANDOM()) % 50)
        WHEN 0 THEN 'Bank of America'
        WHEN 1 THEN 'JPMorgan Chase'
        WHEN 2 THEN 'Wells Fargo'
        WHEN 3 THEN 'Citibank'
        WHEN 4 THEN 'U.S. Bank'
        WHEN 5 THEN 'PNC Bank'
        WHEN 6 THEN 'Truist Bank'
        WHEN 7 THEN 'Capital One'
        WHEN 8 THEN 'TD Bank'
        WHEN 9 THEN 'Fifth Third Bank'
        WHEN 10 THEN 'KeyBank'
        WHEN 11 THEN 'Regions Bank'
        WHEN 12 THEN 'M&T Bank'
        WHEN 13 THEN 'Huntington Bank'
        WHEN 14 THEN 'Ally Bank'
        WHEN 15 THEN 'Navy Federal Credit Union'
        WHEN 16 THEN 'State Employees Credit Union'
        WHEN 17 THEN 'Pentagon Federal Credit Union'
        WHEN 18 THEN 'SchoolsFirst Federal Credit Union'
        WHEN 19 THEN 'Golden 1 Credit Union'
        WHEN 20 THEN 'Discover Bank'
        WHEN 21 THEN 'American Express National Bank'
        WHEN 22 THEN 'USAA Federal Savings Bank'
        WHEN 23 THEN 'Synchrony Bank'
        WHEN 24 THEN 'Marcus by Goldman Sachs'
        WHEN 25 THEN 'Citizens Bank'
        WHEN 26 THEN 'BMO Harris Bank'
        WHEN 27 THEN 'HSBC Bank USA'
        WHEN 28 THEN 'Santander Bank'
        WHEN 29 THEN 'First National Bank'
        WHEN 30 THEN 'Union Bank'
        WHEN 31 THEN 'Webster Bank'
        WHEN 32 THEN 'Frost Bank'
        WHEN 33 THEN 'UMB Bank'
        WHEN 34 THEN 'Comerica Bank'
        WHEN 35 THEN 'Synovus Bank'
        WHEN 36 THEN 'Zions Bank'
        WHEN 37 THEN 'Arvest Bank'
        WHEN 38 THEN 'Umpqua Bank'
        WHEN 39 THEN 'First Horizon Bank'
        WHEN 40 THEN 'Valley National Bank'
        WHEN 41 THEN 'BOK Financial'
        WHEN 42 THEN 'Prosperity Bank'
        WHEN 43 THEN 'Flagstar Bank'
        WHEN 44 THEN 'Pinnacle Bank'
        WHEN 45 THEN 'First Citizens Bank'
        WHEN 46 THEN 'Simmons Bank'
        WHEN 47 THEN 'BankUnited'
        WHEN 48 THEN 'Cadence Bank'
        ELSE 'Community Financial Bank'
    END AS institution_name,
    CASE WHEN seq4() <= 35 THEN 'Bank'
         WHEN seq4() <= 45 THEN 'Credit Union'
         ELSE 'Payment Provider'
    END AS institution_type,
    LPAD((100000000 + ABS(RANDOM()) % 900000000)::VARCHAR, 9, '0') AS routing_number,
    50000 + (ABS(RANDOM()) % 5000000) AS total_customers,
    (1000000000 + ABS(RANDOM()) % 99000000000)::NUMBER(18,2) AS total_assets,
    DATEADD(day, -1 * (ABS(RANDOM()) % 7300), CURRENT_DATE()) AS member_since,
    CASE (ABS(RANDOM()) % 4)
        WHEN 0 THEN 'Platinum'
        WHEN 1 THEN 'Gold'
        WHEN 2 THEN 'Silver'
        ELSE 'Bronze'
    END AS network_tier,
    TRUE AS zelle_enabled,
    (ABS(RANDOM()) % 10) < 8 AS paze_enabled,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'New York'
        WHEN 1 THEN 'Los Angeles'
        WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston'
        WHEN 4 THEN 'Phoenix'
        WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio'
        WHEN 7 THEN 'San Diego'
        WHEN 8 THEN 'Dallas'
        ELSE 'San Jose'
    END AS city,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'NY'
        WHEN 1 THEN 'CA'
        WHEN 2 THEN 'IL'
        WHEN 3 THEN 'TX'
        WHEN 4 THEN 'AZ'
        WHEN 5 THEN 'PA'
        WHEN 6 THEN 'TX'
        WHEN 7 THEN 'CA'
        WHEN 8 THEN 'TX'
        ELSE 'CA'
    END AS state,
    'USA' AS country,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- Customers (100,000 customers)
-- ============================================================================

INSERT INTO CUSTOMERS
SELECT
    'CUST' || LPAD(seq4(), 10, '0') AS customer_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'James' WHEN 1 THEN 'Mary' WHEN 2 THEN 'John' WHEN 3 THEN 'Patricia'
        WHEN 4 THEN 'Robert' WHEN 5 THEN 'Jennifer' WHEN 6 THEN 'Michael' WHEN 7 THEN 'Linda'
        WHEN 8 THEN 'William' WHEN 9 THEN 'Barbara' WHEN 10 THEN 'David' WHEN 11 THEN 'Elizabeth'
        WHEN 12 THEN 'Richard' WHEN 13 THEN 'Susan' WHEN 14 THEN 'Joseph' WHEN 15 THEN 'Jessica'
        WHEN 16 THEN 'Thomas' WHEN 17 THEN 'Sarah' WHEN 18 THEN 'Charles' ELSE 'Karen'
    END AS first_name,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
        WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
        WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
        WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
        WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' ELSE 'Martin'
    END AS last_name,
    DATEADD(day, -1 * (6570 + (ABS(RANDOM()) % 21900)), CURRENT_DATE()) AS date_of_birth,
    SHA2(LPAD((ABS(RANDOM()) % 900000000)::VARCHAR, 9, '0')) AS ssn_hash,
    LOWER(
        CASE (ABS(RANDOM()) % 20)
            WHEN 0 THEN 'James' WHEN 1 THEN 'Mary' WHEN 2 THEN 'John' WHEN 3 THEN 'Patricia'
            WHEN 4 THEN 'Robert' WHEN 5 THEN 'Jennifer' WHEN 6 THEN 'Michael' WHEN 7 THEN 'Linda'
            WHEN 8 THEN 'William' WHEN 9 THEN 'Barbara' WHEN 10 THEN 'David' WHEN 11 THEN 'Elizabeth'
            WHEN 12 THEN 'Richard' WHEN 13 THEN 'Susan' WHEN 14 THEN 'Joseph' WHEN 15 THEN 'Jessica'
            WHEN 16 THEN 'Thomas' WHEN 17 THEN 'Sarah' WHEN 18 THEN 'Charles' ELSE 'Karen'
        END || '.' || 
        CASE (ABS(RANDOM()) % 20)
            WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
            WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
            WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
            WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
            WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' ELSE 'Martin'
        END || (ABS(RANDOM()) % 1000)::VARCHAR || '@' ||
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'gmail.com'
            WHEN 1 THEN 'yahoo.com'
            WHEN 2 THEN 'outlook.com'
            WHEN 3 THEN 'hotmail.com'
            ELSE 'icloud.com'
        END) AS email,
    '+1' || LPAD((ABS(RANDOM()) % 9000000000 + 1000000000)::VARCHAR, 10, '0') AS phone,
    (100 + (ABS(RANDOM()) % 9900))::VARCHAR || ' ' ||
        CASE (ABS(RANDOM()) % 10)
            WHEN 0 THEN 'Main St' WHEN 1 THEN 'Oak Ave' WHEN 2 THEN 'Maple Dr'
            WHEN 3 THEN 'Cedar Ln' WHEN 4 THEN 'Pine Rd' WHEN 5 THEN 'Elm St'
            WHEN 6 THEN 'Washington Blvd' WHEN 7 THEN 'Park Ave' WHEN 8 THEN 'Lake Dr'
            ELSE 'Hill Rd'
        END AS address_line1,
    CASE WHEN (ABS(RANDOM()) % 10) < 3 THEN 'Apt ' || (ABS(RANDOM()) % 500 + 1)::VARCHAR ELSE NULL END AS address_line2,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas'
        WHEN 9 THEN 'San Jose' WHEN 10 THEN 'Austin' WHEN 11 THEN 'Jacksonville'
        WHEN 12 THEN 'Fort Worth' WHEN 13 THEN 'Columbus' WHEN 14 THEN 'Charlotte'
        WHEN 15 THEN 'Indianapolis' WHEN 16 THEN 'Seattle' WHEN 17 THEN 'Denver'
        WHEN 18 THEN 'Boston' ELSE 'Nashville'
    END AS city,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL' WHEN 3 THEN 'TX'
        WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA' WHEN 6 THEN 'TX' WHEN 7 THEN 'CA'
        WHEN 8 THEN 'TX' WHEN 9 THEN 'CA' WHEN 10 THEN 'TX' WHEN 11 THEN 'FL'
        WHEN 12 THEN 'TX' WHEN 13 THEN 'OH' WHEN 14 THEN 'NC' WHEN 15 THEN 'IN'
        WHEN 16 THEN 'WA' WHEN 17 THEN 'CO' WHEN 18 THEN 'MA' ELSE 'TN'
    END AS state,
    LPAD((10000 + (ABS(RANDOM()) % 90000))::VARCHAR, 5, '0') AS zip_code,
    DATEADD(day, -1 * (ABS(RANDOM()) % 3650), CURRENT_DATE()) AS customer_since,
    CASE 
        WHEN (ABS(RANDOM()) % 100) < 95 THEN 'ACTIVE'
        WHEN (ABS(RANDOM()) % 100) < 98 THEN 'SUSPENDED'
        ELSE 'CLOSED'
    END AS customer_status,
    (ABS(RANDOM()) % 10000) / 100.0 AS risk_score,
    TRUE AS kyc_verified,
    (ABS(RANDOM()) % 10) < 9 AS identity_verified,
    (ABS(RANDOM()) % 10) < 7 AS zelle_enrolled,
    CASE WHEN (ABS(RANDOM()) % 10) < 7 
         THEN DATEADD(day, -1 * (ABS(RANDOM()) % 1095), CURRENT_DATE()) 
         ELSE NULL END AS zelle_enrollment_date,
    (ABS(RANDOM()) % 10) < 5 AS paze_enrolled,
    CASE WHEN (ABS(RANDOM()) % 10) < 5 
         THEN DATEADD(day, -1 * (ABS(RANDOM()) % 730), CURRENT_DATE()) 
         ELSE NULL END AS paze_enrollment_date,
    CASE WHEN (ABS(RANDOM()) % 100) < 5 THEN (ABS(RANDOM()) % 10) ELSE 0 END AS fraud_alerts_count,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- ============================================================================
-- Accounts (150,000 accounts - 1.5 accounts per customer on average)
-- ============================================================================

INSERT INTO ACCOUNTS
SELECT
    'ACCT' || LPAD(seq4(), 10, '0') AS account_id,
    'CUST' || LPAD((seq4() * 2 / 3) + (ABS(RANDOM()) % 10000), 10, '0') AS customer_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    LPAD((ABS(RANDOM()) % 9000000000000000 + 1000000000000000)::VARCHAR, 16, '0') AS account_number,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'CHECKING'
        WHEN 1 THEN 'CHECKING'
        WHEN 2 THEN 'CHECKING'
        WHEN 3 THEN 'SAVINGS'
        WHEN 4 THEN 'SAVINGS'
        WHEN 5 THEN 'CREDIT_CARD'
        WHEN 6 THEN 'CREDIT_CARD'
        WHEN 7 THEN 'MONEY_MARKET'
        WHEN 8 THEN 'MONEY_MARKET'
        ELSE 'CHECKING'
    END AS account_type,
    CASE 
        WHEN (ABS(RANDOM()) % 100) < 95 THEN 'ACTIVE'
        WHEN (ABS(RANDOM()) % 100) < 98 THEN 'FROZEN'
        ELSE 'CLOSED'
    END AS account_status,
    DATEADD(day, -1 * (ABS(RANDOM()) % 3650), CURRENT_DATE()) AS opening_date,
    CASE WHEN (ABS(RANDOM()) % 100) < 5 
         THEN DATEADD(day, -1 * (ABS(RANDOM()) % 365), CURRENT_DATE()) 
         ELSE NULL END AS closing_date,
    (ABS(RANDOM()) % 10000000) / 100.0 AS current_balance,
    (ABS(RANDOM()) % 10000000) / 100.0 AS available_balance,
    CASE WHEN account_type = 'CHECKING' THEN (ABS(RANDOM()) % 200000) / 100.0 ELSE 0 END AS overdraft_limit,
    CASE 
        WHEN account_type IN ('SAVINGS', 'MONEY_MARKET') THEN (ABS(RANDOM()) % 500) / 10000.0
        ELSE NULL 
    END AS interest_rate,
    CASE WHEN account_type = 'CREDIT_CARD' THEN (500 + (ABS(RANDOM()) % 49500)) ELSE NULL END AS credit_limit,
    DATEADD(day, -1 * (ABS(RANDOM()) % 30), CURRENT_DATE()) AS last_transaction_date,
    CASE 
        WHEN account_type = 'CHECKING' THEN (ABS(RANDOM()) % 1500) / 100.0
        ELSE 0 
    END AS monthly_fee,
    (seq4() % 2 = 1) AS is_primary_account,
    (ABS(RANDOM()) % 100) < 2 AS fraud_hold,
    CASE (ABS(RANDOM()) % 100)
        WHEN 0 THEN 'CRITICAL'
        WHEN 1 THEN 'HIGH'
        WHEN 2 THEN 'HIGH'
        WHEN 3 THEN 'MEDIUM'
        WHEN 4 THEN 'MEDIUM'
        WHEN 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 150000));

-- ============================================================================
-- Transactions (2 million transactions over 2 years)
-- ============================================================================

INSERT INTO TRANSACTIONS
SELECT
    'TXN' || LPAD(seq4(), 15, '0') AS transaction_id,
    'ACCT' || LPAD((ABS(RANDOM()) % 150000) + 1, 10, '0') AS account_id,
    'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0') AS customer_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    DATEADD(minute, -1 * (ABS(RANDOM()) % 1051200), CURRENT_TIMESTAMP()) AS transaction_date,
    DATE(transaction_date) AS post_date,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'DEBIT'
        WHEN 1 THEN 'DEBIT'
        WHEN 2 THEN 'DEBIT'
        WHEN 3 THEN 'DEBIT'
        WHEN 4 THEN 'DEBIT'
        WHEN 5 THEN 'DEBIT'
        WHEN 6 THEN 'CREDIT'
        WHEN 7 THEN 'CREDIT'
        WHEN 8 THEN 'CREDIT'
        WHEN 9 THEN 'TRANSFER'
        WHEN 10 THEN 'TRANSFER'
        WHEN 11 THEN 'POS'
        WHEN 12 THEN 'POS'
        WHEN 13 THEN 'POS'
        WHEN 14 THEN 'ATM'
        WHEN 15 THEN 'ATM'
        WHEN 16 THEN 'ONLINE'
        WHEN 17 THEN 'ONLINE'
        WHEN 18 THEN 'FEE'
        ELSE 'INTEREST'
    END AS transaction_type,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'GROCERIES' WHEN 1 THEN 'GAS' WHEN 2 THEN 'DINING'
        WHEN 3 THEN 'RETAIL' WHEN 4 THEN 'UTILITIES' WHEN 5 THEN 'HEALTHCARE'
        WHEN 6 THEN 'ENTERTAINMENT' WHEN 7 THEN 'TRAVEL' WHEN 8 THEN 'INSURANCE'
        WHEN 9 THEN 'RENT' WHEN 10 THEN 'MORTGAGE' WHEN 11 THEN 'AUTO'
        WHEN 12 THEN 'EDUCATION' WHEN 13 THEN 'SHOPPING' WHEN 14 THEN 'SUBSCRIPTIONS'
        WHEN 15 THEN 'TRANSFER' WHEN 16 THEN 'CASH' WHEN 17 THEN 'BILLS'
        WHEN 18 THEN 'SERVICES' ELSE 'OTHER'
    END AS transaction_category,
    CASE 
        WHEN transaction_type IN ('DEBIT', 'FEE', 'ATM') THEN -1 * (ABS(RANDOM()) % 100000) / 100.0
        ELSE (ABS(RANDOM()) % 100000) / 100.0
    END AS amount,
    (ABS(RANDOM()) % 10000000) / 100.0 AS balance_after,
    CASE (ABS(RANDOM()) % 30)
        WHEN 0 THEN 'Walmart' WHEN 1 THEN 'Amazon' WHEN 2 THEN 'Target'
        WHEN 3 THEN 'Costco' WHEN 4 THEN 'Home Depot' WHEN 5 THEN 'CVS'
        WHEN 6 THEN 'Walgreens' WHEN 7 THEN 'Starbucks' WHEN 8 THEN 'McDonalds'
        WHEN 9 THEN 'Shell' WHEN 10 THEN 'Chevron' WHEN 11 THEN 'Exxon'
        WHEN 12 THEN 'Whole Foods' WHEN 13 THEN 'Safeway' WHEN 14 THEN 'Kroger'
        WHEN 15 THEN 'Apple' WHEN 16 THEN 'Best Buy' WHEN 17 THEN 'Lowes'
        WHEN 18 THEN 'Netflix' WHEN 19 THEN 'Spotify' WHEN 20 THEN 'Uber'
        WHEN 21 THEN 'Lyft' WHEN 22 THEN 'DoorDash' WHEN 23 THEN 'Grubhub'
        WHEN 24 THEN 'PayPal' WHEN 25 THEN 'Venmo' WHEN 26 THEN 'Square'
        WHEN 27 THEN 'Delta Airlines' WHEN 28 THEN 'Marriott' ELSE 'Local Merchant'
    END AS merchant_name,
    LPAD((ABS(RANDOM()) % 10000)::VARCHAR, 4, '0') AS merchant_category_code,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas'
        WHEN 9 THEN 'San Jose' WHEN 10 THEN 'Austin' WHEN 11 THEN 'Jacksonville'
        WHEN 12 THEN 'Fort Worth' WHEN 13 THEN 'Columbus' WHEN 14 THEN 'Charlotte'
        WHEN 15 THEN 'Indianapolis' WHEN 16 THEN 'Seattle' WHEN 17 THEN 'Denver'
        WHEN 18 THEN 'Boston' ELSE 'Nashville'
    END AS location_city,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL' WHEN 3 THEN 'TX'
        WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA' WHEN 6 THEN 'TX' WHEN 7 THEN 'CA'
        WHEN 8 THEN 'TX' WHEN 9 THEN 'CA' WHEN 10 THEN 'TX' WHEN 11 THEN 'FL'
        WHEN 12 THEN 'TX' WHEN 13 THEN 'OH' WHEN 14 THEN 'NC' WHEN 15 THEN 'IN'
        WHEN 16 THEN 'WA' WHEN 17 THEN 'CO' WHEN 18 THEN 'MA' ELSE 'TN'
    END AS location_state,
    'USA' AS location_country,
    merchant_name || ' - ' || transaction_category AS description,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'BRANCH' WHEN 1 THEN 'ATM' WHEN 2 THEN 'ONLINE'
        WHEN 3 THEN 'MOBILE' ELSE 'PHONE'
    END AS channel,
    (ABS(RANDOM()) % 100) < 5 AS is_international,
    (ABS(RANDOM()) % 100) < 15 AS is_recurring,
    (ABS(RANDOM()) % 10000) / 100.0 AS fraud_score,
    (ABS(RANDOM()) % 100) < 3 AS fraud_flagged,
    (ABS(RANDOM()) % 1000) < 5 AS reversed,
    CASE WHEN reversed THEN 
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'Fraud' WHEN 1 THEN 'Duplicate' WHEN 2 THEN 'Customer Dispute'
            WHEN 3 THEN 'Merchant Error' ELSE 'System Error'
        END
    ELSE NULL END AS reversal_reason,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 2000000));

-- ============================================================================
-- Zelle Payments (500,000 payments)
-- ============================================================================

INSERT INTO ZELLE_PAYMENTS
SELECT
    'ZELLE' || LPAD(seq4(), 12, '0') AS payment_id,
    'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0') AS sender_customer_id,
    'ACCT' || LPAD((ABS(RANDOM()) % 150000) + 1, 10, '0') AS sender_account_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS sender_institution_id,
    'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0') AS receiver_customer_id,
    'ACCT' || LPAD((ABS(RANDOM()) % 150000) + 1, 10, '0') AS receiver_account_id,
    rc.institution_id AS receiver_institution_id,
    CASE (ABS(RANDOM()) % 2)
        WHEN 0 THEN 'user' || (ABS(RANDOM()) % 100000)::VARCHAR || '@' || 
                    CASE (ABS(RANDOM()) % 3) WHEN 0 THEN 'gmail.com' WHEN 1 THEN 'yahoo.com' ELSE 'outlook.com' END
        ELSE '+1' || LPAD((ABS(RANDOM()) % 9000000000 + 1000000000)::VARCHAR, 10, '0')
    END AS receiver_identifier,
    CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'EMAIL' ELSE 'PHONE'     END AS receiver_identifier_type,
    DATEADD(minute, -1 * (ABS(RANDOM()) % 1051200), CURRENT_TIMESTAMP()) AS payment_date,
    (1 + (ABS(RANDOM()) % 500000)) / 100.0 AS amount,
    CASE (ABS(RANDOM()) % 100)
        WHEN 0 THEN 'FAILED'
        WHEN 1 THEN 'CANCELLED'
        WHEN 2 THEN 'DISPUTED'
        WHEN 3 THEN 'PENDING'
        ELSE 'COMPLETED'
    END AS status,
    CASE WHEN status = 'COMPLETED' THEN DATEADD(minute, (ABS(RANDOM()) % 10), payment_date) ELSE NULL END AS completion_time,
    CASE WHEN status = 'FAILED' THEN
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'Insufficient Funds'
            WHEN 1 THEN 'Invalid Account'
            WHEN 2 THEN 'Daily Limit Exceeded'
            WHEN 3 THEN 'Fraud Hold'
            ELSE 'Technical Error'
        END
    ELSE NULL END AS failure_reason,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'Rent' WHEN 1 THEN 'Utilities' WHEN 2 THEN 'Dinner'
        WHEN 3 THEN 'Gift' WHEN 4 THEN 'Loan repayment' WHEN 5 THEN 'Shared expense'
        WHEN 6 THEN 'Birthday' WHEN 7 THEN 'Thank you' WHEN 8 THEN 'Payment'
        ELSE NULL
    END AS payment_memo,
    (ABS(RANDOM()) % 100) < 10 AS request_to_pay,
    (ABS(RANDOM()) % 100) < 5 AS split_payment,
    (ABS(RANDOM()) % 100) < 15 AS is_business_payment,
    (ABS(RANDOM()) % 10000) / 100.0 AS risk_score,
    (ABS(RANDOM()) % 100) < 4 AS fraud_flagged,
    CASE WHEN fraud_flagged THEN
        CASE (ABS(RANDOM()) % 3)
            WHEN 0 THEN 'CLEARED'
            WHEN 1 THEN 'UNDER_REVIEW'
            ELSE 'BLOCKED'
        END
    ELSE NULL END AS fraud_review_status,
    (ABS(RANDOM()) % 1000) < 2 AS reversal_requested,
    CASE WHEN reversal_requested THEN (ABS(RANDOM()) % 2) = 1 ELSE FALSE END AS reversal_approved,
    0.00 AS network_fee,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 500000)) g
LEFT JOIN CUSTOMERS sc ON sc.customer_id = 'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0')
LEFT JOIN CUSTOMERS rc ON rc.customer_id = 'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0');

-- ============================================================================
-- Paze Transactions (300,000 transactions)
-- ============================================================================

INSERT INTO PAZE_TRANSACTIONS
SELECT
    'PAZE' || LPAD(seq4(), 12, '0') AS paze_transaction_id,
    'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0') AS customer_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    LPAD((ABS(RANDOM()) % 10000)::VARCHAR, 4, '0') AS card_last_four,
    CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'DEBIT' ELSE 'CREDIT' END AS card_type,
    CASE (ABS(RANDOM()) % 50)
        WHEN 0 THEN 'Amazon.com' WHEN 1 THEN 'eBay' WHEN 2 THEN 'Walmart.com'
        WHEN 3 THEN 'Target.com' WHEN 4 THEN 'BestBuy.com' WHEN 5 THEN 'Apple.com'
        WHEN 6 THEN 'Nike.com' WHEN 7 THEN 'Adidas.com' WHEN 8 THEN 'Macys.com'
        WHEN 9 THEN 'Nordstrom.com' WHEN 10 THEN 'HomeDepot.com' WHEN 11 THEN 'Lowes.com'
        WHEN 12 THEN 'Etsy.com' WHEN 13 THEN 'Wayfair.com' WHEN 14 THEN 'Overstock.com'
        WHEN 15 THEN 'Zappos.com' WHEN 16 THEN 'Sephora.com' WHEN 17 THEN 'Ulta.com'
        WHEN 18 THEN 'PetSmart.com' WHEN 19 THEN 'Chewy.com' WHEN 20 THEN 'GrubHub.com'
        WHEN 21 THEN 'DoorDash.com' WHEN 22 THEN 'UberEats.com' WHEN 23 THEN 'Instacart.com'
        WHEN 24 THEN 'HelloFresh.com' WHEN 25 THEN 'BlueApron.com' WHEN 26 THEN 'Netflix.com'
        WHEN 27 THEN 'Hulu.com' WHEN 28 THEN 'Disney+' WHEN 29 THEN 'Spotify.com'
        WHEN 30 THEN 'AirBnB.com' WHEN 31 THEN 'Booking.com' WHEN 32 THEN 'Expedia.com'
        WHEN 33 THEN 'Hotels.com' WHEN 34 THEN 'Kayak.com' WHEN 35 THEN 'Southwest.com'
        WHEN 36 THEN 'Delta.com' WHEN 37 THEN 'United.com' WHEN 38 THEN 'Kohls.com'
        WHEN 39 THEN 'JCPenney.com' WHEN 40 THEN 'Gap.com' WHEN 41 THEN 'OldNavy.com'
        WHEN 42 THEN 'BananaRepublic.com' WHEN 43 THEN 'Athleta.com' WHEN 44 THEN 'Lululemon.com'
        WHEN 45 THEN 'Costco.com' WHEN 46 THEN 'SamsClub.com' WHEN 47 THEN 'CVS.com'
        WHEN 48 THEN 'Walgreens.com' ELSE 'OnlineRetailer.com'
    END AS merchant_name,
    'MERCH' || LPAD((ABS(RANDOM()) % 10000)::VARCHAR, 6, '0') AS merchant_id,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'RETAIL' WHEN 1 THEN 'FOOD_DELIVERY' WHEN 2 THEN 'TRAVEL'
        WHEN 3 THEN 'ENTERTAINMENT' WHEN 4 THEN 'GROCERY' WHEN 5 THEN 'FASHION'
        WHEN 6 THEN 'HOME_GOODS' WHEN 7 THEN 'ELECTRONICS' WHEN 8 THEN 'SUBSCRIPTIONS'
        ELSE 'SERVICES'
    END AS merchant_category,
    DATEADD(minute, -1 * (ABS(RANDOM()) % 1051200), CURRENT_TIMESTAMP()) AS transaction_date,
    (1 + (ABS(RANDOM()) % 100000)) / 100.0 AS amount,
    'USD' AS currency,
    CASE (ABS(RANDOM()) % 100)
        WHEN 0 THEN 'DECLINED'
        WHEN 1 THEN 'DECLINED'
        WHEN 2 THEN 'DECLINED'
        WHEN 3 THEN 'PENDING'
        WHEN 4 THEN 'REFUNDED'
        ELSE 'APPROVED'
    END AS status,
    CASE WHEN status = 'DECLINED' THEN
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'Insufficient Funds'
            WHEN 1 THEN 'Suspected Fraud'
            WHEN 2 THEN 'Card Limit Exceeded'
            WHEN 3 THEN 'Expired Card'
            ELSE 'Technical Error'
        END
    ELSE NULL END AS decline_reason,
    CASE (ABS(RANDOM()) % 3)
        WHEN 0 THEN 'DESKTOP' WHEN 1 THEN 'MOBILE' ELSE 'TABLET'
    END AS device_type,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'Chrome' WHEN 1 THEN 'Safari' WHEN 2 THEN 'Firefox'
        WHEN 3 THEN 'Edge' ELSE 'Mobile App'
    END AS browser_type,
    (ABS(RANDOM()) % 256)::VARCHAR || '.' || (ABS(RANDOM()) % 256)::VARCHAR || '.' || 
    (ABS(RANDOM()) % 256)::VARCHAR || '.' || (ABS(RANDOM()) % 256)::VARCHAR AS ip_address,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas'
        WHEN 9 THEN 'San Jose' WHEN 10 THEN 'Austin' WHEN 11 THEN 'Jacksonville'
        WHEN 12 THEN 'Fort Worth' WHEN 13 THEN 'Columbus' WHEN 14 THEN 'Charlotte'
        WHEN 15 THEN 'Indianapolis' WHEN 16 THEN 'Seattle' WHEN 17 THEN 'Denver'
        WHEN 18 THEN 'Boston' ELSE 'Nashville'
    END AS location_city,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL' WHEN 3 THEN 'TX'
        WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA' WHEN 6 THEN 'TX' WHEN 7 THEN 'CA'
        WHEN 8 THEN 'TX' WHEN 9 THEN 'CA' WHEN 10 THEN 'TX' WHEN 11 THEN 'FL'
        WHEN 12 THEN 'TX' WHEN 13 THEN 'OH' WHEN 14 THEN 'NC' WHEN 15 THEN 'IN'
        WHEN 16 THEN 'WA' WHEN 17 THEN 'CO' WHEN 18 THEN 'MA' ELSE 'TN'
    END AS location_state,
    'USA' AS location_country,
    (ABS(RANDOM()) % 10) < 8 AS shipping_address_match,
    (ABS(RANDOM()) % 10) < 9 AS cvv_match,
    (ABS(RANDOM()) % 10) < 6 AS three_d_secure_used,
    (ABS(RANDOM()) % 10000) / 100.0 AS risk_score,
    (ABS(RANDOM()) % 100) < 4 AS fraud_flagged,
    (ABS(RANDOM()) % 1000) < 5 AS chargeback,
    CASE WHEN chargeback THEN DATEADD(day, (ABS(RANDOM()) % 90), DATE(transaction_date)) ELSE NULL END AS chargeback_date,
    CASE WHEN chargeback THEN
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'Fraud' WHEN 1 THEN 'Not as Described' WHEN 2 THEN 'Not Received'
            WHEN 3 THEN 'Duplicate Charge' ELSE 'Unauthorized'
        END
    ELSE NULL END AS chargeback_reason,
    (amount * (ABS(RANDOM()) % 300) / 10000.0) AS merchant_fee,
    (amount * 0.0015) AS network_fee,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 300000));

-- ============================================================================
-- Fraud Alerts (50,000 alerts)
-- ============================================================================

INSERT INTO FRAUD_ALERTS
SELECT
    'ALERT' || LPAD(seq4(), 12, '0') AS alert_id,
    CASE WHEN (ABS(RANDOM()) % 10) < 9 THEN 'CUST' || LPAD((ABS(RANDOM()) % 100000) + 1, 10, '0') ELSE NULL END AS customer_id,
    CASE WHEN customer_id IS NOT NULL THEN 'ACCT' || LPAD((ABS(RANDOM()) % 150000) + 1, 10, '0') ELSE NULL END AS account_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    DATEADD(minute, -1 * (ABS(RANDOM()) % 1051200), CURRENT_TIMESTAMP()) AS alert_date,
    CASE (ABS(RANDOM()) % 15)
        WHEN 0 THEN 'IDENTITY_THEFT'
        WHEN 1 THEN 'ACCOUNT_TAKEOVER'
        WHEN 2 THEN 'CARD_FRAUD'
        WHEN 3 THEN 'P2P_FRAUD'
        WHEN 4 THEN 'SYNTHETIC_IDENTITY'
        WHEN 5 THEN 'WIRE_FRAUD'
        WHEN 6 THEN 'ACH_FRAUD'
        WHEN 7 THEN 'CHECK_FRAUD'
        WHEN 8 THEN 'ATM_FRAUD'
        WHEN 9 THEN 'PHISHING'
        WHEN 10 THEN 'MALWARE'
        WHEN 11 THEN 'SOCIAL_ENGINEERING'
        WHEN 12 THEN 'UNAUTHORIZED_ACCESS'
        WHEN 13 THEN 'SUSPICIOUS_ACTIVITY'
        ELSE 'OTHER_FRAUD'
    END AS alert_type,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'CRITICAL'
        WHEN 1 THEN 'CRITICAL'
        WHEN 2 THEN 'HIGH'
        WHEN 3 THEN 'HIGH'
        WHEN 4 THEN 'HIGH'
        WHEN 5 THEN 'MEDIUM'
        WHEN 6 THEN 'MEDIUM'
        WHEN 7 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS alert_severity,
    (50 + (ABS(RANDOM()) % 5000)) / 100.0 AS fraud_score,
    CASE WHEN (ABS(RANDOM()) % 10) < 3 THEN 'TXN' || LPAD((ABS(RANDOM()) % 2000000) + 1, 15, '0') ELSE NULL END AS related_transaction_id,
    CASE WHEN (ABS(RANDOM()) % 10) < 2 THEN 'ZELLE' || LPAD((ABS(RANDOM()) % 500000) + 1, 12, '0') ELSE NULL END AS related_payment_id,
    CASE WHEN (ABS(RANDOM()) % 10) < 2 THEN 'PAZE' || LPAD((ABS(RANDOM()) % 300000) + 1, 12, '0') ELSE NULL END AS related_paze_id,
    CASE (ABS(RANDOM()) % 4)
        WHEN 0 THEN 'ML_MODEL'
        WHEN 1 THEN 'RULE_ENGINE'
        WHEN 2 THEN 'NETWORK_INTELLIGENCE'
        ELSE 'CUSTOMER_REPORT'
    END AS detection_method,
    alert_type || ' detected via ' || detection_method || ' with score ' || fraud_score::VARCHAR AS alert_description,
    (ABS(RANDOM()) % 10000000) / 100.0 AS amount_at_risk,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'RESOLVED'
        WHEN 1 THEN 'RESOLVED'
        WHEN 2 THEN 'CONFIRMED_FRAUD'
        WHEN 3 THEN 'FALSE_POSITIVE'
        WHEN 4 THEN 'INVESTIGATING'
        ELSE 'OPEN'
    END AS status,
    'Fraud Analyst ' || (ABS(RANDOM()) % 20 + 1)::VARCHAR AS assigned_to,
    CASE WHEN status IN ('RESOLVED', 'CONFIRMED_FRAUD', 'FALSE_POSITIVE') THEN
        'Investigation completed. ' ||
        CASE (ABS(RANDOM()) % 3)
            WHEN 0 THEN 'Confirmed fraud pattern.'
            WHEN 1 THEN 'Determined to be false positive.'
            ELSE 'Customer verified activity.'
        END
    ELSE 'Under investigation.' END AS investigation_notes,
    CASE WHEN status IN ('RESOLVED', 'CONFIRMED_FRAUD', 'FALSE_POSITIVE') THEN 
        DATEADD(hour, (ABS(RANDOM()) % 168), alert_date) 
    ELSE NULL END AS resolution_date,
    CASE WHEN status IN ('RESOLVED', 'CONFIRMED_FRAUD') THEN
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'ACCOUNT_FROZEN'
            WHEN 1 THEN 'TRANSACTION_REVERSED'
            WHEN 2 THEN 'CUSTOMER_NOTIFIED'
            WHEN 3 THEN 'CARD_BLOCKED'
            ELSE 'NO_ACTION'
        END
    ELSE NULL END AS resolution_action,
    status = 'FALSE_POSITIVE' AS false_positive,
    (ABS(RANDOM()) % 10) < 8 AS customer_notified,
    (ABS(RANDOM()) % 100) < 10 AS law_enforcement_notified,
    CASE WHEN status = 'CONFIRMED_FRAUD' THEN (amount_at_risk * (ABS(RANDOM()) % 100) / 100.0) ELSE 0.00 END AS amount_recovered,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- ============================================================================
-- Account Openings (75,000 applications)
-- ============================================================================

INSERT INTO ACCOUNT_OPENINGS
SELECT
    'APP' || LPAD(seq4(), 12, '0') AS application_id,
    'FI' || LPAD((ABS(RANDOM()) % 50) + 1, 5, '0') AS institution_id,
    DATEADD(minute, -1 * (ABS(RANDOM()) % 525600), CURRENT_TIMESTAMP()) AS application_date,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'James' WHEN 1 THEN 'Mary' WHEN 2 THEN 'John' WHEN 3 THEN 'Patricia'
        WHEN 4 THEN 'Robert' WHEN 5 THEN 'Jennifer' WHEN 6 THEN 'Michael' WHEN 7 THEN 'Linda'
        WHEN 8 THEN 'William' WHEN 9 THEN 'Barbara' WHEN 10 THEN 'David' WHEN 11 THEN 'Elizabeth'
        WHEN 12 THEN 'Richard' WHEN 13 THEN 'Susan' WHEN 14 THEN 'Joseph' WHEN 15 THEN 'Jessica'
        WHEN 16 THEN 'Thomas' WHEN 17 THEN 'Sarah' WHEN 18 THEN 'Charles' ELSE 'Karen'
    END AS applicant_first_name,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
        WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
        WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
        WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
        WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' ELSE 'Martin'
    END AS applicant_last_name,
    DATEADD(day, -1 * (6570 + (ABS(RANDOM()) % 21900)), CURRENT_DATE()) AS applicant_dob,
    SHA2(LPAD((ABS(RANDOM()) % 900000000)::VARCHAR, 9, '0')) AS applicant_ssn_hash,
    LOWER(
        CASE (ABS(RANDOM()) % 20)
            WHEN 0 THEN 'James' WHEN 1 THEN 'Mary' WHEN 2 THEN 'John' WHEN 3 THEN 'Patricia'
            WHEN 4 THEN 'Robert' WHEN 5 THEN 'Jennifer' WHEN 6 THEN 'Michael' WHEN 7 THEN 'Linda'
            WHEN 8 THEN 'William' WHEN 9 THEN 'Barbara' WHEN 10 THEN 'David' WHEN 11 THEN 'Elizabeth'
            WHEN 12 THEN 'Richard' WHEN 13 THEN 'Susan' WHEN 14 THEN 'Joseph' WHEN 15 THEN 'Jessica'
            WHEN 16 THEN 'Thomas' WHEN 17 THEN 'Sarah' WHEN 18 THEN 'Charles' ELSE 'Karen'
        END || '.' || 
        CASE (ABS(RANDOM()) % 20)
            WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
            WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
            WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
            WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
            WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' ELSE 'Martin'
        END || (ABS(RANDOM()) % 10000)::VARCHAR || '@' ||
        CASE (ABS(RANDOM()) % 5)
            WHEN 0 THEN 'gmail.com' WHEN 1 THEN 'yahoo.com' WHEN 2 THEN 'outlook.com'
            WHEN 3 THEN 'hotmail.com' ELSE 'icloud.com'
        END) AS applicant_email,
    '+1' || LPAD((ABS(RANDOM()) % 9000000000 + 1000000000)::VARCHAR, 10, '0') AS applicant_phone,
    (100 + (ABS(RANDOM()) % 9900))::VARCHAR || ' Main St' AS applicant_address,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas'
        WHEN 9 THEN 'San Jose' WHEN 10 THEN 'Austin' WHEN 11 THEN 'Jacksonville'
        WHEN 12 THEN 'Fort Worth' WHEN 13 THEN 'Columbus' WHEN 14 THEN 'Charlotte'
        WHEN 15 THEN 'Indianapolis' WHEN 16 THEN 'Seattle' WHEN 17 THEN 'Denver'
        WHEN 18 THEN 'Boston' ELSE 'Nashville'
    END AS applicant_city,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL' WHEN 3 THEN 'TX'
        WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA' WHEN 6 THEN 'TX' WHEN 7 THEN 'CA'
        WHEN 8 THEN 'TX' WHEN 9 THEN 'CA' WHEN 10 THEN 'TX' WHEN 11 THEN 'FL'
        WHEN 12 THEN 'TX' WHEN 13 THEN 'OH' WHEN 14 THEN 'NC' WHEN 15 THEN 'IN'
        WHEN 16 THEN 'WA' WHEN 17 THEN 'CO' WHEN 18 THEN 'MA' ELSE 'TN'
    END AS applicant_state,
    LPAD((10000 + (ABS(RANDOM()) % 90000))::VARCHAR, 5, '0') AS applicant_zip,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'CHECKING'
        WHEN 1 THEN 'CHECKING'
        WHEN 2 THEN 'CHECKING'
        WHEN 3 THEN 'SAVINGS'
        WHEN 4 THEN 'SAVINGS'
        WHEN 5 THEN 'CREDIT_CARD'
        WHEN 6 THEN 'CREDIT_CARD'
        WHEN 7 THEN 'MONEY_MARKET'
        ELSE 'CHECKING'
    END AS requested_account_type,
    CASE WHEN requested_account_type = 'CREDIT_CARD' THEN (1000 + (ABS(RANDOM()) % 49000)) ELSE NULL END AS requested_credit_limit,
    CASE WHEN requested_account_type IN ('CHECKING', 'SAVINGS', 'MONEY_MARKET') 
         THEN (ABS(RANDOM()) % 1000000) / 100.0 
         ELSE 0.00 END AS initial_deposit_amount,
    CASE (ABS(RANDOM()) % 4)
        WHEN 0 THEN 'BRANCH' WHEN 1 THEN 'ONLINE' WHEN 2 THEN 'MOBILE' ELSE 'PHONE'
    END AS application_channel,
    SHA2((ABS(RANDOM()) % 1000000000)::VARCHAR) AS device_fingerprint,
    (ABS(RANDOM()) % 256)::VARCHAR || '.' || (ABS(RANDOM()) % 256)::VARCHAR || '.' || 
    (ABS(RANDOM()) % 256)::VARCHAR || '.' || (ABS(RANDOM()) % 256)::VARCHAR AS ip_address,
    (ABS(RANDOM()) % 10000) / 100.0 AS early_warning_risk_score,
    (ABS(RANDOM()) % 10000) / 100.0 AS identity_verification_score,
    (300 + (ABS(RANDOM()) % 550)) AS credit_score,
    (ABS(RANDOM()) % 10) AS existing_accounts_count,
    CASE WHEN early_warning_risk_score > 70 THEN (ABS(RANDOM()) % 5) ELSE 0 END AS fraud_database_hits,
    (ABS(RANDOM()) % 100) AS shared_database_hits,
    (ABS(RANDOM()) % 10000) / 100.0 AS velocity_check_score,
    (ABS(RANDOM()) % 10000) / 100.0 AS synthetic_identity_score,
    CASE 
        WHEN early_warning_risk_score >= 80 OR fraud_database_hits > 2 THEN 'DENIED'
        WHEN early_warning_risk_score >= 60 OR synthetic_identity_score >= 70 THEN 'MANUAL_REVIEW'
        WHEN early_warning_risk_score < 30 THEN 'APPROVED'
        ELSE CASE (ABS(RANDOM()) % 3)
            WHEN 0 THEN 'APPROVED'
            WHEN 1 THEN 'MANUAL_REVIEW'
            ELSE 'DENIED'
        END
    END AS application_status,
    CASE WHEN application_status = 'DENIED' THEN
        CASE (ABS(RANDOM()) % 7)
            WHEN 0 THEN 'High fraud risk score'
            WHEN 1 THEN 'Synthetic identity suspected'
            WHEN 2 THEN 'Failed identity verification'
            WHEN 3 THEN 'Fraud database match'
            WHEN 4 THEN 'Excessive velocity'
            WHEN 5 THEN 'Low credit score'
            ELSE 'Unable to verify information'
        END
    ELSE NULL END AS denial_reason,
    application_status = 'MANUAL_REVIEW' AS manual_review_required,
    CASE WHEN manual_review_required THEN 'Requires additional verification and review by underwriting team.' ELSE NULL END AS review_notes,
    CASE WHEN application_status IN ('APPROVED', 'DENIED') THEN 
        DATEADD(hour, (ABS(RANDOM()) % 72), application_date) 
    ELSE NULL END AS decision_date,
    CASE WHEN decision_date IS NOT NULL THEN 'System' || (ABS(RANDOM()) % 5 + 1)::VARCHAR ELSE NULL END AS decided_by,
    CASE WHEN application_status = 'APPROVED' THEN 'CUST' || LPAD(seq4(), 10, '0') ELSE NULL END AS approved_customer_id,
    CASE WHEN application_status = 'APPROVED' THEN 'ACCT' || LPAD(seq4(), 10, '0') ELSE NULL END AS approved_account_id,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 75000));

-- ============================================================================
-- Display data generation summary
-- ============================================================================

SELECT 'Data generation completed successfully' AS status;

SELECT
    'FINANCIAL_INSTITUTIONS' AS table_name,
    COUNT(*) AS row_count
FROM FINANCIAL_INSTITUTIONS
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL
SELECT 'ZELLE_PAYMENTS', COUNT(*) FROM ZELLE_PAYMENTS
UNION ALL
SELECT 'PAZE_TRANSACTIONS', COUNT(*) FROM PAZE_TRANSACTIONS
UNION ALL
SELECT 'FRAUD_ALERTS', COUNT(*) FROM FRAUD_ALERTS
UNION ALL
SELECT 'ACCOUNT_OPENINGS', COUNT(*) FROM ACCOUNT_OPENINGS
ORDER BY table_name;

