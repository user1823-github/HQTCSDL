SET TRANSACTION ISOLATION
LEVEL READ COMMITTED

select * from Accounts
where AccountID=101

-- B3: Client B cập nhật account trên AccountID =101, balance =1000-500
update Accounts
set balance=1000-500
where AccountID=101

-- B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT;
select * from Accounts
where AccountID=101;
commit;

--Thông báo lỗi "The COMMIT TRANSACTION request has no corresponding 
--BEGIN TRANSACTION" có nghĩa là chương trình cố gắng kết thúc một giao dịch mà 
--không có giao dịch nào được bắt đầu trước đó bằng lệnh BEGIN TRANSACTION.

--Trong SQL Server, mỗi giao dịch phải bắt đầu bằng lệnh BEGIN TRANSACTION và kết 
--thúc bằng lệnh COMMIT hoặc ROLLBACK để xác nhận các thao tác trong giao dịch đó 
--có được lưu trữ (nếu sử dụng COMMIT) hoặc hủy bỏ (nếu sử dụng ROLLBACK).

--4) Thiết lập ISOLATION LEVEL REPEATABLE READ (không thể đọc được dữ liệu
--đã được hiệu chỉnh nhưng chưa commit bởi các transaction khác và không có
--transaction khác có thể hiệu chỉnh dữ liệu đã được đọc bởi các giao dịch hiện tại cho
--đến transaction hiện tại hoàn thành) ở 2 client. Thực hiện yêu cầu sau:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với
--AccountID =101
select * from Accounts
where AccountID=101

-- B3: Client B cập nhật accounts trên AccountID =101, balance =1000-500
update Accounts
set balance=1000-500
where AccountID=101

--5) Giả sử có 2 giao dịch chuyển tiền từ tài khoản 101 và 202 như sau:
-- Client A chuyển 100$ từ tài khoản 101 sang 202
-- Client B chuyển 200$ từ tài khoản 202 sang 101.
--Viết các lệnh tương ứng ở 2 client để kiểm soát các giao dịch xảy ra đúng

begin transaction
	declare @from_account int = 202
	declare @to_account int = 101
	declare @amount int = 200

begin try
	if(select balance from Accounts where AccountID=@from_account) < 100
		begin
			print 'Số tiền trong tài khoản nguồn không đủ'
			return;
		end

	update Accounts
	set balance -= @amount
	where AccountID=@from_account

	update Accounts 
	set balance += @amount
	where AccountID=@to_account

	commit tran
end try
begin catch
	rollback transaction
	print error_message();
end catch

--6) Xóa tất cả dữ liệu của bảng Accounts. Thêm lại các dòng mới
--B2: Client B: thiết lập 
set transaction ISOLATION LEVEL READ UNCOMMITTED
SELECT * FROM Accounts;
COMMIT;

--B2: Client B:
INSERT INTO Accounts (AccountID ,balance) 
VALUES (303,3000);
COMMIT;

--Lỗi vì thiếu begin transaction để bắt đầu câu lệnh

