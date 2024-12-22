-- 19_NguyenThanhPhat_21010471

use AdventureWorks2008R2

--Câu 1: (5đ) Hãy vi ết 1 store procedure
--a.  Vi ết  th ủ  tục  tên M aSV_Total   trả về tổng  trị giá các hóa đơn đã xuất 
--bán    thuộc  về  một  TerritoryID   trong một tháng,  năm  (tương  ứng  với 
--các tham số đầu vào). Thủ tục trả về giá trị qua tham số OUTPUT.

--Cau a)
go
alter proc MaSV_Total @TerritoryID int, @OrderMonth int, @OrderYear int, @TotalDue money output 
as begin
	
	select @TotalDue=sum(soh.TotalDue)
	from Sales.SalesOrderHeader as soh 
	where soh.TerritoryID=@TerritoryID and month(soh.OrderDate)=@OrderMonth 
	and year(soh.OrderDate)=@OrderYear

end
go

--Cau b) Viết  batch  gọi  thủ tục   với tham số  @TerritoryID=10  ,  @thang 5 , 
--@nam=  2011,  và  xuất ra thông báo  ‘ Tổng trị giá các hóa đơn  thuộc 
--vùng Territorry có tên ….  là …’  
--(Gợi ý :  Name trong Sales.SalesTerritory)
go
declare @TerritoryID int=10, @OrderMonth int=5, @OrderYear int=2011, @TotalDue money
declare @Name varchar(20)
exec MaSV_Total	@TerritoryID, @OrderMonth, @OrderYear, @TotalDue output

select @Name=st.Name from Sales.SalesTerritory as st
where st.TerritoryID=10
print concat(N'Tổng trị giá các hóa đơn thuộc vùng Territorry có tên ', @Name, ' là: ', @TotalDue)
go

select * from Sales.SalesTerritory


--Câu 2: (5đ) 
--c.  Hãy  viết  hàm  dạng  table_valued  function  có  tên  MaSV_ThongKe 
--cho  bi ết  Sản phẩm   có tổng số l ượng bán cao nhất trong năm bất kỳ
--(@nam là tham số truyền vào). Thông tin hiển thị bao gồm :  Mã sản 
--phẩm , Tổng số lượng bán 
go
create function MaSV_ThongKe (@nam int)
returns table 
as 
return (select top 1 p.ProductID, sum(sod.OrderQty) as SoLuong
	from Sales.SalesOrderHeader as soh join Sales.SalesOrderDetail as sod
	on soh.SalesOrderID=sod.SalesOrderID join Production.Product as p 
	on p.ProductID=sod.ProductID
	where year(soh.OrderDate)=@nam
	group by p.ProductID
	order by sum(sod.OrderQty) desc
	)
go

--d.  Thực thi   hàm  với tham số @nam=  2011
--select * from Sales.SalesOrderHeader
--select * from Sales.SalesTerritory
go
declare @name int=2011
select * from MaSV_ThongKe(@name)
