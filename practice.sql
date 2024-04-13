SET SERVEROUTPUT ON;

/*
    Some SQL-queries for the database provided by https://www.w3schools.com/
*/

/*
    Display suppliers (supplier id, supplier name, total number of products
    who have N or more products
*/
SELECT 	s.SupplierID,
		s.SupplierName,
        COUNT(s.SupplierID) AS "Total number of products"
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY 	s.SupplierID, 
			s.SupplierName
HAVING COUNT(s.SupplierID) >= 4; -- N=4

/*
    Display the names of customers and their order number
    if they ordered products worth exactly or more than 10,000
*/
SELECT  cs.CustomerName MainCustomers, 
        o.orderID, 
        SUM(p.Price * od.Quantity) --PurchaseSum
FROM Customers cs 
LEFT JOIN Orders o ON cs.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
LEFT JOIN Products p ON od.ProductID = p.ProductID
--WHERE o.OrderID IS NOT NULL

GROUP BY    cs.CustomerName,
            o.orderID
HAVING SUM(p.Price * od.Quantity) >= 10000
ORDER BY o.orderID;

/*
    Display the names of customers and the number of purchases they made.
    Sort the resulting list:
        1. by number of purchases, from most to least,
        2. by customer names in alphabetical order 
*/
SELECT  c.CustomerName, 
        COUNT(o.CustomerID) PurchasesMadeNTimes 
FROM    Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY    c.CustomerName
ORDER BY    PurchasesMadeNTimes DESC,
            c.CustomerName;

/*
    Display product categories by popularity (category name, total sales), 
    it is necessary to calculate sales of products
*/
SELECT  c.CategoryName, 
        ROUND(SUM(od.Quantity * p.Price), 2) TotalSales
FROM    OrderDetails od
LEFT JOIN Products p ON od.ProductID = p.ProductID
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY c.CategoryName;
--ORDER BY TotalSales;

/*
    Display the number of products in the database for each category
*/
SELECT  c.CategoryName, 
        COUNT(*) AmountOfProducts
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY    p.CategoryID,
            c.CategoryName
ORDER BY c.CategoryName;

/* 
    Display the number of products in the database for each category
    AND rounded total sales for each category
*/
    SELECT  c.CategoryName, 
            COUNT(DISTINCT p.ProductID) "Number of products",
            ROUND(SUM(od.Quantity * p.Price), 0) "Total sales"  -- ROUND(..., 2)
    FROM Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    JOIN OrderDetails od ON p.ProductId = od.ProductID
    GROUP BY c.CategoryName
    ORDER BY c.CategoryName;

/*
     Query to sort orders by
        � year,
        � month
        � order number
        � amount of positions of products in the order
        � product quantity (e.g. if 2 positions: 1 position = 5 items, 2 position = 10 items. Product quantity = 15 items)
        � total price of the order
*/
SELECT  '19' || EXTRACT(YEAR FROM o.OrderDate) year,
        EXTRACT(MONTH FROM o.OrderDate) month,
        o.OrderID,
        COUNT(*) "Number of positions in order",
        SUM(od.Quantity) "Product quantity",
        SUM(od.Quantity * p.Price) OrderPrice
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY EXTRACT(YEAR FROM o.OrderDate),
         EXTRACT(MONTH FROM o.OrderDate),
         o.OrderID
ORDER BY year,
         month,
         o.OrderID;

/*
    Query to 
    � count the amount of orders per month
    � calculate the average order price
*/
SELECT year, month,
       COUNT(*) NumberOfOrdersPerMonth,
       ROUND(AVG(PositionsPerOrder), 1) AvgPositionQuantityPerOrder,
       ROUND(AVG(OrderPrice), 2) AvgOrderPricePerMonth
FROM (SELECT  EXTRACT(YEAR FROM o.OrderDate) year,
            EXTRACT(MONTH FROM o.OrderDate) month,
            o.OrderID,
            COUNT(*) PositionsPerOrder,
            SUM(od.Quantity * p.Price) OrderPrice
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY EXTRACT(YEAR FROM o.OrderDate),
             EXTRACT(MONTH FROM o.OrderDate),
             o.OrderID) nq
GROUP BY year, month;

/*
    Query to
    � calculate the average number of orders per month by year
    � calculate the average order price
*/
SELECT  year,
        ROUND(AVG(NumberOfOrdersPerMonth), 1) AvgNumberOfOrdersPerYear,
        ROUND(AVG(AvgOrderPricePerMonth), 2) AvgOrderPricePerYear
FROM (SELECT year, month,
             COUNT(*) NumberOfOrdersPerMonth,
             ROUND(AVG(PositionsPerOrder), 1) AvgPositionQuantityPerOrder,
             ROUND(AVG(OrderPrice), 2) AvgOrderPricePerMonth
      FROM (SELECT  EXTRACT(YEAR FROM o.OrderDate) year,
                    EXTRACT(MONTH FROM o.OrderDate) month,
                    o.OrderID,
                    COUNT(*) PositionsPerOrder,
                    SUM(od.Quantity * p.Price) OrderPrice
            FROM Orders o
            JOIN OrderDetails od ON o.OrderID = od.OrderID
            JOIN Products p ON od.ProductID = p.ProductID
            GROUP BY EXTRACT(YEAR FROM o.OrderDate),
                     EXTRACT(MONTH FROM o.OrderDate),
                     o.OrderID
            ) nq
      GROUP BY year, month
    ) nq2
GROUP BY year;

/*
    Query for employee summary table:
    � first and last name of the employee,
    � year and month of order execution,
    � order number (order id),
    � number of positions in the order
    � order price
*/
SELECT  LastName, FirstName,
        EXTRACT(YEAR FROM o.OrderDate) year,
        EXTRACT(MONTH FROM o.OrderDate) month,
        o.OrderId,
        COUNT(*) PosInOrder, 
        SUM(od.Quantity * p.Price) OrderPrice
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY e.EmployeeID, 
         EXTRACT(YEAR FROM o.OrderDate),
         EXTRACT(MONTH FROM o.OrderDate),
         o.OrderId
ORDER BY o.OrderDate, o.OrderID;


--    Sales distributons by sales amounts 
--    (from the most profitable category in descending order) 
--    by product category



