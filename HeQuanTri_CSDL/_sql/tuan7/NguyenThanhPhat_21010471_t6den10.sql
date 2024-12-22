-- Tuần 7: Trigger

--1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
use AdventureWorks2008R2

go
create table M_Department (
	DepartmentID int not null primary key,
	Name nvarchar(50),
	GroupName nvarchar(50)
)

go
create table M_Employees (
	EmployeeID int not null primary key,
	Firstname nvarchar(50),    
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references M_Department(DepartmentID)
)
go
-- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
--trên 2 bảng M_Employees và M_Department.
go
create view EmpDepart_View 
as (
	select e.EmployeeID, e.Firstname, e.MiddleName, 
		e.LastName, e.DepartmentID, d.Name, d.GroupName
		from M_Employees as e join M_Department as d ON e.DepartmentID=d.DepartmentID
)

select * from EmpDepart_View

-- Tạo Trigger

-- Tạo một trigger tên InsteadOf_Trigger thực hiện trên view
--EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và
--M_Department khi chèn một record mới thông qua view EmpDepart_View.
--Lưu ý chỉ instead of mới áp dụng dc trên view với table còn after/for áp dụng trên table
go
create trigger InsteadOf_Trigger on EmpDepart_View
instead of insert
as 
	if not exists (select * from inserted i join M_Department d 
					on i.DepartmentID=d.DepartmentID)
	begin
		insert M_Department
		select i.DepartmentID, i.Name, i.GroupName from inserted i
	end

	insert M_Employees
	select i.EmployeeID, i.Firstname, i.MiddleName, i.LastName, i.DepartmentID 
	from inserted i
go

-- Exec
insert EmpDepart_View 
values (1, 'Nguyen', 'Hoang', 'Huy', 11, 'Marketing', 'Sales')

insert EmpDepart_View 
values (2, 'Nguyen', 'Hoang', 'Huy', 11, 'ABC', 'Sales')

select * from M_Department
select * from M_Employees

--2. 
create table MCustomer (
	CustomerID int not null primary key,
	CustPriority int
)

create table MSalesOrders (
	SalesOrderID int not null primary key,
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID)
)

--Tạo một trigger thực hiện trên bảng MSalesOrders có chức năng thiết lập độ ưu
--tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
--Update và Delete trên bảng MSalesOrders theo điều kiện như sau:
-- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
--khách hàng (CustPriority) là 3

-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $
--thì độ ưu tiên của khách hàng (CustPriority) là 2

-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
--của khách hàng (CustPriority) là 1
go
create trigger trigg_UpdateCustPriority on MSalesOrders
after insert, update, delete
as 
	declare @CustomerID int = (select i.CustomerID from inserted i)

	update MCustomer
	set CustPriority = rs.result from
		(select 'result' = 
		case 
			when sum(s.SubTotal)<10000 then 3
			when sum(s.SubTotal)>=10000 and sum(s.SubTotal)<50000 then 2
			else 1
		end
		from MCustomer c
		join 
			(select so.CustomerID, sum(so.SubTotal) as SubTotal
			from MSalesOrders so
			group by so.CustomerID) s
			on c.CustomerID=s.CustomerID
			group by s.CustomerID
		) rs
	where CustomerID=@CustomerID
go

-- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,
--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho
--giá trị null
go
insert MCustomer 
select c.CustomerID, null from Sales.Customer c
where c.CustomerID>30100 and c.CustomerID<30118
go

select * from Sales.Customer
select * from MCustomer

-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
--khách hàng.
go
insert MSalesOrders (SalesOrderID, OrderDate, SubTotal, CustomerID)
select soh.SalesOrderID, soh.OrderDate, soh.SubTotal, soh.CustomerID 
from Sales.SalesOrderHeader soh 
where soh.CustomerID in (select c.CustomerID from MCustomer c)
go

select * from MSalesOrders
select * from Sales.SalesOrderHeader

-- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted
go
create trigger trigg_GetInsertedDeleted on MSalesOrders
after insert, delete, update
as 
begin 
	select so.*, c.*
	from inserted as i 
	join MSalesOrders as so on i.SalesOrderID=so.SalesOrderID
	join MCustomer as c on so.CustomerID=c.CustomerID

	select so.*, c.*
	from deleted as d
	join MSalesOrders as so on d.SalesOrderID=so.SalesOrderID
	join MCustomer as c on so.CustomerID=c.CustomerID
end

--Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc
--xóa hoặc update một record trên bảng MSalesOrders

select * from MSalesOrders

delete MSalesOrders
where SalesOrderID=43661

--3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
--hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập
--nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng
--số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì
--hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
-- Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
create table MDepartment (
	DepartmentID int not null primary key,
	Name nvarchar(50),
	NumOfEmployee int
)

create table MEmployees (
	EmployeeID int not null,
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references MDepartment(DepartmentID),
	constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)

-- Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
--NumOfEmployee gán giá trị NULL, 
insert MDepartment (DepartmentID, Name, NumOfEmployee)
	select d.DepartmentID, d.Name, null as NumOfEmployee 
	from HumanResources.Department as d


--	bảng MEmployees lấy từ bảng EmployeeDepartmentHistory
insert MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
	select edh.BusinessEntityID, p.FirstName, p.MiddleName,
	p.LastName, edh.DepartmentID  
	from HumanResources.EmployeeDepartmentHistory as edh
	join Person.Person as p on edh.BusinessEntityID=p.BusinessEntityID

select * from MDepartment
select * from MEmployees

-- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger
go
create trigger trigg_MEmployees on MEmployees
after insert
as
	declare @DepartmentID int;
	declare @NumOfEmployee int;

	select @DepartmentID=i.DepartmentID from inserted i;
	select @NumOfEmployee=NumOfEmployee from MDepartment d
							 where d.DepartmentID=@DepartmentID;
	
	if @NumOfEmployee is null
		set @NumOfEmployee=1
	else
		set @NumOfEmployee += 1

	if (@NumOfEmployee <= 200)
		begin
			update MDepartment
			set NumOfEmployee = @NumOfEmployee
			where DepartmentID=@DepartmentID
		end
	else
		begin
			print N'Bộ phận đã đủ nhân viên'
			rollback tran
		end
go

-- Exec
insert into MEmployees (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
	values (291, 'Nguyen', 'Thanh', 'Phat', 3)
-- Kiểm tra
select * from MEmployees
where EmployeeID=291

--4. Bảng [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc tính
--CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị:
--1 = Superior
--2 = Excellent
--3 = Above average
--4 = Average
--5 = Below average
--Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng
--[Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị
--thông báo không cho phép chèn và đồng thời hủy giao tác.
go
create trigger trigg_Vender on Purchasing.PurchaseOrderHeader
instead of insert
as
	declare @vendorID int;
	declare @CreditRating int;

	select @vendorID = i.VendorID from inserted i
	select @CreditRating = v.CreditRating from Purchasing.Vendor v
						   where v.BusinessEntityID=@vendorID
	if (select v.CreditRating from Purchasing.Vendor v 
		where v.BusinessEntityID=@vendorID)=5
		begin
			print N'Nhông được phép chèn'
			rollback tran
		end
go

-- Exec
INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status,
		EmployeeID, VendorID, ShipMethodID, OrderDate, 
		ShipDate, SubTotal, TaxAmt, Freight) 
	VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55, 
			3567.564, 1114.8638 );

select * from [Purchasing].[PurchaseOrderHeader]
select * from Purchasing.Vendor

--5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng sản
--phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với
--số lượng xác định trong field OrderQty, nếu số lượng trong kho
--Quantity> OrderQty thì cập nhật lại số lượng trong kho
--Quantity= Quantity- OrderQty, ngược lại nếu Quantity=0 thì xuất
--thông báo “Kho hết hàng” và đồng thời hủy giao tác
go
create trigger trigg_ProductInventory on Production.ProductInventory
after insert
as 
	declare @OrderQty int;
	declare @Quantity int;
	declare @ProductID int;

	select @ProductID = i.ProductID from inserted i

	select @OrderQty = sod.OrderQty from Sales.SalesOrderDetail as sod
						where sod.ProductID=@ProductID

	select @Quantity = pdi.Quantity 
				from Production.ProductInventory as pdi
				where pdi.ProductID=@ProductID

	if (@Quantity> @OrderQty)
		begin
			update Production.ProductInventory
			set Quantity=@OrderQty-@OrderQty
			where ProductID=@ProductID
		end
	else if (@Quantity = 0)
		begin
			print N'Kho hết hàng'
			rollback tran
		end
go

select * from Sales.SalesOrderDetail
select * from Production.ProductInventory
select * from Production.Product

--6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
-- Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader

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
insert M_SalesPerson (SalePSID, TerritoryID, BonusPS)
	select sp.BusinessEntityID, sp.TerritoryID, sp.Bonus 
	from Sales.SalesPerson as sp

insert M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
	select soh.SalesOrderID, soh.OrderDate, soh.SubTotal, soh.SalesPersonID
	from Sales.SalesOrderHeader as soh

select * from M_SalesOrderHeader
select * from M_SalesPerson
-- Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.
go
create trigger tg_UpdateBonus_M_SalesPerson on M_SalesOrderHeader
after insert
as
begin
	declare @SalePSID int;
	declare @SubTotalOrd money;

	select @SalePSID = i.SalePSID from inserted i

	select @SubTotalOrd = soh.SubTotalOrd from M_SalesOrderHeader as soh 
						where soh.SalePSID=@SalePSID
	if(@SubTotalOrd > 10000000)
		begin
			update M_SalesPerson
			set BonusPS += BonusPS*10.0/100
			where SalePSID=@SalePSID
		end
end

-- Exec
go
insert into M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
values (75130, '2013-02-12', 11000000, 280)

select * from M_SalesOrderHeader where SalesOrdID=75130
--

select * from M_SalesPerson where SalePSID=280