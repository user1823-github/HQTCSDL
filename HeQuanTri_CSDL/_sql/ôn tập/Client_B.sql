use abc
go
-------------------------------------------------
----Client B
-------------------------------------------------
--VD1: READ UNCOMMITTED => không gây Lost Updated 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
go
BEGIN TRAN
update Accounts
set balance = balance + 2000
where AccountID = 101
COMMIT
go
select * from Accounts
-----------------------------------------------
--VD2: READ UNCOMMITTED -> gây lỗi Dirty Read
go
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
go
BEGIN TRAN
select * from Accounts 
COMMIT

-----------------------------------------------
--VD3: READ COMMITTED => khắc phục lỗi Dirty Read (VD2)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
go
BEGIN TRAN
select * from Accounts 
COMMIT


---------------------------------------
--VD4: READ COMMITTED => gây lỗi UnRepeatable Read
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
go
BEGIN TRAN
update Accounts
set balance = balance + 2000
where AccountID = 101
COMMIT
select * from Accounts where AccountID = 101

---------------------------------------
--VD5: REPEATABLE READ  => khắc phục lỗi UnRepeatable Read, Dirty Read 
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
go
BEGIN TRAN
update Accounts
set balance = balance + 2000
where AccountID = 101
COMMIT
go
select * from Accounts where AccountID = 101

------------------------------------------------
--VD6: REPEATABLE READ => gây lỗi Phantom Read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
go
Begin tran
INSERT INTO Accounts VALUES (303,2000)
Commit

------------------------------------------------
--VD7: SERIALIZABLE => khắc phục lỗi Phantom Read, UnRepeatable Read, Dirty Read 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
go
Begin tran
INSERT INTO Accounts VALUES (606,2000)
Commit

------------------------------------------------