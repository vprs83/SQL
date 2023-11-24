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
     Query to sort orders by
        • years,
        • months
        • order number
        • amount of positions in the order
        • total price of the order
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
    Query to 
    • count the amount of orders per month
    • calculate the average order price
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
    • calculate the average number of orders per month by year
    • calculate the average order price
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
    • first and last name of the employee,
    • year and month of order execution,
    • order number (order id),
    • number of positions in the order
    • order price
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



