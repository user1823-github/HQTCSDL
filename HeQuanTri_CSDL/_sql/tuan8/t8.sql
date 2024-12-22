-- Tuần 8
--Module 6. ROLE - PERMISSION
--1) Đăng nhập vào SQL bằng SQL Server authentication, tài khoản sa. Sử dụng TSQL.
use master

exec sp_addlogin 'sa', '123456'
--2) Tạo hai login SQL server Authentication User2 và User3
create login User2 with password = '123'
create login User3 with password = '456'

--3) Tạo một database user User2 ứng với login User2 và một database user User3
--ứng với login User3 trên CSDL AdventureWorks2008.
use AdventureWorks2008R2
create user User2 for login User2
create user User3 for login User3

--4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các
--thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực
--hiện được không?
-- Tiến hành đổi connect đến các tài khoản đã tạo ở trên sau đó
-- thựch hiện truy vấn dữ liệu
select * from Sales.SalesOrderDetail

--5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select
--trên Employee cho User2. Ngắt 2 kết nối của User2 và User3
grant select on [HumanResources].[Employee] to User2
revoke select on [HumanResources].[Employee] from User2

--6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
--CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
--Employee_Role.
use AdventureWorks2008R2
go
create role Employee_Role
grant select, update, delete on [HumanResources].[Employee] to Employee_Role

--7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông
--qua login User2 và User3 thực hiện các thao tác sau:
--a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng
--Employee
--login sa
USE AdventureWorks2008;
GO
use master
EXECUTE AS user = 'User2';
GO

exec as login = 'sa' with password = '123456';
select * from HumanResources.Employee

-- Thêm User2 và User3 vào role này
exec sp_addrolemember 'Employee_Role', 'User2'
exec sp_addrolemember 'Employee_Role', 'User3'

--login User2
exec as login = 'User2' with password = '123';
select * from HumanResources.Employee

--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
--viên có BusinessEntityID=1

--login User3
exec as login = 'User3' with password = '456';
update HumanResources.Employee
set JobTitle='Sale Manager'
where BusinessEntityID=1

-- Kiểm tra
select * from HumanResources.Employee
where BusinessEntityID=1

SELECT CURRENT_USER

--c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
--login User2
exec as login = 'User2' with password = '123';

select * from HumanResources.Employee
where BusinessEntityID=1

--d) Xóa role Employee_Role, (quá trình xóa role ra sao?)
drop role Employee_Role

--Muốn xoá được thì phải xoá các member ra khỏi role
exec sp_droprolemember 'Employee_Role', 'User2'
exec sp_droprolemember 'Employee_Role', 'User3'

-- Kiểm tra xem User này còn tồn tại trong role này không
EXEC sp_helprolemember 'Employee_Role';


-- module 7: transaction -------
use AdventureWorks2008R2

--1) Thêm vào bảng Department một dòng dữ liệu tùy ý bằng câu lệnh
--INSERT..VALUES…
--a) Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng
--cách thực hiện lệnh Begin tran và Rollback, dùng câu lệnh Select * From
--Department xem kết quả.
begin tran
	insert into HumanResources.Department(Name, GroupName)
		values ('Infomation2', 'Technology')
rollback tran

select * from HumanResources.Department

--b) Thực hiện câu lệnh trên với lệnh Commit và kiểm tra kết quả
begin tran
	insert into HumanResources.Department(Name, GroupName)
	values ('Infomation2', 'Technology')
commit tran


select * from HumanResources.Department

--2) Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS
--ON). Tạo đoạn batch gồm các thao tác:
SET IMPLICIT_TRANSACTIONS ON

-- Thêm một dòng vào bảng Department
-- Tạo một bảng Test (ID int, Name nvarchar(10))
-- Thêm một dòng vào Test
-- ROLLBACK;
-- Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết
--quả.
begin tran
	insert into HumanResources.Department(Name, GroupName)
	values ('Infomation3', 'Technology')

	--Tạo một bảng Test (ID int, Name nvarchar(10))
	create table Test (
		ID int,
		Name nvarchar(10)
	)

	--Thêm một dòng vào Test
	insert into Test (ID, Name)
	values (1, 'test1')

	--ROLLBACK;
rollback

	--	Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết
	--quả.
	select * from HumanResources.Department
	select * from Test

-- Vì sau khi chèn vao bảng HumanResources.Department, tạo bảng Test và
-- chèn vào sau đó bạn đã rollback nên các lệnh trên sẽ hoàn tác lại
-- nên ta không thấy bảng được chèn và tạo

--3) Viết đoạn batch thực hiện các thao tác sau (lưu ý thực hiện lệnh SET
--XACT_ABORT ON: nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn bộ giao
--dịch được chấm dứt và Rollback)
-- Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
-- Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này
--không tồn tại)
-- Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
-- Thêm một dòng bất kỳ vào bảng Department
-- COMMIT;
--Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.
SET XACT_ABORT ON

begin tran
	--Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
	select 1/0 as Dummy
	
	--Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này
	--không tồn tại)
	update HumanResources.Department
	set Name='ABC' where DepartmentID=9

	--Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
	delete from HumanResources.Department
	where DepartmentID=66

	--Thêm một dòng bất kỳ vào bảng Department
	insert into HumanResources.Department(Name, GroupName)
	values ('market', 'marketingGroup')

	--COMMIT;
	COMMIT;

	--Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.
--Giải thích: Thông báo lỗi sẽ là: "Divide by zero error encountered".
--có nghĩa là chương trình đã cố gắng thực hiện phép chia cho số 0. Trong SQL Server, 
--việc chia cho số 0 sẽ gây ra lỗi runtime và giao dịch sẽ bị gián đoạn nếu không được xử lý đúng.

--4) Thực hiện lệnh SET XACT_ABORT OFF (những câu lệnh lỗi sẽ rollback,
--transaction vẫn tiếp tục) sau đó thực thi lại các thao tác của đoạn batch ở câu 3. Quan
--sát kết quả và giải thích kết quả?
SET XACT_ABORT OFF

begin tran
	--Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
	select 1/0 as Dummy
	
	--Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này
	--không tồn tại)
	update HumanResources.Department
	set Name='ABC' where DepartmentID=9

	--Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
	delete from HumanResources.Department
	where DepartmentID=66

	--Thêm một dòng bất kỳ vào bảng Department
	insert into HumanResources.Department(Name, GroupName)
	values ('market', 'marketingGroup')

	--COMMIT;
	COMMIT;

--Giải thích: Câu lệnh select 1/0 as Dummy vẫn bị lỗi tuy nhiên các câu lệnh phía sau
--vẫn đúng nên vẫn thực thi được



