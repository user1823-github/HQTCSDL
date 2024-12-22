----1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 
--theo cấu trúc sau:
use AdventureWorks2008R2
create table MyDepartment (
	DepID smallint not null primary key,
	DepName nvarchar(50),
	GrpName nvarchar(50)
)

create table MyEmployee (
	EmpID int not null primary key,
	FirstName nvarchar(50),
	MidName nvarchar(50),
	LastName nvarchar(50),
	DepID smallint not null foreign key references MyDepartment(DepID)
)

--2) Dùng lệnh insert <TableName1> select <fieldList> from
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
--bảng [HumanResources].[Department].
insert MyDepartment 
select d.DepartmentID, d.Name, d.GroupName
	from HumanResources.Department as d

select * from MyDepartment



--3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
--từ 2 bảng
--[Person].[Person] và
--[HumanResources].[EmployeeDepartmentHistory]
insert MyEmployee
select top 20 p.BusinessEntityID, p.FirstName, p.MiddleName, 
	p.LastName, edh.DepartmentID
	from Person.Person as p
	join HumanResources.EmployeeDepartmentHistory as edh
	ON p.BusinessEntityID=edh.BusinessEntityID
	where edh.DepartmentID=1

select * from MyEmployee

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
--có thực hiện được không? Vì sao?      dasdad
delete from MyDepartment 
where DepID=1

select * from MyEmployee
where DepID=1

-- Không xoá được vì ràng buộc về khoá ngoại trong cột DepID tới bảng MyEmployee

--5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
--với giá trị mặc định là 1.
alter table MyEmployee
add constraint ck_DepID default 1 for DepID

--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
--insert into MyEmployee (EmpID, FrstName, MidName,
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
--trong field depID của record mới thêm.
insert into MyEmployee (EmpID, FirstName, MidName, LastName)
values (1, 'Nguyen', 'Nhat', 'Nam')

select * from MyEmployee
where DepID=1


--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
--delete set default.
-- Lệnh này để xem tên của ràng buộc foreign key
SELECT name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('MyEmployee')
AND referenced_object_id = OBJECT_ID('MyDepartment')

alter table MyEmployee
drop constraint "FK__MyEmploye__DepID__6497E884"
alter table MyEmployee
add constraint ck_FK_DepID_MyEmployee 
foreign key (DepID)
references MyDepartment(DepID)
on delete set default 

--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
--trong hai bảng MyEmployee và MyDepartment
delete from MyDepartment
where DepID=7

select * from MyDepartment
select * from MyEmployee

--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
--ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
--cascade và on update cascade
alter table MyEmployee
drop constraint ck_FK_DepID_MyEmployee

alter table MyEmployee
add constraint ck_FK_DepID foreign key (DepID) references MyDepartment(DepID)
on delete cascade

alter table MyEmployee 
add constraint ck2_FK_DepID foreign key (DepID) references MyDepartment(DepID)
on update cascade

--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
--thực hiện được không?
delete from MyDepartment
where DepID=3
-- thực hiện được
select * from MyDepartment


--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturing
alter table MyDepartment
add constraint ck_GrpName check (GrpName = ('Manufacturing'))

--Vì trong trong này đã có chứa nhiều dữ liệu khác với 'Manufacturing' 
--nên ta phải thay đổi dữ liệu một chút để có thể thêm ràng buộc này vào

update MyDepartment
set GrpName='Manufacturing'

select * from MyDepartment

-- Thực hiện lại
alter table MyDepartment
add constraint ck_GrpName check (GrpName = ('Manufacturing'))


--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60
select * from HumanResources.Employee
update HumanResources.Employee
set BirthDate='2000-02-20' 

alter table HumanResources.Employee
add constraint ck_Emp_Age 
check (datediff(year, BirthDate, getdate()) between 18 and 60)

--SELECT name
--FROM sys.check_constraints
--WHERE parent_object_id = OBJECT_ID('HumanResources.Employee') 
--AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('HumanResources.Employee'), 'BirthDate', 'ColumnId')

--ALTER TABLE HumanResources.Employee 
--NOCHECK CONSTRAINT CK_Employee_BirthDate

--ALTER TABLE HumanResources.Employee 
--WITH CHECK CHECK CONSTRAINT CK_Employee_BirthDate

-- Module 3: VIEW

--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
create view dbo.vw_Products
as (select p.ProductID, Name, Color, Size, Style, p.StandardCost, EndDate, StartDate
	from Production.Product as p
	join Production.ProductCostHistory as pch on p.ProductID=pch.ProductID)

select top 5 * from dbo.vw_Products

--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal
create view dbo.List_Product_View
as select sod.ProductID, p.Name, count(sod.OrderQty) as CountOfOrderID, 
	sum(soh.SubTotal) as SubTotal
	from Sales.SalesOrderDetail sod 
	join Production.Product p
	on sod.ProductID=p.ProductID
	join Sales.SalesOrderHeader soh
	on sod.SalesOrderID=soh.SalesOrderID
	where datepart(quarter, soh.OrderDate)=1 and year(soh.OrderDate)=2008
	group by sod.ProductID, p.Name
	having sum(soh.SubTotal)>10000 and count(soh.SalesOrderID)>500

select * from [dbo].[List_Product_View]

drop view List_Product_View
sp_helptext 'List_Product_View'

-- 3). Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).
create view dbo.vw_CustomerTotals
as (select soh.CustomerID, year(soh.OrderDate) as OrderYear
	, month(soh.OrderDate) as OrderMonth, sum(soh.TotalDue) as SumTotalDue
	from Sales.SalesOrderHeader as soh 
	group by soh.CustomerID, year(soh.OrderDate), month(soh.OrderDate))

select  * from dbo.vw_CustomerTotals

--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
create view vw_Pur_Sum_Product
as (select sp.BusinessEntityID, year(soh.OrderDate) as OrderYear
	, sum(sod.OrderQty) as sumOfOrderQty
	from Sales.SalesPerson as sp
	join Sales.SalesOrderHeader as soh on sp.BusinessEntityID=soh.SalesPersonID
	join Sales.SalesOrderDetail as sod on sod.SalesOrderID=soh.SalesOrderID
	group by sp.BusinessEntityID, year(soh.OrderDate))

select * from Sales.SalesPerson
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

select * from dbo.vw_Pur_Sum_Product

--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
use AdventureWorks2008R2
create view ListCustomer_view
as (select c.PersonID, p.FirstName+' '+ p.LastName as FullName, 
	count(soh.SalesOrderID) as CountOfOrders
	from Sales.Customer as c
	join Sales.SalesOrderHeader as soh on soh.CustomerID=c.CustomerID
	join Person.Person as p
	on p.BusinessEntityID=c.PersonID
	join Sales.SalesOrderHeader as sod on sod.SalesOrderID=soh.SalesOrderID
	where year(soh.OrderDate) between 2007 and 2008
	group by c.PersonID, p.FirstName, p.LastName
	having count(soh.SalesOrderID)>25)

select * from dbo.ListCustomer_view

select * from Person.Person

--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
create view ListProduct_view
as (select p.ProductID, p.Name, sum(sod.OrderQty) as CountOfOrderQty, 
	   year(soh.OrderDate) as [Year]
	   from Production.Product as p
	   join Sales.SalesOrderDetail as sod ON p.ProductID=sod.ProductID
	   join Sales.SalesOrderHeader as soh ON sod.SalesOrderID=soh.SalesOrderID
	   where p.Name like 'Bike%' or p.Name like 'Sport%' 
	   group by p.ProductID, p.Name, year(soh.OrderDate)
	   having sum(sod.OrderQty)>50)

select * from dbo.ListProduct_view

--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
create view List_department_View
as (select d.DepartmentID, d.Name, avg(eph.Rate) as AvgOfRate
	   from HumanResources.Department as d
	   join HumanResources.EmployeeDepartmentHistory as edh
	   ON d.DepartmentID=edh.DepartmentID
	   join HumanResources.EmployeePayHistory as eph
	   ON edh.BusinessEntityID=eph.BusinessEntityID
	   group by d.DepartmentID, d.Name
	   having avg(eph.Rate) > 30)

select * from dbo.List_department_View

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
create view Sales.vw_OrderSummary
with encryption
as (select year(soh.OrderDate) as OrderYear, 
	month(soh.OrderDate) as OrderMonth, soh.SubTotal as OrderTotal
	from Sales.SalesOrderHeader as soh
	group by year(soh.OrderDate), month(soh.OrderDate), soh.SubTotal)

sp_helptext 'Sales.vw_OrderSummary'

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
create view Production.vwProducts
with schemabinding
as (select p.ProductID, p.Name, pch.StartDate, pch.EndDate, p.ListPrice
	from Production.Product as p 
	join Production.ProductCostHistory as pch
	on p.ProductID=pch.ProductID)

select * from Production.vwProducts

-- Kô xoá được vì này là 1 view chứ không phải là 1 table
alter table Production.vwProducts
drop column ListPrice

--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
--c. Dùng câu lệnh Select xem kết quả trong bảng Department
create view view_Department
as (select d.DepartmentID, d.Name, d.GroupName
	from HumanResources.Department as d
	where d.GroupName like'%Manufacturing%'or d.GroupName like'%Quality%'or
	d.GroupName like '%Assurance%')
with check option

select * from view_Department

-- a).
insert into view_Department(DepartmentID, Name, GroupName)
values (19, 'Production xyz', 'Manufacturing')
--View với WITH CHECK OPTION chỉ cho phép cập nhật các hàng 
--trong bảng nếu chúng đáp ứng điều kiện được xác định trong 
--câu lệnh SELECT của view. Tuy nhiên, nếu bảng chứa một cột identity, 
--bạn không thể chèn giá trị rõ ràng cho cột đó trong câu lệnh INSERT, 
--vì giá trị identity sẽ được tạo ra tự động bởi hệ thống.

set identity_insert HumanResources.Department on

-- b).
insert into view_Department(DepartmentID, Name, GroupName)
values (17, 'Product text', 'Manufacturing')
insert into view_Department(DepartmentID, Name, GroupName)
values (18, 'Product abc', 'Quality Assurance')

-- c). 
select * from HumanResources.Department
