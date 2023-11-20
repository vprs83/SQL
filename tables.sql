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

-- Number of contracts per year
SELECT EXTRACT(YEAR FROM OrderDate) year_indicator, COUNT(EXTRACT(YEAR FROM OrderDate)) orders_per_year
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate);
