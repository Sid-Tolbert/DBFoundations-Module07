--*************************************************************************--
-- Title: Assignment07
-- Author: SidTolbert
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-03-10,SidTolbert,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_SidTolbert')
	 Begin 
	  Alter Database [Assignment07DB_SidTolbert] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_SidTolbert;
	 End
	Create Database Assignment07DB_SidTolbert;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_SidTolbert;

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
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

select
ProductName,
FORMAT(CONVERT(money, UnitPrice), 'C', 'en-US') as UnitPrice
from Assignment07DB_SidTolbert.dbo.vProducts as a
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

select
a.CategoryName,
b.ProductName,
FORMAT(CONVERT(money, b.UnitPrice), 'C', 'en-US') as UnitPrice
from Assignment07DB_SidTolbert.dbo.vCategories as a
join Assignment07DB_SidTolbert.dbo.vProducts as b
on a.CategoryID = b.CategoryID
order by CategoryName, ProductName
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

select
a.ProductName,
InventoryDate = DateName(MONTH, InventoryDate) + ', ' + DateName(Year, InventoryDate),
b.[Count] as InventoryCount
from Assignment07DB_SidTolbert.dbo.vProducts as a
join Assignment07DB_SidTolbert.dbo.vInventories as b
on a.ProductID = b.ProductID
order by a.ProductName, b.InventoryDate asc
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

create
view vProductInventories
as
select
a.ProductName,
b.InventoryDate as InventoryDate_b,
-- had to make a column as 'Raw' pull to order stuff
DateName(MONTH, b.InventoryDate) + ', ' + DateName(Year, b.InventoryDate) as InventoryDate,
b.[Count] as InventoryCount

from Assignment07DB_SidTolbert.dbo.vProducts as a
join Assignment07DB_SidTolbert.dbo.vInventories as b
on a.ProductID = b.ProductID
go
select
ProductName,
InventoryDate,
InventoryCount
from vProductInventories
order by ProductName, InventoryDate_b;
go

-- Check that it works: 
Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Category and Date.

create
view vCategoryInventories
as
select
a.CategoryName,
c.InventoryDate as InventoryDate_b,
-- had to make a column as 'Raw' pull to order stuff
DateName(MONTH, c.InventoryDate) + ', ' + DateName(Year, c.InventoryDate) as InventoryDate,
SUM([Count]) as InventoryCountByCategory

from Assignment07DB_SidTolbert.dbo.vCategories as a
join Assignment07DB_SidTolbert.dbo.vProducts as b
on a.CategoryID = b.CategoryID
join Assignment07DB_SidTolbert.dbo.vInventories as c
on b.ProductID = c.ProductID

group by a.CategoryName, c.InventoryDate
go

select
CategoryName,
InventoryDate,
InventoryCountByCategory
from vCategoryInventories

order by CategoryName, InventoryDate_b;
go

Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

create
view vProductInventoriesWithPreviousMonthCounts
as
select
ProductName,
InventoryDate,
InventoryDate_b,
InventoryCount,
IIF(month(InventoryDate_b) = 1, 0, Lag(InventoryCount) over(partition by ProductName order by year(InventoryDate_b), month(InventoryDate_b))) as PreviousMonthCount

from Assignment07DB_SidTolbert.dbo.vProductInventories

go
select
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount
from vProductInventoriesWithPreviousMonthCounts
order by ProductName, InventoryDate_b
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

create
view vProductInventoriesWithPreviousMonthCountsWithKPIs
as
select
ProductName,
InventoryDate,
InventoryDate_b,
InventoryCount,
IIF(month(InventoryDate_b) = 1, 0, Lag(InventoryCount) over(partition by ProductName order by year(InventoryDate_b), month(InventoryDate_b))) as PreviousMonthCount,
CountVsPreviousCountKPI = case
when InventoryCount > PreviousMonthCount then 1
when InventoryCount = PreviousMonthCount then 0
when InventoryCount < PreviousMonthCount then -1
End
from Assignment07DB_SidTolbert.dbo.vProductInventoriesWithPreviousMonthCounts

go
select
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount,
CountVsPreviousCountKPI

from vProductInventoriesWithPreviousMonthCountsWithKPIs
order by ProductName, InventoryDate_b
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

create function fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI INT)
returns table
AS
	return(
		select
			ProductName,
			InventoryDate,
			InventoryCount,
			PreviousMonthCount,
			CountVsPreviousCountKPI
		from vProductInventoriesWithPreviousMonthCountsWithKPIs
		where CountVsPreviousCountKPI = @CountVsPreviousCountKPI
			);
go

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/