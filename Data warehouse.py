import pandas as pd
import random
from datetime import datetime, timedelta


NUM_RECORDS = 100

payment_methods = ["Credit Card", "Debit Card", "UPI", "Wallet", "Net Banking"]
transaction_types = ["Purchase", "Refund", "Subscription"]
statuses = ["Success", "Failed"]
failure_reasons = ["Insufficient Funds", "Network Error", "Card Expired", "Invalid PIN", None]
countries = ["India", "USA", "UK", "Canada", "Australia"]
currencies = ["INR", "USD", "GBP", "CAD", "AUD"]

start_date = datetime(2025, 1, 1)


data = []

for i in range(1, NUM_RECORDS + 1):
    txn_date = start_date + timedelta(days=random.randint(0, 30))
    txn_time = datetime.strptime(
        f"{random.randint(0,23)}:{random.randint(0,59)}:{random.randint(0,59)}",
        "%H:%M:%S"
    ).time()

    status = random.choice(statuses)
    failure = None if status == "Success" else random.choice(failure_reasons)

    amount = round(random.uniform(50, 5000), 2)

    platform_fee = round(amount * 0.02, 2) if status == "Success" else 0
    merchant_payable = round(amount - platform_fee, 2) if status == "Success" else 0

    record = {
        "Transaction_ID": f"T{i:04d}",
        "Transaction_Date": txn_date.date(),
        "Transaction_Time": txn_time,
        "Customer_ID": f"CUST{random.randint(1000, 9999)}",
        "Merchant_ID": f"MER{random.randint(100, 999)}",
        "Payment_Method": random.choice(payment_methods),
        "Transaction_Type": random.choice(transaction_types),
        "Amount": amount,
        "Currency": random.choice(currencies),
        "Status": status,
        "Failure_Reason": failure,
        "Platform_Fee": platform_fee,
        "Merchant_Payable": merchant_payable,
        "Country": random.choice(countries)
    }

    data.append(record)


df = pd.DataFrame(data)


df.to_csv("payment_transactions_sample_100.csv", index=False)

print("Dataset created successfully!")
print(df.head())
