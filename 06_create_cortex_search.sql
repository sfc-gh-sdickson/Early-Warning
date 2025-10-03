-- ============================================================================
-- Early Warning Intelligence Demo - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search service for
--          fraud investigation notes, support transcripts, and policy documents
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE EARLY_WARNING_DEMO;
USE SCHEMA RAW;

-- ============================================================================
-- Step 1: Create table for fraud investigation notes (unstructured text data)
-- ============================================================================

CREATE TABLE IF NOT EXISTS FRAUD_INVESTIGATION_NOTES (
    note_id VARCHAR(30) PRIMARY KEY,
    alert_id VARCHAR(30),
    customer_id VARCHAR(20),
    institution_id VARCHAR(20),
    investigator_id VARCHAR(20),
    investigation_date TIMESTAMP_NTZ NOT NULL,
    note_type VARCHAR(50) NOT NULL,  -- INITIAL_REVIEW, FOLLOW_UP, RESOLUTION, ESCALATION
    note_text VARCHAR(16777216) NOT NULL,  -- Main searchable content (16MB max)
    case_status VARCHAR(30),  -- OPEN, INVESTIGATING, CLOSED, ESCALATED
    fraud_confirmed BOOLEAN,
    amount_involved NUMBER(18,2),
    tags VARCHAR(500),  -- Comma-separated tags for categorization
    created_by VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (alert_id) REFERENCES FRAUD_ALERTS(alert_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Step 2: Create table for customer support transcripts
-- ============================================================================

CREATE TABLE IF NOT EXISTS CUSTOMER_SUPPORT_TRANSCRIPTS (
    transcript_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20),
    institution_id VARCHAR(20),
    support_date TIMESTAMP_NTZ NOT NULL,
    channel VARCHAR(30),  -- PHONE, CHAT, EMAIL, IN_PERSON
    agent_id VARCHAR(20),
    category VARCHAR(50),  -- FRAUD_REPORT, ACCOUNT_ISSUE, PAYMENT_ISSUE, GENERAL_INQUIRY
    transcript_text VARCHAR(16777216) NOT NULL,  -- Main searchable content
    sentiment_score NUMBER(5,2),  -- -100 to 100 (negative to positive)
    resolution_status VARCHAR(30),  -- RESOLVED, PENDING, ESCALATED, UNRESOLVED
    fraud_related BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (institution_id) REFERENCES FINANCIAL_INSTITUTIONS(institution_id)
);

-- ============================================================================
-- Step 3: Create table for policy and training documents
-- ============================================================================

CREATE TABLE IF NOT EXISTS POLICY_DOCUMENTS (
    document_id VARCHAR(30) PRIMARY KEY,
    document_title VARCHAR(500) NOT NULL,
    document_type VARCHAR(50) NOT NULL,  -- POLICY, PROCEDURE, TRAINING, GUIDELINE, FAQ
    document_category VARCHAR(50),  -- FRAUD_PREVENTION, COMPLIANCE, RISK_MANAGEMENT, OPERATIONS
    document_text VARCHAR(16777216) NOT NULL,  -- Main searchable content
    version VARCHAR(20),
    effective_date DATE,
    last_reviewed_date DATE,
    owned_by VARCHAR(100),
    tags VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
-- Per documentation: Change tracking is required to build the cortex search service

ALTER TABLE FRAUD_INVESTIGATION_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE CUSTOMER_SUPPORT_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE POLICY_DOCUMENTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 4.5: Clear existing data (for re-runs)
-- ============================================================================
-- Truncate in reverse dependency order to prevent foreign key violations
-- These tables reference FRAUD_ALERTS and CUSTOMERS from previous scripts

TRUNCATE TABLE IF EXISTS FRAUD_INVESTIGATION_NOTES;
TRUNCATE TABLE IF EXISTS CUSTOMER_SUPPORT_TRANSCRIPTS;
TRUNCATE TABLE IF EXISTS POLICY_DOCUMENTS;

-- ============================================================================
-- Step 5: Generate sample fraud investigation notes
-- ============================================================================

INSERT INTO FRAUD_INVESTIGATION_NOTES
SELECT
    'NOTE' || LPAD(SEQ4(), 10, '0') AS note_id,
    fa.alert_id,
    fa.customer_id,
    fa.institution_id,
    'INV' || LPAD((ABS(RANDOM()) % 50) + 1, 4, '0') AS investigator_id,
    DATEADD('hour', UNIFORM(0, 24, RANDOM()), fa.alert_date) AS investigation_date,
    ARRAY_CONSTRUCT('INITIAL_REVIEW', 'FOLLOW_UP', 'RESOLUTION', 'ESCALATION')[UNIFORM(0, 3, RANDOM())] AS note_type,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'Initial review of fraud alert. Customer reported unauthorized Zelle payment to unknown recipient. Transaction amount: $' || fa.amount_at_risk::VARCHAR || '. Customer claims they did not initiate this payment. Phone number used was not recognized by customer. Preliminary assessment suggests account takeover. Recommend immediate account freeze and password reset.'
        WHEN 1 THEN 'Follow-up investigation completed. Verified customer identity through security questions. Customer confirmed they received suspicious text message claiming to be from their bank requesting urgent action. Customer clicked link and entered credentials. This appears to be a phishing attack followed by account takeover. Fraud confirmed. Initiating reversal process.'
        WHEN 2 THEN 'Analyzed transaction patterns for the past 30 days. Multiple Zelle payments to same recipient over short time period detected. Velocity check triggered alert. Customer interviewed and confirmed legitimate business relationship. Payments were for contractor services. False positive - no fraud detected. Customer educated on reporting requirements for business use.'
        WHEN 3 THEN 'High-risk account opening application flagged by Early Warning risk model. Applicant provided documentation that appears altered. SSN validation failed cross-reference check. Address provided does not match credit bureau records. Suspect synthetic identity fraud. Application denied. Case forwarded to law enforcement.'
        WHEN 4 THEN 'Customer dispute investigation: Paze transaction at online merchant for electronics. Customer claims unauthorized purchase. Device fingerprint analysis shows transaction originated from customer usual device and IP address. Browser cookies match historical pattern. CVV was entered correctly. Strong evidence customer initiated transaction. Likely buyer remorse rather than fraud. Dispute denied.'
        WHEN 5 THEN 'Fraud ring investigation expanded. This customer linked to 15 other accounts with similar patterns. All accounts opened within 2-week period using similar documentation. Shared email domains detected. Network analysis reveals coordinated fraud scheme targeting multiple financial institutions. All accounts frozen. Federal authorities notified. Estimated exposure: $2.3M across Early Warning network.'
        WHEN 6 THEN 'Elder fraud investigation. Customer age 78 reported Zelle payments totaling $47,000 over 3 months to person claiming to be grandchild in distress. Customer genuinely believed they were helping family member. Classic grandparent scam. Funds already withdrawn by recipient. Recovery unlikely. Customer very distressed. Referred to victim services and law enforcement. Enhanced monitoring applied to remaining accounts.'
        WHEN 7 THEN 'Account takeover investigation. Customer reported multiple unauthorized transactions after data breach at third-party merchant. Customer credentials compromised in breach. Bad actor gained access and changed contact information. 23 fraudulent transactions identified totaling $12,850. All transactions reversed. New account issued. Customer enrolled in enhanced fraud monitoring. Case documented for network intelligence sharing.'
        WHEN 8 THEN 'Chargeback investigation for Paze merchant transaction. Merchant provided proof of delivery with signature. Shipping address matches customer billing address. Customer claims item not as described but evidence shows customer received item as advertised. Product photos and description accurate. Chargeback denied in favor of merchant. Customer advised to resolve with merchant directly.'
        WHEN 9 THEN 'Risk assessment completed for high-value Zelle payment ($15,000). Customer attempting to purchase vehicle from private seller. Red flags: first time sending to this recipient, amount exceeds normal pattern, recipient not in customer contacts. Customer interviewed - confirmed legitimate transaction, provided bill of sale and vehicle details. Risk accepted with additional verification. Transaction approved with enhanced monitoring.'
    END AS note_text,
    fa.status AS case_status,
    CASE WHEN fa.false_positive = FALSE AND fa.status = 'CONFIRMED_FRAUD' THEN TRUE
         WHEN fa.false_positive = TRUE THEN FALSE
         ELSE NULL END AS fraud_confirmed,
    fa.amount_at_risk AS amount_involved,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'account_takeover,phishing,credential_theft'
        WHEN 1 THEN 'synthetic_identity,fake_documents,application_fraud'
        WHEN 2 THEN 'elder_fraud,romance_scam,social_engineering'
        WHEN 3 THEN 'chargeback,dispute,merchant_fraud'
        WHEN 4 THEN 'fraud_ring,organized_crime,network_fraud'
    END AS tags,
    'Investigator' || (ABS(RANDOM()) % 50 + 1)::VARCHAR AS created_by,
    DATEADD('hour', UNIFORM(1, 48, RANDOM()), fa.created_at) AS created_at,
    fa.updated_at AS updated_at
FROM RAW.FRAUD_ALERTS fa
WHERE fa.alert_id IS NOT NULL
LIMIT 50000;

-- ============================================================================
-- Step 6: Generate sample customer support transcripts
-- ============================================================================

INSERT INTO CUSTOMER_SUPPORT_TRANSCRIPTS
SELECT
    'TRANS' || LPAD(SEQ4(), 10, '0') AS transcript_id,
    c.customer_id,
    c.institution_id,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS support_date,
    ARRAY_CONSTRUCT('PHONE', 'CHAT', 'EMAIL', 'IN_PERSON')[UNIFORM(0, 3, RANDOM())] AS channel,
    'AGT' || LPAD((ABS(RANDOM()) % 100) + 1, 4, '0') AS agent_id,
    ARRAY_CONSTRUCT('FRAUD_REPORT', 'ACCOUNT_ISSUE', 'PAYMENT_ISSUE', 'GENERAL_INQUIRY')[UNIFORM(0, 3, RANDOM())] AS category,
    CASE (ABS(RANDOM()) % 15)
        WHEN 0 THEN 'Agent: Thank you for calling Early Warning Network Support. How may I help you today? Customer: I just noticed a Zelle payment for $850 that I did not send. It went out yesterday to someone I do not know. Agent: I understand your concern. Let me pull up your account. Can you verify your account number? Customer: Yes, it is ending in 4739. Agent: Thank you. I see the transaction you mentioned. For security, I am immediately placing a hold on your account. Can you tell me if you received any unusual texts or emails recently? Customer: Now that you mention it, yes. I got a text saying my account was locked and I needed to verify. Agent: That was a phishing attempt. The fraudsters used your credentials to send that payment. I am initiating a fraud investigation and we will work to recover those funds. You will need to change your password immediately.'
        WHEN 1 THEN 'Customer: Hello, I am trying to enroll in Zelle but it keeps saying my phone number is already registered. Agent: Let me check that for you. What is your phone number? Customer: 555-234-8890. Agent: I see the issue. That number is registered to another account. Do you have another phone number you could use, or would you prefer to use your email address? Customer: I only have one number. Could someone else have used it? Agent: It is possible. Let me file a report to investigate. In the meantime, would you like to enroll with your email address instead? Customer: Yes, please. My email is customer@email.com. Agent: Perfect. I am processing your enrollment now. You should receive a verification code shortly.'
        WHEN 2 THEN 'Chat initiated. Agent: Hi! I am here to help. What can I assist you with? Customer: I tried to make a payment through Paze but it was declined. I know I have enough money in my account. Agent: I can help with that. Let me look up your recent transactions. What was the merchant name? Customer: It was BestBuy.com for $1,245. Agent: I see the decline. It triggered our fraud detection system because it is a larger than usual purchase and from a new merchant. For your security, I just need to verify a few details. Can you confirm the last 4 digits of your card? Customer: 8823. Agent: Perfect. And what is your billing zip code? Customer: 60614. Agent: Thank you. Your identity is verified. I am removing the fraud hold. Please try your purchase again and it should go through. We apologize for the inconvenience.'
        WHEN 3 THEN 'Agent: Early Warning Support, this is Agent Johnson. How can I assist? Customer: I am calling because I think I was scammed. Someone called saying they were from fraud prevention and convinced me to send them money through Zelle. Agent: I am very sorry to hear that. You did the right thing by calling. How much did you send? Customer: $3,500 over two payments. Agent: When did this happen? Customer: This morning, about 2 hours ago. Agent: Okay, time is critical. I am immediately filing a fraud report and contacting the receiving institution to attempt recovery. Can you describe the person who called you? Customer: They said their name was Officer Rodriguez from the Fraud Department. They had a badge number and everything. Agent: That is a common scam tactic. We will never call and ask you to send money. Let me walk you through the recovery process and get you enrolled in enhanced monitoring.'
        WHEN 4 THEN 'Email Support Thread. Customer: I received a fraud alert about my account but when I try to log in, it says my password is incorrect. I did not change my password. Agent: Thank you for contacting us. This is a serious security concern. Do NOT use any links in emails or texts claiming to be from us. Please call our verified support number immediately at 1-800-XXX-XXXX so we can verify your identity and secure your account. This may be an account takeover attempt. Customer: I will call right now. Should I be worried about my money? Agent: We have automatic fraud detection in place. If unauthorized access was detected, your account may already be temporarily frozen for protection. The phone agent will be able to give you specific details after verifying your identity. Please call as soon as possible.'
        WHEN 5 THEN 'Agent: Good afternoon, Early Warning Network Support. Customer: Hi, I need help understanding a charge on my account. It says Paze Transaction but I do not remember making it. Agent: I can help you with that. What is the transaction date and amount? Customer: It was yesterday for $67.89 at Amazon.com. Agent: Let me pull up the details. Okay, I see this was an online purchase using your Paze digital wallet. Do you have Amazon Prime or shop there regularly? Customer: Oh yes, actually I ordered groceries yesterday. Is that what this is? Agent: Yes, exactly. Paze is the checkout service that processes your payment securely. It would have appeared as a quick checkout option. Customer: Oh, I remember now. I did use the fast checkout. Sorry for the confusion. Agent: No problem at all! That is what we are here for. Is there anything else I can help you with today?'
        WHEN 6 THEN 'In-Person Branch Visit. Agent: Welcome! What brings you in today? Customer: I am 72 years old and I keep hearing about all these scams. I want to make sure my account is protected. Agent: That is very smart to be proactive. Let me review your account security settings. I see you have basic fraud alerts enabled. I recommend we upgrade you to enhanced monitoring given the increase in elder-targeted fraud. Customer: Yes, please do that. What else should I watch out for? Agent: Never give out your password or verification codes, even if someone claims to be from the bank. We will never ask for that. Also, be cautious of unexpected phone calls asking you to send money, especially through Zelle. Customer: My grandson uses Zelle. Is that safe? Agent: Yes, Zelle is safe when you know the person you are sending to. Just verify it is really your grandson before sending money. Scammers pretend to be family members in distress. Customer: Thank you, this is very helpful.'
        WHEN 7 THEN 'Chat: Customer: Help! My account shows a fraud hold and I need to make an urgent payment! Agent: I understand this is frustrating. The hold was placed by our automated system for your protection. What payment are you trying to make? Customer: I need to pay a contractor $5,000 today. Agent: I can help, but I need to verify some information first for security. Can you tell me about this contractor? Is this someone you have worked with before? Customer: No, I found them online. They need payment upfront to start work tomorrow. Agent: I want to caution you - that is a common scam pattern. Legitimate contractors rarely require full payment upfront from new clients. Can you verify their business license and insurance? Customer: They said they would provide that after payment. Agent: That is a major red flag. I strongly recommend not proceeding with this payment. This matches known fraud patterns in our system. Can I connect you with our fraud prevention team? Customer: Maybe I should think about this more carefully. Agent: That is a wise decision. We are here to protect you.'
        WHEN 8 THEN 'Agent: Thank you for calling. I see you are calling about application status? Customer: Yes, I applied for an account 3 days ago and have not heard back. Agent: Let me look that up. Can I have your application reference number? Customer: It is APP20240145890. Agent: Thank you. I see your application is currently in manual review by our risk assessment team. Customer: Why? I have good credit. Agent: The review is a standard procedure for certain applications. It is not necessarily a negative indicator. Our Early Warning risk model flagged your application for additional verification, which could be for various reasons like recent address change or identity verification requirements. Customer: How long will this take? Agent: Manual reviews typically complete within 5-7 business days. You should receive a decision by next week. Customer: Okay, thank you for checking.'
        WHEN 9 THEN 'Email: Customer inquiry - I tried to send $2,000 via Zelle to my daughter for college tuition but the payment is showing as pending for 24 hours. Is this normal? Agent Response: Thank you for contacting us. Payments over $1,000 to new recipients may experience a short delay for security verification, especially for fraud prevention. This is normal and for your protection. Your payment should complete within 24-48 hours. If you need to expedite this, please call us at 1-800-XXX-XXXX with documentation of the tuition payment, and we can potentially release it sooner after verification. Customer Reply: Thank you for explaining. I will wait for it to process. Agent: You are welcome. The payment will complete automatically once the verification period expires. Your daughter should receive it by tomorrow.'
        WHEN 10 THEN 'Agent: Early Warning Fraud Department. Customer: Someone from your fraud department just called me about suspicious activity and asked me to verify my account by sending a test payment. Is this legitimate? Agent: ABSOLUTELY NOT. That is a scam. We will NEVER ask you to send test payments or give us your password. You did exactly the right thing by calling us directly. Did you provide any information or send any money? Customer: No, I got suspicious when they asked for a payment. Agent: Excellent instincts. What phone number did they call from? Customer: It showed up as 1-800-XXX-XXXX, your main number. Agent: They spoofed our number. This is a known scam. I am filing a report. Please block that contact and if they call again, do not answer. Customer: Thank you for confirming. I almost fell for it. Agent: You did great by verifying. We have resources on our website about common scams. Would you like me to email those to you?'
        WHEN 11 THEN 'Chat Support. Customer: I got charged a fee on my Paze transaction. Why? Agent: Let me look up that transaction. What is the transaction ID? Customer: It is PAZE20240398745. Agent: I see that transaction. The fee was charged by the merchant, not by Paze or our network. Some merchants add a service fee for certain payment methods. Customer: That does not seem right. Can I dispute it? Agent: You can dispute the merchant fee directly with the merchant. If they refuse to refund it and you believe it was not properly disclosed, you can file a formal dispute and we will investigate. Customer: How do I do that? Agent: I can start that process for you now. I will need the merchant name, transaction date, and a brief description of why you believe the fee was improper. Customer: The merchant is OnlineMart, transaction was yesterday, and there was no fee mentioned at checkout. Agent: Thank you. I am filing the dispute. You should receive a response within 10 business days.'
        WHEN 12 THEN 'Phone Support. Agent: Thank you for calling Early Warning Network. Customer: I am traveling internationally and want to make sure my Zelle will work. Agent: Zelle is designed for U.S. domestic transfers between U.S. bank accounts. It will work for sending money back to the U.S., but you cannot send to international accounts through Zelle. Customer: What about Paze for online shopping? Agent: Paze will work for international online shopping at participating merchants. However, your bank may flag international transactions for fraud prevention. I recommend notifying your bank of your travel dates. Customer: How do I do that? Agent: You can do that through your bank mobile app or by calling your bank directly. Would you like me to place a note on your account indicating international travel? Customer: Yes please. I will be in Europe for 2 weeks. Agent: Done. I have noted your account. Have a safe trip!'
        WHEN 13 THEN 'Agent: Early Warning Support, how may I help you? Customer: I want to increase my Zelle sending limit. The current limit is too low for my business needs. Agent: I can help with that. Are you using a personal or business account? Customer: Personal account, but I run a small business. Agent: For business use, I recommend upgrading to a business account which has higher limits and additional fraud protection. Personal accounts have regulatory limits. Customer: What are the limits? Agent: Personal accounts are typically limited to $500-$2,500 per transaction depending on your bank, while business accounts can have limits of $10,000 or higher. Customer: How do I upgrade? Agent: You would need to apply for a business account with your financial institution. I can transfer you to account services if you would like. Customer: Yes, please transfer me. Agent: One moment please.'
        WHEN 14 THEN 'Email Support. Customer: I received a Zelle payment from someone I do not know. What should I do? Agent: Do not accept the payment. This could be a scam where they send you money, ask you to send it back to a different account, and then dispute the original payment. You would be liable. Please do not send any money. What is the sender name and amount? Customer: The sender name is J.Martinez and it is for $900. They sent me a text saying it was sent by accident. Agent: This is a known scam. Do NOT send the money back. The payment will automatically be returned to the sender if you decline it. I am flagging this for investigation. Please forward that text message to our fraud team at fraud@earlywarning.com. Customer: Thank you. I almost sent it back. Agent: You did the right thing by checking first. We see this scam frequently. The payment will be returned to the sender within 14 days.'
    END AS transcript_text,
    (ABS(RANDOM()) % 200) - 100 AS sentiment_score,
    ARRAY_CONSTRUCT('RESOLVED', 'PENDING', 'ESCALATED', 'UNRESOLVED')[UNIFORM(0, 3, RANDOM())] AS resolution_status,
    CASE WHEN (ABS(RANDOM()) % 100) < 30 THEN TRUE ELSE FALSE END AS fraud_related,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_at
FROM RAW.CUSTOMERS c
WHERE c.customer_id IS NOT NULL
LIMIT 25000;

-- ============================================================================
-- Step 7: Generate sample policy documents
-- ============================================================================

INSERT INTO POLICY_DOCUMENTS VALUES
('DOC0001', 'Fraud Prevention and Detection Policy', 'POLICY', 'FRAUD_PREVENTION',
$$PURPOSE: This policy establishes the framework for fraud prevention, detection, and response across the Early Warning network. SCOPE: This policy applies to all member financial institutions, customers, and transactions processed through Early Warning payment networks including Zelle and Paze. DEFINITIONS: Fraud is defined as the intentional deception or misrepresentation that an individual or entity makes knowing that the misrepresentation could result in some unauthorized benefit. POLICY STATEMENT: Early Warning is committed to protecting its network members and their customers from fraud through advanced analytics, network intelligence, and collaborative information sharing. FRAUD DETECTION METHODS: 1) Machine Learning Models - Advanced ML algorithms analyze transaction patterns to identify anomalies. 2) Rule-Based Engine - Configurable rules trigger alerts based on known fraud patterns. 3) Network Intelligence - Shared fraud data across 2,500+ financial institutions. 4) Customer Reports - Direct customer reporting of suspected fraud. RISK SCORING: All transactions and account applications receive Early Warning risk scores from 0-100, with scores above 70 requiring additional review. ALERT SEVERITY LEVELS: CRITICAL (90-100) - Immediate action required, HIGH (70-89) - Review within 4 hours, MEDIUM (40-69) - Review within 24 hours, LOW (0-39) - Standard monitoring. RESPONSE PROCEDURES: Upon fraud detection, accounts may be immediately frozen, transactions reversed, and customers notified. All confirmed fraud cases are shared across the network. INVESTIGATION TIMELINE: Initial review within 2 hours, full investigation within 48 hours, resolution within 10 business days. REPORTING REQUIREMENTS: All member institutions must report confirmed fraud within 24 hours to network intelligence database. CUSTOMER PROTECTION: Customers are not liable for unauthorized transactions when reported within 60 days. TRAINING: All fraud investigators must complete annual training on fraud detection techniques and emerging threats. POLICY REVIEW: This policy is reviewed annually and updated as needed based on emerging fraud trends.$$,
'2.1', '2024-01-01', '2024-10-01', 'Chief Risk Officer', 'fraud,prevention,detection,policy,security', TRUE, '2024-01-01', '2024-10-01'),

('DOC0002', 'Account Opening Risk Assessment Guidelines', 'GUIDELINE', 'RISK_MANAGEMENT',
$$OVERVIEW: These guidelines provide detailed procedures for assessing risk in new account opening applications using Early Warning proprietary risk models and data. RISK MODEL COMPONENTS: 1) Identity Verification Score (0-100) - Validates applicant identity against authoritative data sources. 2) Credit Score Analysis - Evaluates creditworthiness and payment history. 3) Fraud Database Checks - Cross-references applicant against known fraud databases. 4) Synthetic Identity Detection (0-100) - Identifies potentially fabricated identities. 5) Velocity Checks - Detects multiple applications in short timeframe. 6) Shared Database Hits - Flags applicants with negative history across network. RISK THRESHOLDS: Applications scoring 0-40 = Low Risk (Auto-Approve), 41-70 = Medium Risk (Enhanced Review), 71-89 = High Risk (Manual Review Required), 90-100 = Critical Risk (Auto-Decline). VERIFICATION REQUIREMENTS: Low Risk - Standard ID verification, Medium Risk - Additional documentation required, High Risk - In-person verification preferred, Critical Risk - Decline with option to appeal. DOCUMENTATION STANDARDS: Acceptable forms of identification include government-issued photo ID, social security card, proof of address within 90 days. All documents must be verified for authenticity. RED FLAGS: 1) Address does not match credit bureau records. 2) SSN fails validation checks. 3) Documents appear altered or fabricated. 4) Multiple applications from same device/IP. 5) Applicant information matches known fraud patterns. 6) Discrepancies in applicant-provided information. MANUAL REVIEW PROCESS: High-risk applications must be reviewed by senior risk analyst within 24 hours. Review includes enhanced identity verification, database searches, and applicant interview if needed. DECISION TIMELINE: Low risk decisions automated within seconds, Medium risk decisions within 4 hours, High risk decisions within 48 hours. DENIAL REASONS: Applicants must be provided specific denial reason compliant with Fair Credit Reporting Act requirements. APPEAL PROCESS: Denied applicants may appeal by providing additional documentation. Appeals reviewed within 10 business days. DATA RETENTION: Application data retained for 7 years for compliance and fraud investigation purposes.$$,
'1.5', '2024-03-15', '2024-09-15', 'Account Opening Division', 'account,opening,risk,assessment,guidelines', TRUE, '2024-03-15', '2024-09-15'),

('DOC0003', 'Zelle Payment Network Security Standards', 'PROCEDURE', 'FRAUD_PREVENTION',
$$SCOPE: This procedure defines security standards for all Zelle payment transactions processed through the Early Warning network. TRANSACTION LIMITS: Personal accounts $500-$2,500 per transaction, Business accounts up to $10,000 per transaction, Daily limits may be lower based on risk profile. RECIPIENT VERIFICATION: First-time recipients require enrollment verification, High-value payments (>$5,000) require additional authentication, Recipients must be enrolled with valid email or phone number. FRAUD MONITORING: All Zelle payments scored in real-time using ML models, Payments scoring >70 held for review, Payments >$1,000 to new recipients may experience 24-48 hour verification delay. SUSPICIOUS PATTERNS: 1) Multiple payments to same recipient in short time, 2) Payments to newly enrolled recipients, 3) Round-number amounts common in scams, 4) Pattern changes from customer normal behavior, 5) Payments following suspected account takeover. ACCOUNT TAKEOVER INDICATORS: Login from new device/location, Password reset followed by immediate high-value payment, Contact information changes followed by payment activity, Multiple failed login attempts then successful login. CUSTOMER AUTHENTICATION: Strong customer authentication required for high-risk transactions, Two-factor authentication recommended for all users, Biometric authentication supported where available. REVERSAL POLICY: Zelle payments are typically instant and irreversible, Reversals only processed for confirmed fraud or technical errors, Customer must report unauthorized payments within 60 days, Financial institution has discretion on reversal decisions. SCAM PREVENTION: Payment warnings displayed for common scam patterns, Customer education materials provided during enrollment, Real-time alerts for high-risk payment attempts. MERCHANT RESTRICTIONS: Zelle is for person-to-person payments only, Commercial/merchant use requires business account, Violations may result in account suspension. INCIDENT RESPONSE: Suspected fraud reported immediately to fraud team, Affected accounts frozen within 1 hour, Investigation initiated within 4 hours, Customer notified within 24 hours. NETWORK INTELLIGENCE: Confirmed fraud shared across Early Warning network, Fraudulent recipient information flagged network-wide, Trends analyzed for proactive prevention.$$,
'3.0', '2024-02-01', '2024-08-01', 'Zelle Product Team', 'zelle,payments,security,procedure', TRUE, '2024-02-01', '2024-08-01'),

('DOC0004', 'Paze Checkout Fraud Prevention Training', 'TRAINING', 'FRAUD_PREVENTION',
$$TRAINING OBJECTIVE: Equip fraud analysts with knowledge to identify and prevent Paze checkout fraud. MODULE 1: PAZE OVERVIEW - Paze is Early Warning online checkout solution providing secure digital wallet functionality. Customers can save payment credentials for fast checkout at participating merchants. Transactions use tokenization for security. MODULE 2: COMMON FRAUD TYPES - 1) Stolen Card Fraud - Fraudster uses stolen card details at checkout. 2) Account Takeover - Criminal gains access to legitimate customer account. 3) Friendly Fraud - Customer disputes legitimate purchase claiming fraud. 4) Merchant Fraud - Merchant charges customer for services not delivered. 5) Chargeback Fraud - Customer receives goods but disputes charge. MODULE 3: DETECTION SIGNALS - Device Fingerprint Mismatch - Transaction from unrecognized device, Shipping Address Variation - Different from billing address, High-Value First Purchase - Large amount for new customer/merchant, Velocity Patterns - Multiple transactions in short period, Failed Authentication - CVV or 3D Secure failures, Geographic Anomalies - Transaction location does not match customer profile. MODULE 4: RISK SCORING - Paze transactions scored 0-100 using Early Warning risk models. Scores incorporate: Device trust score, Merchant risk category, Customer transaction history, Shipping address validation, Payment velocity, Cross-network intelligence. Scores >70 trigger additional authentication. MODULE 5: AUTHENTICATION METHODS - CVV Verification - Card security code validation, 3D Secure - Additional authentication layer with issuer, Device Recognition - Fingerprinting and trust scoring, Biometric Authentication - Where supported by device, Step-Up Authentication - Additional verification for high-risk transactions. MODULE 6: INVESTIGATION PROCEDURES - Review transaction details and risk signals, Check device and IP address history, Validate shipping address, Contact customer if needed, Review merchant reputation and category, Check for related transactions across network, Document findings in case management system. MODULE 7: CHARGEBACK MANAGEMENT - Customer disputes must be filed within 60 days, Merchant has 10 days to respond with evidence, Evidence includes: Proof of delivery, Customer signature, Transaction logs, Communication records. Valid chargebacks result in refund to customer. MODULE 8: MERCHANT MONITORING - Merchants with high fraud rates monitored closely, Chargeback ratios above 1% flagged, Repeated complaints result in merchant review, Merchants may be suspended for policy violations. MODULE 9: CUSTOMER EDUCATION - Educate customers on secure checkout practices, Recommend strong passwords and 2FA, Advise monitoring statements regularly, Report unauthorized transactions immediately. MODULE 10: CERTIFICATION - Complete exam with 80% passing score, Annual recertification required, Continuing education on emerging fraud trends.$$,
'1.0', '2024-04-01', '2024-10-01', 'Training Department', 'paze,training,fraud,prevention,checkout', TRUE, '2024-04-01', '2024-10-01'),

('DOC0005', 'Synthetic Identity Fraud Detection FAQ', 'FAQ', 'FRAUD_PREVENTION',
$$Q1: What is synthetic identity fraud? A: Synthetic identity fraud occurs when criminals create fake identities by combining real and fabricated information. Unlike identity theft where a real person identity is stolen, synthetic identities are entirely new personas created for fraud. Q2: Why is synthetic identity fraud difficult to detect? A: Synthetic identities often establish legitimate-looking credit histories over time. They use real SSNs (often from children or deceased individuals) combined with fake names and addresses. Traditional fraud detection may not flag them as fraudulent. Q3: What are common indicators of synthetic identity fraud? A: 1) SSN issued recently but applicant claims long credit history, 2) SSN does not match name in credit bureau records, 3) Address is commercial location or mail drop, 4) Phone number is prepaid/VOIP, 5) Limited or inconsistent online presence, 6) Multiple applications from same device/IP with different identities, 7) Credit file is thin with only authorized user accounts, 8) No utility bills or long-term service contracts. Q4: How does Early Warning detect synthetic identities? A: Early Warning uses proprietary synthetic identity detection models scoring 0-100. Models analyze: SSN validation and issuance patterns, Name-SSN-Address correlation across data sources, Credit file characteristics, Velocity of applications, Device and behavioral analytics, Network intelligence from consortium data, Cross-institutional pattern matching. Q5: What score indicates potential synthetic identity? A: Scores 0-30 = Low Risk (likely real identity), 31-60 = Medium Risk (additional verification recommended), 61-85 = High Risk (likely synthetic, manual review required), 86-100 = Very High Risk (likely synthetic, recommend decline). Q6: What should institutions do when synthetic identity detected? A: 1) Do not approve account opening, 2) Request additional documentation, 3) Conduct enhanced identity verification, 4) Consider in-person verification, 5) Report to fraud database, 6) Share intelligence with Early Warning network. Q7: Can synthetic identities be rehabilitated? A: No. Once identified as synthetic, the identity should be flagged permanently in fraud databases. Do not allow account opening even with additional documentation. Q8: What is the financial impact of synthetic identity fraud? A: Industry estimates $6 billion annual losses. Average loss per synthetic identity is $15,000. Synthetic identities often maintain accounts for 2-3 years building credit before busting out with maximum credit utilization and disappearing. Q9: How can institutions prevent synthetic identity fraud? A: Use Early Warning risk models during account opening, Implement enhanced verification for high-risk applications, Validate SSN-name-address correlation, Monitor for velocity patterns, Share confirmed fraud with network, Train staff on detection techniques, Require in-person verification for high-risk applications. Q10: Are there legal considerations? A: Yes. When denying applications for suspected synthetic identity fraud, provide adverse action notices compliant with Fair Credit Reporting Act. Document decision rationale. Do not make accusations of fraud to applicant. Simply state application does not meet approval criteria. Q11: How often should detection models be updated? A: Early Warning updates synthetic identity models quarterly based on latest fraud trends and consortium data. Member institutions receive automatic model updates. Q12: What should customers know? A: Legitimate customers should ensure their SSN and personal information is protected. Monitor credit reports regularly. Report suspected identity theft immediately. Synthetic identity fraud victimizes children whose SSNs are used without knowledge.$$,
'1.2', '2024-05-01', '2024-09-01', 'Fraud Intelligence Team', 'synthetic,identity,fraud,detection,faq', TRUE, '2024-05-01', '2024-09-01');

-- ============================================================================
-- Step 8: Create Cortex Search Service for Fraud Investigation Notes
-- ============================================================================
-- Syntax verified: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search

CREATE OR REPLACE CORTEX SEARCH SERVICE FRAUD_NOTES_SEARCH
  ON note_text
  ATTRIBUTES alert_id, customer_id, institution_id, note_type, case_status, tags, investigation_date
  WAREHOUSE = EARLY_WARNING_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for fraud investigation notes - enables semantic search across unstructured investigation documentation'
AS
  SELECT
    note_id,
    note_text,
    alert_id,
    customer_id,
    institution_id,
    note_type,
    case_status,
    amount_involved,
    tags,
    investigation_date,
    created_at
  FROM RAW.FRAUD_INVESTIGATION_NOTES;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Customer Support Transcripts
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE SUPPORT_TRANSCRIPTS_SEARCH
  ON transcript_text
  ATTRIBUTES customer_id, institution_id, channel, category, resolution_status, support_date
  WAREHOUSE = EARLY_WARNING_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for customer support transcripts - enables semantic search across customer interactions'
AS
  SELECT
    transcript_id,
    transcript_text,
    customer_id,
    institution_id,
    channel,
    category,
    sentiment_score,
    resolution_status,
    support_date,
    created_at
  FROM RAW.CUSTOMER_SUPPORT_TRANSCRIPTS;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Policy Documents
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE POLICY_DOCUMENTS_SEARCH
  ON document_text
  ATTRIBUTES document_type, document_category, document_title, version, effective_date
  WAREHOUSE = EARLY_WARNING_WH
  TARGET_LAG = '24 hours'
  COMMENT = 'Cortex Search service for policy documents - enables semantic search across fraud prevention policies and procedures'
AS
  SELECT
    document_id,
    document_title,
    document_type,
    document_category,
    document_text,
    version,
    effective_date,
    last_reviewed_date,
    tags,
    created_at
  FROM RAW.POLICY_DOCUMENTS;

-- ============================================================================
-- Step 11: Verify Cortex Search Services Created
-- ============================================================================

SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- ============================================================================
-- Display success message
-- ============================================================================

SELECT 'Cortex Search services created successfully' AS status,
       COUNT(*) AS service_count
FROM (
  SELECT 'FRAUD_NOTES_SEARCH' AS service_name
  UNION ALL
  SELECT 'SUPPORT_TRANSCRIPTS_SEARCH'
  UNION ALL
  SELECT 'POLICY_DOCUMENTS_SEARCH'
);

-- ============================================================================
-- NOTES FOR USERS:
-- ============================================================================
-- 1. Cortex Search services will begin indexing immediately after creation
-- 2. Initial indexing may take several minutes depending on data volume
-- 3. Services automatically refresh based on TARGET_LAG setting
-- 4. Query the services using the REST API or Snowpark
-- 5. See AGENT_SETUP.md for instructions on integrating with Intelligence Agent
-- ============================================================================

