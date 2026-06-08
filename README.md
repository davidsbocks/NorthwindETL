# NorthwindETL
SSIS ETL pipeline from Northwind OLTP to Northwind Data Warehouse star schema
# Northwind ETL Pipeline (SSIS)

## Overview
A full ETL pipeline built with SQL Server Integration Services (SSIS) 
that extracts data from the Northwind OLTP database and loads it into 
a Northwind Data Warehouse using a star schema design.

## Tech Stack
- SQL Server 2025 (Developer Edition)
- SSIS (SQL Server Integration Services)
- Visual Studio 2022
- SSMS 19+
- T-SQL

## Architecture
### Source: Northwind OLTP
- 8 tables: Categories, Suppliers, Customers, Employees, 
  Shippers, Products, Orders, OrderDetails

### Destination: NorthwindDW (Star Schema)
- 4 Dimension tables: DimCustomer, DimEmployee, DimShipper, DimProduct
- 1 Fact table: FactSales
- 1 Date dimension: DimDate (pre-populated 2024-2026)

## ETL Flow
1. Load DimCustomer — maps Customers to DimCustomer
2. Load DimEmployee — concatenates FirstName + LastName into FullName
3. Load DimShipper — maps Shippers to DimShipper
4. Load DimProduct — joins Products + Categories + Suppliers
5. Load FactSales — joins Orders + OrderDetails + all dimension keys

## Row Counts (after execution)
| Table | Rows |
|-------|------|
| DimCustomer | 10 |
| DimEmployee | 5 |
| DimShipper | 3 |
| DimProduct | 15 |
| FactSales | 30 |

## How to Run
1. Restore Northwind and NorthwindDW databases from the SQL scripts in /sql
2. Open NorthwindETL.sln in Visual Studio 2022
## Screenshot
![ETL Package Execution](screenshots/package_execution.png)
4. Update connection managers to point to your SQL Server instance
5. Run Package.dtsx or deploy to SSISDB
