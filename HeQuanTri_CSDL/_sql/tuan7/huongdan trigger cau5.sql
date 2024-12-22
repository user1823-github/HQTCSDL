
--1.trigger chay khi nao ?  
--Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail 

--2.trigger lam gi?
--nếu số lượng trong kho 
--Quantity> OrderQty thì cập nhật 
--lại  số   lượng   trong   kho 
--Quantity=  Quantity-  OrderQty, 
--ngược lại nếu Quantity=0 thì xuất 
--thông báo “Kho hết hàng” và đồng 
--thời hủy giao  tác.

--3. kieu trigger : after , instead of

select *
from Sales.SalesOrderDetail
go
sp_help 'Sales.SalesOrderDetail'
delete Sales.SalesOrderDetail where SalesOrderID=43659 and SalesOrderDetailID = 121320

insert Sales.SalesOrderDetail(SalesOrderID,OrderQty,ProductID,SpecialOfferID,UnitPrice)
values (43660, 300, 707,1,  100 )

select * from Sales.SpecialOfferProduct where ProductID = 316


go
select * from Production.ProductInventory where ProductID = 707

go 
select * from Production.ProductInventory i join Sales.SpecialOfferProduct s
on i.ProductID = s.ProductID


go
use AdventureWorks2012
go
create trigger  cau5
on Sales.SalesOrderDetail
after insert
as
declare @productid int, @qty smallint  , @locationid int
select  @qty= OrderQty,  @productid = ProductID
from inserted

if exists (select * from  Production.ProductInventory where ProductID = @productid 
						and Quantity >= @qty)
begin
	select  top 1 @locationid=  LocationID
	from  Production.ProductInventory where ProductID = @productid and Quantity >= @qty

	update Production.ProductInventory
	set	Quantity = Quantity - @qty
	where ProductID = @productid  and @locationid=  LocationID
end

else
begin
	print N'Kho ....hết hàng'
	rollback
end








