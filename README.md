# Bellabeat Smart Device Analytics: Executive Insights Portfolio Project

An end-to-end, production-quality analytics project designed to identify consumer behavior trends from Fitbit smart device users and translate them into growth opportunities for Bellabeat, a high-tech wellness company for women.

---

## 1. Executive Summary

This project conducts a 2-month longitudinal study of 35 smart device users tracking physical activity, sleep, and weight. The final results reveal critical, counter-intuitive insights regarding user habit structures, including a significant **53.7-minute sleep reduction** on highly active days, which highlights a crucial lifestyle trade-off. We propose three actionable marketing and product recommendations to improve user wellness and drive premium subscriptions for Bellabeat's ecosystem.

---

## 2. Project at a Glance

| Metric | Project Value |
|---|---|
| **Analysis Duration** | 2 months (61 days, March 12 - May 12, 2016) |
| **Users Analyzed** | 35 unique users |
| **Raw Files Processed** | 10 raw CSV files |
| **Engineered Features** | 14+ engineered features (e.g. sleep efficiency, active percentages, consistency) |
| **SQL Queries** | 20 intermediate-to-advanced analytical queries |
| **Statistical Tests** | 2 Paired samples t-tests, Shapiro-Wilk normality tests, Wilcoxon signed-rank tests, K-Means clustering |
| **Python Scripts** | 6 modular scripts (`config.py`, `utils.py`, `preprocessing.py`, `feature_engineering.py`, `analysis.py`, `db_setup.py`) |
| **Jupyter Notebooks** | 5 notebooks |
| **Tableau Dashboard(s)** | 1 Executive Dashboard Spec |

---

## 3. Business Problem

Urška Sršen (Chief Creative Officer & Co-founder) believes that analyzing smart device tracker data can unlock new growth opportunities for Bellabeat's own line of products: the **Bellabeat App**, **Leaf tracker**, **Time smartwatch**, and **Spring smart water bottle**.

### Objectives:
* Analyze how non-Bellabeat consumers use their smart devices day-to-day.
* Apply Python, SQL, and statistical reasoning to clean, segment, and model user behaviors.
* Translate data-driven findings into marketing campaigns and product enhancements for Bellabeat.

---

## 4. Tech Stack

| Category | Technology | Usage / Purpose |
|---|---|---|
| **Programming** | Python 3.14 | Core language for scripting and analytics |
| **Data Processing** | Pandas, NumPy | Data cleaning, merging, and feature engineering |
| **Statistics** | SciPy, Statsmodels, Scikit-learn | Normality checks, t-tests, K-means clustering |
| **Database** | SQLite3 | Reusable local database engine |
| **SQL** | SQL (ANSI compliant) | Database views, CTEs, and window functions |
| **Visualization** | Matplotlib, Seaborn, Tableau | Exploratory plotting and executive dashboard design |
| **Version Control** | Git / GitHub | Code management, replication, and hosting |

---

## 5. Technical Competencies Demonstrated

### Python Engineering
* Developed a modular, config-driven script architecture utilizing logging, error handling, and relative directory paths rather than hardcoded references.

### Data Cleaning
* Reconstructed Month 1 daily sleep metrics from raw minute-level datasets.
* Audited and resolved transition-day cut-off discrepancies (April 12, 2016) where Month 1 tracking was terminated at 10:00 AM, avoiding step count deflation.

### Feature Engineering
* Calculated record-level metrics (sleep efficiency, active ratio, sedentary percentage) and user-level aggregates (average daily steps, sleep consistency standard deviations, weekend-to-weekday activity change percentages).

### SQL Analytics
* Built analytical database views joining physical activity with sleep records.
* Authored 20 complex queries implementing rolling window averages, CTEs, dense ranking, percent contribution, and covariance-correlation proxies.

### Statistical Analysis
* Applied normality tests (Shapiro-Wilk) to verify assumptions before executing parametric paired t-tests.
* Calculated Cohen's $d$ effect sizes and 95% confidence intervals to evaluate practical vs. statistical significance.
* Performed K-means clustering to segment users based on activity and sleep profiles.

### Data Visualization
* Structured clean, minimalist exploratory plots in Seaborn and mapped calculations, worksheet layouts, and action filters for a premium Tableau executive dashboard.

### Business Communication
* Translated statistical metrics and data discrepancies into clear, actionable C-suite reports using the Observation $\rightarrow$ Evidence $\rightarrow$ Business Impact $\rightarrow$ Recommendation framework.

### Documentation & Reproducibility
* Standardized dependencies in `requirements.txt`, created a `.gitignore`, and detailed numbered, step-by-step setup guides to guarantee 100% project reproducibility.

---

## 6. Architecture Diagram

```mermaid
graph TD
    A[Raw Month 1 & 2 Data] --> B[preprocessing.py]
    B -->|Deduplicate & Align Sleep| C[Cleaned CSV Data]
    C --> D[feature_engineering.py]
    D -->|Add Deficit & Consistency Metrics| E[Engineered CSV Features]
    E --> F[db_setup.py]
    F -->|Run schema.sql & views.sql| G[(sqlite3: bellabeat.db)]
    G --> H[analysis.py]
    G --> I[Tableau Views]
    H -->|Paired t-tests & KMeans| J[Statistical Findings]
    I -->|Visual Encodings| K[Tableau Dashboard]
    J --> L[Business Recommendations]
    K --> L
```

---

## 7. Methodology

Rather than analyzing only the standard 30-day Fitabase dataset (which is the typical course submission pattern), this project **consolidates both available Mechanical Turk datasets** to construct a seamless **61-day tracking window (March 12 - May 12, 2016)**.

### Transition Day Audit & Deduplication
Our data provenance audit uncovered a critical data quality issue on the transition date **April 12, 2016**, which appeared in both datasets. 
* Hourly logs showed that Month 1 was cut off at **10:00 AM** on April 12, resulting in artificially deflated step and calorie counts.
* Month 2 recorded the full **24-hour cycle**.
* **Consolidation Rule:** We discarded the Month 1 transition-day records and preserved Month 2's complete records, preventing data corruption and protecting our analysis from deflated averages.

### Sleep Data Reconstruction
Since Month 1 only contained minute-level sleep logs, we built a custom aggregator in `preprocessing.py` that maps sleep records to the **waking calendar date** (matching Fitabase's native behavior) and sums the minutes to construct a uniform sleep table.

---

## 8. Key Findings

### Statistical Insights:
1. **The Sleep-Activity Tradeoff (Hypothesis Test):**
   * *Business Question:* Do highly active days improve sleep duration?
   * *Test:* Paired samples t-test comparing sleep duration on active vs. inactive days.
   * *Evidence:* On highly active days (MVPA >= 21 mins or steps >= 12,000), users sleep **53.7 minutes LESS** on average than on inactive days ($t = -3.32, p = 0.0038$, Cohen's $d = -0.76$, 95% CI: $[-87.7, -19.7]$ mins).
   * *Practical Impact:* Active days coincide with busy schedules where users sacrifice sleep. Bellabeat must actively protect users' sleep windows on high-activity days.
2. **Weekly Steps (Weekday vs. Weekend):**
   * *Business Question:* Do users walk more on weekends?
   * *Evidence:* Weekday average steps (7,142) vs. weekend average steps (6,936) showed no statistically significant difference ($t = -0.47, p = 0.6392$, Cohen's $d = -0.08$). Activity levels are consistently low throughout the entire week.
3. **Sedentary Dominance:**
   * Average sedentary time is **79% of the tracked day** (11.8 hours). Users are overwhelmingly desk-bound.

### Behavioral Segmentation:
Unsupervised K-means clustering (N=3) identified distinct profiles:
* **Cluster 0 (50% of users) - Consistent Moderate Walkers:** ~8k steps/day, 7.4 hours sleep.
* **Cluster 1 (29% of users) - Sleep-Deprived Walkers:** ~9.8k steps/day, but only 3.6 hours sleep. High activity coupled with severe sleep deficits.
* **Cluster 2 (21% of users) - Sedentary Sleepers:** ~2.8k steps/day, 7.6 hours sleep.

---

## 9. Dashboard Preview

### Executive Dashboard
![Executive Dashboard Mockup](images/dashboard_mockup.png)
*Caption: High-fidelity executive visualization presenting core KPI cards, daily step distributions, and sleep efficiency indices compiled from consolidated database views.*

### Activity Dashboard
*(Placeholder for Activity Dashboard Screenshot)*
*Caption: Detailed hourly analysis of peak walking cycles, sedentary times, and WHO MVPA guideline compliance rates.*

### Sleep Dashboard
*(Placeholder for Sleep Dashboard Screenshot)*
*Caption: Visualizing individual sleep efficiency ratios, sleep latency (time awake in bed), and sleep deficit categories.*

### Behavioral Segmentation
*(Placeholder for Behavioral Segmentation Dashboard Screenshot)*
*Caption: Multi-dimensional user profiling comparing K-means cluster classifications with Tudor-Locke step cohorts.*

---

## 10. Business Recommendations

Every recommendation maps directly to Bellabeat's marketing and product development strategies:

1. **Product: Introduce the "Recovery Optimizer"**
   * *Observation:* Sleep duration drops by nearly an hour (53.7 mins) on highly active days.
   * *Evidence:* Paired t-test ($p = 0.0038$, Cohen's $d = -0.76$).
   * *Impact:* High active days without adequate sleep recovery lead to physical burnout and reduced compliance.
   * *Recommendation:* Implement a feature in the Bellabeat App. When the Leaf or Time tracker logs a highly active day, the app should trigger a wind-down notification 60 minutes early, offering a guided meditation or breathing session to protect the sleep window.
2. **Marketing: "Wellness Companions for the Working Woman"**
   * *Observation:* Users spend over 12 hours a day sedentary, mostly during business hours.
   * *Evidence:* Average sedentary ratio is 79%; 63% of tracked days exceed 12 hours of inactivity.
   * *Impact:* Prolonged sitting increases long-term health risks, leading to wellness dissatisfaction.
   * *Recommendation:* Launch a marketing campaign highlighting the Leaf's silent haptic alarms. Program the tracker to send a gentle vibration after 60 consecutive sedentary minutes, nudging the user to do a 3-minute "Desk Yoga" stretch from the Bellabeat library.
3. **Strategy: Cycle-Synced Goal Setting**
   * *Observation:* Standard trackers treat users identically. Bellabeat can leverage its female focus.
   * *Evidence:* Medical literature (CDC/WHO) shows that menstrual phases affect energy, recovery, and sleep.
   * *Impact:* General fitness targets are often unrealistic during certain phases of the cycle, frustrating users.
   * *Recommendation:* Enable cycle-synced goals in the Bellabeat App. Daily step targets and sleep reminders should adjust dynamically according to the user's menstrual phase (e.g., higher step goals in the follicular phase, active recovery prompts in the luteal phase).

---

## 11. Repository Structure

```
Bellabeat-Smart-Device-Analytics/
├── .gitignore
├── README.md
├── requirements.txt
├── data/
│   ├── raw/                 # Raw datasets (split by Month 1 & Month 2 folders)
│   └── processed/           # Cleaned, deduplicated, and feature-engineered outputs
├── scripts/
│   ├── config.py            # Global constants, seeds, and directories
│   ├── utils.py             # Shared logging and string sanitization functions
│   ├── preprocessing.py     # Aggregates sleep, applies transition-day deduplication
│   ├── feature_engineering.py # Computes sleep efficiency, active percentages, consistency
│   ├── analysis.py          # Runs paired t-tests, ANOVA, and KMeans clustering
│   └── db_setup.py          # Populates SQLite database with cleaned files
├── sql/
│   ├── schema.sql           # Reusable DDL schemas
│   ├── views.sql            # Table joins and segmentation views
│   └── business_queries.sql # ~20 business queries (CTEs, windows, rolling averages)
├── notebooks/
│   ├── 01_data_preparation.ipynb
│   ├── 02_exploratory_analysis.ipynb
│   ├── 03_feature_engineering.ipynb
│   ├── 04_statistical_analysis.ipynb
│   └── 05_tableau_export.ipynb
├── tableau/
│   └── dashboard_spec.md    # Tableau calculated fields and visual spec
└── reports/
    ├── data_provenance.md   # Data audit report (Month 1/2 transition cut-off finding)
    ├── data_quality_summary.md # Post-cleaning metrics
    ├── statistical_and_segmentation_analysis.md # Statistical outputs
    └── executive_summary.md # Executive business brief
```

---

## 12. Setup Instructions

Follow these numbered steps to reproduce the entire analytics pipeline locally:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Shanksreddy005/Bellabeat-Smart-Device-Analytics-Platform.git
   cd Bellabeat-Smart-Device-Analytics-Platform
   ```
2. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
3. **Verify the Dataset Placement:**
   Ensure the raw Fitbit files are placed in the `data/raw/month1/` and `data/raw/month2/` folders respectively, as mapped out in `scripts/config.py`.
4. **Execute Preprocessing:**
   ```bash
   python scripts/preprocessing.py
   ```
   This will align datatypes, aggregate Month 1 sleep records, execute transition-day deduplication, and export clean files to `data/processed/`.
5. **Run Feature Engineering:**
   ```bash
   python scripts/feature_engineering.py
   ```
   This generates active ratios, sleep efficiency, user consistencies, and behavioral classifications.
6. **Initialize the SQLite Database:**
   ```bash
   python scripts/db_setup.py
   ```
   This will initialize `data/processed/bellabeat.db`, execute `sql/schema.sql` and `sql/views.sql`, and populate the tables with processed data.
7. **Execute Notebooks:**
   Open Jupyter Notebook or Lab and run the notebooks in `notebooks/` sequentially to interactively inspect results.
8. **Open Tableau Workbook:**
   Connect Tableau Desktop to the generated SQLite database `bellabeat.db` or the processed CSV exports, using the specs in `tableau/dashboard_spec.md` to map calculations and filter actions.

---

## 13. Project Limitations

* **Historical Dataset:** The Fitbit dataset was collected in 2016. While standard for training analyses, consumer behavior, screen time habits, and wearable technology accuracy have evolved.
* **Small Participant Pool:** The study tracks 35 users, which decreases to 24 users for sleep analysis and only 8-11 users for weight logging. This small sample size restricts generalized demographic representation.
* **No Demographic Attributes:** The dataset lacks gender, age, occupation, and geographical location indicators. Because Bellabeat products are specifically designed for women, demographic alignments are based on medical literature rather than direct evidence.
* **Wearable Hardware Limitations:** Smart device tracker logs are subject to user errors, non-wear times, and battery drains which can introduce noise.
* **Association vs. Causation:** The findings show statistical associations (e.g., lower sleep duration on active days) but cannot verify direct physical or psychological causation.
* **Direct Inference Constraints:** Fitbit consumer habits serve as a proxy and cannot directly infer how current Bellabeat customers interact with Bellabeat-specific hardware.

---

## 14. Future Improvements

* **Predictive Modeling:** Build machine learning classifiers (e.g., Random Forests or XGBoost) to predict days when a user is likely to experience a sleep deficit based on mid-day activity.
* **Anomaly Detection:** Implement automated alerts for sudden declines in sleep efficiency or device wear time, signaling potential illness or abandonment.
* **Automated ETL Scheduling:** Design an Apache Airflow or Prefect pipeline to automate daily data ingestion, cleaning, and model updates.
* **Interactive Streamlit Deployment:** Build an interactive Python dashboard using Streamlit to serve as a web-based presentation of the metrics.
* **Cloud Database Migration:** Migrate the local SQLite instance to a cloud data warehouse (e.g., Snowflake or Google BigQuery) to simulate enterprise analytical workloads.
* **Additional Wearable Integrations:** Expand the ingestion scripts to process Apple Health, Garmin, and Oura Ring datasets.
* **Longitudinal Cohort Study:** Analyze multi-year tracker logs to model seasonality and long-term user retention.

---

## 15. Project Outcomes

This project demonstrates a production-quality analytical portfolio piece featuring:
* **✓ Reproducible Analytics Pipeline:** Dynamic configuration management, standard utilities, and clean logging.
* **✓ Production-Quality ETL:** Seamless merging of disjoint datasets, cleaning overlapping transition periods, and aggregating granular time series.
* **✓ SQL Analytical Reporting:** CTEs, window functions, and views designed to support executive decision-making.
* **✓ Statistical Hypothesis Testing:** Normality checking, paired samples modeling, and multi-dimensional K-means user segmentation.
* **✓ Executive Dashboard Design:** Comprehensive calculated field mapping and interaction guides.
* **✓ Business Recommendation Framework:** Data-driven strategic insights directly mapped to Bellabeat's marketing positioning.
