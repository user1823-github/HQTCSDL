--I)  Batch

--1)  Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của  sản phẩm 
--có ProductID=’778’;  nếu  @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên  500  đơn  hàng”,  ngược  lại  thì  in  ra  chuỗi  “Sản  phẩm  778  có  ít  đơn  đặt
--hàng”
use AdventureWorks2008R2
go
	declare @tongsoHD int
	select @tongsoHD=count(sod.SalesOrderID)
	from Sales.SalesOrderDetail sod
	where sod.ProductID=778

	if(@tongsoHD) > 500
		print concat(N'Sản phẩm 778 có trên  500  đơn  hàng', @tongsoHD)
	else
		print concat(N'Sản  phẩm  778  có  ít  đơn  đặt hàng', @tongsoHD)
go

--2)  Viết  một  đoạn  Batch  với  tham  số  @makh  và  @n  chứa  số  hóa  đơn  của  khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008),    nếu
--@n>0  thì  in  ra  chuỗi:  “Khách  hàng  @makh  có  @n  hóa  đơn  trong  năm  2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng  @makh không có hóa đơn nào 
--trong năm 2008”

use AdventureWorks2008R2
go
	declare @makh int = 29825, @n int
	declare @nam int = 2008

	select @n=count(soh.SalesOrderID)
	from Sales.SalesOrderHeader soh
	where year(soh.OrderDate)=@nam and soh.CustomerID=@makh

	if @n>0
		print concat(N'Khách hàng ', @makh, N' có ', @n, N' hóa  đơn  trong  năm  2008')
	else
		print concat(N'Khách hàng ', @makh, N' không có hóa  đơn nào trong  năm  2008')
go	


--3)  Viết  một  batch  tính  số  tiền  giảm  cho  những  hóa  đơn  (SalesOrderID)  có  tổng 
--tiền>100000,  thông  tin  gồm  [SalesOrderID],  SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như  sau:
--  Những hóa đơn có SubTotal<100000 thì không  giảm,
--  SubTotal từ 100000 đến <120000 thì giảm 5% của  SubTotal
--  SubTotal từ 120000 đến <150000 thì giảm 10% của  SubTotal
--  SubTotal từ 150000 trở lên thì giảm 15% của  SubTotal

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
	end
	from Sales.SalesOrderDetail sod
	group by sod.SalesOrderID

go

--4)  Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các  field  [ProductID],[BusinessEntityID],[OnOrderQty],  với  giá  trị  truyền  cho 
--các biến @mancc,  @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc,   nếu
--@soluongcc trả về giá  trị là null  thì in  ra chuỗi  “Nhà cung  cấp 1650  không cung 
--cấp sản phẩm  4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là  5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

use AdventureWorks2008R2
go
	declare @mancc int = 1650, @masp int = 4, @soluongcc int

	select @soluongcc= pv.OnOrderQty
	from Purchasing.ProductVendor as pv
	where pv.BusinessEntityID=@mancc and pv.ProductID=@masp
	if @soluongcc is null 
		print concat(N'Nhà cung cấp ', @mancc, N' không cung cấp sản phẩm ', @masp)
	else if(@soluongcc = 5)
		print concat(N'Nhà cung cấp ', @mancc, N' cung cấp sản phẩm ', @masp, N' với số lượng là ', @soluongcc)
go

--5)  Viết  một  batch  thực  hiện  tăng  lương  giờ  (Rate)  của  nhân  viên  trong 
--[HumanResources].[EmployeePayHistory]  theo  điều  kiện  sau:  Khi  tổng  lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì  dừng.
use AdventureWorks2008R2
go
	while (select sum(ep.Rate)
		  from HumanResources.EmployeePayHistory ep) < 6000
	begin
		update HumanResources.EmployeePayHistory
		set Rate += Rate*10.0/100

		if( select max(Rate) from HumanResources.EmployeePayHistory) > 150
			break
		else continue
	end
go