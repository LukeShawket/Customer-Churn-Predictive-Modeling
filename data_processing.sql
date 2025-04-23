# Rename the table
RENAME TABLE `old_table_name` TO `customer_churn_raw`;
# set sql safe update mode to false
SET SQL_SAFE_UPDATES = 0;

# Create a new table to work on
CREATE TABLE customer_churn_clean
LIKE customer_churn;

# Copy all the content from raw data
INSERT customer_churn_clean
SELECT *
FROM customer_churn;

# Review the data
SELECT *  FROM customer_churn_clean;

# Check for duplicates
WITH duplicates AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY customerID, gender, SeniorCitizen,
Partner, Dependents, tenure, PhoneService, MultipleLines, InternetService,
OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies, Contract,
PaperlessBilling, PaymentMethod, MonthlyCharges, TotalCharges, Churn) AS row_num
FROM customer_churn_clean
)
SELECT *
FROM duplicates
WHERE row_num > 1;

# Check data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_churn_clean';

# Updating rows that contains yes's and no's
# Repeated this process for multiple columns
SELECT DISTINCT Churn
FROM customer_churn_clean;

UPDATE customer_churn_clean
SET Churn = CASE
    WHEN Churn = 'Yes' THEN '1'
    WHEN Churn = 'No' THEN '0'
END;

# Update data type
ALTER TABLE customer_churn_clean
MODIFY SeniorCitizen BIT(1),
MODIFY MonthlyCharges float,
MODIFY TotalCharges float,
MODIFY Partner BIT(1),
MODIFY Dependents BIT(1),
MODIFY PhoneService BIT(1),
MODIFY MultipleLines BIT(1),
MODIFY OnlineSecurity BIT(1),
MODIFY OnlineBackup BIT(1),
MODIFY DeviceProtection BIT(1),
MODIFY TechSupport BIT(1),
MODIFY StreamingTV BIT(1),
MODIFY StreamingMovies BIT(1),
MODIFY PaperlessBilling BIT(1),
MODIFY Churn BIT(1);

# Check for null values
SELECT 
	(SELECT COUNT(*) FROM customer_churn_clean WHERE customerID IS NULL) as customer_id,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE tenure IS NULL) as tenure,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE InternetService IS NULL) as internet_service,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE Contract IS NULL) as contract,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE PaymentMethod IS NULL) as payment_method,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE MonthlyCharges IS NULL) as monthly_charges,
    (SELECT COUNT(*) FROM customer_churn_clean WHERE TotalCharges IS NULL) as total_charges
FROM customer_churn_clean;

# Standardizing
# Trim 
SELECT customerID, trim(customerID)
FROM customer_churn_clean;

UPDATE customer_churn_clean
SET customerID = TRIM(customerID),
	InternetService = TRIM(InternetService),
    Contract = TRIM(Contract),
    PaymentMethod = TRIM(PaymentMethod);

# Standardizing column names
ALTER TABLE customer_churn_clean
CHANGE tenure Tenure INT NOT NULL,
CHANGE gender Gender VARCHAR(10) NOT NULL,
CHANGE customerID CustomerID VARCHAR(50);

# Checking for outliers from strings columns
SELECT DISTINCT COUNT(InternetService), InternetService
FROM customer_churn_clean
GROUP BY InternetService;


# Data exploreation
# review the data
SELECT *  FROM customer_churn_clean;

# count total customers
SELECT DISTINCT count(customerID) as total_customers
FROM customer_churn_clean;

# customers by gender and their pct distribution
SELECT gender, count(customerID) AS count, count(customerID)/(SELECT count(customerID) FROM customer_churn_clean)*100 pct
FROM customer_churn_clean
group by gender;

# Total people left and churn rate
SELECT COUNT(customerID) AS customers_left, CAST(count(customerID)/(SELECT count(customerID) FROM customer_churn_clean) * 100 AS DECIMAL(10, 2)) AS churn_rate
FROM customer_churn_clean
WHERE Churn = 1;

# Total senior citizen
SELECT SeniorCitizen, COUNT(*) AS people_count
FROM customer_churn_clean
GROUP BY SeniorCitizen;

# Export CSV



