import pandas as pd

# Define sample payment data
data = {
    'Transaction_ID': ['TXN001', 'TXN002', 'TXN003', 'TXN004', 'TXN005'],
    'User_ID': ['U001', 'U002', 'U003', 'U004', 'U005'],
    'Payment_Method': ['Credit Card', 'UPI', 'Debit Card', 'Net Banking', 'Wallet'],
    'Amount': [1200, 500, 1500, 2000, 800],
    'Status': ['SUCCESS', 'FAILED', 'SUCCESS', 'SUCCESS', 'FAILED'],
    'Timestamp': [
        '2026-01-20 10:15:00',
        '2026-01-20 10:20:00',
        '2026-01-20 11:00:00',
        '2026-01-21 09:45:00',
        '2026-01-21 10:05:00'
    ]
}

# Create DataFrame
df = pd.DataFrame(data)

# Save to CSV in the current folder
csv_file = 'payment_data.csv'
df.to_csv(csv_file, index=False)

print(f"CSV file '{csv_file}' has been created successfully in the current folder!")
