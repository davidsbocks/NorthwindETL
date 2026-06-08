-- =============================================
-- NORTHWIND OLTP SOURCE DATABASE
-- Author: David
-- Description: Legacy Northwind transactional
--              database used as ETL source
-- =============================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Northwind')
BEGIN
    ALTER DATABASE Northwind SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Northwind;
END
GO

CREATE DATABASE Northwind;
GO
USE Northwind;
GO

CREATE TABLE Categories (
    CategoryID   INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(15) NOT NULL,
    Description  NVARCHAR(200)
);
CREATE TABLE Suppliers (
    SupplierID  INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    Country     NVARCHAR(15),
    Phone       NVARCHAR(24)
);
CREATE TABLE Customers (
    CustomerID  NCHAR(5) PRIMARY KEY,
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    City        NVARCHAR(15),
    Country     NVARCHAR(15)
);
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    LastName   NVARCHAR(20) NOT NULL,
    FirstName  NVARCHAR(10) NOT NULL,
    Title      NVARCHAR(30),
    HireDate   DATETIME,
    Country    NVARCHAR(15)
);
CREATE TABLE Shippers (
    ShipperID   INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    Phone       NVARCHAR(24)
);
CREATE TABLE Products (
    ProductID    INT PRIMARY KEY IDENTITY(1,1),
    ProductName  NVARCHAR(40) NOT NULL,
    SupplierID   INT REFERENCES