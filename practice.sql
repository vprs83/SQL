SELECT cs.CustomerName MainCustomers, o.orderID, SUM(p.Price * od.Quantity) PurchaseSum
FROM Customers cs 
LEFT JOIN Orders o ON cs.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
LEFT JOIN Products p ON od.ProductID = p.ProductID
--WHERE o.OrderID IS NOT NULL

GROUP BY o.orderID
HAVING PurchaseSum >= 10000;
