--*************************************************************************--
-- Title: Assignment06
-- Author: Kayla Pham
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-16,Kayla Pham,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KaylaPham')
	 Begin 
	  Alter Database [Assignment06DB_KaylaPham] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KaylaPham;
	 End
	Create Database Assignment06DB_KaylaPham;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KaylaPham;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories
With Schemabinding
As
	Select 
		CategoryID
		, CategoryName
		From dbo.Categories;
Go

Create View vEmployees
With Schemabinding
As
	Select 
		EmployeeID
		, EmployeeFirstName
		, EmployeeLastName
		, ManagerID
		From dbo.Employees;
Go

Create View vInventories
With Schemabinding
As
	Select 
		InventoryID
		, InventoryDate
		, EmployeeID
		, ProductID
		, Count
		From dbo.Inventories;
Go

Create View vProducts
With Schemabinding
As
	Select 
		ProductID
		, ProductName
		, CategoryID
		, UnitPrice
		From dbo.Products;
Go

--To review the basic views
Select * From vCategories; 
Select * From vEmployees; 
Select * From vInventories; 
Select * From vProducts; 

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_KaylaPham;
Deny Select On dbo.Categories To Public;
Deny Select On dbo.Employees To Public;
Deny Select On dbo.Inventories To Public;
Deny Select On dbo.Products To Public;
Grant Select On v.Categories To Public;
Grant Select On v.Employees To Public;
Grant Select On v.Inventories To Public;
Grant Select On v.Products To Public;
Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

Create View vCategoryProductsByPrice
As
	Select Top 1000000000
		CategoryName
		, ProductName
		, UnitPrice
		From dbo.vProducts 
		Inner Join dbo.vCategories
			On dbo.vProducts.CategoryID = dbo.vCategories.CategoryID
Order By CategoryName, ProductName;
Go

Select * From vCategoryProductsByPrice; 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

Create View vProductsInventoryCountsByDate
As
	Select Top 1000000000
		ProductName
		, InventoryDate
		, Count 
		From dbo.vProducts 
		Inner Join dbo.vInventories
			On dbo.vProducts.ProductID = dbo.vInventories.ProductID
Order By ProductName, InventoryDate, Count;
Go

Select * From vProductsInventoryCountsByDate;


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

Create View vInventoryDatesByEmployee
As
	Select Top 1000000000
		InventoryDate 
		, [EmployeeName] = dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName
		From dbo.vInventories 
		Inner Join dbo.vEmployees
			On dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
Group By InventoryDate, dbo.vEmployees.EmployeeFirstName, dbo.vEmployees.EmployeeLastName
Order By InventoryDate;
Go

Select * From vInventoryDatesByEmployee;


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

Create View vProductsByInventoryDateAndCount
As
	Select Top 1000000000
		CategoryName
		, ProductName
		, InventoryDate
		, Count
		From dbo.vInventories 
		Inner Join dbo.vProducts
			On dbo.vInventories.ProductID = dbo.vProducts.ProductID
		Inner Join dbo.vCategories
			On dbo.vProducts.CategoryID = dbo.vCategories.CategoryID
Order By CategoryName, ProductName, InventoryDate, Count;
Go

Select * From vProductsByInventoryDateAndCount;


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

Create View vProductsByInventoryDateAndCountAndEmp
As
	Select Top 1000000000
		CategoryName
		, ProductName
		, InventoryDate
		, Count
		, [EmployeeName] = dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName
		From dbo.vInventories 
		Inner Join dbo.vProducts
			On dbo.vInventories.ProductID = dbo.vProducts.ProductID
		Inner Join dbo.vCategories
			On dbo.vProducts.CategoryID = dbo.vCategories.CategoryID
		Inner Join dbo.vEmployees
			On dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
Order By InventoryDate, CategoryName, ProductName, EmployeeName;
Go

Select * From vProductsByInventoryDateAndCountAndEmp;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

Create View vProductsByInventoryDateAndCountAndEmpForChaiAndChang
As
	Select Top 1000000000
		CategoryName
		, ProductName
		, InventoryDate
		, Count
		, [EmployeeName] = dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName
		From dbo.vInventories 
		Inner Join dbo.vProducts
			On dbo.vInventories.ProductID = dbo.vProducts.ProductID
		Inner Join dbo.vCategories
			On dbo.vProducts.CategoryID = dbo.vCategories.CategoryID
		Inner Join dbo.vEmployees
			On dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
		Where dbo.vInventories.ProductID In (Select dbo.vProducts.ProductID
						From dbo.vProducts
						Where dbo.vProducts.ProductName In ('Chai','Chang'))
Order By InventoryDate, CategoryName, ProductName;
Go

Select * From vProductsByInventoryDateAndCountAndEmpForChaiAndChang;


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

Create View vEmployeesByManager
As
	Select Top 1000000000
		[Manager] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName
		, [Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
		From dbo.vEmployees As Emp
		Inner Join dbo.vEmployees Mgr
			On Emp.ManagerID = Mgr.EmployeeID
Order By Manager;
Go

Select * From vEmployeesByManager;


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

Create View vCategoriesEmployeesInventoriesProducts
As
	Select Top 1000000000
		b.CategoryID
		, CategoryName
		, c.ProductID
		, ProductName
		, UnitPrice
		, InventoryID
		, InventoryDate
		, Count
		, c.EmployeeID
		, [Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
		, [Manager] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName
	From dbo.vCategories as a
	Join dbo.vProducts as b
		On a.CategoryID = b.CategoryID
	Join dbo.vInventories as c
		On b.ProductID = c.ProductID
	Join dbo.vEmployees as Emp
		On c.EmployeeID = Emp.EmployeeID
	Join dbo.vEmployees as Mgr
		On Emp.ManagerID = Mgr.EmployeeID
Go

Select * From vCategoriesEmployeesInventoriesProducts;


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryProductsByPrice]
Select * From [dbo].[vProductsInventoryCountsByDate]
Select * From [dbo].[vInventoryDatesByEmployee]
Select * From [dbo].[vProductsByInventoryDateAndCount]
Select * From [dbo].[vProductsByInventoryDateAndCountAndEmp]
Select * From [dbo].[vProductsByInventoryDateAndCountAndEmpForChaiAndChang]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vCategoriesEmployeesInventoriesProducts]
/***************************************************************************************/