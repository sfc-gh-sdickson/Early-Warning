-- ============================================================================
-- Early Warning Intelligence Demo - Analytical Views
-- ============================================================================
-- Purpose: Create curated views for customer analytics, fraud detection, and
--          payment network intelligence
-- All syntax verified against Snowflake documentation
-- ============================================================================

USE DATABASE EARLY_WARNING_DEMO;
USE SCHEMA ANALYTICS;

-- ============================================================================
-- Customer 360 View
-- ============================================================================

CREATE OR REPLACE VIEW V_CUSTOMER_360 AS
SELECT
    c.customer_id,
    c.institution_id,
    fi.institution_name,
    fi.institution_type,
    c.first_name,
    c.last_name,
    c.first_name || ' ' || c.last_name AS full_name,
    c.date_of_birth,
    DATEDIFF('year', c.date_of_birth, CURRENT_DATE()) AS age,
    c.email,
    c.phone,
    c.city,
    c.state,
    c.zip_code,
    c.customer_since,
    DATEDIFF('day', c.customer_since, CURRENT_DATE()) AS customer_tenure_days,
    c.customer_status,
    c.risk_score AS customer_risk_score,
    c.kyc_verified,
    c.identity_verified,
    c.zelle_enrolled,
    c.zelle_enrollment_date,
    c.paze_enrolled,
    c.paze_enrollment_date,
    c.fraud_alerts_count,
    -- Account aggregations
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT CASE WHEN a.account_status = 'ACTIVE' THEN a.account_id END) AS active_accounts,
    SUM(CASE WHEN a.account_status = 'ACTIVE' THEN a.current_balance ELSE 0 END) AS total_balance,
    MAX(a.current_balance) AS max_account_balance,
    -- Transaction aggregations (last 90 days)
    COUNT(DISTINCT CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) THEN t.transaction_id END) AS transactions_last_90_days,
    SUM(CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) AND t.amount > 0 THEN t.amount ELSE 0 END) AS total_credits_90_days,
    SUM(CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) AND t.amount < 0 THEN ABS(t.amount) ELSE 0 END) AS total_debits_90_days,
    -- Zelle payment aggregations
    COUNT(DISTINCT zs.payment_id) AS zelle_payments_sent,
    COALESCE(SUM(zs.amount), 0) AS zelle_total_sent,
    COUNT(DISTINCT zr.payment_id) AS zelle_payments_received,
    COALESCE(SUM(zr.amount), 0) AS zelle_total_received,
    -- Paze transaction aggregations
    COUNT(DISTINCT p.paze_transaction_id) AS paze_transactions,
    COALESCE(SUM(CASE WHEN p.status = 'APPROVED' THEN p.amount ELSE 0 END), 0) AS paze_total_spent,
    -- Fraud indicators
    COUNT(DISTINCT fa.alert_id) AS total_fraud_alerts,
    COUNT(DISTINCT CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.alert_id END) AS confirmed_fraud_incidents,
    COALESCE(SUM(CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.amount_at_risk ELSE 0 END), 0) AS total_fraud_loss,
    MAX(fa.alert_date) AS last_fraud_alert_date,
    -- Risk classification
    CASE
        WHEN c.risk_score >= 80 OR COUNT(DISTINCT CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.alert_id END) > 2 THEN 'HIGH_RISK'
        WHEN c.risk_score >= 50 OR COUNT(DISTINCT CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.alert_id END) > 0 THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS overall_risk_classification,
    c.created_at,
    c.updated_at
FROM RAW.CUSTOMERS c
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS fi ON c.institution_id = fi.institution_id
LEFT JOIN RAW.ACCOUNTS a ON c.customer_id = a.customer_id
LEFT JOIN RAW.TRANSACTIONS t ON c.customer_id = t.customer_id
LEFT JOIN RAW.ZELLE_PAYMENTS zs ON c.customer_id = zs.sender_customer_id AND zs.status = 'COMPLETED'
LEFT JOIN RAW.ZELLE_PAYMENTS zr ON c.customer_id = zr.receiver_customer_id AND zr.status = 'COMPLETED'
LEFT JOIN RAW.PAZE_TRANSACTIONS p ON c.customer_id = p.customer_id
LEFT JOIN RAW.FRAUD_ALERTS fa ON c.customer_id = fa.customer_id
GROUP BY
    c.customer_id, c.institution_id, fi.institution_name, fi.institution_type,
    c.first_name, c.last_name, c.date_of_birth, c.email, c.phone, c.city, c.state,
    c.zip_code, c.customer_since, c.customer_status, c.risk_score, c.kyc_verified,
    c.identity_verified, c.zelle_enrolled, c.zelle_enrollment_date, c.paze_enrolled,
    c.paze_enrollment_date, c.fraud_alerts_count, c.created_at, c.updated_at;

-- ============================================================================
-- Fraud Detection Analytics View
-- ============================================================================

CREATE OR REPLACE VIEW V_FRAUD_ANALYTICS AS
SELECT
    fa.alert_id,
    fa.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    fa.account_id,
    fa.institution_id,
    fi.institution_name,
    fa.alert_date,
    DATE(fa.alert_date) AS alert_date_only,
    HOUR(fa.alert_date) AS alert_hour,
    DAYOFWEEK(fa.alert_date) AS alert_day_of_week,
    fa.alert_type,
    fa.alert_severity,
    fa.fraud_score,
    fa.detection_method,
    fa.amount_at_risk,
    fa.status AS alert_status,
    fa.resolution_date,
    DATEDIFF('hour', fa.alert_date, fa.resolution_date) AS resolution_time_hours,
    fa.resolution_action,
    fa.false_positive,
    fa.customer_notified,
    fa.law_enforcement_notified,
    fa.amount_recovered,
    CASE WHEN fa.amount_recovered > 0 THEN (fa.amount_recovered / NULLIF(fa.amount_at_risk, 0)) * 100 ELSE 0 END AS recovery_rate_percent,
    -- Related transaction details
    fa.related_transaction_id,
    fa.related_payment_id,
    fa.related_paze_id,
    -- Customer risk profile
    c.risk_score AS customer_risk_score,
    c.fraud_alerts_count AS customer_total_alerts,
    c.customer_since,
    DATEDIFF('day', c.customer_since, fa.alert_date) AS customer_age_at_alert_days,
    -- Classification
    CASE
        WHEN fa.status = 'CONFIRMED_FRAUD' THEN 'True Positive'
        WHEN fa.status = 'FALSE_POSITIVE' THEN 'False Positive'
        WHEN fa.status IN ('OPEN', 'INVESTIGATING') THEN 'Under Investigation'
        ELSE 'Resolved - Other'
    END AS investigation_outcome,
    -- Time to detection
    CASE
        WHEN fa.detection_method = 'ML_MODEL' THEN 'Real-time'
        WHEN fa.detection_method = 'RULE_ENGINE' THEN 'Real-time'
        WHEN fa.detection_method = 'NETWORK_INTELLIGENCE' THEN 'Batch'
        ELSE 'Manual'
    END AS detection_speed,
    fa.created_at,
    fa.updated_at
FROM RAW.FRAUD_ALERTS fa
LEFT JOIN RAW.CUSTOMERS c ON fa.customer_id = c.customer_id
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS fi ON fa.institution_id = fi.institution_id;

-- ============================================================================
-- Zelle Network Analytics View
-- ============================================================================

CREATE OR REPLACE VIEW V_ZELLE_NETWORK_ANALYTICS AS
SELECT
    zp.payment_id,
    zp.payment_date,
    DATE(zp.payment_date) AS payment_date_only,
    HOUR(zp.payment_date) AS payment_hour,
    DAYOFWEEK(zp.payment_date) AS payment_day_of_week,
    -- Sender information
    zp.sender_customer_id,
    sc.first_name || ' ' || sc.last_name AS sender_name,
    zp.sender_institution_id,
    sfi.institution_name AS sender_institution_name,
    sfi.institution_type AS sender_institution_type,
    sc.city AS sender_city,
    sc.state AS sender_state,
    sc.risk_score AS sender_risk_score,
    -- Receiver information
    zp.receiver_customer_id,
    CASE WHEN rc.customer_id IS NOT NULL 
         THEN rc.first_name || ' ' || rc.last_name 
         ELSE zp.receiver_identifier 
    END AS receiver_name,
    zp.receiver_institution_id,
    rfi.institution_name AS receiver_institution_name,
    rfi.institution_type AS receiver_institution_type,
    CASE WHEN rc.customer_id IS NOT NULL THEN rc.city ELSE NULL END AS receiver_city,
    CASE WHEN rc.customer_id IS NOT NULL THEN rc.state ELSE NULL END AS receiver_state,
    CASE WHEN rc.customer_id IS NOT NULL THEN rc.risk_score ELSE NULL END AS receiver_risk_score,
    zp.receiver_identifier,
    zp.receiver_identifier_type,
    -- Payment details
    zp.amount,
    zp.status,
    zp.completion_time,
    DATEDIFF('second', zp.payment_date, zp.completion_time) AS completion_time_seconds,
    zp.failure_reason,
    zp.payment_memo,
    zp.request_to_pay,
    zp.split_payment,
    zp.is_business_payment,
    -- Risk and fraud
    zp.risk_score,
    zp.fraud_flagged,
    zp.fraud_review_status,
    zp.reversal_requested,
    zp.reversal_approved,
    -- Network analysis
    CASE WHEN zp.sender_institution_id = zp.receiver_institution_id THEN 'INTRA_BANK' ELSE 'INTER_BANK' END AS payment_flow_type,
    -- Transaction categorization
    CASE
        WHEN zp.amount < 50 THEN 'SMALL'
        WHEN zp.amount < 500 THEN 'MEDIUM'
        WHEN zp.amount < 2500 THEN 'LARGE'
        ELSE 'VERY_LARGE'
    END AS payment_size_category,
    zp.created_at
FROM RAW.ZELLE_PAYMENTS zp
LEFT JOIN RAW.CUSTOMERS sc ON zp.sender_customer_id = sc.customer_id
LEFT JOIN RAW.CUSTOMERS rc ON zp.receiver_customer_id = rc.customer_id
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS sfi ON zp.sender_institution_id = sfi.institution_id
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS rfi ON zp.receiver_institution_id = rfi.institution_id;

-- ============================================================================
-- Paze Checkout Analytics View
-- ============================================================================

CREATE OR REPLACE VIEW V_PAZE_CHECKOUT_ANALYTICS AS
SELECT
    pt.paze_transaction_id,
    pt.transaction_date,
    DATE(pt.transaction_date) AS transaction_date_only,
    HOUR(pt.transaction_date) AS transaction_hour,
    DAYOFWEEK(pt.transaction_date) AS transaction_day_of_week,
    -- Customer information
    pt.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    pt.institution_id,
    fi.institution_name,
    c.city AS customer_city,
    c.state AS customer_state,
    c.risk_score AS customer_risk_score,
    -- Card details
    pt.card_last_four,
    pt.card_type,
    -- Merchant details
    pt.merchant_name,
    pt.merchant_id,
    pt.merchant_category,
    -- Transaction details
    pt.amount,
    pt.currency,
    pt.status,
    pt.decline_reason,
    -- Device and location
    pt.device_type,
    pt.browser_type,
    pt.ip_address,
    pt.location_city,
    pt.location_state,
    pt.location_country,
    -- Security checks
    pt.shipping_address_match,
    pt.cvv_match,
    pt.three_d_secure_used,
    CASE
        WHEN pt.shipping_address_match AND pt.cvv_match AND pt.three_d_secure_used THEN 'HIGH'
        WHEN (pt.shipping_address_match AND pt.cvv_match) OR pt.three_d_secure_used THEN 'MEDIUM'
        ELSE 'LOW'
    END AS security_level,
    -- Risk and fraud
    pt.risk_score,
    pt.fraud_flagged,
    pt.chargeback,
    pt.chargeback_date,
    pt.chargeback_reason,
    CASE WHEN pt.chargeback THEN DATEDIFF('day', pt.transaction_date, pt.chargeback_date) ELSE NULL END AS days_to_chargeback,
    -- Fees and revenue
    pt.merchant_fee,
    pt.network_fee,
    pt.merchant_fee + pt.network_fee AS total_fees,
    -- Transaction categorization
    CASE
        WHEN pt.amount < 25 THEN 'MICRO'
        WHEN pt.amount < 100 THEN 'SMALL'
        WHEN pt.amount < 500 THEN 'MEDIUM'
        WHEN pt.amount < 1000 THEN 'LARGE'
        ELSE 'VERY_LARGE'
    END AS transaction_size_category,
    -- Success indicators
    CASE WHEN pt.status = 'APPROVED' THEN 1 ELSE 0 END AS is_successful,
    CASE WHEN pt.status = 'DECLINED' THEN 1 ELSE 0 END AS is_declined,
    pt.created_at
FROM RAW.PAZE_TRANSACTIONS pt
LEFT JOIN RAW.CUSTOMERS c ON pt.customer_id = c.customer_id
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS fi ON pt.institution_id = fi.institution_id;

-- ============================================================================
-- Account Opening Analytics View
-- ============================================================================

CREATE OR REPLACE VIEW V_ACCOUNT_OPENING_ANALYTICS AS
SELECT
    ao.application_id,
    ao.institution_id,
    fi.institution_name,
    fi.institution_type,
    ao.application_date,
    DATE(ao.application_date) AS application_date_only,
    HOUR(ao.application_date) AS application_hour,
    DAYOFWEEK(ao.application_date) AS application_day_of_week,
    -- Applicant information
    ao.applicant_first_name,
    ao.applicant_last_name,
    ao.applicant_first_name || ' ' || ao.applicant_last_name AS applicant_name,
    ao.applicant_dob,
    DATEDIFF('year', ao.applicant_dob, ao.application_date) AS applicant_age_at_application,
    ao.applicant_email,
    ao.applicant_phone,
    ao.applicant_city,
    ao.applicant_state,
    ao.applicant_zip,
    -- Application details
    ao.requested_account_type,
    ao.requested_credit_limit,
    ao.initial_deposit_amount,
    ao.application_channel,
    -- Risk scores
    ao.early_warning_risk_score,
    ao.identity_verification_score,
    ao.credit_score,
    ao.velocity_check_score,
    ao.synthetic_identity_score,
    -- Fraud indicators
    ao.existing_accounts_count,
    ao.fraud_database_hits,
    ao.shared_database_hits,
    -- Decision
    ao.application_status,
    ao.denial_reason,
    ao.manual_review_required,
    ao.decision_date,
    DATEDIFF('hour', ao.application_date, ao.decision_date) AS decision_time_hours,
    ao.decided_by,
    ao.approved_customer_id,
    ao.approved_account_id,
    -- Risk classification
    CASE
        WHEN ao.early_warning_risk_score >= 80 THEN 'CRITICAL_RISK'
        WHEN ao.early_warning_risk_score >= 60 THEN 'HIGH_RISK'
        WHEN ao.early_warning_risk_score >= 40 THEN 'MEDIUM_RISK'
        WHEN ao.early_warning_risk_score >= 20 THEN 'LOW_RISK'
        ELSE 'MINIMAL_RISK'
    END AS risk_classification,
    -- Approval indicators
    CASE WHEN ao.application_status = 'APPROVED' THEN 1 ELSE 0 END AS is_approved,
    CASE WHEN ao.application_status = 'DENIED' THEN 1 ELSE 0 END AS is_denied,
    CASE WHEN ao.application_status = 'MANUAL_REVIEW' THEN 1 ELSE 0 END AS is_manual_review,
    ao.created_at,
    ao.updated_at
FROM RAW.ACCOUNT_OPENINGS ao
LEFT JOIN RAW.FINANCIAL_INSTITUTIONS fi ON ao.institution_id = fi.institution_id;

-- ============================================================================
-- Institution Performance View
-- ============================================================================

CREATE OR REPLACE VIEW V_INSTITUTION_PERFORMANCE AS
SELECT
    fi.institution_id,
    fi.institution_name,
    fi.institution_type,
    fi.network_tier,
    fi.routing_number,
    fi.total_customers AS registered_customers,
    fi.total_assets,
    fi.member_since,
    DATEDIFF('day', fi.member_since, CURRENT_DATE()) AS member_tenure_days,
    fi.zelle_enabled,
    fi.paze_enabled,
    fi.city,
    fi.state,
    -- Customer metrics
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(a.current_balance) AS total_deposits,
    -- Transaction metrics (last 90 days)
    COUNT(DISTINCT CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) THEN t.transaction_id END) AS transactions_90_days,
    SUM(CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) AND t.amount > 0 THEN t.amount ELSE 0 END) AS total_inflows_90_days,
    SUM(CASE WHEN t.transaction_date >= DATEADD('day', -90, CURRENT_DATE()) AND t.amount < 0 THEN ABS(t.amount) ELSE 0 END) AS total_outflows_90_days,
    -- Zelle metrics
    COUNT(DISTINCT zs.payment_id) AS zelle_payments_sent,
    COALESCE(SUM(zs.amount), 0) AS zelle_volume_sent,
    COUNT(DISTINCT zr.payment_id) AS zelle_payments_received,
    COALESCE(SUM(zr.amount), 0) AS zelle_volume_received,
    -- Paze metrics
    COUNT(DISTINCT p.paze_transaction_id) AS paze_transactions,
    COALESCE(SUM(CASE WHEN p.status = 'APPROVED' THEN p.amount ELSE 0 END), 0) AS paze_volume_approved,
    -- Fraud metrics
    COUNT(DISTINCT fa.alert_id) AS total_fraud_alerts,
    COUNT(DISTINCT CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.alert_id END) AS confirmed_fraud_cases,
    COALESCE(SUM(CASE WHEN fa.status = 'CONFIRMED_FRAUD' THEN fa.amount_at_risk ELSE 0 END), 0) AS total_fraud_losses,
    COALESCE(SUM(fa.amount_recovered), 0) AS total_fraud_recovered,
    -- Account opening metrics
    COUNT(DISTINCT ao.application_id) AS total_applications,
    COUNT(DISTINCT CASE WHEN ao.application_status = 'APPROVED' THEN ao.application_id END) AS approved_applications,
    COUNT(DISTINCT CASE WHEN ao.application_status = 'DENIED' THEN ao.application_id END) AS denied_applications,
    CASE WHEN COUNT(DISTINCT ao.application_id) > 0 
         THEN (COUNT(DISTINCT CASE WHEN ao.application_status = 'APPROVED' THEN ao.application_id END)::FLOAT / COUNT(DISTINCT ao.application_id) * 100)
         ELSE 0 END AS approval_rate_percent,
    fi.created_at,
    fi.updated_at
FROM RAW.FINANCIAL_INSTITUTIONS fi
LEFT JOIN RAW.CUSTOMERS c ON fi.institution_id = c.institution_id AND c.customer_status = 'ACTIVE'
LEFT JOIN RAW.ACCOUNTS a ON fi.institution_id = a.institution_id AND a.account_status = 'ACTIVE'
LEFT JOIN RAW.TRANSACTIONS t ON fi.institution_id = t.institution_id
LEFT JOIN RAW.ZELLE_PAYMENTS zs ON fi.institution_id = zs.sender_institution_id AND zs.status = 'COMPLETED'
LEFT JOIN RAW.ZELLE_PAYMENTS zr ON fi.institution_id = zr.receiver_institution_id AND zr.status = 'COMPLETED'
LEFT JOIN RAW.PAZE_TRANSACTIONS p ON fi.institution_id = p.institution_id
LEFT JOIN RAW.FRAUD_ALERTS fa ON fi.institution_id = fa.institution_id
LEFT JOIN RAW.ACCOUNT_OPENINGS ao ON fi.institution_id = ao.institution_id
GROUP BY
    fi.institution_id, fi.institution_name, fi.institution_type, fi.network_tier,
    fi.routing_number, fi.total_customers, fi.total_assets, fi.member_since,
    fi.zelle_enabled, fi.paze_enabled, fi.city, fi.state, fi.created_at, fi.updated_at;

-- Display confirmation
SELECT 'Analytical views created successfully' AS status,
       COUNT(*) AS view_count
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS';

