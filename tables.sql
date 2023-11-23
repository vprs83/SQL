CREATE TABLE Orders (
    OrderID NUMBER NOT NULL,
    OrderDate DATE NOT NULL
);

DROP TABLE Orders;

INSERT INTO Orders (OrderID, OrderDate) VALUES (10248, TO_DATE('1996-07-04', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10249, TO_DATE('1996-07-05', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10333, TO_DATE('1996-02-05', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10434, TO_DATE('1997-02-03', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10440, TO_DATE('1997-02-10', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10443, TO_DATE('1997-02-12', 'yyyy/mm/dd'));
INSERT INTO Orders (OrderID, OrderDate) VALUES (10555, TO_DATE('1997-03-05', 'yyyy/mm/dd'));

SELECT * FROM Orders ORDER BY OrderDate;

CREATE TABLE OrderDetails (
    OrderID NUMBER NOT NULL,
    Quantity NUMBER NOT NULL
);

DROP TABLE OrderDetails;

INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10248, 12);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10249, 10);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10333, 27);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10434, 90);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10440, 5);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10443, 120);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10555, 1);

SELECT * FROM OrderDetails;

/* 
    COMMIT & ROLLBACK usage example 
    An alternative session for clarity of processes can be called using SQL*Plus tool
*/
COMMIT;

DELETE FROM OrderDetails;
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10001, 999);
INSERT INTO OrderDetails (OrderID, Quantity) VALUES (10666, 999);

ROLLBACK;
/* ROLLBACK */

-- Number of contracts per year
SELECT EXTRACT(YEAR FROM OrderDate) year_indicator, COUNT(*) orders_per_year
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate);

-- Number of contracts per year; average, maximum and minimal quantity of goods per order per year
SELECT  EXTRACT(YEAR FROM o.OrderDate) year_indicator, 
        COUNT(*) orders_per_year, 
        ROUND(AVG(od.Quantity), 2) average_quantity,
        MAX(od.Quantity) maximum_quantity,
        MIN(od.Quantity) minimal_quantity
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID 
GROUP BY EXTRACT(YEAR FROM o.OrderDate);

SELECT TO_CHAR(OrderDate, 'Month') order_month FROM Orders;

/*
    Number of contracts per month and per year;
    Average quantity of goods per order per month
*/

SELECT  EXTRACT(YEAR FROM o.OrderDate) year_indicator,
        TO_CHAR(OrderDate, 'Month') order_month,
        COUNT(*) number_of_contracts,
        ROUND(AVG(od.Quantity), 2) average_quantity
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY    EXTRACT(YEAR FROM o.OrderDate), 
            TO_CHAR(OrderDate, 'Month');

/*
    UPDATE
    Number of contracts per month and per year;
    Average quantity of goods per order per month, where quantity > 11
*/
SELECT * FROM 
                (SELECT EXTRACT(YEAR FROM o.OrderDate) year_indicator,
                        TO_CHAR(OrderDate, 'Month') order_month,
                        COUNT(*) number_of_contracts,
                        ROUND(AVG(od.Quantity), 2) average_quantity
                FROM Orders o
                JOIN OrderDetails od ON o.OrderID = od.OrderID
                GROUP BY    EXTRACT(YEAR FROM o.OrderDate), 
                            TO_CHAR(OrderDate, 'Month'))
WHERE average_quantity>11;

