--1)  Tạo  view  dbo.vw_Products  hiển  thị  danh  sách  các  sản  phẩm  từ  bảng 
--Production.Product và bảng  Production.ProductCostHistory. Thông tin  bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
use AdventureWorks2008R2
create view dbo.vw_Products
as 
select p.ProductID, Name, color, size, Style, pch.StandardCost, EndDate, StartDate
from Production.Product p join Production.ProductCostHistory pch
on p.ProductID=pch.ProductID

select * from vw_Products

--2)  Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008  và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.
create view dbo.List_Product_View
as
select p.ProductID, p.Name, count(sod.SalesOrderID) as CountOfOrdrID, soh.SubTotal
from Sales.SalesOrderDetail sod join Production.Product p
on sod.ProductID=p.ProductID join Sales.SalesOrderHeader soh
on sod.SalesOrderID=soh.SalesOrderID
where datepart(quarter, soh.OrderDate)=1 and year(soh.OrderDate)=2008 and soh.SubTotal>10000
group by p.ProductID, p.Name, soh.SubTotal

select * from dbo.List_Product_View

--3)  Tạo view dbo.vw_CustomerTotals  hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID,  YEAR(OrderDate)  AS  OrderYear,  MONTH(OrderDate)  AS 
--OrderMonth,  SUM(TotalDue).
create view dbo.vw_CustomerTotals
as
select soh.CustomerID, year(soh.OrderDate) as OrderYear, month(soh.OrderDate) as OrderMonth, sum(TotalDue) as TotalDue
from Sales.SalesOrderHeader soh
group by soh.CustomerID, soh.OrderDate

select * from dbo.vw_CustomerTotals