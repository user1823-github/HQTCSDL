-- Tuần 4
--I) Batch
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
--hàng”
use AdventureWorks2008R2

begin transaction
	declare @tongsoHD int
	select @tongsoHD=count(*) 
	from Sales.SalesOrderDetail as sod
	where sod.ProductID=778
	if (@tongsoHD>500)
		begin
			print N'Sản phẩm 778 có trên 500 đơn hàng:' + convert(char(5), @tongsoHD) +N'đơn' 
		end
	else
		begin 
			print N'Sản phẩm 778 có ít đơn đặt hàng: '+ convert(char(5), @tongsoHD) +N'đơn'
		end
commit transaction

select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008”
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào
--trong năm 2008”

begin transaction
	declare @makh int, @nam int, @n int
	select @nam=year(soh.OrderDate), @n=count(*), @makh=soh.CustomerID
		from Sales.SalesOrderHeader as soh
		group by year(soh.OrderDate), soh.CustomerID
	if (@n>0)
		begin
			print N'Khách hàng '+cast(@makh as varchar)+N' có '+cast(@n as varchar)+N' hoá đơn trong năm 2008'
		end
	else if (@n=0)
		begin
			print N'Khách hàng '+cast(@makh as varchar)+N' không có hóa đơn nào trong năm 2008'
		end
commit transaction

--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]),
--Discount (tiền giảm), với Discount được tính như sau:
-- Những hóa đơn có SubTotal<100000 thì không giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal

--(Gợi ý: Dùng cấu trúc Case… When …Then …)
begin transaction
	select soh.SalesOrderID, sum(sod.LineTotal) as SubTotal, 
			case when sum(sod.LineTotal) > 150000 
				then sum(sod.LineTotal)*15/100
			 when sum(sod.LineTotal) >= 120000 and sum(sod.LineTotal)<150000
				then sum(sod.LineTotal)*10/100
			 when sum(sod.LineTotal) >= 100000 and sum(sod.LineTotal) < 120000
				then sum(sod.LineTotal)*5/100
			 else sum(sod.LineTotal) end as 'Discount'
		from Sales.SalesOrderHeader as soh
		join Sales.SalesOrderDetail as sod on soh.SalesOrderID=sod.SalesOrderID
		group by soh.SalesOrderID

commit transaction

--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
--cung cấp sản phẩm 4 với số lượng là 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

begin transaction
	declare @mancc int, @masp int, @soluongcc int;
	set @mancc = 1650;
	set @masp = 4;
	
	select @soluongcc=pv.OnOrderQty 
		from Purchasing.ProductVendor as pv
		where pv.BusinessEntityID=@mancc and pv.ProductID=@masp
	if (@soluongcc is null)
		begin
			print N'Nhà cung cấp '+CAST(@mancc as varchar)
			+N' không cung cấp sản phẩm '+CAST(@masp as varchar)
		end
	else 
		begin
			print N'Nhà cung cấp '+CAST(@mancc as varchar)+'cung cấp sản phẩm '
			+CAST(@masp as varchar)+'với số lượng là '+CAST(@soluongcc as varchar)
		end
commit transaction

select * from Purchasing.ProductVendor as pv


--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%,
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.

WHILE (SELECT SUM(rate) FROM
	[HumanResources].[EmployeePayHistory])<6000
	BEGIN
		UPDATE [HumanResources].[EmployeePayHistory]
		SET rate = rate*1.1
		IF (SELECT MAX(rate)FROM
		[HumanResources].[EmployeePayHistory]) > 150
			BREAK
		ELSE
			CONTINUE
	END

--
select * from HumanResources.EmployeePayHistory

-- C2
DECLARE @totalRate DECIMAL(10,2);
SET @totalRate = (SELECT SUM(Rate) FROM [HumanResources].[EmployeePayHistory]);

IF @totalRate < 6000
BEGIN
    UPDATE [HumanResources].[EmployeePayHistory]
    SET Rate = Rate * 1.1 -- Tăng lương giờ lên 10%
    WHERE Rate <= 150; -- Chỉ tăng lương giờ cho nhân viên có mức lương <= 150

    -- Kiểm tra nếu lương giờ cao nhất của nhân viên > 150 thì rollback và hiển thị thông báo
    IF (SELECT MAX(Rate) FROM [HumanResources].[EmployeePayHistory]) > 150
		BEGIN
			PRINT N'Không thể thực hiện tăng lương giờ vì lương giờ cao nhất của nhân viên > 150.';
			ROLLBACK;
		END
    ELSE
		BEGIN
			COMMIT;
		END
	END
	ELSE
	BEGIN
    PRINT N'Không cần thực hiện tăng lương giờ vì tổng lương giờ của tất cả nhân viên >= 6000.';
END