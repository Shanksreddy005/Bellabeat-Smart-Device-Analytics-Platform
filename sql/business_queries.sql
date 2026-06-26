-- business_queries.sql
-- 20 Advanced Analytical SQL Queries for Bellabeat Smart Device Case Study
-- Uses CTEs, Window Functions, Ranking, and Cohorts for executive reporting

-- ==========================================
-- 1. COHORT & SEGMENTATION ANALYTICS
-- ==========================================

-- Query 1: User Activity Segments (Tudor-Locke Indices)
-- Purpose: Classify users based on average daily steps to understand the user base's fitness level.
SELECT 
    ActivitySegment,
    COUNT(Id) AS NumberOfUsers,
    ROUND(COUNT(Id) * 100.0 / (SELECT COUNT(DISTINCT Id) FROM v_user_segmentation_summary), 2) AS PercentageContribution
FROM v_user_segmentation_summary
GROUP BY ActivitySegment
ORDER BY NumberOfUsers DESC;

-- Query 2: Wear Compliance Segments
-- Purpose: Segment users by how consistently they wear their device (High vs. Low compliance).
SELECT 
    ComplianceSegment,
    COUNT(Id) AS NumberOfUsers,
    ROUND(AVG(AvgSteps), 1) AS AvgStepsForSegment,
    ROUND(AVG(AvgCalories), 1) AS AvgCaloriesForSegment
FROM v_user_segmentation_summary
GROUP BY ComplianceSegment
ORDER BY NumberOfUsers DESC;

-- Query 3: Sleep Deficit Cohort Analysis
-- Purpose: Segment users by their average sleep duration compared to CDC recommendations (7-9 hours).
SELECT 
    SleepDeficitSegment,
    COUNT(Id) AS NumberOfUsers,
    ROUND(AVG(AvgSleepEfficiency) * 100, 2) AS AvgSleepEfficiencyPct,
    ROUND(AVG(AvgLatency), 1) AS AvgBedLatencyMins
FROM v_user_segmentation_summary
GROUP BY SleepDeficitSegment
ORDER BY NumberOfUsers DESC;

-- Query 4: Daily Highly Active Flag Summary
-- Purpose: Identify what percentage of tracked days meet clinical/highly active thresholds.
SELECT 
    CASE 
        WHEN (VeryActiveMinutes + FairlyActiveMinutes) >= 21 OR TotalSteps >= 12000 THEN 'Highly Active Day'
        ELSE 'Sub-Optimal Day'
    END AS DayClassification,
    COUNT(*) AS DayCount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM daily_activity), 2) AS DayPercentage
FROM daily_activity
GROUP BY DayClassification;


-- ==========================================
-- 2. TEMPORAL & TREND ANALYSIS
-- ==========================================

-- Query 5: Average Steps and Calories by Weekday
-- Purpose: Analyze weekly behavior patterns to identify which days have the lowest/highest activity.
SELECT 
    CASE CAST(strftime('%w', ActivityDate) AS INT)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS Weekday,
    ROUND(AVG(TotalSteps), 1) AS AvgSteps,
    ROUND(AVG(Calories), 1) AS AvgCalories,
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes), 1) AS AvgMVPA_Mins
FROM daily_activity
GROUP BY strftime('%w', ActivityDate)
ORDER BY strftime('%w', ActivityDate);

-- Query 6: Peak Hourly Steps and Intensities
-- Purpose: Find which hours of the day are most active.
SELECT 
    strftime('%H:00', ActivityHour) AS HourOfDay,
    ROUND(AVG(StepTotal), 1) AS AvgSteps,
    ROUND(AVG(Calories), 1) AS AvgCaloriesBurned,
    ROUND(AVG(TotalIntensity), 1) AS AvgIntensity
FROM hourly_activity
GROUP BY strftime('%H', ActivityHour)
ORDER BY AvgSteps DESC;


-- ==========================================
-- 3. WINDOW FUNCTIONS & ROLLING STATS
-- ==========================================

-- Query 7: 7-Day Rolling Average Steps (User-Specific)
-- Purpose: Smooth out daily variance for a specific user to view activity trajectories.
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    ROUND(AVG(TotalSteps) OVER (
        PARTITION BY Id 
        ORDER BY ActivityDate 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 1) AS Rolling7DayAvgSteps
FROM daily_activity
WHERE Id = 1503960366
ORDER BY ActivityDate;

-- Query 8: Ranking Users by Daily Step Output (DENSE_RANK)
-- Purpose: Rank users by their average daily steps to identify the top 5 most active users.
WITH UserRanks AS (
    SELECT 
        Id,
        ROUND(AVG(TotalSteps), 1) AS AvgSteps,
        DENSE_RANK() OVER (ORDER BY AVG(TotalSteps) DESC) AS StepRank
    FROM daily_activity
    GROUP BY Id
)
SELECT * 
FROM UserRanks 
WHERE StepRank <= 5;

-- Query 9: Percent Contribution of Activity Intensities (Window Function)
-- Purpose: For each user, calculate the percentage of total active minutes spent in high-intensity vs. low-intensity activity.
WITH UserActiveMins AS (
    SELECT 
        Id,
        SUM(VeryActiveMinutes) AS TotalVeryActive,
        SUM(FairlyActiveMinutes) AS TotalFairlyActive,
        SUM(LightlyActiveMinutes) AS TotalLightlyActive,
        SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS TotalActive
    FROM daily_activity
    GROUP BY Id
)
SELECT 
    Id,
    TotalActive,
    ROUND(TotalVeryActive * 100.0 / NULLIF(TotalActive, 0), 2) AS VeryActiveContributionPct,
    ROUND(TotalFairlyActive * 100.0 / NULLIF(TotalActive, 0), 2) AS FairlyActiveContributionPct,
    ROUND(TotalLightlyActive * 100.0 / NULLIF(TotalActive, 0), 2) AS LightlyActiveContributionPct
FROM UserActiveMins
WHERE TotalActive > 0
ORDER BY VeryActiveContributionPct DESC;


-- ==========================================
-- 4. BEHAVIORAL DEEP DIVES & CORRELATIONS
-- ==========================================

-- Query 10: Weekday vs Weekend Activity Change per User (CTEs)
-- Purpose: Identify "Weekend Warriors" vs "Weekday Walkers".
WITH WeekdayAvg AS (
    SELECT Id, AVG(TotalSteps) AS WeekdaySteps
    FROM daily_activity
    WHERE strftime('%w', ActivityDate) NOT IN ('0', '6')
    GROUP BY Id
),
WeekendAvg AS (
    SELECT Id, AVG(TotalSteps) AS WeekendSteps
    FROM daily_activity
    WHERE strftime('%w', ActivityDate) IN ('0', '6')
    GROUP BY Id
)
SELECT 
    w1.Id,
    ROUND(w1.WeekdaySteps, 1) AS WeekdayAvgSteps,
    ROUND(w2.WeekendSteps, 1) AS WeekendAvgSteps,
    ROUND(((w2.WeekendSteps - w1.WeekdaySteps) / w1.WeekdaySteps) * 100, 2) AS WeekendChangePct,
    CASE 
        WHEN ((w2.WeekendSteps - w1.WeekdaySteps) / w1.WeekdaySteps) >= 0.20 THEN 'Weekend Warrior'
        WHEN ((w2.WeekendSteps - w1.WeekdaySteps) / w1.WeekdaySteps) <= -0.20 THEN 'Weekday Walker'
        ELSE 'Consistent Mover'
    END AS BehavioralProfile
FROM WeekdayAvg w1
JOIN WeekendAvg w2 ON w1.Id = w2.Id;

-- Query 11: Sleep Latency vs. Total Steps
-- Purpose: Test if high daily steps are associated with shorter latency in bed (getting to sleep faster).
SELECT 
    CASE 
        WHEN TotalSteps < 5000 THEN 'Sedentary'
        WHEN TotalSteps BETWEEN 5000 AND 9999 THEN 'Moderate'
        ELSE 'Active'
    END AS ActivityLevel,
    ROUND(AVG(TotalMinutesAsleep), 1) AS AvgMinsAsleep,
    ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 1) AS AvgMinsAwakeInBed,
    ROUND(AVG(CAST(TotalMinutesAsleep AS REAL) / TotalTimeInBed) * 100, 2) AS AvgSleepEfficiencyPct
FROM sleep_day sd
JOIN daily_activity da 
    ON sd.Id = da.Id 
    AND sd.SleepDay = da.ActivityDate
GROUP BY ActivityLevel;

-- Query 12: Weekly Active Minutes Adherence (WHO Guidelines)
-- Purpose: Find what percentage of users meet the WHO guideline of 150+ minutes of MVPA per week (approx 21 mins/day).
WITH MVPA_PerUser AS (
    SELECT 
        Id,
        AVG(VeryActiveMinutes + FairlyActiveMinutes) AS AvgMVPA_Daily
    FROM daily_activity
    GROUP BY Id
)
SELECT 
    CASE 
        WHEN AvgMVPA_Daily >= 21.4 THEN 'Meets WHO Guideline (>=150 mins/week)'
        ELSE 'Does Not Meet WHO Guideline (<150 mins/week)'
    END AS WHOCohort,
    COUNT(Id) AS UserCount,
    ROUND(COUNT(Id) * 100.0 / (SELECT COUNT(*) FROM MVPA_PerUser), 2) AS UserPercentage
FROM MVPA_PerUser
GROUP BY WHOCohort;


-- ==========================================
-- 5. DEVICE ADHERENCE & LOGGING PATTERNS
-- ==========================================

-- Query 13: Correlation Proxy between Steps and Calories
-- Purpose: Verify mathematically that step counts strongly drive calorie burns in SQL.
SELECT 
    COUNT(*) AS SampleSize,
    ROUND(SUM(TotalSteps * Calories) / COUNT(*) - AVG(TotalSteps) * AVG(Calories), 2) AS CovarianceStepsCalories,
    ROUND((SUM(TotalSteps * Calories) / COUNT(*) - AVG(TotalSteps) * AVG(Calories)) / 
          (CAST(stdev_steps AS REAL) * stdev_calories), 4) AS CorrelationProxy
FROM daily_activity, 
(
    SELECT 
        (SUM((TotalSteps - avg_steps) * (TotalSteps - avg_steps)) / (COUNT(*) - 1)) AS var_steps,
        (SUM((Calories - avg_cals) * (Calories - avg_cals)) / (COUNT(*) - 1)) AS var_calories,
        -- Square roots of variance (Stdev)
        -- SQLite doesn't have standard STDEV, so we use a subquery proxy
        1373 AS num_rows -- total rows
    FROM daily_activity,
    (SELECT AVG(TotalSteps) AS avg_steps, AVG(Calories) AS avg_cals FROM daily_activity)
),
(
    -- Hardcoded Standard Deviations for covariance scaling (calculated from Python for standard SQLite)
    SELECT 3885.6 AS stdev_steps, 687.1 AS stdev_calories
);

-- Query 14: Sedentary Streaks Analysis
-- Purpose: Identify days where users have spent more than 12 hours (720 minutes) sedentary, posing cardiovascular risks.
SELECT 
    Id,
    COUNT(*) AS HighSedentaryDays,
    ROUND(AVG(SedentaryMinutes), 1) AS AvgSedentaryMins,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM daily_activity WHERE Id = da.Id), 2) AS PctOfTrackedDays
FROM daily_activity da
WHERE SedentaryMinutes >= 720
GROUP BY Id
ORDER BY HighSedentaryDays DESC;

-- Query 15: Manual Weight Logging vs. Auto
-- Purpose: Check how many weight logs are manual vs. automated to assess user interface compliance.
SELECT 
    IsManualReport,
    COUNT(*) AS WeightLogCount,
    ROUND(AVG(WeightKg), 2) AS AvgWeightKg,
    ROUND(AVG(BMI), 2) AS AvgBMI
FROM weight_log
GROUP BY IsManualReport;


-- ==========================================
-- 6. DASHBOARD & VIEW QUERIES
-- ==========================================

-- Query 16: Executive KPI Cards Visuals
-- Purpose: Summary metrics for dashboard KPI cards.
SELECT 
    (SELECT COUNT(DISTINCT Id) FROM daily_activity) AS TotalUsers,
    ROUND(AVG(TotalSteps), 0) AS AvgStepsOverall,
    ROUND(AVG(Calories), 0) AS AvgCaloriesOverall,
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes), 1) AS AvgMVPAMinsOverall,
    ROUND(AVG(TotalMinutesAsleep) / 60.0, 2) AS AvgSleepHoursOverall,
    ROUND(AVG(CAST(TotalMinutesAsleep AS REAL) / TotalTimeInBed) * 100, 1) AS AvgSleepEfficiencyOverall
FROM daily_activity da
LEFT JOIN sleep_day sd 
    ON da.Id = sd.Id 
    AND da.ActivityDate = sd.SleepDay;

-- Query 17: User Lifetime Tracker Active Days
-- Purpose: Rank users by total steps taken in the database.
SELECT 
    Id,
    SUM(TotalSteps) AS TotalLifetimeSteps,
    SUM(Calories) AS TotalLifetimeCalories,
    COUNT(ActivityDate) AS TotalActiveDays
FROM daily_activity
GROUP BY Id
ORDER BY TotalLifetimeSteps DESC
LIMIT 10;

-- Query 18: Sleep Latency Breakdown by Day of Week
-- Purpose: Track if sleep latency (time awake in bed) increases on weekends due to screen/social activity.
SELECT 
    CASE CAST(strftime('%w', SleepDay) AS INT)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS Weekday,
    ROUND(AVG(TotalMinutesAsleep), 1) AS AvgMinsAsleep,
    ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 1) AS AvgAwakeMins,
    ROUND(AVG(TotalTimeInBed), 1) AS AvgTimeInBed
FROM sleep_day
GROUP BY strftime('%w', SleepDay)
ORDER BY strftime('%w', SleepDay);

-- Query 19: High-Intensity Activity Burn Rate (Calorie Efficiency)
-- Purpose: Check how calories burned per minute scales with activity levels.
SELECT 
    CASE 
        WHEN VeryActiveMinutes >= 20 THEN 'Vigorous Activity (>=20m)'
        WHEN FairlyActiveMinutes >= 20 THEN 'Moderate Activity (>=20m)'
        WHEN LightlyActiveMinutes >= 60 THEN 'Light Activity (>=60m)'
        ELSE 'Mainly Sedentary'
    END AS DayIntensityClass,
    ROUND(AVG(Calories), 1) AS AvgCaloriesBurned,
    ROUND(AVG(TotalSteps), 1) AS AvgSteps
FROM daily_activity
GROUP BY DayIntensityClass;

-- Query 20: Sleep Deficit Correlation with Steps Variance
-- Purpose: Investigate if users with high sleep deficit have less consistent step counts day-to-day.
SELECT 
    v.SleepDeficitSegment,
    ROUND(AVG(v.AvgSteps), 1) AS AvgSteps,
    ROUND(AVG(da.TotalSteps), 1) AS AvgDailySteps,
    ROUND(AVG(v.AvgLatency), 1) AS AvgSleepLatencyMins
FROM v_user_segmentation_summary v
JOIN daily_activity da ON v.Id = da.Id
GROUP BY v.SleepDeficitSegment;
