## OVERALL SALES PERFORMANCE 
 
#1 TOTAL SALES BT STORE TYPE

SELECT
    Store_Type,
    CONCAT('$', ROUND(SUM(Total_Cost) / 1000000, 3), ' M') AS Total_Sales
FROM
    retail_transaction_dataset
GROUP BY
    Store_Type
ORDER BY
    SUM(Total_Cost) DESC;


#2 TOTAL SALES BY CITIES

SELECT * FROM retail_transaction_dataset;

SELECT
    City,
    CONCAT('$', ROUND(SUM(Total_Cost) / 1000000, 3), ' M') AS Total_Sales
FROM
    retail_transaction_dataset
GROUP BY
    City
ORDER BY
    SUM(Total_Cost) DESC; 


## ANNUAL SALES TRENDS

#3 YEARLY SALES PERFORMANCE BY STORE TYPE

SELECT 
   YEAR(Transaction_date) AS Year,
    Store_Type, 
    CONCAT('$ ', FORMAT(SUM(Total_Cost) / 1000000, 3), ' M') AS Total_Sales
FROM 
    retail_transaction_dataset
GROUP BY 
    Year, Store_Type
Order by
Year, Total_Sales;


#4 TOTAL SEASONAL SALES TRENDS

SELECT 
    YEAR(Transaction_date) AS Year,
    Season,
   CONCAT('$ ',ROUND(SUM(Total_Cost) / 1000000, 3), ' M') AS Total_Sales
FROM 
    retail_transaction_dataset
GROUP BY 
    Year, Season
ORDER BY 
    Year, Season;


#5 TOTAL SALES BY PAYMENT METHOD OVER THE YEARS

SELECT
    YEAR(Transaction_Date) AS Transaction_Year,
    Payment_Method,
    CONCAT('$', FORMAT(SUM(Total_Cost) / 1000000, 2), 'M') AS Total_Sales
FROM retail_transaction_dataset
GROUP BY Transaction_Year, Payment_Method
ORDER BY Transaction_Year ASC;


#6 TOTAL SALES BY PROMOTIONS OVER THE YEARS

SELECT 
    YEAR(Transaction_Date) AS Transaction_Year,
    Promotion, 
    CONCAT('$ ', FORMAT(SUM(Total_Cost) / 1000000, 2), ' M') AS Total_Sales
FROM 
  retail_transaction_dataset
GROUP BY 
    Transaction_Year, Promotion
order by
Transaction_Year ASC;


## CUSTOMER INSIGHTS

#7 TOTAL SALES BY CUTOMER CATEGORY

SELECT
    Customer_Category,
    CONCAT('$ ', FORMAT(SUM(Total_Cost) / 1000000, 3), ' M') AS Total_Sales
FROM retail_transaction_dataset
GROUP BY Customer_Category
Order by Total_Sales ASC;


#8 TOP 10 CUSTOMERS BY LIFEIME SPENDINGS

SELECT 
    customer_name, 
    CONCAT('$ ', FORMAT(SUM(total_cost), 0), ' K') AS lifetime_value
FROM 
    retail_transaction_dataset
GROUP BY 
    customer_name
ORDER BY 
    SUM(total_cost) DESC
LIMIT 10;


#9 TOP 3 CUSTOMER BY TOTAL SPENDING ANNUALLY

SELECT 
    Transaction_Year,
    Customer_Name,
    CONCAT('$ ', Total_Spending) AS Total_Spending
FROM (
    SELECT 
        Customer_Name, 
        YEAR(Transaction_Date) AS Transaction_Year,
        SUM(Total_Cost) AS Total_Spending,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Transaction_Date) ORDER BY SUM(Total_Cost) DESC) as CRank
    FROM retail_transaction_dataset
    GROUP BY Customer_Name, YEAR(Transaction_Date)
) AS RankedSpending
WHERE CRank <= 3;



#10 TOP CUSTOMERS BY SEASONAL SPENDING ANNUALLY

WITH SeasonalRankedSpending AS (
    SELECT 
        Customer_Name,
        YEAR(Transaction_Date) AS Transaction_Year,
        CASE 
            WHEN MONTH(Transaction_Date) BETWEEN 3 AND 5 THEN 'Spring'
            WHEN MONTH(Transaction_Date) BETWEEN 6 AND 8 THEN 'Summer'
            WHEN MONTH(Transaction_Date) BETWEEN 9 AND 11 THEN 'Fall'
            ELSE 'Winter' 
        END AS Season,
        SUM(Total_Cost) AS Total_Spending,
        DENSE_RANK() OVER (PARTITION BY 
                            YEAR(Transaction_Date),
                            CASE 
                                WHEN MONTH(Transaction_Date) BETWEEN 3 AND 5 THEN 'Spring'
                                WHEN MONTH(Transaction_Date) BETWEEN 6 AND 8 THEN 'Summer'
                                WHEN MONTH(Transaction_Date) BETWEEN 9 AND 11 THEN 'Fall'
                                ELSE 'Winter' 
                            END 
                            ORDER BY SUM(Total_Cost) DESC) AS SRank
    FROM retail_transaction_dataset
    GROUP BY Customer_Name,
             YEAR(Transaction_Date),
             CASE 
                WHEN MONTH(Transaction_Date) BETWEEN 3 AND 5 THEN 'Spring'
                WHEN MONTH(Transaction_Date) BETWEEN 6 AND 8 THEN 'Summer'
                WHEN MONTH(Transaction_Date) BETWEEN 9 AND 11 THEN 'Fall'
                ELSE 'Winter' 
             END
)
SELECT 
    Transaction_Year,
    Season,
    Customer_Name,
    CONCAT('$', Total_Spending) AS Total_Spending
FROM SeasonalRankedSpending
WHERE SRank <= 1;


## GEOGRAPHIC SALES ANALYSIS


#11 TOP 3 TOTAL SALES BY CITIES YEARLY

WITH ranked_sales AS (
    SELECT
        YEAR(Transaction_date) AS Year,
        City,
        SUM(Total_Cost) AS Total_Sales
    FROM
        retail_transaction_dataset
    GROUP BY
        Year, City
),
ranked_sales_by_year AS (
    SELECT
        Year,
        City,
        Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_Sales DESC) AS sales_rank
    FROM
        ranked_sales
)
SELECT
    Year,
    City,
    CONCAT('$ ', FORMAT(Total_Sales / 1000000, 3), ' M') AS Total_Sales_Millions
FROM
    ranked_sales_by_year
WHERE
    sales_rank <= 3
ORDER BY
    Year, sales_rank;



#12 BOTTOM 3 SALES BY CITIES YEARLY

WITH ranked_sales AS (
    SELECT
        YEAR(Transaction_date) AS Year,
        City,
        SUM(Total_Cost) AS Total_Sales
    FROM
        retail_transaction_dataset
    GROUP BY
        Year, City
),
ranked_sales_by_year AS (
    SELECT
        Year,
        City,
        Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_Sales ASC) AS sales_rank
    FROM
        ranked_sales
)
SELECT
    Year,
    City,
    CONCAT('$ ', FORMAT(Total_Sales / 1000000, 3), ' M') AS Total_Sales_Millions
FROM
    ranked_sales_by_year
WHERE
    sales_rank <= 3
ORDER BY
    Year, sales_rank;


## PRODUCT PERFORMANCE ANALYSIS


#13 Total Product Sales

SELECT 
    Product,
    CONCAT('$ ', ROUND(SUM(Total_Sales) / 1000, 3), ' K') AS Total_Sales
FROM (
    SELECT 
        Product,
        SUM(Total_Sales) AS Total_Sales
    FROM product_sales
    GROUP BY Product, Year
) AS yearly_sales
GROUP BY Product
ORDER BY SUM(Total_Sales) DESC;



#14 TOP 10 PRODUCTS BY SALES

SELECT 
    Product,
    CONCAT('$ ', ROUND(SUM(Total_Sales)/1000, 3), ' K') AS Total_Sales
FROM (
    SELECT 
        Product,
        SUM(Total_Sales) AS Total_Sales,
        RANK() OVER(ORDER BY SUM(Total_Sales) DESC) AS Product_Rank
    FROM product_sales
    GROUP BY Product
) AS ranked_products
WHERE Product_Rank <= 10
GROUP BY Product, Product_Rank
ORDER BY Product_Rank
LIMIT 10;



#15 BOTTOM 10 PRODUCTS BY SALES

SELECT 
    Product,
    CONCAT('$ ', ROUND(SUM(Total_Sales)/1000, 3), ' K') AS Total_Sales
FROM (
    SELECT 
        Product,
        SUM(Total_Sales) AS Total_Sales,
        RANK() OVER(ORDER BY SUM(Total_Sales) ASC) AS Product_Rank
    FROM product_sales
    GROUP BY Product
) AS ranked_products
WHERE Product_Rank <= 10
GROUP BY Product, Product_Rank
ORDER BY Product_Rank
LIMIT 10;


#16 TOP 3 BEST SELLING PRODUCTS ANNUALLY

SELECT 
    Year,  Product,
    CONCAT('$ ', ROUND(SUM(Total_Sales)/1000, 3), ' K') AS Total_Sales
FROM (
    SELECT 
        Year,
        Product,
        SUM(Total_Sales) AS Total_Sales,
        ROW_NUMBER() OVER(PARTITION BY Year ORDER BY SUM(Total_Sales) DESC) AS Product_Rank
    FROM product_sales
    GROUP BY Year, Product
) AS ranked_products
WHERE Product_Rank <= 3
GROUP BY Year, Product;



#17 BOTTOM 3 SELLING PRODUCTS ANNUALLY

SELECT 
    Year,  Product,
    CONCAT('$ ', ROUND(SUM(Total_Sales)/1000, 3), ' K') AS Total_Sales
FROM (
    SELECT 
        Year,
        Product,
        SUM(Total_Sales) AS Total_Sales,
        ROW_NUMBER() OVER(PARTITION BY Year ORDER BY SUM(Total_Sales) ASC) AS Product_Rank
    FROM product_sales
    GROUP BY Year, Product
) AS ranked_products
WHERE Product_Rank <= 3
GROUP BY Year, Product;
