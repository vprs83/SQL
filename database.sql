CREATE TABLE customers(
    CustomerID      NUMBER          NOT NULL,
    CustomerName    VARCHAR2(20)    NOT NULL,
    ContactName     VARCHAR2(20),
    Address         VARCHAR2(20),
    City            VARCHAR2(20),
    PostalCode      VARCHAR2(20),
    Country         VARCHAR2(20),
    
    PRIMARY KEY(CustomerID)
);

/* Change column size */
ALTER TABLE customers MODIFY (CustomerName  VARCHAR2(50));
ALTER TABLE customers MODIFY (ContactName   VARCHAR2(50));
ALTER TABLE customers MODIFY (Address       VARCHAR2(50));

CREATE TABLE employees(
    EmployeeID      NUMBER          NOT NULL,
    FirstName       VARCHAR2(20)    NOT NULL,
    LastName        VARCHAR2(20)    NOT NULL,
    BirthDate       DATE            NOT NULL,
    --Photo          BLOB,
    --Notes          CLOB,
    
    PRIMARY KEY(EmployeeID)
);

CREATE TABLE shippers(
    ShipperID       NUMBER          NOT NULL,
    ShipperName     VARCHAR2(20)    NOT NULL,
    Phone           NUMBER          NOT NULL,
    
    PRIMARY KEY(ShipperID)
);

ALTER TABLE shippers MODIFY (Phone          VARCHAR2(20));
ALTER TABLE shippers MODIFY (ShipperName    VARCHAR2(50));

CREATE TABLE orders(
    OrderID     NUMBER  NOT NULL,
    CustomerID  NUMBER,
    EmployeeID  NUMBER  NOT NULL,
    ShipperID   NUMBER  NOT NULL,
    OrderDate   DATE    NOT NULL,
    
    PRIMARY KEY(OrderID),
    
    FOREIGN KEY(CustomerID)
        REFERENCES customers(CustomerID)
        ON DELETE SET NULL,
        
    FOREIGN KEY(EmployeeID)
        REFERENCES employees(EmployeeID),
        
    FOREIGN KEY(ShipperID)
        REFERENCES shippers(ShipperID)
);

CREATE TABLE orderDetails(
    OrderDetailID   NUMBER  NOT NULL,
    OrderID         NUMBER  NOT NULL,
    ProductID       NUMBER  NOT NULL,
    Quantity        NUMBER  NOT NULL,
    
    PRIMARY KEY(OrderDetailID),
    
    FOREIGN KEY(OrderID)
        REFERENCES orders(OrderID),
    
    FOREIGN KEY(ProductID)
        REFERENCES products(ProductID)
);

------------------------------------------------------------------- +
CREATE TABLE products(                      
    ProductID   NUMBER          NOT NULL,
    ProductName VARCHAR2(20)    NOT NULL,
    SupplierID  NUMBER          NOT NULL,
    CategoryID  NUMBER          NOT NULL,
    Unit        VARCHAR2(20),
    Price       NUMBER          NOT NULL,    
    --best_before_date    DATE,
    --stock               NUMBER, 
    --product_description VARCHAR2(1000), -- CLOB
    
    PRIMARY KEY(ProductID),
    
    FOREIGN KEY(SupplierID)
        REFERENCES suppliers(SupplierID),
        
    FOREIGN KEY(CategoryID)
        REFERENCES categories(CategoryID)
);

ALTER TABLE products MODIFY (ProductName  VARCHAR2(50));

CREATE TABLE suppliers(
    SupplierID      NUMBER          NOT NULL,
    SupplierName    VARCHAR2(20)    NOT NULL,
    ContactName     VARCHAR2(20),
    Address         VARCHAR2(20),
    City            VARCHAR2(20),
    PostalCode      VARCHAR2(20),
    Country         VARCHAR2(20),
    Phone           NUMBER          NOT NULL,
    
    PRIMARY KEY(SupplierID)    
);

ALTER TABLE suppliers MODIFY (Phone         VARCHAR2(20));
ALTER TABLE suppliers MODIFY (SupplierName  VARCHAR2(50));
ALTER TABLE suppliers MODIFY (ContactName   VARCHAR2(50));
ALTER TABLE suppliers MODIFY (Address       VARCHAR2(50));

CREATE TABLE categories(
    CategoryID      NUMBER          NOT NULL,
    CategoryName    VARCHAR2(20)    NOT NULL,
    Description     VARCHAR2(1000), -- CLOB
    
    PRIMARY KEY(CategoryID)
);

        
DROP TABLE customers;
DROP TABLE categories;
DROP TABLE employees;
DROP TABLE orderDetails;
DROP TABLE orders;
DROP TABLE products;
DROP TABLE shipper;
DROP TABLE suppliers;


-------------------------- DB update --------------------------  
-- create tables STORES, TARGETS
CREATE TABLE stores(
    StoreID     NUMBER          NOT NULL,
    Address     VARCHAR2(20),
    City        VARCHAR2(20),
    PostalCode  VARCHAR2(20),
    Country     VARCHAR2(20),
    Phone       NUMBER,
    
    PRIMARY KEY(StoreID)
);

CREATE TABLE targets(
    TargetID    NUMBER      NOT NULL,
    StoreID     NUMBER      NOT NULL,
    Year        VARCHAR2(4) NOT NULL,
    Month       NUMBER      NOT NULL,
    TargetSum   NUMBER,
    
    PRIMARY KEY(TargetID),
    
    FOREIGN KEY(StoreID)
        REFERENCES stores(StoreID)
);

-- update table ORDERS
ALTER TABLE orders ADD StoreID NUMBER; --NOT NULL;
ALTER TABLE orders ADD FOREIGN KEY (StoreID) REFERENCES stores(StoreID);

SELECT * FROM orders;        

-- 1.
INSERT INTO stores
VALUES(1, 'First street 36', 'Los-Angeles', '15023', 'USA', 123456789);

SELECT * FROM stores; 
-- 2. now constraint NOT NULL can be added to attribute StoreID
ALTER TABLE orders
MODIFY StoreID NOT NULL;    -- ALTER COLUMN StoreID NOT NULL for SQL Server

-- 3.
UPDATE orders
SET StoreID = 1
WHERE StoreID IS NULL;

INSERT INTO targets VALUES(1, 1, '1996', 7, 36000);
INSERT INTO targets VALUES(2, 1, '1996', 8, 35000);
INSERT INTO targets VALUES(3, 1, '1996', 9, 36000);
INSERT INTO targets VALUES(4, 1, '1996', 10, 45000);
INSERT INTO targets VALUES(5, 1, '1996', 11, 58000);
INSERT INTO targets VALUES(6, 1, '1996', 12, 65000);
INSERT INTO targets VALUES(7, 1, '1997', 1, 90000);
INSERT INTO targets VALUES(8, 1, '1997', 2, 60000);
INSERT INTO targets VALUES(9, 1, '1997', 3, 55000);
INSERT INTO targets VALUES(10, 1, '1997', 4, 50000);
INSERT INTO targets VALUES(11, 1, '1997', 5, 55000);
INSERT INTO targets VALUES(12, 1, '1997', 6, 40000);
INSERT INTO targets VALUES(13, 1, '1997', 7, 55000);
INSERT INTO targets VALUES(14, 1, '1997', 8, 45000);
INSERT INTO targets VALUES(15, 1, '1997', 9, 55000);
INSERT INTO targets VALUES(16, 1, '1997', 10, 65000);
INSERT INTO targets VALUES(17, 1, '1997', 11, 50000);
INSERT INTO targets VALUES(18, 1, '1997', 12, 70000); 
INSERT INTO targets VALUES(19, 1, '1998', 1, 12000);
INSERT INTO targets VALUES(20, 1, '1998', 2, 12000);
INSERT INTO targets VALUES(21, 1, '1998', 3, 10000);
INSERT INTO targets VALUES(22, 1, '1998', 4, 11000);
INSERT INTO targets VALUES(23, 1, '1998', 5, 15000);

UPDATE targets SET TargetSum = 120000 WHERE TargetID = 19;
UPDATE targets SET TargetSum = 120000 WHERE TargetID = 20;
UPDATE targets SET TargetSum = 100000 WHERE TargetID = 21;
UPDATE targets SET TargetSum = 110000 WHERE TargetID = 22;

SELECT * FROM targets; 
