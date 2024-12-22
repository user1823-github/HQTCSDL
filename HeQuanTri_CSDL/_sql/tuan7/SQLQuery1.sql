--6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
-- Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader

use AdventureWorks2008R2
create table M_SalesPerson (
	SalePSID int not null primary key,
	TerritoryID int,
	BonusPS money
)

create table M_SalesOrderHeader (
	SalesOrdID int not null primary key,
	OrderDate date,
	SubTotalOrd money,
	SalePSID int foreign key references M_SalesPerson(SalePSID)
)

-- Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
--những field tương ứng với 2 bảng mới tạo.
insert M_SalesPerson 
select sp.BusinessEntityID, sp.TerritoryID, sp.Bonus from Sales.SalesPerson sp

insert M_SalesOrderHeader
select soh.SalesOrderID, soh.OrderDate, soh.SubTotal, soh.SalesPersonID 
from Sales.SalesOrderHeader soh 


select * from M_SalesPerson
select * from M_SalesOrderHeader

-- Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.
go
alter trigger tg_UpdateBonus_M_SalesPerson 
on M_SalesOrderHeader
after insert
as
	declare @SalesPersonID int, @SubTotal money
	select @SalesPersonID=i.SalePSID, @SubTotal=i.SubTotalOrd from inserted i

	if (@SubTotal > 10000000)
	begin
		update M_SalesPerson
		set BonusPS += BonusPS * (10.0/100)
		where SalePSID=@SalesPersonID
	end
	else
	begin
		print ('Gia tri nhap vao phai > 10000000')
		rollback tran
	end

-- Exec
insert M_SalesOrderHeader
values (75138, '2023-04-04', 10000000, 277)

-- Kiem tra du lieu vua Insert Vao
select * from M_SalesOrderHeader
order by SalesOrdID desc

-- Kiem tra lai Bonus
select * from M_SalesPerson
order by SalePSID

