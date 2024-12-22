SET TRANSACTION ISOLATION
LEVEL READ COMMITTED

select * from Accounts
where AccountID=101

-- B2: Client A cập nhật account trên AccountID =101, balance =1000-200
update Accounts
set balance=1000-200
where AccountID=101

-- B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
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

-- B2: Client A cập nhật accounts trên AccountID =101, balance =1000-200
update Accounts
set balance=1000-200
where AccountID=101

--B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
select * from Accounts
where AccountID=101

--không thể đọc được dữ liệu
--đã được hiệu chỉnh nhưng chưa commit bởi các transaction khác và không có
--transaction khác có thể hiệu chỉnh dữ liệu đã được đọc bởi các giao dịch hiện tại cho
--đến transaction hiện tại hoàn thành
-- Kết quả ta thấy ở clientA balance vẫn = 800 mặc dù ở clientB đã trừ đi 500

--5) Giả sử có 2 giao dịch chuyển tiền từ tài khoản 101 và 202 như sau:
-- Client A chuyển 100$ từ tài khoản 101 sang 202
-- Client B chuyển 200$ từ tài khoản 202 sang 101.
--Viết các lệnh tương ứng ở 2 client để kiểm soát các giao dịch xảy ra đúng
begin transaction
	declare @from_account int = 101
	declare @to_account int = 202
	declare @amount int = 100

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

--B1: Client A: cập nhật balance của account giảm đi 100 cho AccountID =101,
--cập nhật balance của account tăng lên 100 cho AccountID =202
update Accounts
set balance -= 100 where AccountID=101

update Accounts
set balance += 100 where AccountID=202

--B3: Client A:
ROLLBACK;
SELECT * FROM Accounts;
COMMIT;

-- Báo lỗi vì phải bắt đầu bằng BEGIN TRANSACTION

--7) Xóa tất cả dữ liệu của bảng Account, thêm lại các dòng mới
--B1: Client A: thiết lập ISOLATION LEVEL REPEATABLE READ;
--Lấy ra các Accounts có Balance>1000

set transaction ISOLATION LEVEL REPEATABLE READ;

select * from Accounts 
where balance>1000

--B3: Client A:
SELECT * FROM Accounts WHERE balance > 1000;
COMMIT;

--Lỗi vì thiếu begin transaction để bắt đầu câu lệnh