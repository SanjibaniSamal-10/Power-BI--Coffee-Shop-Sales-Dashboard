select * from `coffee shop sales`;
SET SQL_SAFE_UPDATES=0;
-- CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT
update `coffee shop sales`
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y')
where transaction_date is not NULL and transaction_date != '';
set sql_safe_updates=1;
-- ALTER DATE (transaction_date) COLUMN TO DATE DATA TYPE
alter table `coffee shop sales`
MODIFY COLUMN transaction_date DATE;
describe `coffee shop sales`;
SET SQL_SAFE_UPDATES=0;
-- CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
update `coffee shop sales`
set transaction_time = str_to_date(transaction_time, '%H:%i:%s')
where transaction_time is not NULL and transaction_time != '';
set sql_safe_updates=1;
-- ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
alter table `coffee shop sales`
MODIFY COLUMN transaction_time TIME;
-- CHANGE COLUMN NAME `ï»¿transaction_id` to transaction_id
ALTER TABLE `coffee shop sales`
change column transaction_id transaction_id INT;
-- TOTAL SALES
SELECT SUM(unit_price * transaction_qty) AS Total_Sales FROM `coffee shop sales`
where MONTH(transaction_date)=5 ;-- MAY month
SELECT round(SUM(unit_price * transaction_qty),1) AS Total_Sales FROM `coffee shop sales`
where MONTH(transaction_date)=3; -- march

-- selected month /current month - may -5
-- previous month april 4
-- TOTAL SALES KPI - M0nth On Month DIFFERENCE AND Month On Month GROWTH
SELECT 
    MONTH(transaction_date) AS month, -- number of months
    ROUND(SUM(unit_price * transaction_qty)) AS Total_sales, -- Total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- month sales diff
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- divided by previous month sales 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- convert to percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
-- TOTAL ORDERS
SELECT count(transaction_id) As Total_oders FROM `coffee shop sales`
where MONTH(transaction_date)=3; 
-- TOTAL ORDERS KPI - Month On Month DIFFERENCE AND Month On Month GROWTH
SELECT 
    MONTH(transaction_date) AS Month,
    ROUND(COUNT(transaction_id)) AS Total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    -- TOTAL QUANTITY SOLD
    SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM `coffee shop sales` 
WHERE MONTH(transaction_date) = 5; -- for month of (CM-May)
-- TOTAL QUANTITY SOLD KPI - Month On Month DIFFERENCE AND Month On Month GROWTH

SELECT 
    MONTH(transaction_date) AS Month,
    ROUND(SUM(transaction_qty)) AS Total_Quantity_Sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS Total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS Total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS Total_Quantity_Sold
FROM 
    `coffee shop sales`
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    -- SALES TREND OVER PERIOD
    SELECT AVG(total_sales) AS Average_Sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS Total_sales
    FROM 
        `coffee shop sales`
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;
-- DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS Day_Of_Month,
    ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    Day_Of_Month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS Sales_Status,
    Total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS Day_Of_Month,
        SUM(unit_price * transaction_qty) AS Total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_Sales
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS Sales_Data
ORDER BY 
    Day_Of_Month;
    -- SALES BY WEEKDAY / WEEKEND:
    SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS Total_sales
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;
-- SALES BY STORE LOCATION
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM `coffee shop sales`
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC;


-- SALES BY PRODUCT CATEGORY

SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `coffee shop sales`
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;
-- SALES BY PRODUCTS (TOP 10)
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `coffee shop sales`
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;
-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM
    `coffee shop sales`
WHERE
    DAYOFWEEK(transaction_date) = 3
        AND HOUR(transaction_time) = 8
        AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
    -- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
    SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
