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

