use AdventureWorks2008R2

create table M_Department (
	DepartmentID int not null primary key, 
	Name nvarchar(50),
	GroupName nvarchar(50)
)

create table M_Employees (
	EmployeeID int not null primary key, 
	Firstname nvarchar(50),
	MiddleName nvarchar(50), 
	LastName nvarchar(50),
	DepartmentID int foreign key references M_Department(DepartmentID)
)

--  Tạo  một  view  tên  EmpDepart_View  bao  gồm  các  field:  EmployeeID,
--FirstName,  MiddleName,  LastName,  DepartmentID,  Name,  GroupName,  dựa 
--trên 2 bảng M_Employees và  M_Department.
go
create view EmpDepart_View
AS 
	select EmployeeID, Firstname, MiddleName, LastName, me.DepartmentID, Name, GroupName 
	from M_Employees me inner join M_Department md
	on me.DepartmentID=md.DepartmentID
go

select * from EmpDepart_View

--  Tạo  một  trigger  tên  InsteadOf_Trigger  thực  hiện  trên  view
--EmpDepart_View,  dùng  để  chèn  dữ  liệu  vào  các  bảng  M_Employees  và 
--M_Department khi chèn một record mới thông qua view EmpDepart_View
go
alter trigger InsteadOf_Trigger
on EmpDepart_View
instead of insert
as 
	if not exists (select * from M_Department d join inserted i 
					on i.DepartmentID=d.DepartmentID
				  )
	begin
		insert into M_Department
		select DepartmentID, i.Name, i.GroupName from inserted i
	end
	
	insert into M_Employees
	select i.EmployeeID, i.Firstname, i.MiddleName, i.LastName, i.DepartmentID 
	from inserted i
go

insert EmpDepart_View
values (1, 'Nguyen', 'Thanh', 'Phat', 10, 'CNTT', 'Technical')

insert EmpDepart_View
values (2, 'Pham', 'Van', 'Doan', 10, 'Kinh doanh', 'Sale')


select * from M_Department
select * from M_Employees

--2.  Tạo một trigger thực hiện trên bảng  MSalesOrders có chức năng thiết lập độ ưu 
--tiên của  khách hàng (CustPriority) khi người dùng thực hiện các thao tác  Insert, 
--Update và Delete trên bảng MSalesOrders theo điều kiện như  sau:
--  Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của 
--khách hàng (CustPriority) là 3
--  Nếu tổng tiền  Sum(SubTotal)  của khách hàng từ 10,000 $ đến dưới 50000  $ 
--thì độ ưu tiên của khách hàng (CustPriority) là  2
--  Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000  $ trở lên thì độ ưu tiên 
--của khách hàng (CustPriority) là 1

create table  MCustomer (
	CustomerID int not null primary key, 
	CustPriority int 
)

create table MSalesOrders (
	SalesOrderID int not null primary key, 
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID)
)

