/*
    SOLUTIONS.sql
    i2i Systems - telco database case study

    In this file I wrote the required SQL queries for the telecom dataset
    I used the CUSTOMERS, TARIFFS and MONTHLY_STATS tables according to the relations in the csv files
    Each question has a short explanation before the query
*/


/*
    1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.

    Explanation:
    In this query I need to find customers according to tariff name, but tariff name is not directly stored in CUSTOMERS table.
    Because of that I joined CUSTOMERS table with TARIFFS table by using TARIFF_ID column.
    After the join, I filtered only the rows where tariff name is 'Kobiye Destek', so the result shows the customers using this tariff.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.CUSTOMER_ID;


/*
    1.2 Find the newest customer who subscribed to the 'Kobiye Destek' tariff.

    Explanation:
    Here I again used the join between CUSTOMERS and TARIFFS because I have to filter the customer by tariff name
    To find the newest customer, I sorted the result according to SIGNUP_DATE from newest to oldest
    Then I used FETCH FIRST 1 ROW ONLY to get only the first row, which should be the latest subscribed customer for this tariff
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;


/*
    2.1 Find the distribution of tariffs among the customers.

    Explanation:
    In this part I wanted to see how many customers are using each tariff.
    I joined TARIFFS with CUSTOMERS, so I can show the tariff name instead of only tariff id.
    I used GROUP BY and COUNT to calculate the total customer number for every tariff.
*/
SELECT
    t.TARIFF_ID,
    t.NAME AS TARIFF_NAME,
    COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c
    ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY
    t.TARIFF_ID,
    t.NAME
ORDER BY CUSTOMER_COUNT DESC;


/*
    3.1 Identify the earliest customers to sign up.

    Explanation:
    For this question I should not use CUSTOMER_ID, because lower id does not always mean older customer.
    The correct column is SIGNUP_DATE, so I used MIN(SIGNUP_DATE) to find the earliest signup date in the table.
    After that, I selected all customers who have this earliest date, because maybe more than one customer signed up on same day.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    c.TARIFF_ID
FROM CUSTOMERS c
WHERE c.SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
ORDER BY c.CUSTOMER_ID;


/*
    3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.

    Explanation:
    In this query I first selected only the customers who signed up at the earliest signup date.
    Then I grouped these customers by CITY to understand from which cities these first customers came.
    COUNT(*) gives the number of earliest customers for each city in the result.
*/
SELECT
    c.CITY,
    COUNT(*) AS EARLIEST_CUSTOMER_COUNT
FROM CUSTOMERS c
WHERE c.SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY c.CITY
ORDER BY EARLIEST_CUSTOMER_COUNT DESC, c.CITY;


/*
    4.1 Every customer has a monthly fee, and the dataset contains this month's usage values.
    However, an insertion error occurred, and some customers' monthly records are missing.
    Identify the IDs of these missing customers.

    Explanation:
    In this query I need to find customers that exists in CUSTOMERS table but there is no record for them in MONTHLY_STATS.
    For this reason, I used LEFT JOIN because it keeps all rows from CUSTOMERS even if monthly record is missing.
    Then I checked ms.CUSTOMER_ID IS NULL, and this gives the customers without monthly stats record.
*/
SELECT
    c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
ORDER BY c.CUSTOMER_ID;


/*
    4.2 Find the distribution of these missing customers across different cities.

    Explanation:
    This question is similar to previous one, but now I need to count missing customers by city.
    I again used LEFT JOIN between CUSTOMERS and MONTHLY_STATS and filtered the rows where monthly stats does not exist.
    After that I grouped the result by CITY and counted how many missing monthly records are in each city.
*/
SELECT
    c.CITY,
    COUNT(*) AS MISSING_CUSTOMER_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY c.CITY
ORDER BY MISSING_CUSTOMER_COUNT DESC, c.CITY;


/*
    5.1 Find the customers who have used at least 75% of their data limit.

    Explanation:
    For this query I compared customer's DATA_USAGE with the DATA_LIMIT value of his/her tariff.
    Since usage information is in MONTHLY_STATS and limit information is in TARIFFS, I joined all three tables together.
    I also added t.DATA_LIMIT > 0 condition to avoid division problems for tariffs which may not include data package.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    ROUND((ms.DATA_USAGE / t.DATA_LIMIT) * 100, 2) AS DATA_USAGE_PERCENTAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
  AND ms.DATA_USAGE >= (t.DATA_LIMIT * 0.75)
ORDER BY DATA_USAGE_PERCENTAGE DESC;


/*
    5.2 Identify the customers who have completely exhausted all of their package limits: data, minutes, and SMS.

    Explanation:
    In this question I checked all package limits together, not only data usage.
    The customer must have data usage greater than or equal to data limit, minute usage greater than or equal to minute limit, and sms usage greater than or equal to sms limit.
    I used joins because package limits and monthly usage values are stored in different tables.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    t.MINUTE_LIMIT,
    ms.MINUTE_USAGE,
    t.SMS_LIMIT,
    ms.SMS_USAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.DATA_USAGE >= t.DATA_LIMIT
  AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT
  AND ms.SMS_USAGE >= t.SMS_LIMIT
ORDER BY c.CUSTOMER_ID;


/*
    6.1 Find the customers who have unpaid fees.

    Explanation:
    Payment information is not in CUSTOMERS table, it is stored in MONTHLY_STATS table as PAYMENT_STATUS.
    So I joined CUSTOMERS and MONTHLY_STATS by CUSTOMER_ID to see payment status with customer details.
    Then I filtered the rows where PAYMENT_STATUS is 'UNPAID', because these customers did not pay their fee.
*/
SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.PAYMENT_STATUS = 'UNPAID'
ORDER BY c.CUSTOMER_ID;


/*
    6.2 Find the distribution of all payment statuses across the different tariffs.

    Explanation:
    In this last query I wanted to see payment status distribution for every tariff.
    I joined CUSTOMERS with TARIFFS for tariff name and also joined MONTHLY_STATS for payment status.
    Finally, I grouped by tariff name and payment status, and counted the customers in each group.
*/
SELECT
    t.NAME AS TARIFF_NAME,
    ms.PAYMENT_STATUS,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
GROUP BY
    t.NAME,
    ms.PAYMENT_STATUS
ORDER BY
    t.NAME,
    ms.PAYMENT_STATUS;
