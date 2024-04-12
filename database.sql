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

CREATE TABLE orders(
    OrderID     NUMBER  NOT NULL,
    CustomerID  NUMBER,
    EmployeeID  NUMBER  NOT NULL,
    ShipperID   NUMBER  NOT NULL,
    OrderDate   DATE    NOT NULL,
    
    PRIMARY KEY(OrderID),
    
    FOREIGN KEY(CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE SET NULL,
        
    FOREIGN KEY(EmployeeID)
        REFERENCES employees(EmployeeID),
        
    FOREIGN KEY(ShipperID)
        REFERENCES shippers(ShipperID)
)

CREATE TABLE orderDetails(
    OrderDetailID   NUMBER  NOT NULL,
    OrderID         NUMBER  NOT NULL,
    ProductID       NUMBER  NOT NULL,
    Quantity        NUMBER  NOT NULL,
    
    PRIMARY KEY(OrderDetailID),
    
    FOREIGN KEY(OrderID)
        REFERENCES order(order_id),
    
    FOREIGN KEY(ProductID)
        REFERENCES products(ProductID)
);

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
        REFERENCES category(CategoryID)
);

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

CREATE TABLE categories(
    CategoryID      NUMBER          NOT NULL,
    CategoryName    VARCHAR2(20)    NOT NULL,
    Description     VARCHAR2(1000), -- CLOB
    
    PRIMARY KEY(CategoryID)
);

CREATE TABLE shipper(
    ShipperID       NUMBER          NOT NULL,
    ShipperName     VARCHAR2(20)    NOT NULL,
    Phone           NUMBER          NOT NULL
);

CREATE TABLE employees(
    EmployeeID      NUMBER          NOT NULL,
    FirstName       VARCHAR2(20)    NOT NULL,
    LastName        VARCHAR2(20)    NOT NULL,
    BirthDate       DATE            NOT NULL --,
    --Photo          BLOB
    --Notes          CLOB
);
        
        
        
        
        
        
        
        
        
        
        