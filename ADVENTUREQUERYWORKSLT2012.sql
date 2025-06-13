
SELECT * FROM SalesLT.Address;

SELECT * FROM SalesLT.Customer;

SELECT * FROM SalesLT.SalesOrderDetail;

SELECT * FROM SalesLT.CustomerAddress;

SELECT * FROM SalesLT.SalesOrderHeader;

SELECT * FROM SalesLT.Product;

SELECT * FROM SalesLT.ProductCategory

SELECT * FROM SalesLT.ProductDescription;

SELECT * FROM SalesLT.ProductModel;

SELECT * FROM SalesLT.ProductModelProductDescription;



-- Question 1---PROVIDE THE TOP 10 CUSTOMERS(FULLNAME) BY REVENUE, THE COUNTRY
----------------THEY SHIPPED TO, THE CITIES AND THEIR REVENUE (ORDER*UNIT PRICE), THIS INSIGHT
----------------WILL HELP YOU UNDERSTAND WHERE YOUR TOP SPENDING CUSTOMERS ARE COMING FROM.
----------------YOU CAN MARKET BETTER, GET MORE CAPABLE CUSTOMER SERVICE REP, HAVE MORE STOCK AND
----------------BUILD PARTNERSHIP IN THESE COUNTRIES AND CITIES.

SELECT TOP 10
	CONCAT_WS(' ', c.FirstName,c.MiddleName,c.LastName) AS FullName,
	a.CountryRegion,
	a.City,
	ROUND(SUM(sod.OrderQty*sod.UnitPrice),2) AS Revenue
FROM 
	SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address a ON ca.AddressID = a.AddressID
JOIN SalesLT.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
GROUP BY
	c.FirstName,
	c.MiddleName,
	c.LastName,
	a.CountryRegion,
	a.City 
ORDER BY 
	Revenue DESC
;

-- QUESTION 2---- CREATE 4 DINSTINCT CUSTOMER SEGMENTS USING THE TOTAL REVENUE
-----------------(OREDER*UNITPRICE) BY CUSTOMER---LIST THE CUSTOMER DETAIL (ID, COMPANYNAME),
-----------------REVENUE AND THE SEGMENT THE CUSTOMER BELONGS TO
-----------------THIS ANALYSIS CAN BE USED TO CREATE A LOYALTY PROGRAM, MARKET CUSTOMER WITH
-----------------DISCOUNT OR LEAVE CUSTOMERS AS-IS.

WITH CustomerRevenue AS(
	SELECT 
		c.CustomerID,
		c.CompanyName,
	ROUND(SUM(sod.OrderQty * sod.UnitPrice),2) AS TotalRevenue
	FROM
		SalesLT.Customer c
	JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
	JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY 
		c.CustomerID,
		c.CompanyName
		)
	SELECT 
		CustomerID,
		CompanyName,
		TotalRevenue,
	CASE 
		WHEN TotalRevenue > 10000
	THEN 'Platinum'
		WHEN TotalRevenue BETWEEN 5000 AND 10000
	THEN 'Gold'
		WHEN TotalRevenue BETWEEN 1000 AND 5000
	THEN 'Silver'
		ELSE 'Bronze'
		END AS  CustomerSegment
	FROM 
		CustomerRevenue
	ORDER BY
		TotalRevenue DESC
	;

	-- Question 3---WHAT PRODUCTS WITH THEIR RESPECTIVE CATEGORIES DID OUR CUSTOMERS BUY
	----------------ON OUR LAST DAY OF BUSINESS?--- LIST THE CUSTOMERID, PRODUCTID,PRODUCT NAME, CATEGORY NAME
	----------------AND ORDER DATE. THIS INSIGHT WILL HELP UNDERSTAAND THE LATEST PRODUCTS AND CATEGORIES THAT 
	---------------YOUR CUSTOMERS BOUGHT FROM. THIS WILL HELP YOU DO NEAR-REAL-TIME MARKETING AND STOCK PILING
	----------------FOR THESE PRODUCTS.

	SELECT
		c.CustomerID,
		p.ProductID,
		p.Name AS ProductName,
		soh.OrderDate
	FROM 
		SalesLT.Customer c
	JOIN
		SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
	JOIN
		SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	JOIN 
		SalesLT.Product p ON sod.ProductID = p.ProductID
	WHERE
		soh.OrderDate = (SELECT
	MAX(OrderDate) FROM SalesLT.SalesOrderHeader);
	
	
SELECT soh.OrderDate,
COUNT(*) AS OrderCount
FROM SalesLT.SalesOrderHeader soh
GROUP BY soh.OrderDate ORDER BY soh.OrderDate DESC;

SELECT soh.OrderDate
FROM SalesLT.SalesOrderHeader soh
WHERE soh.OrderDate = (SELECT MAX(OrderDate) FROM SalesLT.SalesOrderHeader);

SELECT c.CustomerID, 
		soh.OrderDate
FROM SalesLT.Customer c
join SalesLT.SalesOrderHeader soh on c.CustomerID =soh.CustomerID
WHERE soh.OrderDate = (SELECT MAX(OrderDate) FROM SalesLT.SalesOrderHeader);


	SELECT
		c.CustomerID,
		p.ProductID,
		p.Name AS ProductName,
		soh.OrderDate
	FROM 
		SalesLT.Customer c
	JOIN
		SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
	JOIN
		SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	JOIN 
		SalesLT.Product p ON sod.ProductID = p.ProductID
	WHERE
		soh.OrderDate = (SELECT
	MAX(OrderDate) FROM SalesLT.SalesOrderHeader);
	
	SELECT
    c.CustomerID,
    soh.OrderDate,
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM 
    SalesLT.Customer c
JOIN
    SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN
    SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    SalesLT.Product p ON sod.ProductID = p.ProductID
JOIN
    SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID  -- key fix here!
WHERE
    soh.OrderDate = (
        SELECT MAX(OrderDate)
        FROM SalesLT.SalesOrderHeader
    );


	--Question 4---- CREATE A VIEW CALLED CUSTOMER SEGMENT THAT STORES THE DETAILS(ID,NAME, REVENUE)FOR CUSTOMERS AND THIER
	----------------SEGMENTS. I.E BUILD A VIEW FOR QUESTION 2

	
	CREATE VIEW CustomerSegment AS

	WITH CustomerRevenue AS (
	SELECT 
		c.CustomerID,
		c.CompanyName,
		SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue
	FROM 
		SalesLT.Customer c
	JOIN
		SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
	JOIN 
		SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY
		c.CustomerID,
		c.CompanyName
		)
	SELECT 
		CustomerID,
		CompanyName,
		TotalRevenue,
		CASE
			WHEN TotalRevenue >10000
		THEN 'Platinum'
			WHEN TotalRevenue BETWEEN 5000 AND 10000
		THEN 'Gold'
			WHEN TotalRevenue BETWEEN 1000 AND 5000
		THEN 'Silver'
		ELSE 'Bronze'
	END AS CustomerSegment
	FROM 
		CustomerRevenue;

	SELECT * FROM CustomerSegment;
	

	--Question 5------WHAT ARE THE TOP THREE SELLING PRODUCTS(INCLUDE PRODUCT NAME) 
	-------------------IN EACH CATEGORY(INCLUDE CATEGORY NAME)BY REVENUE. 
	-------------------THIS ANALYSIS WILL INFORM YOUR MARKETING, YOUR SUPPLY CHAIN, YOUR PARTNERSHIPS,
	-------------------POSITION OF PRODUCTS ON WEBSITES E.T.C

WITH ProductRevenue AS (
    SELECT
        pc.Name AS CategoryName,
        p.Name AS ProductName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue,
        ROW_NUMBER() OVER (
            PARTITION BY pc.Name 
            ORDER BY SUM(sod.OrderQty * sod.UnitPrice) DESC
        ) AS RankNum
    FROM 
        SalesLT.Product p
    JOIN 
        SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    JOIN 
        SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    GROUP BY 
        pc.Name, p.Name
)
SELECT
    CategoryName,
    ProductName,
    TotalRevenue
FROM 
    ProductRevenue
WHERE 
    RankNum <= 3
ORDER BY 
    CategoryName,
    TotalRevenue DESC;

	