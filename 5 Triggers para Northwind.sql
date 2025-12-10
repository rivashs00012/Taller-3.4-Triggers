USE Northwind;
GO

-- Categories
INSERT INTO Categories (CategoryName, Description)
VALUES
('Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
('Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings'),
('Confections', 'Desserts, candies, and sweet breads'),
('Dairy Products', 'Cheeses'),
('Grains/Cereals', 'Breads, crackers, pasta, and cereal'),
('Meat/Poultry', 'Prepared meats'),
('Produce', 'Dried fruit and bean curd'),
('Seafood', 'Seaweed and fish');

INSERT INTO Products 
(ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, 
 UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES
('Chai', 1, 1, '10 cajas', 18.00, 50, 0, 10, 0),
('Galletas de Chocolate', 1, 1, '20 paquetes', 12.50, 25, 0, 5, 0),
('Pasta Italiana', 1, 1, '5 bolsas', 9.80, 40, 0, 8, 0);

INSERT INTO Products (ProductName, UnitPrice, UnitsInStock)
VALUES
('Laptop Lenovo', 2500.00, 10),
('Mouse Logitech', 80.00, 50),
('Teclado Mecánico', 150.00, 30),
('Monitor Samsung', 900.00, 20),
('Disco SSD 1TB', 350.00, 40);

INSERT INTO Customers (CustomerID, CompanyName, ContactName, Phone)
VALUES
('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', '123456'),
('BOLID', 'Bolido Express', 'Carlos Luna', '987654'),
('CHOPS', 'Chop Shop', 'Linda Park', '555777'),
('DRACD', 'Draco Delivery', 'Robert Miles', '555888'),
('EASTC', 'Eastern Traders', 'Ana Souza', '444999');
INSERT INTO Employees (LastName, FirstName, Title)
VALUES
('Davolio', 'Nancy', 'Sales Representative'),
('Fuller', 'Andrew', 'Vice President'),
('Leverling', 'Janet', 'Sales Representative'),
('Peacock', 'Margaret', 'Sales Representative');
SELECT * FROM Employees;

USE Northwind;
GO

IF OBJECT_ID('Log_InsertProducts') IS NULL
BEGIN
    CREATE TABLE Log_InsertProducts (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT,
        ProductName NVARCHAR(40),
        UnitPrice MONEY,
        InsertDate DATETIME
    );
END
GO

CREATE OR ALTER TRIGGER TRG_Products_Insert
ON Products
AFTER INSERT
AS
BEGIN
    INSERT INTO Log_InsertProducts (ProductID, ProductName, UnitPrice, InsertDate)
    SELECT ProductID, ProductName, UnitPrice, GETDATE()
    FROM inserted;

    PRINT 'Trigger ejecutado: Producto registrado en auditoría.';
END;
GO

INSERT INTO Products 
(ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, 
 UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES 
('Galletas Oreo', 1, 1, '15 cajas', 12.50, 25, 0, 0, 0);
GO

SELECT * FROM Products
SELECT * FROM Log_InsertProducts 

--------------------------------------------------------------------
IF OBJECT_ID('Log_UpdateProducts') IS NULL
BEGIN
    CREATE TABLE Log_UpdateProducts (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT,
        OldPrice MONEY,
        NewPrice MONEY,
        UpdateDate DATETIME
    );
END
GO

CREATE OR ALTER TRIGGER TRG_Products_Update
ON Products
AFTER UPDATE
AS
BEGIN
    INSERT INTO Log_UpdateProducts (ProductID, OldPrice, NewPrice, UpdateDate)
    SELECT d.ProductID, d.UnitPrice, i.UnitPrice, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ProductID = i.ProductID
    WHERE d.UnitPrice <> i.UnitPrice;

END;
GO

UPDATE Products
SET UnitPrice = UnitPrice + 1
WHERE ProductID = 31;   -- Cambia por un ID existente
GO
Select * from Products
SELECT * FROM Log_UpdateProducts 

--------------------------------------------------------------------------------
IF OBJECT_ID('Log_DeleteProducts') IS NULL
BEGIN
    CREATE TABLE Log_DeleteProducts (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT,
        ProductName NVARCHAR(40),
        DeleteDate DATETIME
    );
END
GO
CREATE OR ALTER TRIGGER TRG_Products_Delete
ON Products
AFTER DELETE
AS
BEGIN
    INSERT INTO Log_DeleteProducts (ProductID, ProductName, DeleteDate)
    SELECT ProductID, ProductName, GETDATE()
    FROM deleted;

    PRINT 'Trigger DELETE ejecutado.';
END;
GO
DELETE FROM Products
WHERE ProductID = 31;  -- Usa un ID existente
GO
select * from Products
SELECT * FROM Log_DeleteProducts ORDER BY LogID DESC;
--------------------------------------------------------------------------------
IF OBJECT_ID('Log_InsertOrders') IS NULL
BEGIN
    CREATE TABLE Log_InsertOrders (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT,
        CustomerID NCHAR(5),
        OrderDate DATETIME,
        InsertDate DATETIME
    );
END
GO
CREATE OR ALTER TRIGGER TRG_Orders_Insert
ON Orders
AFTER INSERT
AS
BEGIN
    INSERT INTO Log_InsertOrders (OrderID, CustomerID, OrderDate, InsertDate)
    SELECT OrderID, CustomerID, OrderDate, GETDATE()
    FROM inserted;

END;
GO

INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate)
VALUES ('ALFKI', 1, GETDATE(), GETDATE(), NULL);

SELECT * FROM Customers;
SELECT * FROM Log_InsertOrders ORDER BY LogID DESC;
--------------------------------------------------------------------------------


IF OBJECT_ID('Log_DeleteOrders') IS NULL
BEGIN
    CREATE TABLE Log_DeleteOrders (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT,
        CustomerID NCHAR(5),
        EmployeeID INT,
        OrderDate DATETIME,
        RequiredDate DATETIME,
        ShippedDate DATETIME,
        DeleteDate DATETIME
    );
END
GO
CREATE OR ALTER TRIGGER TRG_Orders_Delete
ON Orders
AFTER DELETE
AS
BEGIN
    INSERT INTO Log_DeleteOrders
    (
        OrderID,
        CustomerID,
        EmployeeID,
        OrderDate,
        RequiredDate,
        ShippedDate,
        DeleteDate
    )
    SELECT
        d.OrderID,
        d.CustomerID,
        d.EmployeeID,
        d.OrderDate,
        d.RequiredDate,
        d.ShippedDate,
        GETDATE()
    FROM deleted d;

    PRINT 'Trigger DELETE en Orders ejecutado.';
END;
GO
SELECT OrderID, CustomerID FROM Orders;
DELETE FROM Orders
WHERE OrderID = 31;
GO
SELECT * FROM Orders	
SELECT * FROM Log_DeleteOrders ORDER BY LogID DESC;
GO