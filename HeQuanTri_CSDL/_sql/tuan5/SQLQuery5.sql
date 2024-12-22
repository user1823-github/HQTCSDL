-- Tuần 5

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

--3)  Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
go
create proc ListProductID @MaxPrice int
as begin
	select p.ProductID, p.ListPrice
	from Production.Product as p
	where p.ListPrice <= @MaxPrice
end

exec ListProductID 50000

--4)  Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên  đó. Mức thưởng mới 
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--SumOfSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01
go
create proc NewBonus @EmployeID int
as begin
	declare @Bonus money, @NewBonus money, @SumOfSubTotal money
	set @Bonus = (select p.Bonus 
				  from Sales.SalesPerson as p
				  where p.BusinessEntityID=@EmployeID
				  )
	
	select @SumOfSubTotal=sum(soh.SubTotal) 
	from Sales.SalesOrderHeader as soh
	where soh.SalesPersonID=@EmployeID
	group by soh.SalesPersonID

	set @NewBonus = @Bonus + @SumOfSubTotal*(1.0/100)

	select @EmployeID as SalesPersonID, @NewBonus as NewBonus,
	@SumOfSubTotal as SumOfSubTotal
end

exec NewBonus 290

--5)  Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query) 


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

--Exec
declare @SumSubTotal money
exec Sp_TongThu 279, @SumSubTotal output
select @SumSubTotal as SumSubTotal

select * from Sales.SalesOrderHeader

--7)  Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.
create proc Sp_StoreMaxProduct
as begin
	declare @OrderYear int = 2005
	select top 10 s.Name, max(soh.SubTotal) as MaxSubTotal
	from Sales.store as s
	join Sales.SalesOrderHeader as soh on soh.SalesPersonID=s.SalesPersonID
	where year(soh.OrderDate)=@OrderYear
	group by s.Name
	order by max(soh.SubTotal) desc
end

--Exec 
exec Sp_StoreMaxProduct

--8)  Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa  ngoại.
go
create proc Sp_InsertProduct @Name nvarchar(50), @ProductNumber nvarchar(25), @SafetyStockLevel smallint
	, @ReorderPoint smallint, @StandardCost money, @ListPrice money, @DaysToManufacture int, 
	  @SellStartDate datetime
as begin
	insert into Production.Product([Name], [ProductNumber], [SafetyStockLevel], [ReorderPoint], 
			[StandardCost], [ListPrice], [DaysToManufacture], [SellStartDate])
	values (@Name, @ProductNumber, @SafetyStockLevel, 
			@ReorderPoint, @StandardCost, @ListPrice , @DaysToManufacture, 
			@SellStartDate)
end 

-- Exec
exec Sp_InsertProduct 'ML Crankare', 'BA-8326', 700, 375, 0, 175.655, 1, '2013-02-18 08:30:45'

sp_help 'Production.Product'
-- Check 
select * from Production.Product

--9)  Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi  biết  SalesOrderID.  Lưu  ý  :  trước  khi  xóa  mẫu  tin  trong 
--Sales.SalesOrderHeader  thì  phải  xóa  các  mẫu  tin  của  hoá  đơn  đó  trong 
--Sales.SalesOrderDetail. 
go
create procedure Sp_XoaHD @SalesOrderID int
as begin
	delete Sales.SalesOrderDetail
	where SalesOrderID=@SalesOrderID

	delete Sales.SalesOrderHeader
	where SalesOrderID=@SalesOrderID
end

--Exec
exec Sp_XoaHD 43659

select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader
--10)  Viết  thủ  tục  Sp_Update_Product  có  tham  số  ProductId  dùng  để  tăng  listprice
--lên 10%  nếu  sản phẩm này tồn  tại,  ngược  lại  hiện  thông  báo  không  có  sản  phẩm
--này.
go
create proc Sp_Update_Product @ProductID int
as begin
	if exists (select * from Production.Product as p 
			   where p.ProductID=@ProductID)
		begin
			update Production.Product
			set ListPrice += ListPrice*(10.0/100)
			where ProductID=@ProductID
		end
	else
		print concat(N'Không có sản phẩm: ', @ProductID)
end

--Exec
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