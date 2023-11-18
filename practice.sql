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
    Sales distributons by sales amounts 
    (from the most profitable category in descending order) 
    by product category
*/
SELECT c.CategoryName Categories, ROUND(SUM(od.Quantity * p.Price), 2) TotalSalesAmount
FROM OrderDetails od
LEFT JOIN Products p ON od.ProductID = p.ProductID
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY Categories
ORDER BY TotalSalesAmount; 
