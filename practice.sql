SET SERVEROUTPUT ON;

/*
    Some SQL-queries for the database provided by https://www.w3schools.com/
*/


/*
    Display the names of customers and their order number
    if they ordered products worth exactly or more than 10,000
*/
SELECT cs.CustomerName MainCustomers, o.orderID, SUM(p.Price * od.Quantity) PurchaseSum
FROM Customers cs 
LEFT JOIN Orders o ON cs.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
LEFT JOIN Products p ON od.ProductID = p.ProductID
--WHERE o.OrderID IS NOT NULL

GROUP BY o.orderID
HAVING PurchaseSum >= 10000;

/*
    DESCRIPTION REQUIRED
*/
SELECT c.CategoryName Categories, ROUND(SUM(od.Quantity * p.Price), 2) TotalSalesAmount
FROM OrderDetails od
LEFT JOIN Products p ON od.ProductID = p.ProductID
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY Categories
ORDER BY TotalSalesAmount; 

/*
    Sales distributons by sales amounts 
    (from the most profitable category in descending order) 
    by product category
*/
SELECT c.CustomerName, COUNT(o.CustomerID) PurchasesMadeNTimes 
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerName
ORDER BY PurchasesMadeNTimes DESC , c.CustomerName;

/*
    Display the number of products in the database for each category
*/
SELECT c.CategoryName, COUNT(*) AmountOfProduct
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY p.CategoryID;

/*
     
*/
SELECT  EXTRACT(YEAR FROM o.OrderDate) year,
        EXTRACT(MONTH FROM o.OrderDate) month,
        o.OrderID,
        COUNT(*) PositionsPerOrder,
        SUM(od.Quantity * p.Price) OrderPrice
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY EXTRACT(YEAR FROM o.OrderDate),
         EXTRACT(MONTH FROM o.OrderDate),
         o.OrderID;

/*
     
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
