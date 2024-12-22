--###########--
--Chuẩn bị-----
create database abc
go
use abc
go
create table Accounts 
(AccountID int NOT NULL PRIMARY KEY,
balance int NOT NULL
CONSTRAINT unloanable_account CHECK (balance >= 0) )
go
sp_helpconstraint 'accounts'
go
----refresh data
truncate table Accounts
select * from Accounts
INSERT INTO Accounts (AccountID,balance) VALUES (101,1000);  
INSERT INTO Accounts (AccountID,balance) VALUES (202,1000); 
select * from Accounts
go 
--##############################################--
--Hiểu về  SET TRANSACTION ISOLATION LEVEL  ?
--có 4 mức bảo vệ : 
--READ UNCOMMITTED 
--READ COMMITTED  
--REPEATABLE READ
--SERIALIZABLE 

-------------------------------------------------
----Client A
-------------------------------------------------
--VD1: READ UNCOMMITTED => không gây Lost Updated 
go
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--Cho phép một transaction có thể đọc dữ liệu đang được cập
--nhật bởi transaction khác trước khi transaction hoàn tất
--– Mức bảo vệ thấp nhất , nguy cơ xảy ra dirty read
go
--start transaction
BEGIN TRAN
update Accounts
set balance = balance -500
where AccountID = 101
go
waitfor delay '00:00:10'     

COMMIT TRAN
--end transaction
select * from Accounts
--------------------------------------------
--VD2 : READ UNCOMMITTED => gây lỗi Dirty read
go
--Transaction không lock :
 --cho phép transaction khác đọc dữ liệu đang
 -- update mà chưa commit
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
go
BEGIN TRAN
update Accounts
set balance = balance -500
where AccountID = 101
go
waitfor delay '00:00:10' 

ROLLBACK
go
select * from Accounts 

--------------------------------------------
--VD3: READ COMMITTED => khắc phục lỗi Dirty Read (VD2)
go
SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
--Không cho phép một transaction đọc dữ liệu mà transaction 
--khác đang update chưa hoàn tất
go
BEGIN TRAN
update Accounts
set balance = balance -500
where AccountID = 101
go
waitfor delay '00:00:10' 

ROLLBACK
go
select * from Accounts 

-----------------------------------------
--VD4: READ COMMITTED => gây lỗi UnRepeatable Read

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
go
BEGIN TRAN
select * from Accounts  where AccountID = 101
go


waitfor delay '00:00:10' 
select * from Accounts where AccountID = 101
COMMIT


-----------------------------------------------
--VD5: REPEATABLE READ  => khắc phục lỗi UnRepeatable Read
-- Không cho phép một transaction update dữ liệu khi
--một transaction khác đang đọc
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
go
BEGIN TRAN
select * from Accounts  where AccountID = 101
go

waitfor delay '00:00:10' 
select * from Accounts where AccountID = 101
COMMIT
use AdventureWorks2008R2


use master

------------------------------------------------
--VD6: REPEATABLE READ => gây lỗi Phantom Read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
go
Begin tran
select * from Accounts 



select * from Accounts 
Commit

------------------------------------------------
--VD7: SERIALIZABLE => khắc phục lỗi Phantom Read 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
go
Begin tran
select * from Accounts 



select * from Accounts 
Commit
-------------------------------------------------





