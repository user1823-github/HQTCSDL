use Northwind
--VD 1:
create proc Tong
as
	declare @a int, @b int
	set @a=7
	set @b=3
	print N'Tổng = '+convert(varchar(10), @a+@b)
	print N'Hiệu = '+convert(varchar(10), @a-@b)
	print N'Tích = '+convert(varchar(10), @a*@b)
	if @b<>0
		print N'Thương = '+convert(varchar(10), @a/@b)
	else
		print N'Không chia được'

-- Exec
exec Tong

--VD 2:
create proc Tong1(@a int, @b int)
as 
	print N'Tổng = '+convert(varchar(10), @a+@b)
	print N'Hiệu = '+convert(varchar(10), @a-@b)
	print N'Tích = '+convert(varchar(10), @a*@b)
	if @b<>0
		print N'Thương = '+convert(varchar(10), @a/@b)
	else
		print N'Không chia được'

-- Exec
exec Tong1 3, 5

--VD 3:
-- 1
create proc London_KH 
as 
	select * from Customers 
		where City='London'

-- Exec
exec London_KH

-- 2
create proc TP_KH(@TP nvarchar(15))
as 
	select * from Customers
		where City=@TP

-- Exec	
declare @TP nvarchar(15)
set @TP='London'
exec TP_KH London

--VD 4:
create proc CustOrderHist 
	@CustomerID nchar(5)
as
	select p.ProductName, Total=sum(od.Quantity)
		from Products as p, [Order Details] as od, Orders as o,
		Customers as c
		where c.CustomerID=@CustomerID 
		and c.CustomerID=o.CustomerID 
		and o.OrderID=od.OrderID
		and od.ProductID=p.ProductID
		group by p.ProductName

-- Exec
exec CustOrderHist 'NORTS'

--VD 5:
create proc Tinhtoan
	@a int, @b int, @tong int output, @hieu int output,
	@tich int output, @thuong real output
as
begin
	set @tong=@a + @b
	set @hieu=@a - @b
	set @tich=@a * @b
	if @b <> 0
		begin
			set @thuong= @a / @b
			print 'Thuong = '+convert(varchar(10), @thuong)
		end
	else
		print 'Khong chia duoc'
end

-- Exec
declare @a int, @b int, @tong int, @hieu int, @tich int, @thuong real
set @a=8
set @b=5
exec Tinhtoan @a, @b, @tong, @hieu, @tich, @thuong


drop proc TP_KH

--VD 6:
declare @tong int, @hieu int, @tich int, @thuong real, @a int, @b int
set @a=8
set @b=5
print 'a = '+convert(varchar(10), @a)
print 'b = '+convert(varchar(10), @b)

exec tinhtoan @a, @b, @tong output, @hieu output, @tich output, @thuong output
	print 'a = '+convert(varchar(10), @a)
	print 'b = '+convert(varchar(10), @b)
	print 'Tong = '+convert(varchar(10), @tong)
	print 'Hieu = '+convert(varchar(10), @hieu)
	print 'Tich = '+convert(varchar(10), @tich)
	print 'Thuong = '+convert(varchar(10), @thuong)

-- VD 7:
create proc prcGetUnitPrice_UnitsInStock 
	@ProductID int, @Unitprice money output, @UnitsInStock smallint output
as
begin
	if exists (select * from Products
			   where ProductID=@ProductID)
		begin
			select @Unitprice=Unitprice, @UnitsInStock=UnitsInStock
			from Products
			where ProductID=@ProductID
			return 0
		end
	else
		return 1
end

declare @Unitprice money, @UnitsInStock smallint
exec prcGetUnitPrice_UnitsInStock 1, @Unitprice output, @UnitsInStock output
print '@Unitprice = ' + convert(varchar(20), @Unitprice)
print '@@UnitsInStock = ' + convert(varchar(20), @UnitsInStock)

-- VD 8:
create proc KH_city
	@KH_city varchar(15)
as 
	declare @KH_return int
	select @KH_return=count(*)
	from Customers where City=@KH_city
	return @KH_return + 1

-- Exec
declare @SoKH int
exec @SoKH=KH_city 'LonDon'
print 'So KH la: '+convert(varchar(4), @SoKH)

-- VD 9:
create proc prcDisplayUnitPrice_UnitsInStock 
	@ProductID int
as 
begin
	declare @UnitPrice money, @UnitsInStock smallint
	declare @ReturnValue tinyint
	exec @ReturnValue=prcGetUnitPrice_UnitsInStock @ProductID,
	@UnitPrice output, @UnitsInStock output
	
	if(@ReturnValue = 0)
		begin
			print 'The Status for product: '+convert(char(10), @ProductID)
			print 'Unit price     : '+convert(char(10), @Unitprice)
			print 'Current Units In Stock: '+convert(char(10), @UnitsInStock)
		end
	else
		print 'No records for the given productID '+convert(char(10), @ProductID)
end

exec prcDisplayUnitPrice_UnitsInStock 1

--Function
--VD 1:
create function tong2so()
returns int
as
begin
	declare @so1 int, @so2 int
	set @so1 = 4
	set @so2 = 6
	return @so1 + @so2
end

-- Exec
print 'Tong = '+convert(char(10), dbo.tong2so())
select dbo.tong2so() as Tong

--VD 2:
create function Tongtien()
returns money
as
begin
	declare @tong money
	select @tong = sum(unitprice*quantity) from Orders o, [Order Details] d
	where o.OrderID=d.OrderID and CustomerID='TOMSP'
	return @tong
end

-- Exec
print 'Tong = '+convert(char(10), dbo.tongtien())
select dbo.tongtien() as [Tong Tien Cua Khach Hang TOMPS]






