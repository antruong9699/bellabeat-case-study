-- ============================================================
-- Bellabeat Marketing Analysis — Data Cleaning Pipeline
-- Author: An Truong
-- Tool: Google BigQuery SQL (Sandbox)
-- Dataset: FitBit Fitness Tracker Data (CC0 Public Domain, via Kaggle/Mobius)
-- Project: Google Data Analytics Certificate Capstone
-- 
-- Overview:
--   This script documents the full Process phase of the Bellabeat
--   case study. Raw FitBit CSV tables (loaded into BigQuery dataset
--   'bellabeat') are cleaned and transformed into analysis-ready
--   tables via CREATE OR REPLACE TABLE (CTAS) statements.
--   BigQuery Sandbox does not support DML (UPDATE/DELETE), so all
--   cleaning is implemented as new tables rather than in-place edits.
--
-- Raw tables loaded (7 total):
--   dailyActivity_merged, heartrate_seconds_merged,
--   hourlyCalories_merged, hourlyIntensities_merged,
--   hourlySteps_merged, minuteSleep_merged, weightLogInfo_merged
--
-- Output tables produced (8 total):
--   clean_dailyActivity, clean_hourlyCalories, clean_hourlyIntensities,
--   clean_hourlySteps, clean_minuteSleep, clean_heartrate,
--   clean_weightLogInfo, agg_dailySleep, agg_dailyHeartrate,
--   flagged_dailyActivity, agg_wearRate
-- ============================================================


-- ============================================================
-- SECTION 0: REUSABLE TEMPLATES
-- Duplicate and null check patterns applied to each table below.
-- ============================================================

-- Duplicate check template:
-- SELECT Id, [date_column], COUNT(*)
-- FROM bellabeat.[table]
-- GROUP BY 1, 2
-- HAVING COUNT(*) > 1;

-- Null check template:
-- SELECT
--   COUNTIF([col1] IS NULL) AS null_col1,
--   COUNTIF([col2] IS NULL) AS null_col2
-- FROM bellabeat.[table];


-- ============================================================
-- SECTION 1: CLEAN DAILY ACTIVITY
-- Source: dailyActivity_merged
-- Key decisions:
--   - ActivityDate loaded as DATE natively; no conversion needed
--   - Distance columns dropped: redundant with minutes-based
--     intensity columns for the engagement narrative; not directly
--     relevant to the business task
--   - Zero nulls and zero duplicates confirmed via checks below
-- ============================================================

-- Duplicate check
SELECT Id, ActivityDate, COUNT(*)
FROM bellabeat.dailyActivity_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(TotalSteps IS NULL) AS null_steps,
  COUNTIF(Calories IS NULL) AS null_calories,
  COUNTIF(VeryActiveMinutes IS NULL) AS null_very_active,
  COUNTIF(FairlyActiveMinutes IS NULL) AS null_fairly_active,
  COUNTIF(LightlyActiveMinutes IS NULL) AS null_lightly_active,
  COUNTIF(SedentaryMinutes IS NULL) AS null_sedentary
FROM bellabeat.dailyActivity_merged;

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_dailyActivity AS
SELECT
  Id,
  ActivityDate,
  TotalSteps,
  Calories,
  VeryActiveMinutes,
  FairlyActiveMinutes,
  LightlyActiveMinutes,
  SedentaryMinutes
FROM bellabeat.dailyActivity_merged;


-- ============================================================
-- SECTION 2: CLEAN HOURLY CALORIES
-- Source: hourlyCalories_merged
-- Key decisions:
--   - ActivityHour converted from STRING to DATETIME
--   - Zero nulls and zero duplicates confirmed
-- ============================================================

-- Duplicate check
SELECT Id, ActivityHour, COUNT(*)
FROM bellabeat.hourlyCalories_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(ActivityHour IS NULL) AS null_activityhour,
  COUNTIF(Calories IS NULL) AS null_calories
FROM bellabeat.hourlyCalories_merged;

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_hourlyCalories AS
SELECT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS ActivityHour,
  Calories
FROM bellabeat.hourlyCalories_merged;


-- ============================================================
-- SECTION 3: CLEAN HOURLY INTENSITIES
-- Source: hourlyIntensities_merged
-- Key decisions:
--   - ActivityHour converted from STRING to DATETIME
--   - TotalIntensity dropped; AverageIntensity retained only.
--     AverageIntensity is normalized per minute and therefore
--     comparable across incomplete tracking hours, unlike
--     TotalIntensity which would be artificially low for partial hours
--   - Zero nulls and zero duplicates confirmed
-- ============================================================

-- Duplicate check
SELECT Id, ActivityHour, COUNT(*)
FROM bellabeat.hourlyIntensities_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(ActivityHour IS NULL) AS null_activityhour,
  COUNTIF(TotalIntensity IS NULL) AS null_total_intensity,
  COUNTIF(AverageIntensity IS NULL) AS null_average_intensity
FROM bellabeat.hourlyIntensities_merged;

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_hourlyIntensities AS
SELECT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS ActivityHour,
  AverageIntensity
FROM bellabeat.hourlyIntensities_merged;


-- ============================================================
-- SECTION 4: CLEAN HOURLY STEPS
-- Source: hourlySteps_merged
-- Key decisions:
--   - ActivityHour converted from STRING to DATETIME
--   - Zero nulls and zero duplicates confirmed
-- ============================================================

-- Duplicate check
SELECT Id, ActivityHour, COUNT(*)
FROM bellabeat.hourlySteps_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(ActivityHour IS NULL) AS null_activityhour,
  COUNTIF(StepTotal IS NULL) AS null_steptotal
FROM bellabeat.hourlySteps_merged;

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_hourlySteps AS
SELECT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS ActivityHour,
  StepTotal
FROM bellabeat.hourlySteps_merged;


-- ============================================================
-- SECTION 5: CLEAN MINUTE SLEEP
-- Source: minuteSleep_merged
-- Key decisions:
--   - date column converted from STRING to DATETIME
--   - 525 true duplicate rows found (identical Id, date, value, logId)
--     confirmed via spot-check; removed using SELECT DISTINCT
--   - Likely caused by overlapping date ranges in the original
--     two-period Kaggle dataset export
-- ============================================================

-- Duplicate check
SELECT Id, date, COUNT(*)
FROM bellabeat.minuteSleep_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(date IS NULL) AS null_date,
  COUNTIF(value IS NULL) AS null_value,
  COUNTIF(logId IS NULL) AS null_logid
FROM bellabeat.minuteSleep_merged;

-- Verify sleep value codes (1=asleep, 2=restless, 3=awake)
SELECT DISTINCT value
FROM bellabeat.minuteSleep_merged
ORDER BY value;

-- Create clean table (SELECT DISTINCT removes 525 true duplicates)
CREATE OR REPLACE TABLE bellabeat.clean_minuteSleep AS
SELECT DISTINCT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date) AS date,
  value,
  logId
FROM bellabeat.minuteSleep_merged;


-- ============================================================
-- SECTION 5A: AGGREGATE DAILY SLEEP SUMMARY
-- Source: clean_minuteSleep
-- Purpose: sleepDay_merged was not included in the uploaded dataset.
--   This table derives equivalent daily sleep totals from the
--   minute-level sleep data.
-- Key decisions:
--   - DATE(date) extracts calendar date from datetime for grouping
--   - TotalMinutesAsleep counts only value=1 (asleep) rows
--   - TotalTimeInBed counts all rows (asleep + restless + awake)
--   - TotalSleepRecords counts distinct logIds per day
--   - Multi-session days (59% of 467 total days) retained:
--     daily totals across all sessions reflect real device usage
--     behavior relevant to the business task
-- ============================================================

CREATE OR REPLACE TABLE bellabeat.agg_dailySleep AS
SELECT
  Id,
  DATE(date) AS SleepDate,
  COUNTIF(value = 1) AS TotalMinutesAsleep,
  COUNT(*) AS TotalTimeInBed,
  COUNT(DISTINCT logId) AS TotalSleepRecords
FROM bellabeat.clean_minuteSleep
GROUP BY Id, SleepDate;

-- Sanity check: TotalMinutesAsleep must never exceed TotalTimeInBed
SELECT COUNT(*) AS impossible_rows
FROM bellabeat.agg_dailySleep
WHERE TotalMinutesAsleep > TotalTimeInBed;
-- Result: 0 impossible rows confirmed

-- Plausibility check: verify min/max/avg values are in realistic range
SELECT
  MIN(TotalMinutesAsleep) AS min_asleep,
  MAX(TotalMinutesAsleep) AS max_asleep,
  MIN(TotalTimeInBed) AS min_inbed,
  MAX(TotalTimeInBed) AS max_inbed,
  ROUND(AVG(TotalMinutesAsleep), 1) AS avg_asleep,
  ROUND(AVG(TotalTimeInBed), 1) AS avg_inbed
FROM bellabeat.agg_dailySleep;
-- Max values (791 min asleep, 903 min in bed) confirmed to belong
-- to one user with 2 logged sessions on the same date, not one
-- implausible single sleep event.

-- Distribution of sleep sessions per day
SELECT
  TotalSleepRecords,
  COUNT(*) AS number_of_days
FROM bellabeat.agg_dailySleep
GROUP BY TotalSleepRecords
ORDER BY TotalSleepRecords;
-- 59% of days (275/467) have 2+ sleep sessions; retained intentionally


-- ============================================================
-- SECTION 6: CLEAN HEART RATE
-- Source: heartrate_seconds_merged
-- Key decisions:
--   - Time column converted from STRING to DATETIME
--   - Zero nulls and zero duplicates confirmed
-- ============================================================

-- Duplicate check
SELECT Id, Time, COUNT(*)
FROM bellabeat.heartrate_seconds_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check
SELECT
  COUNTIF(Time IS NULL) AS null_time,
  COUNTIF(Value IS NULL) AS null_value
FROM bellabeat.heartrate_seconds_merged;

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_heartrate AS
SELECT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', Time) AS Time,
  Value
FROM bellabeat.heartrate_seconds_merged;


-- ============================================================
-- SECTION 6A: AGGREGATE DAILY HEART RATE SUMMARY
-- Source: clean_heartrate
-- Purpose: 1,154,681 second-level rows aggregated to daily
--   averages to reduce to a manageable size for Python analysis
-- ============================================================

CREATE OR REPLACE TABLE bellabeat.agg_dailyHeartrate AS
SELECT
  Id,
  DATE(Time) AS Date,
  ROUND(AVG(Value), 2) AS AverageHeartrate,
  MIN(Value) AS MinHeartrate,
  MAX(Value) AS MaxHeartrate
FROM bellabeat.clean_heartrate
GROUP BY Id, Date;


-- ============================================================
-- SECTION 7: CLEAN WEIGHT LOG INFO
-- Source: weightLogInfo_merged
-- Key decisions:
--   - Date column converted from STRING to DATETIME
--   - WeightKg dropped: duplicate of WeightPounds in different units
--   - Fat dropped: 94% null (31 of 33 rows); analytically unusable
--   - LogId dropped: system-generated ID with no join value
--   - IsManualReport retained: flags reliability of each entry
--   - Zero nulls on retained columns; zero duplicates confirmed
-- ============================================================

-- Duplicate check
SELECT Id, Date, COUNT(*)
FROM bellabeat.weightLogInfo_merged
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- Null check (including Fat to document its unusability)
SELECT
  COUNTIF(WeightPounds IS NULL) AS null_weightpounds,
  COUNTIF(IsManualReport IS NULL) AS null_ismanualreport,
  COUNTIF(Fat IS NULL) AS null_fat
FROM bellabeat.weightLogInfo_merged;
-- Result: Fat is 94% null (31/33 rows) — column excluded

-- Create clean table
CREATE OR REPLACE TABLE bellabeat.clean_weightLogInfo AS
SELECT
  Id,
  PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', Date) AS Date,
  WeightPounds,
  IsManualReport
FROM bellabeat.weightLogInfo_merged;


-- ============================================================
-- SECTION 8: NON-WEAR DAY FLAGGING
-- Source: clean_dailyActivity
-- Purpose: Flag probable non-wear days for exclusion from
--   activity averages in the Analyze phase.
-- Definition: A day where TotalSteps = 0 AND SedentaryMinutes = 1440
--   (a full 1,440-minute day of sedentary time with zero steps)
--   is classified as a probable non-wear day.
-- Limitation: Cannot distinguish a true non-wear day from a
--   genuinely sedentary day (e.g. illness, bed rest). Label
--   treated as "probable" rather than confirmed.
-- ============================================================

CREATE OR REPLACE TABLE bellabeat.flagged_dailyActivity AS
SELECT
  CASE
    WHEN TotalSteps = 0 AND SedentaryMinutes = 1440 THEN TRUE
    ELSE FALSE
  END AS is_non_wear_day,
  Id,
  ActivityDate,
  TotalSteps,
  Calories,
  VeryActiveMinutes,
  FairlyActiveMinutes,
  LightlyActiveMinutes,
  SedentaryMinutes
FROM bellabeat.clean_dailyActivity;

-- Verify non-wear day distribution
SELECT
  is_non_wear_day,
  COUNT(*) AS row_count
FROM bellabeat.flagged_dailyActivity
GROUP BY is_non_wear_day
ORDER BY is_non_wear_day;
-- Result: 404 wear days (FALSE), 53 non-wear days (TRUE) — 11.6%


-- ============================================================
-- SECTION 8A: WEAR RATE SUMMARY BY USER
-- Source: flagged_dailyActivity
-- Purpose: Quantify device engagement per user.
--   Users with fewer than 12 tracked days excluded from
--   downstream wear rate conclusions (insufficient observation window).
-- ============================================================

CREATE OR REPLACE TABLE bellabeat.agg_wearRate AS
SELECT
  Id,
  COUNT(*) AS TotalDays,
  COUNTIF(is_non_wear_day = FALSE) AS wear_days,
  COUNTIF(is_non_wear_day = TRUE) AS non_wear_days,
  ROUND(COUNTIF(is_non_wear_day = FALSE) / COUNT(*), 2) AS wear_rate
FROM bellabeat.flagged_dailyActivity
GROUP BY Id;

-- Summary statistics for users with sufficient data (>= 12 days)
SELECT
  ROUND(AVG(wear_rate), 2) AS avg_wear_rate,
  MIN(wear_rate) AS min_wear_rate,
  MAX(wear_rate) AS max_wear_rate,
  COUNT(*) AS qualifying_users
FROM bellabeat.agg_wearRate
WHERE TotalDays >= 12;
-- Result: avg = 0.94, min = 0.50, max = 1.0, users = 24 of 35


-- ============================================================
-- SECTION 9: FINAL VERIFICATION CHECKPOINT
-- Confirms all output tables have expected row counts,
-- unique user counts, and consistent date ranges.
-- ============================================================

-- Row counts across all clean and aggregated tables
SELECT table_id, row_count
FROM bellabeat.__TABLES__
WHERE table_id LIKE 'clean_%'
   OR table_id LIKE 'agg_%'
   OR table_id LIKE 'flagged_%'
ORDER BY table_id;

-- Unique user counts per table
SELECT 'clean_dailyActivity' AS table_name, COUNT(DISTINCT Id) AS unique_users FROM bellabeat.clean_dailyActivity UNION ALL
SELECT 'clean_hourlyCalories',    COUNT(DISTINCT Id) FROM bellabeat.clean_hourlyCalories UNION ALL
SELECT 'clean_hourlyIntensities', COUNT(DISTINCT Id) FROM bellabeat.clean_hourlyIntensities UNION ALL
SELECT 'clean_hourlySteps',       COUNT(DISTINCT Id) FROM bellabeat.clean_hourlySteps UNION ALL
SELECT 'clean_minuteSleep',       COUNT(DISTINCT Id) FROM bellabeat.clean_minuteSleep UNION ALL
SELECT 'clean_heartrate',         COUNT(DISTINCT Id) FROM bellabeat.clean_heartrate UNION ALL
SELECT 'clean_weightLogInfo',     COUNT(DISTINCT Id) FROM bellabeat.clean_weightLogInfo UNION ALL
SELECT 'agg_dailySleep',          COUNT(DISTINCT Id) FROM bellabeat.agg_dailySleep UNION ALL
SELECT 'agg_dailyHeartrate',      COUNT(DISTINCT Id) FROM bellabeat.agg_dailyHeartrate UNION ALL
SELECT 'flagged_dailyActivity',   COUNT(DISTINCT Id) FROM bellabeat.flagged_dailyActivity UNION ALL
SELECT 'agg_wearRate',            COUNT(DISTINCT Id) FROM bellabeat.agg_wearRate
ORDER BY table_name;

-- Date ranges across all tables (confirms March–April 2016 window)
SELECT 'clean_dailyActivity'    AS table_name, MIN(ActivityDate) AS earliest, MAX(ActivityDate) AS latest FROM bellabeat.clean_dailyActivity UNION ALL
SELECT 'clean_hourlyCalories',                 MIN(ActivityHour), MAX(ActivityHour)                       FROM bellabeat.clean_hourlyCalories UNION ALL
SELECT 'clean_hourlyIntensities',              MIN(ActivityHour), MAX(ActivityHour)                       FROM bellabeat.clean_hourlyIntensities UNION ALL
SELECT 'clean_hourlySteps',                    MIN(ActivityHour), MAX(ActivityHour)                       FROM bellabeat.clean_hourlySteps UNION ALL
SELECT 'clean_minuteSleep',                    MIN(date),         MAX(date)                               FROM bellabeat.clean_minuteSleep UNION ALL
SELECT 'agg_dailySleep',                       MIN(SleepDate),    MAX(SleepDate)                         FROM bellabeat.agg_dailySleep UNION ALL
SELECT 'clean_heartrate',                      MIN(Time),         MAX(Time)                               FROM bellabeat.clean_heartrate UNION ALL
SELECT 'clean_weightLogInfo',                  MIN(Date),         MAX(Date)                               FROM bellabeat.clean_weightLogInfo
ORDER BY table_name;

-- Coverage gap analysis: which of the 35 core users have matching
-- records in the smaller tables?
SELECT
  CASE WHEN w.Id IS NOT NULL THEN 'has weight log' ELSE 'no weight log' END AS weight_status,
  COUNT(DISTINCT d.Id) AS user_count
FROM bellabeat.dailyActivity_merged AS d
LEFT JOIN bellabeat.weightLogInfo_merged AS w ON d.Id = w.Id
GROUP BY weight_status;
-- Result: 11 of 35 users have weight data; 24 do not

SELECT
  CASE WHEN h.Id IS NOT NULL THEN 'has heart rate data' ELSE 'no heart rate log' END AS hr_status,
  COUNT(DISTINCT d.Id) AS user_count
FROM bellabeat.dailyActivity_merged AS d
LEFT JOIN bellabeat.heartrate_seconds_merged AS h ON d.Id = h.Id
GROUP BY hr_status;
-- Result: 14 of 35 users have heart rate data; 21 do not

SELECT
  CASE WHEN s.Id IS NOT NULL THEN 'has sleep data' ELSE 'no sleep data' END AS sleep_status,
  COUNT(DISTINCT d.Id) AS user_count
FROM bellabeat.dailyActivity_merged AS d
LEFT JOIN bellabeat.minuteSleep_merged AS s ON d.Id = s.Id
GROUP BY sleep_status;
-- Result: 23 of 35 users have sleep data; 12 do not
