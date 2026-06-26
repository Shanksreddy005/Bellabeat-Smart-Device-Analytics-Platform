-- schema.sql
-- Database schema for Fitbit Smart Device Analytics (Bellabeat Portfolio Case Study)
-- Compatible with SQLite, PostgreSQL, and MySQL (standard ANSI SQL)

-- DROP TABLES IF THEY EXIST TO PRESERVE REPRODUCIBILITY
DROP TABLE IF EXISTS daily_activity;
DROP TABLE IF EXISTS sleep_day;
DROP TABLE IF EXISTS weight_log;
DROP TABLE IF EXISTS hourly_activity;

-- 1. Daily Activity Table
CREATE TABLE daily_activity (
    Id BIGINT,
    ActivityDate DATE,
    TotalSteps INT,
    TotalDistance REAL,
    TrackerDistance REAL,
    LoggedActivitiesDistance REAL,
    VeryActiveDistance REAL,
    ModeratelyActiveDistance REAL,
    LightActiveDistance REAL,
    SedentaryActiveDistance REAL,
    VeryActiveMinutes INT,
    FairlyActiveMinutes INT,
    LightlyActiveMinutes INT,
    SedentaryMinutes INT,
    Calories INT,
    PRIMARY KEY (Id, ActivityDate)
);

-- 2. Daily Sleep Table
CREATE TABLE sleep_day (
    Id BIGINT,
    SleepDay DATE,
    TotalSleepRecords INT,
    TotalMinutesAsleep INT,
    TotalTimeInBed INT,
    PRIMARY KEY (Id, SleepDay)
);

-- 3. Weight Log Table
CREATE TABLE weight_log (
    Id BIGINT,
    Date TIMESTAMP,
    WeightKg REAL,
    WeightPounds REAL,
    Fat INT,
    BMI REAL,
    IsManualReport BOOLEAN,
    LogId BIGINT,
    PRIMARY KEY (Id, Date)
);

-- 4. Hourly Activity Table
CREATE TABLE hourly_activity (
    Id BIGINT,
    ActivityHour TIMESTAMP,
    StepTotal INT,
    Calories INT,
    TotalIntensity INT,
    AverageIntensity REAL,
    PRIMARY KEY (Id, ActivityHour)
);
