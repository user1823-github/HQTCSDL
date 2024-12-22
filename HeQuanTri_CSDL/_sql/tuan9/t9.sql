-- Tuần 9
--II. CONCURRENT TRANSACTIONS (Các giao tác đồng thời)
--1) Tạo bảng Accounts (AccountID int NOT NULL PRIMARY KEY,
--balance int NOT NULL
--CONSTRAINT unloanable_account CHECK (balance >= 0)
--Chèn dữ liệu:
use AdventureWorks2008R2

create table Accounts (
	AccountID int not null primary key,
	balance int not null constraint unloanable_account check (balance >= 0)
)

INSERT INTO Accounts (AccountID,balance) VALUES (101,1000);
INSERT INTO Accounts (AccountID,balance) VALUES (202,2000);

--2) SET TRANSACTION ISOLATION LEVEL
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

--3) Mở 2 cửa sổ Query của SQL server, thiết lập SET TRANSACTION ISOLATION
--LEVEL READ COMMITTED ở cả 2 cửa sổ (tạm gọi là client A bên trái, và client B
--bên phải)

-- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts
--với AccountID =101
-- B2: Client A cập nhật account trên AccountID =101, balance =1000-200
-- B3: Client B cập nhật account trên AccountID =101, balance =1000-500
-- B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;

--4) Thiết lập ISOLATION LEVEL REPEATABLE READ (không thể đọc được dữ liệu
--đã được hiệu chỉnh nhưng chưa commit bởi các transaction khác và không có
--transaction khác có thể hiệu chỉnh dữ liệu đã được đọc bởi các giao dịch hiện tại cho
--đến transaction hiện tại hoàn thành) ở 2 client. Thực hiện yêu cầu sau:

--5) Giả sử có 2 giao dịch chuyển tiền từ tài khoản 101 và 202 như sau:
-- Client A chuyển 100$ từ tài khoản 101 sang 202
-- Client B chuyển 200$ từ tài khoản 202 sang 101.
--Viết các lệnh tương ứng ở 2 client để kiểm soát các giao dịch xảy ra đúng

--6) Xóa tất cả dữ liệu của bảng Accounts. Thêm lại các dòng mới
--INSERT INTO Accounts (AccountID ,balance) VALUES (101,1000);
--INSERT INTO Accounts (AccountID ,balance) VALUES (202,2000);
select * from Accounts
delete from Accounts where AccountID=101
delete from Accounts where AccountID=202

INSERT INTO Accounts (AccountID ,balance) VALUES (101,1000);
INSERT INTO Accounts (AccountID ,balance) VALUES (202,2000);

select * from Accounts

--7) Xóa tất cả dữ liệu của bảng Account, thêm lại các dòng mới
select * from Accounts
delete from Accounts where AccountID=101
delete from Accounts where AccountID=202

INSERT INTO Accounts (AccountID ,balance) VALUES (101,1000);
INSERT INTO Accounts (AccountID ,balance) VALUES (202,2000);


--Module 8: Bảo trì cơ sở dữ liệu -----
--1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục
--T:\backup\adv2008back.bak

backup database AdventureWorks2008R2 
to disk = 'D:\HK4\backup\adv2008back.bak'

--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi
--thực hiện full backup vào thiết bị backup vừa tạo
BACKUP DATABASE AdventureWorks2008R2
TO DISK = 'D:\HK4\backup\adv2008back.bak'
WITH FORMAT, 
NAME = 'Full Backup of AdventureWorks2008R2 database';

--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.
use AdventureWorks2008R2

begin tran
	declare @TotalBikeValue money
	declare @DiscountAmount money

	select @TotalBikeValue=sum(ListPrice*SafetyStockLevel)
		   from Production.Product
		   where ProductSubcategoryID=1

	if (@TotalBikeValue <= 0.6 * (
		select sum(ListPrice*SafetyStockLevel)
		   from Production.Product
		   where ProductSubcategoryID=1
	) )
		begin
			print 'tổng trị giá các mặt hàng xe đạp phải >= 60%'
		end
	else
		begin
			set @DiscountAmount = (select max(ListPrice-15) 
				from Production.Product where ProductSubcategoryID=1)
			update Production.Product
			set ListPrice = case
								when ProductSubcategoryID=1 and ListPrice>15 then 15
								else ListPrice
							end
			where ProductSubcategoryID=1
		end
commit transaction

--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup
backup database AdventureWorks2008R2
	to disk = 'D:\HK4\backup\adv8000R2diff.bak'
	with differential;

--b. Tạo 1 transaction log backup
backup log AdventureWorks2008R2
	to disk = 'D:\HK4\backup\adv8000R2log.trn'

--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6).
--Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup

delete from Person.EmailAddress

backup log AdventureWorks2008R2
	to disk = 'D:\HK4\backup\adv8000R2log5.trn'

--6. Thực hiện lệnh:
--a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như
--sau:
INSERT INTO Person.PersonPhone VALUES (10000,'123-456-
7890',1,GETDATE())

--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị
--backup vừa tạo.
backup database AdventureWorks2008R2
	to disk = 'D:\HK4\backup\adv2008R2diff6b.bak'
	with differential


--c. Chú ý giờ hệ thống của máy.
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
drop table Sales.ShoppingCartItem

--7. Xóa CSDL AdventureWorks2008R2
use master
drop database AdventureWorks2008R2

--8. Để khôi phục lại CSDL:
--a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào?
restore database AdventureWorks2008R2
	from disk = 'D:\HK4\backup\adv2008back.bak'
	with norecovery
--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
restore database AdventureWorks2008R2
	from disk = 'D:\HK4\backup\adv8000R2diff.bak'
	with norecovery
--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL
--AdventureWorks2008 ra sao?
restore database AdventureWorks2008R2
	from disk = 'D:\HK4\backup\adv2008R2diff6b.bak'
	with recovery

--9. Thực hiện đoạn lệnh sau:
CREATE DATABASE Plan2Recover;
USE Plan2Recover;

CREATE TABLE T1 (
	PK INT Identity PRIMARY KEY,
	Name VARCHAR(15)
);
GO

INSERT T1 VALUES ('Full');
GO

BACKUP DATABASE Plan2Recover
	TO DISK = 'D:\HK4\backup\P2R.bak'
	WITH NAME = 'P2R_Full', INIT;

--Tiếp tục thực hiện các lệnh sau:
INSERT T1 VALUES ('Log 1');
GO

use master

alter database Plan2Recover set recovery full

BACKUP Log Plan2Recover
	TO DISK ='D:\HK4\backup\P2R.bak'
	WITH NAME = 'P2R_Log';

--Tiếp tục thực hiện các lệnh sau:
use Plan2Recover
INSERT T1 VALUES ('Log 2');
GO

BACKUP Log Plan2Recover
	TO DISK ='D:\HK4\backup\P2R.bak'
	WITH NAME = 'P2R_Log';

--Xóa CSDL vừa tạo, rồi thực hiện quá trình khôi phục như sau:
Use Master;
RESTORE DATABASE Plan2Recover
	FROM DISK = 'D:\HK4\backup\P2R.bak'
	With FILE = 1, NORECOVERY;

RESTORE LOG Plan2Recover
	FROM DISK ='D:\HK4\backup\P2R.bak'
	With FILE = 2, NORECOVERY;

RESTORE LOG Plan2Recover
	FROM DISK ='D:\HK4\backup\P2R.bak'
	With FILE = 3, RECOVERY;


