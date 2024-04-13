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
        
        
        
        
        
        
        