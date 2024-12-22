use AdventureWorks2008R2
https://stackoverflow.com/questions/3699356/difference-between-in-and-any-operators-in-sql
-- 1 Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
--SubTotal =SUM(OrderQty*UnitPrice).

select soh.SalesOrderID, soh.OrderDate, sum(soh.SubTotal) as SubTotal
from Sales.SalesOrderHeader soh
where month(soh.OrderDate)=6 and year(soh.OrderDate)=2008
group by soh.SalesOrderID, soh.OrderDate
having sum(soh.SubTotal)>70000


select * from Sales.SalesOrderDetail

-- 2 Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)

select soh.TerritoryID, count(soh.CustomerID) as CountOfCust, 
	sum(soh.SubTotal) as SubTotal
	from Sales.SalesOrderHeader soh
	join Sales.SalesTerritory st
	on soh.TerritoryID=st.TerritoryID
	where st.CountryRegionCode='US'
	group by soh.TerritoryID
	 
select * from Sales.SalesTerritory

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
-- nhất trong bảng Sales.SalesOrderDetail
select sod.ProductID, max(sod.UnitPrice)
	from Sales.SalesOrderDetail sod
	group by sod.ProductID
	having max(sod.UnitPrice) >= ALL (
		select sod.UnitPrice
		from Sales.SalesOrderDetail sod
	)

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


-------------- INSERT TABLE and CREATE VIEW
--2) Dùng lệnh insert <TableName1> select <fieldList> from
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
--bảng [HumanResources].[Department].
insert MyDepartment 
select d.DepartmentID, d.Name, d.GroupName
	from HumanResources.Department as d

select * from MyDepartment

--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal
go
create view vw_ListProduct 
as select sod.ProductID, p.Name, count(sod.OrderQty) as CountOfOrderID, 
	sum(soh.SubTotal) as SubTotal
	from Sales.SalesOrderDetail sod 
	join Production.Product p
	on sod.ProductID=p.ProductID
	join Sales.SalesOrderHeader soh
	on sod.SalesOrderID=soh.SalesOrderID
	where datepart(quarter, soh.OrderDate)=1 and year(soh.OrderDate)=2008
	group by sod.ProductID, p.Name
	having sum(soh.SubTotal)>10000 and count(soh.SalesOrderID)>500

select * from vw_ListProduct

--------------CASE WHEN THEN-----  22222 CAST
use AdventureWorks2008R2
go
	select sod.SalesOrderID, sum(sod.LineTotal) as SubTotal, 'Discount'=
	case
		when sum(sod.LineTotal) < 10000 
			then cast( sum(sod.LineTotal) as nvarchar)
		when sum(sod.LineTotal) >= 10000 and sum(sod.LineTotal) < 12000 
			then cast( sum(sod.LineTotal)* 5.0/100 as nvarchar)
		when sum(sod.LineTotal) >= 12000 and sum(sod.LineTotal) < 15000 
			then cast(  sum(sod.LineTotal)* 10.0/100 as nvarchar)
		when sum(sod.LineTotal)>15000 
			then cast( sum(sod.LineTotal)* 15.0/100 as nvarchar)
		else cast(4 as varchar)
	end
	from Sales.SalesOrderDetail sod
	group by sod.SalesOrderID
go

DECLARE @totalHourlyPay DECIMAL(10,2)
SELECT @totalHourlyPay = SUM(Rate) FROM [HumanResources].[EmployeePayHistory]

IF @totalHourlyPay < 6000
BEGIN
    UPDATE [HumanResources].[EmployeePayHistory]
    SET Rate += Rate * 0.1 -- Tăng lương giờ lên 10%
    WHERE Rate <= 150 -- Chỉ cập nhật những nhân viên có lương giờ <= 150
END

--- PROCEDURE
--II) Stored Procedure:
--1)  Viết  một  thủ  tục  tính  tổng  tiền  thu  (TotalDue)  của  mỗi  khách  hàng  trong  một 
--tháng bất kỳ của  một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumOfTotalDue  =Sum(TotalDue)

use AdventureWorks2008R2
go
create procedure pr_TotalDoanhThuByCustomer @CustomerID int, @month int, @year int
as 
begin
	select CustomerID, sum(TotalDue) as SumOfTotalDue, OrderDate
	from Sales.SalesOrderHeader
	where CustomerID=@CustomerID and month(OrderDate)=@month and year(OrderDate)=@year
	group by CustomerID, OrderDate
end

exec pr_TotalDoanhThuByCustomer 13666, 10, 2005

------ Tăng lượng NV
exec sp_Update_Product 815

select * from Production.Product
where ProductID=815

go
create proc sp_Update_Product @ProductID int
as 
	if exists (select * from Production.Product where ProductID=@ProductID)
		begin
			update Production.Product
			set ListPrice += ListPrice*0.1
			where ProductID=@ProductID
		end
	else
		print 'Ko có sp:' + cast(@ProductID as varchar)

--6)  Tạo thủ tục đặt tên là TongThu  có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ  tục.
go
create proc Sp_TongThu @EmployeeID int, @SumSubTotal money output 
as begin
	set @SumSubTotal = (select sum(soh.SubTotal) 
					   from Sales.SalesOrderHeader as soh
					   where soh.SalesPersonID=@EmployeeID
					   group by soh.SalesPersonID)
	if @SumSubTotal is null
		return 0
	else
		return 1
end

-- OUTPUT
--2)  Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
go
create procedure pr_ToTalDoanhThuYTDByEmp @SalePerson int, @SaleYTD money output
as
begin
	select @SaleYTD=sp.SalesYTD
	from Sales.SalesPerson sp
	where sp.BusinessEntityID=@SalePerson
end

go
declare @SaleYTD money
declare @EmployeeID int = 274
exec pr_ToTalDoanhThuYTDByEmp 274, @SaleYTD output 

print concat(@EmployeeID, ' có doanh thu: ', @SaleYTD)

-- Function
--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
go
create function Discount_Func()
returns table
as
	return (
		select soh.SalesOrderID, soh.SubTotal, 
			case
				when (soh.SubTotal < 1000) then 0
				when (soh.SubTotal >= 1000 and soh.SubTotal < 5000) then 5.0/100 * soh.SubTotal
				when (soh.SubTotal >= 5000 and soh.SubTotal < 10000) then 10.0/100 * soh.SubTotal
				else  15.0/100 * soh.SubTotal 
			end as Discount
			from Sales.SalesOrderHeader as soh
	)

-- Exec
select * from dbo.Discount_Func()

use AdventureWorks2008R2

go
alter function ListVendorID (@VendorID int, @year int, @value money)
returns @table table 
	(
		VendorID int, 
		TotalDue money
	)
as 
begin
	if @value is NULL
		begin
			insert into @table
			select soh.VendorID, sum(soh.TotalDue) as [ToTalDue]
				from Purchasing.PurchaseOrderHeader soh
				where year(soh.OrderDate)=@year and soh.VendorID=@VendorID
				group by soh.VendorID
		end
	else 
		begin
			insert into @table
			select soh.VendorID, sum(soh.TotalDue) as [ToTalDue]
				from Purchasing.PurchaseOrderHeader soh
				where year(soh.OrderDate)=@year
				group by soh.VendorID
				having sum(soh.TotalDue) > @value
		end
return
end
go
-- EXEC
select * from dbo.ListVendorID(1, 2008, 100000)
select * from dbo.ListVendorID(1608, 2008, NULL)

use AdventureWorks2008R2

--cau 1
go
declare @TerritoryID int = 10, @TerritoryName nvarchar(50) 
declare @SalesYTD money, @NumCustomer int

select @TerritoryName=st.Name, @SalesYTD=st.SalesYTD,
	@NumCustomer=count(soh.CustomerID)
	from Sales.SalesTerritory st join
	Sales.SalesOrderHeader soh 
	on st.TerritoryID=soh.TerritoryID
	where st.Name='United Kingdom' 
	and st.TerritoryID=@TerritoryID
	group by st.Name, st.SalesYTD

print concat(N'Vùng lãnh thổ số ', @TerritoryID, N' tên ', @TerritoryName,
N' với ', @NumCustomer, N' khách hàng có doanh thu hiện tại ', @SalesYTD, ' USD' )
go

select * from Sales.SalesTerritory

--cau 2
go
create procedure uspCustomerInfo @PersonID int
as begin
	if @PersonID is not NULL
	begin
		declare @PersonName nvarchar(200), @TotalDue money

		select @PersonName=p.FirstName+' '+p.MiddleName+' '+p.LastName
			, @TotalDue=sum(soh.SubTotal)
			from Person.Person p join Sales.SalesOrderHeader soh
			on soh.CustomerID=p.BusinessEntityID
			where year(soh.OrderDate)=2008 and soh.OnlineOrderFlag=0
			and soh.CustomerID=@PersonID
			group by p.FirstName, p.MiddleName, p.LastName
		select @PersonName, @TotalDue
	end 
	else
	begin
		print 'Không có thông tin khách hàng này'
		return 1
	end
end
go

go
exec uspCustomerInfo 128
go

go
exec uspCustomerInfo null
go

--cau 3
go
create function ufnVendorList (@CreditRating tinyint, @Status tinyint)
returns table
as 
	return (
		select v.Name, poh.SubTotal, poh.TaxAmt, poh.Freight
			from Purchasing.Vendor v 
			join Purchasing.PurchaseOrderHeader poh
			on v.BusinessEntityID=poh.VendorID
			where v.CreditRating=@CreditRating and poh.Status=@Status
	)

go
declare @CreditRating tinyint = 1, @Status tinyint = 1
select * from dbo.ufnVendorList(@CreditRating, @Status)
go

use AdventureWorks2008R2
select p.ProductID, p.Name, p.ProductNumber, p.StandardCost,
p.ListPrice, p.ProductSubcategoryID, p.ProductModelID
into SanPham 
from Production.Product p
where p.Name like 'H%'

go
create procedure Sp_SanPham @Name varchar(50)
	, @ProductNumber nvarchar(25), @StandardCost money
	, @ListPrice money, @ProductSubcategoryID int
	, @ProductModelID int
as begin
	insert SanPham
	select @Name, @ProductNumber, @StandardCost
		, @ListPrice, @ProductSubcategoryID, @ProductModelID
end

go

--cau 1
create procedure ChangeListPrice_MaSV 
	 @productID int, @endDate datetime
	, @startDate datetime, @listPrice money
as begin
	update Production.Product
	set ListPrice=@listPrice
	where ProductID=@productID 
	and SellEndDate>=@endDate and SellStartDate<=@startDate
end

select * from Production.Product

-- EXEC
go
declare @productID int = 707, @listPrice money = 35
declare @endDate datetime = '2007-11-30', @startDate datetime = '2007-12-01'
exec ChangeListPrice_MaSV 707, @endDate, @startDate, @listPrice

select * from Production.Product
where ProductID=707
go

--câu 3
CREATE FUNCTION fn_UpdateEmployeePayRate (@BusinessEntityID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TotalRate DECIMAL(18,2)
    SELECT @TotalRate = SUM(Rate) FROM [HumanResources].[EmployeePayHistory]
    IF (@TotalRate >= 150) RETURN  -- Nếu tổng lương giờ của tất cả nhân viên >= 150 thì dừng.
    UPDATE [HumanResources].[EmployeePayHistory]
    SET Rate = Rate * 1.1 -- Tăng lương giờ 10%
    WHERE BusinessEntityID = @BusinessEntityID
    RETURN (SELECT Rate FROM [HumanResources].[EmployeePayHistory] WHERE BusinessEntityID = @BusinessEntityID)
END