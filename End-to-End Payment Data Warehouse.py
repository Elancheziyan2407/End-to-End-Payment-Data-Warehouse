import pandas as pd
from sqlalchemy import create_engine


# 1. EXTRACT: Load raw data

# Example: CSV file from payment gateway
payments = pd.read_csv('payment_data.csv')

# Sample columns in CSV: Transaction_ID, User_ID, Payment_Method, Amount, Status, Timestamp


# 2. TRANSFORM: Clean and process data

# Convert timestamp to datetime
payments['Timestamp'] = pd.to_datetime(payments['Timestamp'])

# Standardize payment status
payments['Status'] = payments['Status'].str.upper()

# Calculate additional column: Is_Success (1 if success else 0)
payments['Is_Success'] = payments['Status'].apply(lambda x: 1 if x=='SUCCESS' else 0)

# Aggregate example: total payment amount per day
daily_summary = payments.groupby(payments['Timestamp'].dt.date).agg(
    Total_Transactions=('Transaction_ID','count'),
    Successful_Transactions=('Is_Success','sum'),
    Total_Amount=('Amount','sum')
).reset_index()


# 3. LOAD: Save to Data Warehouse (MySQL Example)
# Create MySQL engine
engine = create_engine('mysql+mysqlconnector://root:password@localhost:3306/payment_dw')

# Load raw data into staging table
payments.to_sql(name='stg_payments', con=engine, if_exists='replace', index=False)

# Load daily summary into analytics table
daily_summary.to_sql(name='daily_payment_summary', con=engine, if_exists='replace', index=False)
print("ETL Process Completed Successfully!")


# 4. ANALYTICS: Simple Query Example

query = """
SELECT 
    DATE(Timestamp) as Payment_Date,
    COUNT(*) as Total_Transactions,
    SUM(Is_Success) as Successful_Transactions,
    SUM(Amount) as Total_Amount
FROM stg_payments
GROUP BY DATE(Timestamp)
ORDER BY Payment_Date DESC
"""
report = pd.read_sql(query, con=engine)
print(report.head())
