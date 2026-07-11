# Customer Transactions & Account Analytics Dashboard

🔗 **[Live Dashboard Link](https://datastudio.google.com/u/0/reporting/73aefbee-18e4-45a7-9f40-908c2d859adb/page/RHd3F)**

## Overview
This dashboard provides a comprehensive view of retail banking performance, customer transaction behaviors, ledger balances, and operational health metrics. It integrates dimensional data models mapping customer records and account states with a transactional fact layer to extract high-level organizational insights.

## Connected Data Sources
The dashboard connects directly to the core analytical database schema, pulling from the following distinct data models:

1. **`DIM_CUSTOMERS` (Dimension Table)**
   * **Purpose:** Serves as the master registry for customer metadata.
   * **Key Fields Used:** `CUSTOMER_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `CREATED_AT`, `IS_CURRENT`.
   * **Note:** Implements Type-2 Slowly Changing Dimension (SCD Type 2) tracking with `EFFECTIVE_FROM`, `EFFECTIVE_TO`, and `IS_CURRENT` to maintain point-in-time profile state history.

2. **`DIM_ACCOUNTS` (Dimension Table)**
   * **Purpose:** Stores details regarding historical and active financial accounts.
   * **Key Fields Used:** `ACCOUNT_ID`, `ACCOUNT_TYPE` (e.g., Savings, Checking), `BALANCE`, `CURRENCY`, `IS_CURRENT`.

3. **`FACT_TRANSACTIONS` (Fact Table)**
   * **Purpose:** Captures immutable streaming ledger records recording actual monetary exchanges.
   * **Key Fields Used:** `TRANSACTION_ID`, `ACCOUNT_ID`, `CUSTOMER_ID`, `AMOUNT`, `STATUS`, `TRANSACTION_TYPE`, `TRANSACTION_TIME`.

---

## Data Blending Configurations
To generate user-centric revenue insights, the dashboard employs a specific data blend configuration detailed below:

### **Blend Name: `Customer to transaction Blend`**
This configurations creates a unified collection combining user identifiers with aggregated operational metrics.

* **Join Typology:** Left Outer Join (`Table 1 ⟕ Table 2`)
  * **Left Table (Primary):** `dim_customers`
  * **Right Table (Secondary):** `fact_transactions`
* **Join Condition:** `dim_customers.CUSTOMER_ID` = `fact_transactions.CUSTOMER_ID`

### **Included Dimensions & Metrics in the Blend:**
* **Dimensions:**
  * `CUSTOMER_ID` (Key field)
  * `FIRST_NAME`
  * `LAST_NAME`
  * `EMAIL`
* **Metrics:**
  * `No of Transactions` (Derived aggregation tracking frequency)
  * `Success Transaction Amount` (Filtered metric isolating completed transfers)
  * `Total Transaction Amount` (Summed financial volume per user)
  * `Record Count`

---

## Visualizations Implemented

### 1. Executive KPIs
* **Total Transaction Value:** `$1,790,576` — High-level metric summing absolute money processed.
* **Total Transaction Volume:** `1,300` — Cumulative count of individual financial items executed.
* **Active Customers:** `500` — Unique current base total tracking unique consumer profiles.
* **Total Funds Held:** `$2,356,818` — Aggregate capital held inside current active ledger structures.

### 2. Operational & Distribution Graphs
* **Transaction Volume & Value Over Time:** Time-series line chart detailing historical trajectories over distinct window intervals (July 10 to July 11).
* **Transactions by Type:** Donut chart highlighting split volume breakdowns across core activities: **Withdrawals (35.1%)**, **Transfers (33%)**, and **Deposits (31.9%)**.
* **Current Balances by Account Type:** Visual stack breakdown tracking funds volume grouped across specific instruments (**Savings** vs **Checking** styles).
* **Current Balances by Currency:** Clear separation tracking asset exposure profiles categorized by legal tender bases (**INR** vs **USD** groups).

### 3. Integrated Top Customer Lists
* **Top 10 Customers by Lifetime Value/Volume:** Structured tabular asset fueled by the **`Customer to transaction Blend`**. This view highlights core premium users sorted by aggregate volume metrics alongside exact tracking keys for administrative review.
README.md
Displaying README.md.