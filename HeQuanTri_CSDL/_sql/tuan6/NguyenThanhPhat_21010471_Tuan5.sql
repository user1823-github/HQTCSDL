--Tuần 5

--III) Function
-- Scalar Function
--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
--giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
--phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
--phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng
--[HumanResources].[EmployeeDepartmentHistory] và
--[HumanResources].[Department])
use AdventureWorks2008R2
go
create function CountOfEmployees (@mapb int)
returns int
as
begin
	declare @CountOfEmpDepartment int
	select @CountOfEmpDepartment=count(edh.BusinessEntityID)
		from HumanResources.Department as d
		join HumanResources.EmployeeDepartmentHistory as edh
		on d.DepartmentID=edh.DepartmentID
		where edh.DepartmentID=@mapb
	return @CountOfEmpDepartment
end

-- Exec
go
declare @mapb int = 7
select dbo.CountOfEmployees(@mapb) as [Số lượng nhân viên]

select d.DepartmentID, d.Name, dbo.CountOfEmployees(@mapb) as CountOfEmp
	from HumanResources.Department as d
	join HumanResources.EmployeeDepartmentHistory as edh
	on d.DepartmentID=edh.DepartmentID
	group by d.DepartmentID, d.Name


select * from HumanResources.Department
select * from HumanResources.Employee

--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
go
create function InventoryFrod (@ProductID int, @LocationID smallint)
returns int
as
begin
	declare @CountOfInventory int
	select @CountOfInventory=count(pri.ProductID)
	from Production.ProductInventory as pri

	return @CountOfInventory
end

-- Exec
declare @ProductID int = 316
declare @LocationID smallint = 1
select dbo.InventoryFrod(@ProductID, @LocationID) as CountOfInventory

select * from Production.ProductInventory

--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
go
create function SubTotalOfEmp (@EmpID int, @MonthOrder int, @YearOrder int)
returns money
as
begin
	declare @SubTotalOfEmp money;

	select @SubTotalOfEmp=sum(soh.TotalDue)
		from Sales.SalesOrderHeader as soh
		where month(soh.OrderDate)=@MonthOrder 
		and year(soh.OrderDate)=@YearOrder
		group by soh.SalesPersonID
	return @SubTotalOfEmp
end

-- Exec
declare @EmpID int = 282, 
		@MonthOrder int = 2, 
		@YearOrder int = 2006

select dbo.SubTotalOfEmp(@EmpID, @MonthOrder, @YearOrder)

select * from Sales.SalesOrderHeader

-- Table Valued Functions:
--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
go
create function SumOfOrder (@thang int, @nam int) 
returns table
as
	return (
		select soh.SalesOrderID, soh.OrderDate, soh.SubTotal
			from Sales.SalesOrderHeader as soh
			where month(soh.OrderDate)=@thang 
			and year(soh.OrderDate)=@nam and soh.SubTotal>70000
	)

-- Exec
select * from SumOfOrder(6, 2007)

select * from Sales.SalesOrderHeader

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
create function NewBonus1 (@SalesPersonID int)
returns table
as 
	return (
		select soh.SalesPersonID, sp.Bonus+ sum(SubTotal)*0.01 as NewBonus,
			sum(soh.SubTotal) as SumOfSubTotal
			from Sales.SalesOrderHeader as soh
			join Sales.SalesPerson as sp
			on soh.SalesPersonID=sp.BusinessEntityID
			where sp.BusinessEntityID = @SalesPersonID
			group by soh.SalesPersonID, sp.Bonus
	)

-- Exec
select * from NewBonus1(284)

--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
--và [Purchasing].[PurchaseOrderDetail])
create function SumOfProduct (@MaNCC int)
returns table
as 
	return (
		select pod.ProductID, sum(pod.OrderQty) as SumOfProduct,
			poh.SubTotal as SumOfSubTotal
			from Purchasing.Vendor as v
			join Purchasing.PurchaseOrderHeader as poh
			on v.BusinessEntityID=poh.VendorID
			join Purchasing.PurchaseOrderDetail as pod
			on poh.PurchaseOrderID=pod.PurchaseOrderID
			where v.BusinessEntityID=@MaNCC
			group by pod.ProductID, poh.SubTotal
	)

-- Exec
select * from SumOfProduct (1678)

select * from Purchasing.PurchaseOrderHeader as poh
select * from Purchasing.PurchaseOrderDetail as pod
select * from Purchasing.Vendor as v


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

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
-- Multi-statement Table Valued Functions:
go
create function TotalOfEmp(@MonthOrder int, @YearOrder int)
returns @OutputTotalOfEmp table (SalesPersonID int, Total money)
as
begin
	insert into @OutputTotalOfEmp (SalesPersonID, Total)
	select soh.SalesPersonID, sum(soh.SubTotal) as Total
		from Sales.SalesOrderHeader as soh
		where month(soh.OrderDate)=@MonthOrder and year(soh.OrderDate)=@YearOrder
		group by soh.SalesPersonID

	return
end

-- Exec
select * from dbo.TotalOfEmp(3, 2007)

--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function
-- 5
create function fc_NewBonus1 (@SalesPersonID int)
returns @OutNewBonus1 table (SalesPersonID int not null, NewBonus money, SumOfSubTotal money)
as 
begin
	insert into @OutNewBonus1 
	select soh.SalesPersonID, sp.Bonus+ sum(SubTotal)*0.01 as NewBonus,
		sum(soh.SubTotal) as SumOfSubTotal
		from Sales.SalesOrderHeader as soh
		join Sales.SalesPerson as sp
		on soh.SalesPersonID=sp.BusinessEntityID
		where sp.BusinessEntityID = @SalesPersonID
		group by soh.SalesPersonID, sp.Bonus
	return 
end
-- Exec
select * from fc_NewBonus1(284)

-- 6
create function fcm_SumOfProduct (@MaNCC int)
returns @OutSumOfProduct table (ProductID int not null, SumOfProduct money not null, 
								SumOfSubTotal money not null)
as 
begin
	insert into @OutSumOfProduct
	select pod.ProductID, sum(pod.OrderQty) as SumOfProduct,
		poh.SubTotal as SumOfSubTotal
		from Purchasing.Vendor as v
		join Purchasing.PurchaseOrderHeader as poh
		on v.BusinessEntityID=poh.VendorID
		join Purchasing.PurchaseOrderDetail as pod
		on poh.PurchaseOrderID=pod.PurchaseOrderID
		where v.BusinessEntityID=@MaNCC
		group by pod.ProductID, poh.SubTotal
	return 
end
-- Exec
select * from fcm_SumOfProduct (1678)

-- 7
go
create function fc_Discount_Func()
returns @OutDiscount_Func table (SalesOrderID int not null, SubTotal money not null, Discount money)
as
begin
	insert into @OutDiscount_Func
	select soh.SalesOrderID, soh.SubTotal, 
		case
			when (soh.SubTotal < 1000) then 0
			when (soh.SubTotal >= 1000 and soh.SubTotal < 5000) then 5.0/100 * soh.SubTotal
			when (soh.SubTotal >= 5000 and soh.SubTotal < 10000) then 10.0/100 * soh.SubTotal
			else  15.0/100 * soh.SubTotal 
		end as Discount
		from Sales.SalesOrderHeader as soh

	return 
end
-- Exec
select * from dbo.Discount_Func()

-- 8
go
create function TotalOfEmp(@MonthOrder int, @YearOrder int)
returns @OutputTotalOfEmp table (SalesPersonID int, Total money)
as
begin
	insert into @OutputTotalOfEmp (SalesPersonID, Total)
	select soh.SalesPersonID, sum(soh.SubTotal) as Total
		from Sales.SalesOrderHeader as soh
		where month(soh.OrderDate)=@MonthOrder and year(soh.OrderDate)=@YearOrder
		group by soh.SalesPersonID

	return
end

-- Exec
select * from dbo.TotalOfEmp(3, 2007)

-- 10)
go
create function SalaryOfEmp (@MaNV int)
returns @OutSalaryOfEmp table (ID int not null, FName nvarchar(50) not null,
							   LNam nvarchar(50) not null, Rate money not null)
as
begin	
	if (@MaNV IS NOT NULL)	
			begin
				insert into @OutSalaryOfEmp
					select eph.BusinessEntityID, p.FirstName as FName,
					p.LastName as LName, eph.Rate as Salary
					from HumanResources.EmployeePayHistory as eph
					join Person.Person as p
					on p.BusinessEntityID=eph.BusinessEntityID
					where eph.BusinessEntityID=@MaNV
			end
	else
		begin
			insert into @OutSalaryOfEmp
				select eph.BusinessEntityID, p.FirstName as FName,
				p.LastName as LName, eph.Rate as Salary
				from HumanResources.EmployeePayHistory as eph
				join Person.Person as p
				on p.BusinessEntityID=eph.BusinessEntityID
		end
	return
end

-- Exec
select * from dbo.SalaryOfEmp(288)
select * from dbo.SalaryOfEmp(null)

select * from Person.Person
select * from HumanResources.EmployeePayHistory
