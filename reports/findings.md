# In-Depth Analytical Findings: Bellabeat Smart Device Case Study

This report provides a comprehensive walkthrough of our findings following the six-phase data analysis framework (Ask, Prepare, Process, Analyze, Share, Act), with expanded business analytics, statistical modeling, and data-driven recommendations.

---

## 1. Ask Phase (Business Problem & Objectives)
Bellabeat manufactures high-tech health-focused products for women. Urška Sršen believes that analyzing smart device fitness data from other brands (such as Fitbit) can help unlock new growth opportunities for Bellabeat.

### Primary Objectives:
* Identify how consumers use non-Bellabeat smart devices (physical activity, sleep, weight logging).
* Find behavioral trends and correlations in daily habit structures.
* Translate these insights into marketing strategies and product feature enhancements for the Bellabeat ecosystem.

---

## 2. Prepare Phase (Data Provenance & Audit)
We utilized two Fitabase datasets representing Mechanical Turk surveys from March 12, 2016 to May 12, 2016.
* **Month 1 (March 12 - April 12):** 35 users, 457 daily rows.
* **Month 2 (April 12 - May 12):** 33 users, 940 daily rows.

### Data Audit Findings:
* **Identical Schema:** Daily, hourly, and sleep logs share identical column headers.
* **User Overlap:** 33 users overlap between both months, representing a solid longitudinal sample (61 days).
* **The Transition Day Flaw:** Both months contained records for April 12, 2016. Month 1 data cut off at 10:00 AM, leaving incomplete step and calorie totals. Month 2 spanned the full 24 hours. Deduplication was executed by preserving the Month 2 records for the transition day.
* **Outliers:** Daily step counts of 0 were present. Investigation revealed these coincided with very low wear times (<100 total tracked minutes), which were treated as non-wear days and cleaned during preprocessing.

---

## 3. Process Phase (Feature Engineering)
We engineered several behavioral metrics to gain deeper insights:
* **Sleep Efficiency:** Total minutes asleep / Total time in bed (clinical benchmark of sleep quality).
* **Sedentary Ratio:** Sedentary minutes / Total minutes tracked (shows daily inactive proportion).
* **Wear Compliance Segment:** Segmented by percentage of tracking period the device was worn (High: >=80% of days, Medium: 50-80%, Low: <50%).
* **Tudor-Locke Activity Segment:** Classifying users by average daily steps:
  * Sedentary: <5,000 steps
  * Low Active: 5,000 - 7,499 steps
  * Somewhat Active: 7,500 - 9,999 steps
  * Active: 10,000 - 12,499 steps
  * Highly Active: >=12,500 steps
* **Highly Active Day Flag:** Set to 1 if user logged >=21 minutes of moderate-to-vigorous activity (MVPA) OR >=12,000 steps.

---

## 4. Analyze Phase (Statistical Reasoning & Insights)

### A. The Activity-Sleep Tradeoff (Hypothesis Test)
* **Hypothesis:** Highly active days lead to longer, better sleep.
* **Test:** Paired Samples t-test on users' average sleep duration on highly active days vs. inactive days (Normality assumption verified: Shapiro-Wilk $p = 0.0988$).
* **Statistical Evidence:**
  * Mean Sleep on Inactive Days: **417.6 minutes (6.96 hours)**
  * Mean Sleep on Highly Active Days: **363.9 minutes (6.07 hours)**
  * Mean Difference: **-53.7 minutes** ($t = -3.32, p = 0.0038$, Cohen's $d = -0.76$, 95% CI: $[-87.7, -19.7]$ mins).
* **Business Insight:** This is a counter-intuitive finding. Highly active days are associated with **nearly an hour less sleep**. This indicates that active days coincide with time-constrained schedules, where users wake up earlier or stay up later, sacrificing sleep.

### B. Weekday vs. Weekend Patterns
* **Hypothesis:** Users walk significantly more on weekends than weekdays.
* **Test:** Paired Samples t-test on average weekday steps vs. weekend steps (Normality verified: Shapiro-Wilk $p = 0.0996$).
* **Statistical Evidence:**
  * Mean Weekday Steps: **7,142.4 steps**
  * Mean Weekend Steps: **6,935.9 steps**
  * Mean Difference: **-206.5 steps** ($t = -0.47, p = 0.6392$, Cohen's $d = -0.08$).
* **Business Insight:** There is no statistically significant difference in activity levels between weekdays and weekends. The effect size is negligible. This disproves the "weekend warrior" stereotype for this population; users are consistently low-active throughout the entire week.

### C. Segmenting the Smart Device User
Using K-Means clustering (N=3 clusters) compared against business-rule segmentation:
1. **Cluster 0 (N=12 users) - Consistent Moderate Walkers:** ~8,070 steps/day, 7.4 hours sleep, stable weekly behavior.
2. **Cluster 1 (N=7 users) - Sleep-Deprived Walkers:** ~9,860 steps/day, but only 3.6 hours sleep/day. Highly active but severely sleep-deprived.
3. **Cluster 2 (N=5 users) - Sedentary Sleepers:** ~2,786 steps/day, 7.6 hours sleep, high sedentary ratio (90.9%).
* **Method Evaluation:** K-means successfully discovered multi-dimensional behavioral groups. However, for programmatic implementation in the Bellabeat App, **Business-Rule Segmentation is preferred** due to its transparent boundaries and alignment with WHO/CDC guidelines.

---

## 5. Share Phase (Dashboard Visuals & Views)
Our SQL schema and views (`sql/views.sql`) calculate these cohorts and metrics dynamically, supporting the Tableau dashboard specification.

* **Workday Cycle:** Peak active hours occur between **12:00 PM - 2:00 PM** (lunch hour) and **5:00 PM - 7:00 PM** (after-work transit).
* **Wear Adherence:** 78% of users are highly compliant in Month 1, but this drops by 24% in Month 2, showing that user engagement naturally decays over time.

---

## 6. Act Phase (Marketing & Product Recommendations)

For detailed business actions, see [executive_summary.md](file:///c:/Users/ShaShank/OneDrive/Desktop/CaseStudy/Bellabeat-Smart-Device-Analytics/reports/executive_summary.md). In short, Bellabeat must:
1. **Launch a "Recovery Optimizer"** to address the sleep deficit caused by highly active days.
2. **Create a "Wellness Companions for the Working Woman"** campaign targeting corporate desk-bound sedentary habits with micro-movement nudges.
3. **Pioneer "Cycle-Synced Coaching"** to align activity targets with the menstrual cycle, differentiating Bellabeat from general trackers.
