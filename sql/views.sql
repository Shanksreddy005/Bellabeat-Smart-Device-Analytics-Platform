-- views.sql
-- Views for Tableau dashboarding and reporting

-- 1. Daily Integrated Metrics View (Combines Activity and Sleep)
DROP VIEW IF EXISTS v_daily_user_metrics;
CREATE VIEW v_daily_user_metrics AS
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.TotalDistance,
    da.VeryActiveMinutes,
    da.FairlyActiveMinutes,
    da.LightlyActiveMinutes,
    da.SedentaryMinutes,
    da.Calories,
    (da.VeryActiveMinutes + da.FairlyActiveMinutes + da.LightlyActiveMinutes) AS TotalActiveMinutes,
    (da.VeryActiveMinutes + da.FairlyActiveMinutes + da.LightlyActiveMinutes + da.SedentaryMinutes) AS TotalTrackedMinutes,
    sd.TotalSleepRecords,
    sd.TotalMinutesAsleep,
    sd.TotalTimeInBed,
    (sd.TotalTimeInBed - sd.TotalMinutesAsleep) AS MinutesAwakeInBed,
    CASE 
        WHEN sd.TotalTimeInBed > 0 THEN CAST(sd.TotalMinutesAsleep AS REAL) / sd.TotalTimeInBed 
        ELSE NULL 
    END AS SleepEfficiency
FROM daily_activity da
LEFT JOIN sleep_day sd 
    ON da.Id = sd.Id 
    AND da.ActivityDate = sd.SleepDay;

-- 2. User Cohort and Segmentation View
DROP VIEW IF EXISTS v_user_segmentation_summary;
CREATE VIEW v_user_segmentation_summary AS
WITH UserDailyAggs AS (
    SELECT 
        Id,
        AVG(TotalSteps) AS AvgSteps,
        AVG(Calories) AS AvgCalories,
        AVG(VeryActiveMinutes + FairlyActiveMinutes) AS AvgMVPA, -- Moderate-to-Vigorous Physical Activity
        AVG(SedentaryMinutes) AS AvgSedentary,
        COUNT(ActivityDate) AS DaysTracked
    FROM daily_activity
    GROUP BY Id
),
UserSleepAggs AS (
    SELECT 
        Id,
        AVG(TotalMinutesAsleep) AS AvgSleepMins,
        AVG(CAST(TotalMinutesAsleep AS REAL) / TotalTimeInBed) AS AvgSleepEfficiency,
        AVG(TotalTimeInBed - TotalMinutesAsleep) AS AvgLatency
    FROM sleep_day
    GROUP BY Id
)
SELECT 
    uda.Id,
    uda.AvgSteps,
    uda.AvgCalories,
    uda.AvgMVPA,
    uda.AvgSedentary,
    uda.DaysTracked,
    CAST(uda.DaysTracked AS REAL) / 61.0 AS TrackedRatio,
    usa.AvgSleepMins,
    usa.AvgSleepEfficiency,
    usa.AvgLatency,
    -- Tudor-Locke Activity segments
    CASE 
        WHEN uda.AvgSteps < 5000 THEN 'Sedentary (<5k)'
        WHEN uda.AvgSteps >= 5000 AND uda.AvgSteps < 7500 THEN 'Low Active (5k-7.5k)'
        WHEN uda.AvgSteps >= 7500 AND uda.AvgSteps < 10000 THEN 'Somewhat Active (7.5k-10k)'
        WHEN uda.AvgSteps >= 10000 AND uda.AvgSteps < 12500 THEN 'Active (10k-12.5k)'
        ELSE 'Highly Active (>=12.5k)'
    END AS ActivitySegment,
    -- Compliance segments
    CASE 
        WHEN CAST(uda.DaysTracked AS REAL) / 61.0 >= 0.80 THEN 'High Compliance (>=80%)'
        WHEN CAST(uda.DaysTracked AS REAL) / 61.0 >= 0.50 THEN 'Medium Compliance (50%-80%)'
        ELSE 'Low Compliance (<50%)'
    END AS ComplianceSegment,
    -- Sleep deficit segment
    CASE 
        WHEN usa.AvgSleepMins IS NULL THEN 'No Sleep Data'
        WHEN usa.AvgSleepMins < 420 THEN 'Sleep Deficit (<7 hrs)'
        WHEN usa.AvgSleepMins >= 420 AND usa.AvgSleepMins <= 540 THEN 'Optimal Sleep (7-9 hrs)'
        ELSE 'Oversleeping (>9 hrs)'
    END AS SleepDeficitSegment
FROM UserDailyAggs uda
LEFT JOIN UserSleepAggs usa ON uda.Id = usa.Id;
