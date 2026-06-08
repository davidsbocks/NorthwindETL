-- =============================================
-- NORTHWIND DATA WAREHOUSE (STAR SCHEMA)
-- Author: David
-- Description: Star schema data warehouse
--              destination for Northwind ETL
-- Tables: DimDate, DimCustomer, DimEmployee,
--         DimShipper, DimProduct, FactSales
-- =============================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NorthwindDW')
BEGIN
    ALTER DATABASE NorthwindDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NorthwindDW;
END
GO

CREATE DATABASE NorthwindDW;
GO

USE NorthwindDW;
GO

-- =============================================
-- DIMENSION: DATE
-- Pre-populated with dates 2024-2026
-- DateKey format: YYYYMMDD (e.g. 20240115)
-- =============================================
CREATE TABLE DimDate (
    DateKey     INT PRIMARY KEY,
    FullDate    DATE NOT NULL,
    DayOfWeek   TINYINT,
    DayName     NVARCHAR(10),
    Month       TINYINT,
    MonthName   NVARCHAR(10),
    Quarter     TINYINT,
    Year        SMALLINT
);
GO

-- =============================================
-- DIMENSION: CUSTOMER
-- SCD Type 2 ready with EffectiveDate/IsCurrent
-- =============================================
CREATE TABLE DimCustomer (
    CustomerKey   INT PRIMARY KEY IDENTITY(1,1),
    CustomerID    NCHAR(5),
    CompanyName   NVARCHAR(40),
    ContactName   NVARCHAR(30),
    City          NVARCHAR(15),
    Country       NVARCHAR(15),
    EffectiveDate DATE DEFAULT GETDATE(),
    IsCurrent     BIT DEFAULT 1
);
GO

-- =============================================
-- DIMENSION: PRODUCT
-- SCD Type 2 ready with EffectiveDate/IsCurrent
-- Includes denormalized CategoryName/SupplierName
-- =============================================
CREATE TABLE DimProduct (
    ProductKey    INT PRIMARY KEY IDENTITY(1,1),
    ProductID     INT,
    ProductName   NVARCHAR(40),
    CategoryName  NVARCHAR(15),
    SupplierName  NVARCHAR(40),
    UnitPrice     MONEY,
    Discontinued  BIT,
    EffectiveDate DATE DEFAULT GETDATE(),
    IsCurrent     BIT DEFAULT 1
);
GO

-- =============================================
-- DIMENSION: EMPLOYEE
-- FullName derived from FirstName + LastName
-- in SSIS Derived Column transformation
-- =============================================
CREATE TABLE DimEmployee (
    EmployeeKey INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID  INT,
    FullName    NVARCHAR(31),
    Title       NVARCHAR(30),
    Country     NVARCHAR(15)
);
GO

-- =============================================
-- DIMENSION: SHIPPER
-- =============================================
CREATE TABLE DimShipper (
    ShipperKey  INT PRIMARY KEY IDENTITY(1,1),
    ShipperID   INT,
    CompanyName NVARCHAR(40),
    Phone       NVARCHAR(24)
);
GO

-- =============================================
-- FACT: SALES
-- Grain: one row per order line item
-- SalesAmount is a computed persisted column
-- Foreign keys reference all 5 dimensions
-- =============================================
CREATE TABLE FactSales (
    SalesKey     INT PRIMARY KEY IDENTITY(1,1),
    OrderID      INT,
    OrderDateKey INT REFERENCES DimDate(DateKey),
    CustomerKey  INT REFERENCES DimCustomer(CustomerKey),
    ProductKey   INT REFERENCES DimProduct(ProductKey),
    EmployeeKey  INT REFERENCES DimEmployee(EmployeeKey),
    ShipperKey   INT REFERENCES DimShipper(ShipperKey),
    UnitPrice    MONEY,
    Quantity     SMALLINT,
    Discount     REAL,
    SalesAmount  AS (UnitPrice * Quantity * (1 - Discount)) PERSISTED,
    Freight      MONEY,
    ShipCountry  NVARCHAR(15)
);
GO

-- =============================================
-- POPULATE DimDate (2024-01-01 to 2026-12-31)
-- Uses recursive CTE to generate date spine
-- DateKey format: YYYYMMDD integer
-- =============================================
WITH Dates AS (
    SELECT CAST('2024-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM Dates
    WHERE d < '2026-12-31'
)
INSERT INTO DimDate (
    DateKey,
    FullDate,
    DayOfWeek,
    DayName,
    Month,
    MonthName,
    Quarter,
    Year
)
SELECT
    CONVERT(INT, CONVERT(NVARCHAR, d, 112)),
    d,
    DATEPART(WEEKDAY, d),
