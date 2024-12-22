
--II) Stored Procedure:

--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
use AdventureWorks2008R2

go
create procedure SumTotalDue @month int, @year int
as 
	select soh.CustomerID, sum(soh.TotalDue) as TotalDue
		from Sales.SalesOrderHeader as soh
		where month(soh.OrderDate)=@month and year(soh.OrderDate)=@year
		group by soh.CustomerID
go

exec SumTotalDue 3, 2007

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.
go
create proc GetSalesYTDBySalesPerson
	@SalesPerson nvarchar(100), @SalesYTD money output
as 
begin
	set @SalesYTD = (
		select sum(sp.SalesYTD)
			from Sales.SalesPerson as sp
			where sp.BusinessEntityID = (
				select p.BusinessEntityID
					from Person.Person as p
					join Sales.SalesPerson as sp 
					ON p.BusinessEntityID=sp.BusinessEntityID
					where FirstName+' '+LastName=@SalesPerson
			)
	)
end
go
-- Exec
declare @SalesYTD money
exec GetSalesYTDBySalesPerson 'Jillian Carson', @SalesYTD output
select @SalesYTD

-- Tìm id của 1 nhân viên
select * from Sales.SalesPerson
select * from Person.Person
where BusinessEntityID=277

go
--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
create proc getListByMaxPrice
	@MaxPrice money
as 
begin
	select p.ProductID, p.ListPrice
	from Production.Product as p
	where p.ListPrice<=@MaxPrice
end

-- Exec
exec getListByMaxPrice 100
select * from Production.Product

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
	--SumOfSubTotal =sum(SubTotal)
	--NewBonus = Bonus+ sum(SubTotal)*0.01

create proc NewBonus
	@SalesPersonID int
as
begin
	declare @Bonus money
	declare @NewBonus money
	declare @SumOfSubTotal money

	select @Bonus=sp.Bonus
		from Sales.SalesPerson as sp
		where sp.BusinessEntityID=@SalesPersonID

	select @SumOfSubTotal=sum(soh.SubTotal)
	from Sales.SalesOrderHeader as soh
	where soh.SalesPersonID=@SalesPersonID

	set @NewBonus = @Bonus+ @SumOfSubTotal * 0.01

	update Sales.SalesPerson
	set Bonus=@NewBonus

	select @SalesPersonID as SalesPersonID, @NewBonus as NewBonus,
		@SumOfSubTotal as SumOfSubTotal
end

-- Exec
exec NewBonus 275

select * from Sales.SalesPerson

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
create proc getProductCateMaxOrderQty (@OrderYear int)
as
begin
	select top 1 pc.ProductCategoryID, pc.Name, 
			max(TableOrderQty.SumOfQty) as SumOfQty
			from Production.ProductCategory as pc
			join Production.ProductSubcategory as psc on pc.ProductCategoryID=psc.ProductCategoryID
			join Production.Product as p on p.ProductSubcategoryID=psc.ProductSubcategoryID
			join Sales.SalesOrderDetail as sod on sod.ProductID=p.ProductID
				join (
					select pc.ProductCategoryID, sum(sod.OrderQty) as SumOfQty
						from Production.ProductCategory as pc
						join Production.ProductSubcategory as psc on pc.ProductCategoryID=psc.ProductCategoryID
						join Production.Product as p on p.ProductSubcategoryID=psc.ProductSubcategoryID
						join Sales.SalesOrderDetail as sod on sod.ProductID=p.ProductID
						join Sales.SalesOrderHeader as soh on sod.SalesOrderID=soh.SalesOrderID
						where year(soh.OrderDate)=@OrderYear
						group by pc.ProductCategoryID
					
				) TableOrderQty 
				ON TableOrderQty.ProductCategoryID=pc.ProductCategoryID 
			group by pc.ProductCategoryID, pc.Name
			order by max(TableOrderQty.SumOfQty) desc
end

-- exec
exec getProductCateMaxOrderQty 2008

drop proc getProductCateMaxOrderQty

select * from Production.Product
select * from Production.ProductCategory
select * from Production.ProductSubcategory
select * from Sales.SalesOrderDetail

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.
create proc TongThu 
	(@EmployeeID int, @TongTien money output)
as 
begin
	select @TongTien=sum(soh.TotalDue)
		from Sales.SalesOrderHeader soh
		group by soh.SalesPersonID
	if @TongTien IS NOT NULL
		return 1
	else
		return 0
end
go
-- exec
declare @TongTien money
exec TongThu 278, @TongTien output
select @TongTien as TongTien

select * from Sales.SalesOrderHeader
select * from Sales.SalesOrderDetail

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.
go
create proc PurShopMaxOrder @year int 
as begin 
	select top 1 s.Name, sum(sod.LineTotal) as TongTien
		from Sales.Store as s 
		join Sales.Customer as c on s.BusinessEntityID=c.StoreID
		join Sales.SalesOrderHeader as soh on soh.CustomerID=c.CustomerID
		join Sales.SalesOrderDetail as sod on sod.SalesOrderID=soh.SalesOrderID
		where year(soh.OrderDate)=@year
		group by s.Name
		order by TongTien desc
end

-- Exec
exec PurShopMaxOrder 2007

select * from Sales.Store
select * from Sales.SalesOrderHeader

--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not
--null và các field là khóa ngoại.
go
create proc Sp_InsertProduct
	(@Name nvarchar(50), @ProductNumber nvarchar(25), @MakeFlag bit, @FinishedGoodsFlag bit,
	@SafetyStockLevel smallint, @ReorderPoint smallint, @StandardCost money,
	@ListPrice money, @SizeUnitMeasureCode nchar(3), @WeightUnitMeasureCode nchar(3), 
	@DaysToManufacture int, @ProductSubcategoryID int, @ProductModelID int, 
	@SellStartDate datetime)
as
begin
	insert into Production.Product (Name,ProductNumber, MakeFlag, FinishedGoodsFlag,
		SafetyStockLevel, ReorderPoint, StandardCost, ListPrice, SizeUnitMeasureCode, 
		WeightUnitMeasureCode, DaysToManufacture, ProductSubcategoryID, ProductModelID,
		SellStartDate)
	values (@Name, @ProductNumber, @MakeFlag, @FinishedGoodsFlag,
			@SafetyStockLevel, @ReorderPoint, @StandardCost,
			@ListPrice, @SizeUnitMeasureCode, @WeightUnitMeasureCode, 
			@DaysToManufacture, @ProductSubcategoryID, @ProductModelID, 
			@SellStartDate)
end

--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
--Sales.SalesOrderDetail.
create proc XoaHD
	@SalesOrderID int
as
begin 
	-- Xoá bảng chứa khoá ngoại
	delete from Sales.SalesOrderDetail
	where Sales.SalesOrderDetail.SalesOrderID=@SalesOrderID

	delete from Sales.SalesOrderHeader 
	where Sales.SalesOrderHeader.SalesOrderID=@SalesOrderID
end

-- Exec 
exec XoaHD 43659

select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader


--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
--này
create proc Sp_Update_Product 
	@ProductID int
as 
begin
	
	if exists(select 1 from Production.Product as p where p.ProductID=@ProductID)
		begin
			update Production.Product
			set ListPrice +=ListPrice*10/100 where ProductID=@ProductID
		end
	else
		begin
			print N'Không có sản phẩm này'
		end
end

-- Exec
exec Sp_Update_Product 707

select * from Production.Product 
	where ProductID=707

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