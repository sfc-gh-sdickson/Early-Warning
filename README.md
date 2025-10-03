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

2. **ANALYTICS Schema**: Curated views and semantic models
   - Customer 360 views
   - Fraud detection analytics
   - Payment network analytics
   - Risk scoring models
   - Semantic views for AI agents

## Files

- `01_setup_database.sql`: Database and schema creation
- `02_create_tables.sql`: Table definitions with proper constraints
- `03_generate_sample_data.sql`: Realistic sample data generation
- `04_create_views.sql`: Analytical views
- `05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `questions.md`: 10 complex questions the agent can answer
- `AGENT_SETUP.md`: Configuration instructions for Snowflake agents

## Setup Instructions

1. Execute SQL files in order (01 through 05)
2. Follow AGENT_SETUP.md for agent configuration
3. Test with questions from questions.md

## Data Model Highlights

- Realistic fraud patterns (3-5% fraud rate)
- Multi-institutional payment flows
- Risk scoring based on Early Warning's intelligence
- Time-series transaction data with seasonal patterns
- Customer relationship mapping across institutions

---

*Based on Early Warning's public information from earlywarning.com*
*Created: October 2025*

