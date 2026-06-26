import os
import sqlite3
import pandas as pd
from config import *
from utils import setup_logger

logger = setup_logger("db_setup")

def init_database():
    db_path = os.path.join(PROCESSED_DATA_DIR, "bellabeat.db")
    logger.info(f"Initializing SQLite database at {db_path}...")
    
    # Connect
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 1. Run Schema.sql
    schema_path = os.path.join(SQL_DIR, "schema.sql")
    with open(schema_path, "r") as f:
        schema_sql = f.read()
    
    # SQLite does not support DROP TABLE IF EXISTS ... CASCADE or multiple statements easily in a single execute,
    # so we split by semicolon.
    statements = [stmt.strip() for stmt in schema_sql.split(";") if stmt.strip()]
    for stmt in statements:
        cursor.execute(stmt)
    conn.commit()
    logger.info("Created tables from schema.sql successfully.")
    
    # 2. Populate Tables from Processed CSVs
    logger.info("Loading processed CSVs into database tables...")
    
    da_df = pd.read_csv(PROCESSED_DAILY_ACTIVITY)
    # Ensure column date strings are parsed nicely
    da_df.to_sql("daily_activity", conn, if_exists="append", index=False)
    logger.info(f"Loaded {len(da_df)} rows into daily_activity.")
    
    sd_df = pd.read_csv(PROCESSED_SLEEP_DAY)
    sd_df.to_sql("sleep_day", conn, if_exists="append", index=False)
    logger.info(f"Loaded {len(sd_df)} rows into sleep_day.")
    
    wl_df = pd.read_csv(PROCESSED_WEIGHT_LOG)
    # Convert IsManualReport to int for SQLite boolean compatibility
    wl_df['IsManualReport'] = wl_df['IsManualReport'].astype(int)
    wl_df.to_sql("weight_log", conn, if_exists="append", index=False)
    logger.info(f"Loaded {len(wl_df)} rows into weight_log.")
    
    ha_df = pd.read_csv(PROCESSED_HOURLY_ACTIVITY)
    # Rename StepTotal to match schema (hourly_activity has StepTotal or steps)
    # Let's inspect column names in ha_df: hourly_activity has 'StepTotal' in raw, we need to map to StepTotal
    if 'StepTotal' not in ha_df.columns and 'Steps' in ha_df.columns:
        ha_df = ha_df.rename(columns={'Steps': 'StepTotal'})
    elif 'StepTotal' not in ha_df.columns and 'StepTotal_merged' in ha_df.columns:
        ha_df = ha_df.rename(columns={'StepTotal_merged': 'StepTotal'})
    # Ensure correct columns mapping
    ha_df.to_sql("hourly_activity", conn, if_exists="append", index=False)
    logger.info(f"Loaded {len(ha_df)} rows into hourly_activity.")
    
    # 3. Run Views.sql
    views_path = os.path.join(SQL_DIR, "views.sql")
    with open(views_path, "r") as f:
        views_sql = f.read()
    
    statements = [stmt.strip() for stmt in views_sql.split(";") if stmt.strip()]
    for stmt in statements:
        cursor.execute(stmt)
    conn.commit()
    logger.info("Created views from views.sql successfully.")
    
    conn.close()
    logger.info("Database setup completed successfully!")

if __name__ == "__main__":
    init_database()
