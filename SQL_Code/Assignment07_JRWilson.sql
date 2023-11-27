--*************************************************************************--
-- Title: Assignment07
-- Author: JRWilson
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2023-11-25,JRWilson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_JRWilson')
	 Begin 
	  Alter Database [Assignment07DB_JRWilson] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_JRWilson;
	 End
	Create Database Assignment07DB_JRWilson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_JRWilson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
SELECT * FROM dbo.vProducts;

SELECT 
    ProductName AS Product
    , UnitPrice As Price
    FROM dbo.vProducts;
GO

-- Use a function to format the price as US dollars.
SELECT
    ProductName As Product
    , FORMAT(UnitPrice, 'C', 'en-US') As Price
    FROM
        dbo.vProducts;
Go

-- Order the result by the product name.
SELECT
    ProductName As Product
    , FORMAT(UnitPrice, 'C', 'en-US') As Price
    FROM
        dbo.vProducts
    ORDER BY ProductName;
Go

-- <Put Your Code Here> --
SELECT
    ProductName As Product
    , FORMAT(UnitPrice, 'C', 'en-US') As Price
    FROM
        dbo.vProducts
    ORDER BY ProductName;
Go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
SELECT * FROM Categories;
SELECT * FROM Products;
GO

SELECT CategoryName AS Category
    , ProductName AS Product
    , UnitPrice as Price
    FROM
    vProducts AS cP
    JOIN vCategories as vC
    ON cP.CategoryID = vC.CategoryID
    ;
GO

-- Use a function to format the price as US dollars.
SELECT CategoryName AS Category
    , ProductName AS Product
    , FORMAT(UnitPrice, 'C', 'en-US') as Price
    FROM
    vProducts AS cP
    JOIN vCategories as vC
    ON cP.CategoryID = vC.CategoryID
    ;
GO

-- Order the result by the Category and Product.
SELECT CategoryName AS Category
    , ProductName AS Product
    , FORMAT(UnitPrice, 'C', 'en-US') as Price
    FROM
    vProducts AS cP
    JOIN vCategories as vC
    ON cP.CategoryID = vC.CategoryID
    ORDER BY CategoryName, ProductName
    ;
GO

-- <Put Your Code Here> --
SELECT CategoryName AS Category
    , ProductName AS Product
    , FORMAT(UnitPrice, 'C', 'en-US') as Price
    FROM
    vProducts AS cP
    JOIN vCategories as vC
    ON cP.CategoryID = vC.CategoryID
    ORDER BY CategoryName, ProductName
    ;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
SELECT * 
FROM
    vProducts as vP
    JOIN vInventories AS vI
    ON vp.ProductID = vI.ProductID
;
GO

SELECT ProductName AS Product
    , InventoryDate AS 'Month, YYYY'
    , Count
FROM
    vProducts as vP
    JOIN vInventories AS vI
    ON vp.ProductID = vI.ProductID
;
GO
-- Format the date like 'January, 2017'.
SELECT ProductName AS Product
   -- , InventoryDate
    , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY'
   -- , MONTH(InventoryDate) AS 'Month, YYYY'
    , Count
FROM
    vProducts as vP
    JOIN vInventories AS vI
    ON vp.ProductID = vI.ProductID
;
GO
-- Order the results by the Product and Date.
SELECT ProductName AS Product
   -- , InventoryDate
    , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY'
   -- , MONTH(InventoryDate) AS 'Month, YYYY'
    , Count
FROM
    vProducts as vP
    JOIN vInventories AS vI
    ON vp.ProductID = vI.ProductID
    ORDER BY vP.ProductName, vI.InventoryDate
;
GO

-- <Put Your Code Here> --
SELECT ProductName AS Product
   -- , InventoryDate
    , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY'
   -- , MONTH(InventoryDate) AS 'Month, YYYY'
    , Count
FROM
    vProducts as vP
    JOIN vInventories AS vI
    ON vp.ProductID = vI.ProductID
    ORDER BY vP.ProductName, vI.InventoryDate
;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

SELECT TOP 1000000
    ProductName AS Product
    , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY' 
    , Count AS 'Inventory Count'
    FROM vProducts AS vP 
        JOIN vInventories AS vI 
        ON vP.ProductID = vI.ProductID
        ORDER BY ProductName, InventoryDate
;
GO
-- <Put Your Code Here> --
CREATE VIEW 
    -- Drop view
    vProductInventories
    AS
    SELECT TOP 100000
        ProductName AS Product
        , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY' 
        , Count AS 'Inventory Count'
        FROM vProducts AS vP 
            JOIN vInventories AS vI 
            ON vP.ProductID = vI.ProductID
            ORDER BY ProductName, InventoryDate
;
GO
-- Check that it works: Select * From vProductInventories;

Select * FROM vProductInventories
;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

SELECT TOP 100000
    CategoryName AS Category
    -- , ProductName AS Product
    , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY' 
    -- , Count AS 'Inventory Count'
    , SUM(Count) As 'Total Inventory'
        FROM vProducts AS vP
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID 
        JOIN vInventories AS vI 
        ON vP.ProductID = vI.ProductID
        GROUP BY CategoryName, InventoryDate
        ORDER BY CategoryName, InventoryDate
;
GO

-- <Put Your Code Here> --
CREATE VIEW
    --DROP View
    vCategoryInventories
    AS
    SELECT TOP 100000
        CategoryName AS Category
        -- , ProductName AS Product
        , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY' 
        -- , Count AS 'Inventory Count'
        , SUM(Count) As 'Total Inventory'
            FROM vProducts AS vP
            JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID 
            JOIN vInventories AS vI 
            ON vP.ProductID = vI.ProductID
            GROUP BY CategoryName, InventoryDate
            ORDER BY CategoryName, InventoryDate
;
GO

-- Test the view and order with my updated understanding of the month function in the order by section. Remove the ordering from the view, and add it back into the select statement. 
CREATE VIEW
    --DROP View
    vCategoryInventoriesV2
    AS
    SELECT
        CategoryName AS Category
        -- , ProductName AS Product
        , DATENAME(mm, InventoryDate) + ', ' + DATENAME(yyyy, InventoryDate) AS 'Month, YYYY' 
        -- , Count AS 'Inventory Count'
        , SUM(Count) As 'Total Inventory'
            FROM vProducts AS vP
            JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID 
            JOIN vInventories AS vI 
            ON vP.ProductID = vI.ProductID
            GROUP BY CategoryName, InventoryDate
 ;
GO


-- Check that it works: Select * From vCategoryInventories;
SELECT * From vCategoryInventories
;
GO
-- Alternative function by nesting the oder by clause in the select statement.
SELECT * From vCategoryInventoriesV2
ORDER BY Category, MONTH([Month, YYYY])
;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
Select * FROM vProductInventories
;
GO

Select 
    Product
    , [Month, YYYY]
    , [Inventory Count]
    FROM vProductInventories
;
GO

-- Lag
Select 
    Product
    , [Month, YYYY]
    , [Inventory Count]
    , LAG([Inventory Count]) OVER (ORDER BY Product, MONTH([Month, YYYY])) AS 'Previous Month Count'
    FROM vProductInventories
    ORDER BY Product, MONTH([Month, YYYY])
;
GO
-- IsNULL
Select 
    Product
    , [Month, YYYY]
    , [Inventory Count]
    , IsNull(
            LAG([Inventory Count]) OVER (ORDER BY Product, MONTH([Month, YYYY])), 0
            ) AS 'Previous Month Count'
    FROM vProductInventories
    ORDER BY Product, MONTH([Month, YYYY])
;
GO

-- Create View
-- <Put Your Code Here> --
CREATE VIEW
    -- Drop View
    vProductInventoriesWithPreviouMonthCounts
    AS
    Select
        Product
        , [Month, YYYY]
        , [Inventory Count]
        , IsNull(
                LAG([Inventory Count]) OVER (ORDER BY Product, MONTH([Month, YYYY])), 0
                ) AS 'Previous Month Count'
    FROM vProductInventories
       -- ORDER BY Product, MONTH([Month, YYYY])
;
GO

-- Check that it works: 
Select * From vProductInventoriesWithPreviouMonthCounts
    ORDER BY Product, MONTH([Month, YYYY])
;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
Select 
    Product
    , [Month, YYYY]
    , [Inventory Count]
    , [Previous Month Count]
    , CASE 
        When [Inventory Count] > [Previous Month Count] then 1
        When [Inventory Count] = [Previous Month Count] then 0
        When [Inventory Count] < [Previous Month Count] then -1
     End AS KPI
From vProductInventoriesWithPreviouMonthCounts
ORDER BY Product, MONTH([Month, YYYY])
;
go


-- <Put Your Code Here> --
CREATE VIEW
    -- Drop View 
    vProductInventoriesWithPreviousMonthCountsWithKPIs
    AS
    Select 
        Product
        , [Month, YYYY]
        , [Inventory Count]
        , [Previous Month Count]
        , CASE 
            When [Inventory Count] > [Previous Month Count] then 1
            When [Inventory Count] = [Previous Month Count] then 0
            When [Inventory Count] < [Previous Month Count] then -1
        End AS KPI
    From vProductInventoriesWithPreviouMonthCounts
    -- ORDER BY Product, MONTH([Month, YYYY])
;
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
SELECT * From vProductInventoriesWithPreviousMonthCountsWithKPIs
    Order BY Product, MONTH([Month, YYYY])
;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
CREATE FUNCTION 
    -- Drop Function
    fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
RETURNS TABLE
AS
    RETURN(
    Select 
        Product
        , [Month, YYYY]
        , [Inventory Count]
        , [Previous Month Count]
        , KPI
    From vProductInventoriesWithPreviousMonthCountsWithKPIs
    WHERE KPI = @KPI
    --ORDER BY Product, MONTH([Month, YYYY])
    )
;
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
    ORDER BY Product, MONTH([Month, YYYY])
;
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
    ORDER BY Product, MONTH([Month, YYYY])
;
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
    ORDER BY Product, MONTH([Month, YYYY])
;
go

/***************************************************************************************/
