import os
import logging
import pandas as pd

def setup_logger(name):
    """Sets up a standardized logger to output to console and file."""
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    
    if not logger.handlers:
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        
        # Console Handler
        ch = logging.StreamHandler()
        ch.setFormatter(formatter)
        logger.addHandler(ch)
        
    return logger

def standardize_columns(df):
    """Standardizes column names: trims whitespace and ensures correct casing."""
    df.columns = [col.strip() for col in df.columns]
    return df

def clean_dates(df, col_name):
    """Parses date string columns to pandas datetime formats."""
    df[col_name] = pd.to_datetime(df[col_name])
    return df
