import os

# Project Root (determined dynamically relative to this script's location)
SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPTS_DIR)

# Folders
RAW_DATA_DIR = os.path.join(PROJECT_ROOT, "data", "raw")
PROCESSED_DATA_DIR = os.path.join(PROJECT_ROOT, "data", "processed")
REPORTS_DIR = os.path.join(PROJECT_ROOT, "reports")
SQL_DIR = os.path.join(PROJECT_ROOT, "sql")
NOTEBOOKS_DIR = os.path.join(PROJECT_ROOT, "notebooks")
IMAGES_DIR = os.path.join(PROJECT_ROOT, "images")

# Raw File Paths
RAW_M1_ACTIVITY = os.path.join(RAW_DATA_DIR, "month1", "dailyActivity_merged.csv")
RAW_M2_ACTIVITY = os.path.join(RAW_DATA_DIR, "month2", "dailyActivity_merged.csv")

RAW_M1_HOURLY_STEPS = os.path.join(RAW_DATA_DIR, "month1", "hourlySteps_merged.csv")
RAW_M2_HOURLY_STEPS = os.path.join(RAW_DATA_DIR, "month2", "hourlySteps_merged.csv")

RAW_M1_HOURLY_CALORIES = os.path.join(RAW_DATA_DIR, "month1", "hourlyCalories_merged.csv")
RAW_M2_HOURLY_CALORIES = os.path.join(RAW_DATA_DIR, "month2", "hourlyCalories_merged.csv")

RAW_M1_HOURLY_INTENSITIES = os.path.join(RAW_DATA_DIR, "month1", "hourlyIntensities_merged.csv")
RAW_M2_HOURLY_INTENSITIES = os.path.join(RAW_DATA_DIR, "month2", "hourlyIntensities_merged.csv")

RAW_M1_MINUTE_SLEEP = os.path.join(RAW_DATA_DIR, "month1", "minuteSleep_merged.csv")
RAW_M2_MINUTE_SLEEP = os.path.join(RAW_DATA_DIR, "month2", "minuteSleep_merged.csv")
RAW_M2_SLEEP_DAY = os.path.join(RAW_DATA_DIR, "month2", "sleepDay_merged.csv")

RAW_M1_WEIGHT = os.path.join(RAW_DATA_DIR, "month1", "weightLogInfo_merged.csv")
RAW_M2_WEIGHT = os.path.join(RAW_DATA_DIR, "month2", "weightLogInfo_merged.csv")

# Processed File Paths
PROCESSED_DAILY_ACTIVITY = os.path.join(PROCESSED_DATA_DIR, "cleaned_daily_activity.csv")
PROCESSED_SLEEP_DAY = os.path.join(PROCESSED_DATA_DIR, "cleaned_sleep_day.csv")
PROCESSED_WEIGHT_LOG = os.path.join(PROCESSED_DATA_DIR, "cleaned_weight_log.csv")
PROCESSED_HOURLY_ACTIVITY = os.path.join(PROCESSED_DATA_DIR, "cleaned_hourly_activity.csv")
ENGINEERED_DAILY_FEATURES = os.path.join(PROCESSED_DATA_DIR, "engineered_features.csv")

# Reproducibility Seed
RANDOM_STATE = 42

# Plotting Settings
PLOT_STYLE = "seaborn-v0_8-whitegrid"
PLOT_CONTEXT = "notebook"
COLOR_PALETTE = ["#FF6B6B", "#4D96FF", "#6BCB77", "#FFD93D", "#9B5DE5", "#F15BB5"]
KPI_COLORS = {
    "primary": "#3B82F6",      # Blue
    "success": "#10B981",      # Green
    "warning": "#F59E0B",      # Yellow
    "danger": "#EF4444",       # Red
    "background": "#F8FAFC"    # Slate background
}

# Behavioral Analysis Thresholds & Constants
TUDOR_LOCKE_INDICES = {
    "sedentary": 5000,
    "low_active": 7500,
    "somewhat_active": 10000,
    "active": 12500
}

# Device Compliance Thresholds (Wear Adherence)
COMPLIANCE_HIGH = 0.80   # >80% days
COMPLIANCE_MEDIUM = 0.50 # 50% - 80% days

# Health Guideline Constants
WHO_MIN_WEEKLY_ACTIVITY_MINS = 150
WHO_MIN_DAILY_STEPS = 10000
CLINICAL_MIN_SLEEP_HOURS = 7.0
CLINICAL_MAX_SLEEP_HOURS = 9.0
CLINICAL_MIN_SLEEP_EFFICIENCY = 0.85 # 85% sleep efficiency threshold
