# Data Provenance and Consolidation Report

This report documents the verification, alignment, and consolidation process for the two monthly Fitbit datasets used in this case study.

## Source Datasets
* **Dataset 1 (Month 1):** `mturkfitbit_export_3.12.16-4.11.16` (March 12, 2016 to April 12, 2016)
* **Dataset 2 (Month 2):** `mturkfitbit_export_4.12.16-5.12.16` (April 12, 2016 to May 12, 2016)

---

## Data Provenance Checklist

We conducted a data integrity audit on three core tables before merging: `dailyActivity`, `hourlyCalories`, and `weightLogInfo`.

| Dataset File | Schemas Match? | Month 1 Users (Rows) | Month 2 Users (Rows) | Overlapping Users | Month 1 Date Range | Month 2 Date Range | Common User-Days |
|---|---|---|---|---|---|---|---|
| `dailyActivity_merged.csv` | **Yes (Identical)** | 35 (457) | 33 (940) | 33 | 2016-03-12 to 2016-04-12 | 2016-04-12 to 2016-05-12 | 24 |
| `hourlyCalories_merged.csv` | **Yes (Identical)** | 34 (24084) | 33 (22099) | 32 | 2016-03-12 to 2016-04-12 | 2016-04-12 to 2016-05-12 | 20 |
| `weightLogInfo_merged.csv` | **Yes (Identical)** | 11 (33) | 8 (67) | 6 | 2016-03-30 to 2016-04-12 | 2016-04-12 to 2016-05-12 | 2 |

---

## Critical Finding: The Transition Day Cutoff

On the transition date **2016-04-12**, data exists in both datasets for the 24 overlapping users. However, a deep dive into the records reveals they are **not identical**:

* **Month 1 Daily Activity (April 12):** Average steps recorded were very low (e.g., User `1503960366` had 224 steps and 50 calories).
* **Month 2 Daily Activity (April 12):** Average steps recorded were standard (e.g., User `1503960366` had 13,162 steps and 1,985 calories).

### Root Cause Analysis
By checking the hourly data for `2016-04-12`, we found:
* Month 1 hourly records for April 12 cut off at **10:00 AM**.
* Month 2 hourly records for April 12 span the full **24-hour cycle (0:00 to 23:00)**.

This indicates that Month 1 was exported midway through April 12, leaving partial-day records, whereas Month 2 captured the full day.

### Consolidation Strategy
To prevent severe data under-reporting and artificial deflation of user activity on the transition date, we will implement the following rules:
1. **Deduplication Rule:** For any user-date key present in both months on `2016-04-12`, **discard the Month 1 record** and **keep the Month 2 record**.
2. **Date Alignment:** Cast all dates to standard `YYYY-MM-DD` and hours to datetime format prior to deduplication.
3. **Consolidation**: Concat Month 1 (deduplicated) and Month 2 datasets. This yields a seamless 2-month longitudinal view (61 days) for active users, increasing the statistical power and validity of our analysis.
