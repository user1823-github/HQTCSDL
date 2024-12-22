-- I). La Mã: Having
use AdventureWorks2008R2

-- 1 Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
--SubTotal =SUM(OrderQty*UnitPrice).
select soh.SalesOrderID, Orderdate, sum(OrderQty*UnitPrice) as SubToTal 
	from Sales.SalesOrderHeader soh 
	join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
	where  SubToTal>70000
	group by soh.SalesOrderID, soh.Orderdate
	having month(Orderdate)=6 and year(Orderdate)=2008

select * from sales.s
select * from sales.SalesOrderHeader
select * from sales.SalesOrderDetail

-- 2 Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
select st.TerritoryID, 
	   count(c.CustomerID) as TotalCustomer, 
	   sum(sod.OrderQty * sod.UnitPrice) as SubTotal
	   from Sales.SalesTerritory st
	   join Sales.Customer c ON st.TerritoryID=c.TerritoryID
	   join Sales.SalesOrderHeader soh ON c.CustomerID=soh.CustomerID
	   join Sales.SalesOrderDetail sod ON soh.SalesOrderID=sod.SalesOrderID
	   where st.CountryRegionCode='US'
	   group by st.TerritoryID

select * from Sales.Customer
select * from Sales.SalesTerritory

-- 3 Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
select soh.SalesOrderID, sod.CarrierTrackingNumber, sum(sod.OrderQty * sod.OrderQty) as SubTotal
	   from Sales.SalesOrderHeader soh
	   join Sales.SalesOrderDetail sod ON soh.SalesOrderID=sod.SalesOrderID
	   group by soh.SalesOrderID, sod.CarrierTrackingNumber
	   having sod.CarrierTrackingNumber like '4BD%'

select * from Sales.SalesOrderHeader
select * from Sales.SalesOrderDetail

-- 4 Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
--trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
select p.ProductID, p.Name, avg(sod.OrderQty) as AverageOfQty
	   from Production.Product p
	   join Sales.SalesOrderDetail sod
	   on p.ProductID=sod.ProductID
	   where sod.UnitPrice<25
	   group by p.ProductID, p.Name
	   having avg(sod.OrderQty)>5

select * from Production.Product

-- 5 Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
--JobTitle, CountOfPerson=Count(*)
select e.JobTitle, count(*) as CountOfPerson
       from HumanResources.Employee e
	   group by e.JobTitle
	   having count(*)>20

select * from HumanResources.Employee

-- 6 Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
--[Purchasing].[PurchaseOrderDetail])
-- Khoá chính
go
select v.BusinessEntityID, v.Name, pod.ProductID, 
	   sum(pod.OrderQty) as SumOfQty,
	   poh.SubTotal
       from Purchasing.Vendor as v 
	   join Purchasing.ProductVendor as pv
	   ON v.BusinessEntityID=pv.BusinessEntityID
	   join Purchasing.PurchaseOrderDetail as pod 
	   ON pv.ProductID=pod.ProductID
	   join Purchasing.PurchaseOrderHeader as poh 
	   ON pod.PurchaseOrderID = poh.PurchaseOrderID
	   where v.Name like '%Bicycles' and poh.SubTotal>800.000
	   group by v.BusinessEntityID, v.Name, pod.ProductID, poh.SubTotal

select * from Purchasing.Vendor
select * from Purchasing.PurchaseOrderHeader
select * from Purchasing.PurchaseOrderDetail

-- 7 Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal
select p.ProductID, p.Name as Product_Name,
	   count(sod.SalesOrderID) as CountOfOrderID, soh.SubTotal
	   from Production.Product as p
	   join Sales.SalesOrderDetail as sod ON p.ProductID=sod.ProductID
	   join Sales.SalesOrderHeader as soh ON sod.SalesOrderID=soh.SalesOrderID
	   where soh.SubTotal>10000 and datepart(QUARTER, soh.OrderDate)=1 
	   and (soh.OrderDate)=2008
	   group by p.ProductID, p.Name, soh.SubTotal
	   having count(sod.SalesOrderID)>500
	   

select * from Production.Product
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader


-- 8 Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders)
select c.PersonID, p.FirstName+' '+p.LastName as FullName, 
	   count(soh.SalesOrderID) as CountOfOrders 
	   from Person.Person  as p
	   join Sales.Customer as c on c.PersonID=p.BusinessEntityID
	   join Sales.SalesOrderHeader as soh on c.CustomerID=soh.CustomerID
	   where year(soh.OrderDate) between 2007 and 2008
	   group by c.PersonID, p.FirstName, p.LastName
	   having count(soh.SalesOrderID)>25

select * from Person.Person
select * from Sales.Customer

-- 9 Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)
select p.ProductID, p.Name, sum(sod.OrderQty) as CountOfOrderQty, 
	   year(soh.OrderDate) as [Year]
	   from Production.Product as p
	   join Sales.SalesOrderDetail as sod ON p.ProductID=sod.ProductID
	   join Sales.SalesOrderHeader as soh ON sod.SalesOrderID=soh.SalesOrderID
	   where p.Name like 'Bike%' or p.Name like 'Sport%' 
	   group by p.ProductID, p.Name, year(soh.OrderDate)
	   having sum(sod.OrderQty)>500

select * from Production.Product
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

-- 10 Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory]
select d.DepartmentID, d.Name, avg(eph.Rate) as AvgOfRate
	   from HumanResources.Department as d
	   join HumanResources.EmployeeDepartmentHistory as edh
	   ON d.DepartmentID=edh.DepartmentID
	   join HumanResources.EmployeePayHistory as eph
	   ON edh.BusinessEntityID=eph.BusinessEntityID
	   group by d.DepartmentID, d.Name
	   having avg(eph.Rate) > 30

select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory
select * from HumanResources.EmployeePayHistory

-- II). La Mã: Subquery

-- 1 Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
-- trên 100 đơn đặt hàng trong tháng 7 năm 2008

-- Có thể thay 'IN' bằng '= ANY'
select p.ProductID, p.Name
	from Production.Product as p
	join Sales.SalesOrderDetail as sod ON p.ProductID=sod.ProductID
	join Sales.SalesOrderHeader as soh ON sod.SalesOrderID=soh.SalesOrderID
	where p.ProductID in
		(	select sod.ProductID
			from Sales.SalesOrderDetail as sod
			group by sod.ProductID
			having count(sod.SalesOrderID)>500
		)
	group by p.ProductID, p.Name

-- 2 Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
-- trong tháng 7/2008


SELECT p.ProductID, p.Name, COUNT(DISTINCT soh.SalesOrderID) as TotalOrders
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY p.ProductID, p.Name
HAVING p.ProductID IN 
(
    SELECT TOP 10 p.ProductID 
    FROM Production.Product AS p
    JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE month(soh.OrderDate)=7 and year(soh.OrderDate)=2008
	GROUP BY p.ProductID
    ORDER BY COUNT(DISTINCT soh.SalesOrderID) DESC
)

-- 3 Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--- CustomerID, Name, CountOfOrder

select soh.CustomerID, (p.FirstName + p.LastName) as FullName
	from Person.Person as p
	join Sales.SalesOrderHeader as soh ON p.BusinessEntityID=soh.CustomerID
	join Sales.SalesOrderDetail as sod ON sod.SalesOrderID=soh.SalesOrderID
	where soh.CustomerID IN (
		select top 5 soh.CustomerID
		from Person.Person as p
		join Sales.SalesOrderHeader as soh ON p.BusinessEntityID=soh.CustomerID
		join Sales.SalesOrderDetail as sod ON sod.SalesOrderID=soh.SalesOrderID
		where p.PersonType='IN'
		group by soh.CustomerID
		order by count(distinct sod.SalesOrderID) desc
	)
	group by soh.CustomerID, p.FirstName + p.LastName

-- 4 Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
-- tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
-- bảng Production.Product và Production.ProductModel)
select p.ProductID, pm.Name
	from Production.Product as p 
	join Production.ProductModel as pm 
	on p.ProductModelID=pm.ProductModelID
	where p.ProductModelID IN (
		select pm.ProductModelID from Production.ProductModel as pm 
		where name like 'Long-Sleeve Logo Jersey%'
	)
-- ...
select p.ProductID, pm.Name
	from Production.Product as p 
	join Production.ProductModel as pm 
	on p.ProductModelID=pm.ProductModelID
	where EXISTS (
		select p.ProductID, pm.Name 
		from Production.ProductModel as pm 
		join Production.Product as p 
		on p.ProductModelID=pm.ProductModelID
		where p.Name like 'Long-Sleeve Logo Jersey%'
	) and p.Name like 'Long-Sleeve Logo Jersey%'


select * from Production.Product as p 
select * from Production.ProductModel as pm 
	where name like 'Long-Sleeve Logo Jersey%'

-- 5 Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
-- đa cao hơn giá trung bình của tất cả các mô hình
select pm.ProductModelID, p.Name, max(p.ListPrice)
	from Production.Product as p
	join Production.ProductModel as pm on p.ProductModelID=pm.ProductModelID
	group by pm.ProductModelID, p.Name, p.ListPrice
	having max(p.ListPrice) >= ALL (
		select avg(p.ListPrice)
		from Production.Product as p
		join Production.ProductModel as pm on p.ProductModelID=pm.ProductModelID
		group by pm.ProductModelID
	)
go
select * from Production.Product as p 
select * from Production.ProductModel as pm 

-- 6 Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
-- đặt hàng > 5000 (dùng IN, EXISTS)
select p.ProductID, p.Name
	from Production.Product as p 
	join Sales.SalesOrderDetail as sod on p.ProductID=sod.ProductID
	where p.ProductID IN (
		select p.ProductID
		from Production.Product as p 
		join Sales.SalesOrderDetail as sod on p.ProductID=sod.ProductID
		group by  p.ProductID, p.Name
		having count(sod.SalesOrderID) > 5000
	)
	group by p.ProductID, p.Name
-- Sử dụng: EXISTS
select p.ProductID, p.Name
	from Production.Product as p 
	join Sales.SalesOrderDetail as sod on p.ProductID=sod.ProductID
	where EXISTS (
		select p.ProductID, p.Name
		from Production.Product as p 
		join Sales.SalesOrderDetail as sod on p.ProductID=sod.ProductID
		group by  p.ProductID, p.Name
		having count(sod.SalesOrderID) >5000
	)
	group by p.ProductID, p.Name
	having count(sod.SalesOrderID) >5000

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
-- nhất trong bảng Sales.SalesOrderDetail
select sod.ProductID, sod.UnitPrice
	from Sales.SalesOrderDetail as sod
	group by sod.ProductID, sod.UnitPrice
	having max(sod.UnitPrice) >= all (
		select max(sod.UnitPrice)
		from Sales.SalesOrderDetail as sod
	)

-- Cách 2:
select sod.ProductID, max(sod.UnitPrice)
	from Sales.SalesOrderDetail as sod
	group by sod.ProductID
	having max(sod.UnitPrice) = (
		select max(sod.UnitPrice)
		from Sales.SalesOrderDetail as sod
	)

select sod.ProductID, max(sod.UnitPrice)
	from Sales.SalesOrderDetail sod
	group by sod.ProductID
	having max(sod.UnitPrice) >= ALL (
		select sod.UnitPrice
		from Sales.SalesOrderDetail sod
	)

select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader


-- 8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
-- Name; dùng 3 cách Not in, Not exists và Left join.

-- Sử dụng: NOT IN
select p.ProductID, p.Name
	from Production.Product as p
	where p.ProductID not in (
		select sod.ProductID
		from Sales.SalesOrderDetail as sod
	)

-- Sử dụng: NOT EXISTS
select p.ProductID, p.Name
	from Production.Product as p
	where not exists (
		select sod.ProductID
		from Sales.SalesOrderDetail as sod
		where p.ProductID = sod.ProductID
	)

-- Sử dụng: LEFT JOIN
select *
	from Production.Product as p
	left join Sales.SalesOrderDetail as sod on p.ProductID=sod.ProductID
	where sod.SalesOrderID is null

-- 9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
-- EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
-- HumanResources.Employees và Sales.SalesOrdersHeader)
select e.BusinessEntityID, (p.FirstName+p.LastName) as fullname
	from HumanResources.Employee as e
	join Person.Person as p on e.BusinessEntityID=p.BusinessEntityID
	where e.BusinessEntityID IN (
		select e.BusinessEntityID
		from HumanResources.Employee as e
		join Sales.SalesOrderHeader as soh ON soh.SalesPersonID=e.BusinessEntityID
		where soh.OrderDate <= '2008-05-01'
	)


--Primary type of person: SC = Store Contact, IN = Individual (retail)
--customer, SP = Sales person, EM = Employee (non-sales), VC = Vendor
--contact, GC = General contact

select * from Person.Person p where p.PersonType='SP'
select * from Sales.SalesPerson
select * from Person.BusinessEntity
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader
select * from  Sales.SalesPerson
select * from HumanResources.Employee as e

-- 10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
-- trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008
select soh.CustomerID, p.FirstName+p.LastName as FullName
	from Sales.SalesOrderHeader as soh
	join Person.Person as p on soh.CustomerID=p.BusinessEntityID
	where soh.CustomerID IN (
		select soh.CustomerID
		from Sales.SalesOrderHeader as soh
		join Person.Person as p on soh.CustomerID=p.BusinessEntityID
		where p.PersonType='IN' and year(soh.OrderDate)=2007
	)
	group by soh.CustomerID, p.FirstName, p.LastName

SELECT
  OBJECT_NAME(f.parent_object_id) AS TableName,
  COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
  OBJECT_NAME (f.referenced_object_id) AS ReferencedTableName,
  COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumnName
FROM
  sys.foreign_keys AS f
  INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
WHERE
  f.referenced_object_id = OBJECT_ID('Sales.SalesOrderHeader')