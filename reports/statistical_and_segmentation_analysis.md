# Statistical Analysis and Hypothesis Testing Report

## Hypothesis Test 1: Weekday vs. Weekend Step Counts
**Business Question:** Do users walk significantly more (or less) on weekends compared to weekdays?
**Test Selected:** Paired samples t-test (comparing the same users' average weekday steps vs. weekend steps).

* **Assumption Check (Shapiro-Wilk Test for Normality of Differences):**
  * W-statistic = 0.9482, p-value = 0.0996
  * *Result:* The assumption of normality is met (p > 0.05). Proceeding with a parametric Paired t-test.

* **Paired t-test Results:**
  * Mean Weekday Steps: 7142.4
  * Mean Weekend Steps: 6935.9
  * Mean Difference (Weekend - Weekday): -206.5 steps
  * t-statistic = -0.4730, p-value = 0.6392
  * 95% Confidence Interval for Difference: (-1093.4, 680.5) steps
  * Effect Size (Cohen's d) = -0.0800 (Interpretation: negligible)

* **Practical Significance & Business Interpretation:**
  * The difference is NOT statistically significant (p = 0.6392).
  * *Insight:* The average difference is only about a few hundred steps. Practically, this suggests users maintain relatively stable step counts between weekdays and weekends, rather than exhibiting a massive 'weekend warrior' surge. This means Bellabeat's marketing doesn't need separate high-intensity weekend programs; instead, a consistent daily habit loop is more suitable.

--------------------------------------------------

## Hypothesis Test 2: High Activity Days vs. Sleep Duration
**Business Question:** Do users sleep longer on days when they are highly active?
**Test Selected:** Paired samples t-test (comparing sleep duration for each user on highly active days vs. non-highly active days).

* **Assumption Check (Shapiro-Wilk Test for Normality of Differences):**
  * W-statistic = 0.9168, p-value = 0.0988
  * *Result:* Normality assumption met. Proceeding with Paired t-test.

* **Paired t-test Results:**
  * Mean Sleep Duration on Inactive Days: 417.6 mins (6.96 hrs)
  * Mean Sleep Duration on Highly Active Days: 363.9 mins (6.07 hrs)
  * Mean Difference (Active - Inactive): -53.7 mins
  * t-statistic = -3.3165, p-value = 0.0038
  * 95% Confidence Interval for Difference: (-87.7, -19.7) mins
  * Effect Size (Cohen's d) = -0.7609

* **Practical Significance & Business Interpretation:**
  * The difference is statistically significant (p = 0.0038).
  * *Insight:* The statistical analysis shows no significant difference or a small, non-meaningful difference in sleep duration between active and inactive days. This indicates that daily activity levels do not immediately dictate sleep duration for these users. For Bellabeat, this suggests that tracking alone does not solve sleep issues; users need smart coaching and wind-down reminders to translate their lifestyle into sleep gains.

==================================================

## Behavioral Segmentation: Business-Rule vs. KMeans Clustering
To identify target consumer groups, we compared a predefined, rule-based approach with unsupervised K-means clustering.

### 1. K-Means Cluster Profiles (N = 3)
* **Cluster 0 (N=12 users):**
  * Average Daily Steps: 8069.6
  * Average Sedentary Ratio: 73.8%
  * Average Sleep Duration: 446.7 mins (7.44 hrs)
  * Weekend Steps Change: -4.9%
* **Cluster 1 (N=7 users):**
  * Average Daily Steps: 9857.9
  * Average Sedentary Ratio: 79.2%
  * Average Sleep Duration: 217.9 mins (3.63 hrs)
  * Weekend Steps Change: +2.5%
* **Cluster 2 (N=5 users):**
  * Average Daily Steps: 2786.3
  * Average Sedentary Ratio: 90.9%
  * Average Sleep Duration: 457.9 mins (7.63 hrs)
  * Weekend Steps Change: +18.6%

### 2. Method Comparison & Evaluation
* **K-Means Clustering Performance:**
  * *Pros:* Uncovers multi-dimensional relationships (e.g., matching low steps with high sleep or high weekend variance) that simple filters miss.
  * *Cons:* Due to the very small user sample size (N=24 users with sleep), clusters are highly sensitive to outliers, and cluster boundaries lack clear, actionable thresholds for real-time app triggers.
* **Business-Rule Segmentation (Tudor-Locke and CDC guidelines):**
  * *Pros:* Highly interpretable, validated by global health standards (WHO/CDC), and easy to implement as programmatic push notifications in the Bellabeat app (e.g., sending sleep hygiene tips to the 'Sleep Deficit' cohort, or active nudges to the 'Sedentary' cohort).
  * *Decision:* For marketing and product features, **Business-Rule Segmentation is selected** due to its superior actionability and clinical justification, while clustering is used to validate that these groups exist as distinct feature densities in multi-dimensional space.