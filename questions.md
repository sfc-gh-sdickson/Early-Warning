<img src="Snowflake_Logo.svg" width="200">

# Early Warning Intelligence Agent - Complex Questions

These 10 complex questions demonstrate the intelligence agent's ability to analyze Early Warning's network data, fraud patterns, payment flows, and risk metrics across multiple dimensions.

---

## 1. Network Fraud Prevention Effectiveness

**Question:** "What is the fraud prevention effectiveness across our Early Warning network? Show me the total amount at risk from fraud alerts, total amount recovered, recovery rate percentage, and break it down by fraud type and detection method. Which detection method has the highest recovery rate?"

**Why Complex:** 
- Requires aggregation across fraud alerts
- Calculates derived metrics (recovery rate)
- Multi-dimensional breakdown (fraud type + detection method)
- Comparative analysis across methods

---

## 2. Cross-Institutional Zelle Payment Flows

**Question:** "Analyze Zelle payment flows between different financial institutions in our network. What is the total volume and dollar amount of inter-bank vs intra-bank payments? Which institution pairs have the highest payment volumes? What percentage of cross-bank payments are flagged for fraud?"

**Why Complex:**
- Requires relationship analysis between sender and receiver institutions
- Multiple aggregations (count, sum, percentage)
- Categorization logic (inter-bank vs intra-bank)
- Ranking and sorting
- Fraud correlation

---

## 3. Customer Risk Segmentation with Payment Behavior

**Question:** "Segment our customers by risk score (low, medium, high, critical) and show me the average Zelle payment volume, Paze transaction volume, account balance, and fraud incident rate for each segment. Which risk segment generates the most payment volume but has the lowest fraud rate?"

**Why Complex:**
- Customer segmentation by risk
- Multiple data sources (customers, Zelle, Paze, fraud, accounts)
- Multiple metrics per segment
- Cross-segment comparison
- Identifies optimal risk/reward segment

---

## 4. Account Opening Risk Model Performance

**Question:** "Evaluate our account opening risk assessment model performance. For applications that were approved but later had confirmed fraud incidents within 90 days, what were the average Early Warning risk scores, synthetic identity scores, and velocity scores at the time of application? Compare this to approved applications with no fraud. Are we approving high-risk applicants?"

**Why Complex:**
- Temporal analysis (fraud within 90 days of approval)
- Requires joining account openings to fraud alerts with time window
- Comparative analysis between fraud/no-fraud cohorts
- Multiple risk score dimensions
- Model effectiveness evaluation

---

## 5. Paze Merchant Fraud Patterns

**Question:** "Which online merchants have the highest fraud rates in Paze transactions? Show me merchants with at least 100 transactions, calculate their fraud rate (fraud-flagged / total transactions), chargeback rate, average risk score, and decline rate. Are high-fraud merchants correlated with specific device types or missing security checks?"

**Why Complex:**
- Merchant-level aggregation with minimum threshold
- Multiple rate calculations
- Correlation analysis (fraud vs device type, security checks)
- Multi-dimensional pattern detection
- Statistical filtering

---

## 6. Seasonal Payment Trends with Fraud Correlation

**Question:** "Analyze Zelle payment volumes and fraud rates by month, day of week, and hour of day over the past 12 months. When do we see the highest payment volumes? When do we see the highest fraud rates? Are there temporal patterns where high volume correlates with high fraud?"

**Why Complex:**
- Time-series analysis at multiple granularities (month, day, hour)
- Multiple metrics (volume and fraud rate)
- Pattern identification
- Correlation analysis
- 12-month historical data

---

## 7. Institution Performance Benchmarking

**Question:** "Benchmark our network institutions by tier (Platinum, Gold, Silver, Bronze). For each tier, show me average customer count, total deposits, Zelle payment volume, Paze transaction volume, fraud alert rate per 1000 customers, and account opening approval rate. Which tier is performing best across multiple dimensions?"

**Why Complex:**
- Institution grouping by tier
- Multiple performance metrics
- Normalized metrics (fraud rate per 1000 customers)
- Cross-dimensional performance evaluation
- Relative ranking

---

## 8. Synthetic Identity Detection Patterns

**Question:** "Identify potential synthetic identity fraud patterns in our account opening applications. Show me applications with synthetic identity scores above 70, cross-referenced with velocity check scores, fraud database hits, and credit scores. For applications that were approved despite high synthetic scores, have any had fraud alerts? What patterns distinguish false positives from true synthetic identities?"

**Why Complex:**
- Multi-score filtering and correlation
- Conditional analysis (approved despite high scores)
- Pattern recognition across multiple variables
- False positive analysis
- Predictive pattern identification

---

## 9. Chargeback Cost Analysis

**Question:** "Calculate the total cost of Paze transaction chargebacks across our network. Show me chargeback volume, chargeback rate by merchant category, average days to chargeback, total fees lost, and compare the risk scores of transactions that resulted in chargebacks vs successful transactions. Which merchant categories have the highest chargeback risk?"

**Why Complex:**
- Financial impact calculation
- Category-level aggregation
- Temporal metrics (days to chargeback)
- Comparative analysis (chargeback vs non-chargeback)
- Risk correlation
- Category ranking

---

## 10. Network Intelligence ROI Analysis

**Question:** "Calculate the ROI of Early Warning's fraud prevention network. Show me total fraud alerts generated, confirmed fraud cases, total amount at risk, total amount recovered, prevented fraud (blocked transactions), and estimated fraud prevention value. Break this down by institution tier and detection method. Which institutions and methods provide the highest fraud prevention ROI?"

**Why Complex:**
- Multi-dimensional ROI calculation
- Requires calculating prevented fraud (counterfactual analysis)
- Aggregation by multiple dimensions (tier + method)
- Financial metrics across the network
- Comparative ROI analysis
- Value attribution

---

## Question Complexity Summary

These questions test the agent's ability to:

1. **Multi-table joins** - connecting customers, accounts, transactions, payments, fraud alerts
2. **Temporal analysis** - time-based patterns, historical comparisons, seasonal trends
3. **Segmentation & classification** - risk tiers, customer segments, fraud categories
4. **Derived metrics** - rates, percentages, ratios, normalized values
5. **Correlation analysis** - identifying relationships between variables
6. **Pattern recognition** - fraud patterns, synthetic identity markers, payment flows
7. **Comparative analysis** - benchmarking, performance comparison, cohort analysis
8. **Financial calculations** - ROI, cost analysis, recovery rates
9. **Aggregation at multiple levels** - customer, account, institution, network
10. **Statistical filtering** - minimum thresholds, outlier detection, distribution analysis

These questions reflect realistic business intelligence needs for Early Warning's fraud prevention and payment network operations.

---

## Cortex Search Questions (Unstructured Data)

These questions test the agent's ability to search and retrieve insights from unstructured data using Cortex Search services.

### 11. Similar Fraud Case Analysis

**Question:** "Find similar account takeover cases from the last 6 months. What investigation procedures were used? What was the average amount involved and recovery rate?"

**Why Complex:**
- Semantic search over fraud investigation notes
- Time-based filtering
- Pattern extraction from unstructured text
- Aggregation of amounts and outcomes

**Data Source:** FRAUD_NOTES_SEARCH

---

### 12. Policy Guidance Retrieval

**Question:** "What does our policy say about handling Zelle payment disputes? Include information about reversal policies and customer protection timelines."

**Why Complex:**
- Searches policy documents for specific topics
- Extracts relevant policy details
- Synthesizes information across multiple documents
- Provides actionable guidance

**Data Source:** POLICY_DOCUMENTS_SEARCH

---

### 13. Customer Support Case Examples

**Question:** "Show me customer support cases involving elder fraud scams. What resolution strategies were most effective? What were the common warning signs?"

**Why Complex:**
- Semantic search for specific fraud type
- Pattern recognition across transcripts
- Effectiveness analysis from resolution status
- Extraction of warning signs from narratives

**Data Source:** SUPPORT_TRANSCRIPTS_SEARCH

---

### 14. Synthetic Identity Investigation Procedures

**Question:** "How do we detect synthetic identity fraud according to our guidelines? What red flags should investigators look for during account opening reviews?"

**Why Complex:**
- Searches policy documents and FAQs
- Extracts procedural information
- Lists specific detection indicators
- Provides investigator guidance

**Data Source:** POLICY_DOCUMENTS_SEARCH

---

### 15. Fraud Ring Investigation Patterns

**Question:** "Find investigation notes about fraud rings and organized crime. What tactics did these fraud rings use? How were they detected and what was the network exposure?"

**Why Complex:**
- Semantic search with multiple related terms
- Pattern extraction from investigation notes
- Financial impact aggregation
- Detection method identification

**Data Source:** FRAUD_NOTES_SEARCH

---

### 16. Phishing Attack Response Procedures

**Question:** "Find cases where customers fell victim to phishing attacks. What were the common characteristics? How did customer support handle these cases? What prevention measures were recommended?"

**Why Complex:**
- Cross-searches fraud notes and support transcripts
- Extracts characteristics from unstructured text
- Identifies resolution patterns
- Lists prevention recommendations

**Data Sources:** FRAUD_NOTES_SEARCH, SUPPORT_TRANSCRIPTS_SEARCH

---

### 17. Chargeback Dispute Resolution Examples

**Question:** "Show me customer support transcripts about Paze chargeback disputes. What evidence was required? What were the outcomes? How long did resolution take?"

**Why Complex:**
- Semantic search for dispute-related conversations
- Extraction of requirements and evidence
- Outcome pattern analysis
- Timeline extraction from narratives

**Data Source:** SUPPORT_TRANSCRIPTS_SEARCH

---

### 18. Risk Assessment Training Content

**Question:** "What training materials do we have about Paze checkout fraud detection? What are the key risk scoring factors and authentication methods covered?"

**Why Complex:**
- Searches training documents
- Extracts structured information from unstructured training content
- Lists specific factors and methods
- Provides educational context

**Data Source:** POLICY_DOCUMENTS_SEARCH

---

### 19. Account Takeover Investigation Best Practices

**Question:** "Find recent account takeover investigations and compare the investigation procedures used. What were the successful recovery tactics? What lessons were learned?"

**Why Complex:**
- Semantic search with comparison intent
- Pattern extraction across multiple cases
- Success factor identification
- Lesson synthesis from narratives

**Data Source:** FRAUD_NOTES_SEARCH

---

### 20. Cross-Source Fraud Intelligence

**Question:** "For synthetic identity fraud cases, show me: 1) What our policies say about detection methods, 2) Investigation notes from confirmed cases, and 3) How customer support handled related inquiries. Combine insights from all sources."

**Why Complex:**
- Multi-source search (policies, notes, transcripts)
- Information synthesis across structured and unstructured data
- Context integration from multiple perspectives
- Comprehensive intelligence gathering

**Data Sources:** POLICY_DOCUMENTS_SEARCH, FRAUD_NOTES_SEARCH, SUPPORT_TRANSCRIPTS_SEARCH

---

## Cortex Search Complexity Summary

These Cortex Search questions test the agent's ability to:

1. **Semantic search** - Understanding intent beyond keywords
2. **Unstructured data retrieval** - Finding relevant information in text
3. **Pattern extraction** - Identifying patterns from narratives
4. **Cross-source synthesis** - Combining insights from multiple knowledge bases
5. **Context understanding** - Grasping nuanced questions about procedures and policies
6. **Relevance ranking** - Prioritizing most relevant cases and examples
7. **Information extraction** - Pulling specific details from long-form text
8. **RAG (Retrieval Augmented Generation)** - Using retrieved context to answer questions
9. **Temporal filtering** - Finding recent or time-specific cases
10. **Multi-document synthesis** - Combining information across documents

These questions complement the structured data analytics questions (1-10) by adding unstructured data intelligence capabilities.

