# Bellabeat Smart Device Analytics: Executive Insights Portfolio Project

An end-to-end, production-quality analytics project designed to identify consumer behavior trends from Fitbit smart device users and translate them into growth opportunities for Bellabeat, a high-tech wellness company for women.

---

## 1. Executive Summary

This project conducts a 2-month longitudinal study of 35 smart device users tracking physical activity, sleep, and weight. The final results reveal critical, counter-intuitive insights regarding user habit structures, including a significant **53.7-minute sleep reduction** on highly active days, which highlights a crucial lifestyle trade-off. We propose three actionable marketing and product recommendations to improve user wellness and drive premium subscriptions for Bellabeat's ecosystem.

---

## 2. Business Problem & Objectives

Urška Sršen (Chief Creative Officer & Co-founder) believes that analyzing smart device tracker data can unlock new growth opportunities for Bellabeat's own line of products: the **Bellabeat App**, **Leaf tracker**, **Time smartwatch**, and **Spring smart water bottle**.

### Objectives:
* Analyze how non-Bellabeat consumers use their smart devices day-to-day.
* Apply Python, SQL, and statistical reasoning to clean, segment, and model user behaviors.
* Translate data-driven findings into marketing campaigns and product enhancements for Bellabeat.

---

## 3. Project Architecture

The project is organized following clean, reproducible software engineering standards:

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
├── reports/
│   ├── data_provenance.md   # Data audit report (Month 1/2 transition cut-off finding)
│   ├── data_quality_summary.md # Post-cleaning metrics
│   ├── statistical_and_segmentation_analysis.md # Statistical outputs
│   └── executive_summary.md # Executive business brief
└── images/
    └── dashboard_mockup.png # Tableau dashboard preview
```

---

## 4. Methodology & Data Provenance

Rather than analyzing only the standard 30-day Fitabase dataset (which is the typical course submission pattern), this project **consolidates both available Mechanical Turk datasets** to construct a seamless **61-day tracking window (March 12 - May 12, 2016)**.

### Transition Day Audit & Deduplication
Our data provenance audit uncovered a critical data quality issue on the transition date **April 12, 2016**, which appeared in both datasets. 
* Hourly logs showed that Month 1 was cut off at **10:00 AM** on April 12, resulting in artificially deflated step and calorie counts.
* Month 2 recorded the full **24-hour cycle**.
* **Consolidation Rule:** We discarded the Month 1 transition-day records and preserved Month 2's complete records, preventing data corruption and protecting our analysis from deflated averages.

### Sleep Data Reconstruction
Since Month 1 only contained minute-level sleep logs, we built a custom aggregator in `preprocessing.py` that maps sleep records to the **waking calendar date** (matching Fitabase's native behavior) and sums the minutes to construct a uniform sleep table.

---

## 5. Key Findings

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
* **Cluster 0 (50% of users) - Moderate Walkers:** ~8k steps/day, 7.4 hours sleep.
* **Cluster 1 (29% of users) - Sleep-Deprived Walkers:** ~9.8k steps/day, but only 3.6 hours sleep. High activity coupled with severe sleep deficits.
* **Cluster 2 (21% of users) - Sedentary Sleepers:** ~2.8k steps/day, 7.6 hours sleep.

---

## 6. Dashboard Preview

Below is a preview of the designed Bellabeat Executive Analytics Dashboard, constructed using our cleaned SQLite database views:

![Bellabeat Executive Analytics Dashboard](images/dashboard_mockup.png)

---

## 7. Business Recommendations

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

## 8. Technical Skills Demonstrated

* **Data Cleaning & Engineering (Pandas, NumPy):** Custom aggregators, transition-day deduplication, datatype casting, and feature engineering.
* **Statistical Reasoning (SciPy):** Paired t-tests, Shapiro-Wilk normality tests, Wilcoxon tests, Cohen's d effect sizes, and K-Means clustering.
* **SQL Querying (SQLite):** View creation, rolling averages using window functions, CTEs, ranking, and cohort summaries.
* **Tableau Spec:** Strategic dashboard specification (calculated fields, sheets, filter actions).
* **Business Communication:** Executive summaries and findings reports using structured frameworks.

---

## 9. Setup Instructions

To reproduce the analysis locally:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/Bellabeat-Smart-Device-Analytics.git
   cd Bellabeat-Smart-Device-Analytics
   ```
2. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
3. **Execute Preprocessing & Database Initialization:**
   ```bash
   python scripts/preprocessing.py
   python scripts/feature_engineering.py
   python scripts/analysis.py
   python scripts/db_setup.py
   ```
   This will output the cleaned CSV datasets under `data/processed/` and initialize the local SQLite database `data/processed/bellabeat.db` with all analytical tables and views.
4. **Run Notebooks:**
   Launch Jupyter to explore the interactive visual wrappers under `notebooks/`.
