import os
import pandas as pd
import numpy as np
from config import *
from utils import setup_logger

logger = setup_logger("feature_engineering")

def engineer_features():
    logger.info("Starting feature engineering...")
    
    # Load cleaned data
    da = pd.read_csv(PROCESSED_DAILY_ACTIVITY)
    sd = pd.read_csv(PROCESSED_SLEEP_DAY)
    wl = pd.read_csv(PROCESSED_WEIGHT_LOG)
    
    da['ActivityDate'] = pd.to_datetime(da['ActivityDate'])
    sd['SleepDay'] = pd.to_datetime(sd['SleepDay'])
    wl['Date'] = pd.to_datetime(wl['Date'])
    
    # 1. Row-level temporal features
    da['day_of_week'] = da['ActivityDate'].dt.day_name()
    da['weekend_flag'] = da['ActivityDate'].dt.dayofweek.isin([5, 6]).astype(int)
    
    # 2. Daily active and sedentary ratios
    da['total_minutes_tracked'] = (da['VeryActiveMinutes'] + 
                                   da['FairlyActiveMinutes'] + 
                                   da['LightlyActiveMinutes'] + 
                                   da['SedentaryMinutes'])
    
    # Avoid division by zero
    da['total_minutes_tracked'] = da['total_minutes_tracked'].replace(0, np.nan)
    
    da['sedentary_percentage'] = (da['SedentaryMinutes'] / da['total_minutes_tracked']) * 100
    da['active_percentage'] = ((da['VeryActiveMinutes'] + da['FairlyActiveMinutes'] + da['LightlyActiveMinutes']) / da['total_minutes_tracked']) * 100
    da['sedentary_ratio'] = da['SedentaryMinutes'] / da['total_minutes_tracked']
    da['active_intensity_ratio'] = (da['VeryActiveMinutes'] + da['FairlyActiveMinutes']) / (da['VeryActiveMinutes'] + da['FairlyActiveMinutes'] + da['LightlyActiveMinutes']).replace(0, np.nan)
    
    # Calories per step
    da['calories_per_step'] = da['Calories'] / da['TotalSteps'].replace(0, np.nan)
    da['calories_per_step'] = da['calories_per_step'].fillna(0)
    
    # Highly active day flag (WHO recommends 20+ mins of moderate-to-vigorous daily, or steps >= 12,000)
    da['highly_active_day_flag'] = ((da['VeryActiveMinutes'] + da['FairlyActiveMinutes'] >= 21) | (da['TotalSteps'] >= 12000)).astype(int)
    
    # Fill NAs
    da['sedentary_percentage'] = da['sedentary_percentage'].fillna(0)
    da['active_percentage'] = da['active_percentage'].fillna(0)
    da['sedentary_ratio'] = da['sedentary_ratio'].fillna(0)
    da['active_intensity_ratio'] = da['active_intensity_ratio'].fillna(0)
    
    # 3. User-level aggregations & consistency metrics
    user_metrics = da.groupby('Id').agg(
        avg_daily_steps_per_user=('TotalSteps', 'mean'),
        avg_daily_calories=('Calories', 'mean'),
        activity_consistency=('TotalSteps', 'std'), # Standard deviation of steps
        active_mins_consistency=('VeryActiveMinutes', lambda x: x.std()),
        total_days_tracked=('ActivityDate', 'count')
    ).reset_index()
    
    # Fill standard deviation for users with only 1 log day
    user_metrics['activity_consistency'] = user_metrics['activity_consistency'].fillna(0)
    user_metrics['active_mins_consistency'] = user_metrics['active_mins_consistency'].fillna(0)
    
    # Device wear compliance segment
    max_days = 61 # 2 months total tracking period
    user_metrics['wear_compliance'] = user_metrics['total_days_tracked'] / max_days
    user_metrics['wear_compliance_segment'] = pd.cut(
        user_metrics['wear_compliance'],
        bins=[0, COMPLIANCE_MEDIUM, COMPLIANCE_HIGH, 1.05],
        labels=['low_compliance', 'medium_compliance', 'high_compliance']
    )
    
    # Tudor-Locke Activity segments based on average steps
    user_metrics['user_activity_segment'] = pd.cut(
        user_metrics['avg_daily_steps_per_user'],
        bins=[0, TUDOR_LOCKE_INDICES['sedentary'], TUDOR_LOCKE_INDICES['low_active'], 
              TUDOR_LOCKE_INDICES['somewhat_active'], TUDOR_LOCKE_INDICES['active'], 200000],
        labels=['sedentary', 'low_active', 'somewhat_active', 'active', 'highly_active']
    )
    
    # Weekend activity change: % difference in steps on weekend vs weekday
    weekend_steps = da.groupby(['Id', 'weekend_flag'])['TotalSteps'].mean().unstack(fill_value=0).reset_index()
    weekend_steps.columns = ['Id', 'weekday_avg_steps', 'weekend_avg_steps']
    
    # Weekend change: (weekend - weekday) / weekday
    weekend_steps['weekend_activity_change'] = (
        (weekend_steps['weekend_avg_steps'] - weekend_steps['weekday_avg_steps']) / 
        weekend_steps['weekday_avg_steps'].replace(0, np.nan)
    )
    weekend_steps['weekend_activity_change'] = weekend_steps['weekend_activity_change'].fillna(0)
    
    user_metrics = pd.merge(user_metrics, weekend_steps[['Id', 'weekend_activity_change']], on='Id', how='left')
    
    # Merge user-level stats back to daily level
    da = pd.merge(da, user_metrics, on='Id', how='left')
    
    # 4. Sleep metrics & Sleep Deficit
    sd['sleep_efficiency'] = sd['TotalMinutesAsleep'] / sd['TotalTimeInBed']
    sd['sleep_efficiency'] = sd['sleep_efficiency'].fillna(0)
    
    # Sleep consistency (std dev of minutes asleep per user)
    sleep_user = sd.groupby('Id').agg(
        sleep_consistency=('TotalMinutesAsleep', 'std'),
        avg_sleep_duration=('TotalMinutesAsleep', 'mean')
    ).reset_index()
    sleep_user['sleep_consistency'] = sleep_user['sleep_consistency'].fillna(0)
    
    # Merge user-level sleep stats back
    sd = pd.merge(sd, sleep_user, on='Id', how='left')
    
    # Sleep Deficit category: CDC recommends 7-9 hours of sleep for adults (420 to 540 mins)
    # Daily Sleep Deficit category
    sd['sleep_deficit_category'] = pd.cut(
        sd['TotalMinutesAsleep'],
        bins=[0, 420, 540, 2000],
        labels=['deficit', 'optimal', 'oversleep']
    )
    sd['sleep_deficit_category'] = sd['sleep_deficit_category'].fillna('deficit')
    
    # 5. Merge Daily Activity and Sleep tables for holistic dashboard exports
    # Merge daily activity and daily sleep on Id and Date
    sd_daily = sd.copy().rename(columns={'SleepDay': 'ActivityDate'})
    features_df = pd.merge(da, sd_daily, on=['Id', 'ActivityDate'], how='left')
    
    # Save output
    features_df.to_csv(ENGINEERED_DAILY_FEATURES, index=False)
    logger.info(f"Saved engineered features dataset with {len(features_df)} rows to {ENGINEERED_DAILY_FEATURES}")
    return features_df

if __name__ == "__main__":
    engineer_features()
    logger.info("Feature engineering completed successfully!")
