<img src="Snowflake_Logo.svg" width="200">

# Early Warning Intelligence Demo

## About Early Warning

Early Warning Services, LLC is a financial services technology leader that has been empowering and protecting consumers, small businesses, and the U.S. financial system with cutting-edge fraud and payment solutions for over three decades.

### Key Business Lines

- **Zelle® Digital Payment Network**: Fast, safe money transfers between consumers and businesses ($1 trillion moved in 2024)
- **Paze℠ Online Checkout Solution**: Secure digital wallet combining credit and debit cards
- **Payment & Identity Risk Solutions**: Network intelligence for fraud prevention
- **Account Opening Intelligence**: Risk assessment for new account applications

### Network Scale

- 2,500+ financial institutions, government, and payment companies
- 151 million enrolled Zelle accounts
- $3 billion in potential annual fraud prevented
- 150 million cards eligible for Paze checkout

## Project Overview

This Snowflake Intelligence solution demonstrates how Early Warning's banking partners can leverage AI agents to analyze:

- **Fraud Detection**: Real-time fraud patterns and prevention effectiveness
- **Payment Analytics**: Zelle and Paze transaction insights
- **Risk Management**: Account opening risk scores and trends
- **Customer Intelligence**: 360-degree customer view with payment behavior
- **Network Health**: Cross-institutional payment flows and risk metrics
- **Unstructured Data Search**: Semantic search over fraud investigation notes, support transcripts, and policy documents using Cortex Search

## Database Schema

The solution includes:

1. **RAW Schema**: Core banking tables
   - CUSTOMERS: Customer master data
   - ACCOUNTS: Bank accounts (checking, savings, credit cards)
   - TRANSACTIONS: All account transactions
   - ZELLE_PAYMENTS: P2P payments via Zelle network
   - PAZE_TRANSACTIONS: Online checkout transactions
   - FRAUD_ALERTS: Fraud detection system alerts
   - ACCOUNT_OPENINGS: New account applications with risk scores
   - FINANCIAL_INSTITUTIONS: Early Warning network members
   - FRAUD_INVESTIGATION_NOTES: Unstructured fraud investigation documentation (50K notes)
   - CUSTOMER_SUPPORT_TRANSCRIPTS: Customer service interaction records (25K transcripts)
   - POLICY_DOCUMENTS: Fraud prevention policies, procedures, training materials, and FAQs

2. **ANALYTICS Schema**: Curated views and semantic models
   - Customer 360 views
   - Fraud detection analytics
   - Payment network analytics
   - Risk scoring models
   - Semantic views for AI agents

3. **Cortex Search Services**: Semantic search over unstructured data
   - FRAUD_NOTES_SEARCH: Search fraud investigation notes
   - SUPPORT_TRANSCRIPTS_SEARCH: Search customer support interactions
   - POLICY_DOCUMENTS_SEARCH: Search policies and training materials

## Files

- `01_setup_database.sql`: Database and schema creation
- `02_create_tables.sql`: Table definitions with proper constraints
- `03_generate_sample_data.sql`: Realistic sample data generation
- `04_create_views.sql`: Analytical views
- `05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `questions.md`: 10 complex questions the agent can answer
- `AGENT_SETUP.md`: Configuration instructions for Snowflake agents

## Setup Instructions

1. Execute SQL files in order (01 through 06)
2. Follow AGENT_SETUP.md for agent configuration
3. Test with questions from questions.md
4. Test Cortex Search with sample queries in AGENT_SETUP.md Step 5

## Data Model Highlights

### Structured Data
- Realistic fraud patterns (3-5% fraud rate)
- Multi-institutional payment flows
- Risk scoring based on Early Warning's intelligence
- Time-series transaction data with seasonal patterns
- Customer relationship mapping across institutions

### Unstructured Data (New in v2.0)
- 50,000 fraud investigation notes with realistic case documentation
- 25,000 customer support transcripts across multiple channels
- 5 comprehensive policy documents (fraud prevention, risk management, training)
- Semantic search powered by Snowflake Cortex Search
- RAG (Retrieval Augmented Generation) ready for AI agents

## Key Features

✅ **Hybrid Data Architecture**: Combines structured tables with unstructured text data  
✅ **Semantic Search**: Find similar fraud cases and policy guidance by meaning, not just keywords  
✅ **RAG-Ready**: Agent can retrieve context from investigation notes and policies  
✅ **Production-Ready Syntax**: All SQL verified against Snowflake documentation  
✅ **Comprehensive Demo**: 2M+ transactions, 50K fraud notes, 25K support cases  

---

*Based on Early Warning's public information from earlywarning.com*  
*Created: October 2025*  
*Version 2.0 - Added Cortex Search for unstructured data*

