CREATE TABLE stg_payments (
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    User_ID VARCHAR(20),
    Payment_Method VARCHAR(50),
    Amount DECIMAL(10,2),
    Status VARCHAR(20),
    Timestamp DATETIME
);

CREATE TABLE daily_payment_summary (
    Payment_Date DATE PRIMARY KEY,
    Total_Transactions INT,
    Successful_Transactions INT,
    Failed_Transactions INT,
    Total_Amount DECIMAL(15,2)
);

INSERT INTO daily_payment_summary (Payment_Date, Total_Transactions, Successful_Transactions, Failed_Transactions, Total_Amount)
SELECT
    DATE(Timestamp) AS Payment_Date,
    COUNT(*) AS Total_Transactions,
    SUM(CASE WHEN Status = 'SUCCESS' THEN 1 ELSE 0 END) AS Successful_Transactions,
    SUM(CASE WHEN Status = 'FAILED' THEN 1 ELSE 0 END) AS Failed_Transactions,
    SUM(Amount) AS Total_Amount
FROM stg_payments
GROUP BY DATE(Timestamp)
ORDER BY Payment_Date;

1.Total transactions by payment method:
SELECT Payment_Method, 
       COUNT(*) AS Total_Transactions,
       SUM(CASE WHEN Status = 'SUCCESS' THEN 1 ELSE 0 END) AS Successful_Transactions,
       SUM(CASE WHEN Status = 'FAILED' THEN 1 ELSE 0 END) AS Failed_Transactions,
       SUM(Amount) AS Total_Amount
FROM stg_payments
GROUP BY Payment_Method
ORDER BY Total_Transactions DESC;

2.Daily success rate:
SELECT Payment_Date,
       Total_Transactions,
       Successful_Transactions,
       Failed_Transactions,
       ROUND((Successful_Transactions/Total_Transactions)*100, 2) AS Success_Rate
FROM daily_payment_summary
ORDER BY Payment_Date DESC;

3.Top 5 users by transaction amount:
SELECT User_ID,
       COUNT(*) AS Total_Transactions,
       SUM(Amount) AS Total_Amount
FROM stg_payments
WHERE Status = 'SUCCESS'
GROUP BY User_ID
ORDER BY Total_Amount DESC
LIMIT 5;

4.Failed transactions to investigate:
SELECT * 
FROM stg_payments
WHERE Status = 'FAILED'
ORDER BY Timestamp DESC;

Join Quereies:
CREATE TABLE users (
    User_ID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    City VARCHAR(50),
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (User_ID, Name, Email, City) VALUES
('U001', 'Alice Johnson', 'alice@example.com', 'New York'),
('U002', 'Bob Smith', 'bob@example.com', 'Los Angeles'),
('U003', 'Charlie Lee', 'charlie@example.com', 'Chicago'),
('U004', 'Diana Rose', 'diana@example.com', 'Houston'),
('U005', 'Ethan Brown', 'ethan@example.com', 'San Francisco');

1.payment details with user info,(INNER JOIN):
SELECT 
    p.Transaction_ID,
    p.User_ID,
    u.Name,
    u.Email,
    p.Payment_Method,
    p.Amount,
    p.Status,
    p.Timestamp
FROM stg_payments p
INNER JOIN users u
ON p.User_ID = u.User_ID
ORDER BY p.Timestamp DESC;

2.all payments, and add user info if available. If no matching user, still show the payment (LEFT JOIN):
SELECT 
    p.Transaction_ID,
    p.User_ID,
    u.Name,
    u.Email,
    p.Payment_Method,
    p.Amount,
    p.Status,
    p.Timestamp
FROM stg_payments p
LEFT JOIN users u
ON p.User_ID = u.User_ID
ORDER BY p.Timestamp DESC;

3.total amount paid by each user(JOIN With Aggregation):
SELECT 
    u.User_ID,
    u.Name,
    SUM(p.Amount) AS Total_Paid,
    COUNT(p.Transaction_ID) AS Total_Transactions
FROM stg_payments p
INNER JOIN users u
ON p.User_ID = u.User_ID
WHERE p.Status = 'SUCCESS'
GROUP BY u.User_ID, u.Name
ORDER BY Total_Paid DESC;

4.Combine staging payments with daily summary to get success rate per day(JOIN With Daily Summary):
SELECT 
    d.Payment_Date,
    d.Total_Transactions,
    d.Successful_Transactions,
    d.Total_Amount,
    ROUND((d.Successful_Transactions / d.Total_Transactions) * 100, 2) AS Success_Rate,
    COUNT(p.Transaction_ID) AS Transactions_Detail
FROM daily_payment_summary d
LEFT JOIN stg_payments p
ON DATE(p.Timestamp) = d.Payment_Date
GROUP BY d.Payment_Date, d.Total_Transactions, d.Successful_Transactions, d.Total_Amount
ORDER BY d.Payment_Date DESC;

5.Find total amount per payment method per user(JOIN With Payment Method):
SELECT 
    u.User_ID,
    u.Name,
    p.Payment_Method,
    SUM(p.Amount) AS Total_Amount,
    COUNT(p.Transaction_ID) AS Total_Transactions
FROM stg_payments p
INNER JOIN users u
ON p.User_ID = u.User_ID
WHERE p.Status = 'SUCCESS'
GROUP BY u.User_ID, u.Name, p.Payment_Method
ORDER BY Total_Amount DESC;

