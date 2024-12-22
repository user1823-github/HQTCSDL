-- Phần 1
create database SmallWorks
on primary (
	name='SmallWorksPrimary',
	filename='D:\NguyenThanhPhat\SmallWorks.mdf',
	size=10MB,
	maxsize=50MB,
	filegrowth=20%
),
filegroup SWUserData1 (
	name='SmallWorksData1',
	filename='D:\NguyenThanhPhat\SmallWorksData1.ndf',
	size=10MB,
	maxsize=50MB,
	filegrowth=20%
),
filegroup SWUserData2 (
	name='SmallWorksData2',
	filename='D:\NguyenThanhPhat\SmallWorksData2.ndf',
	size=10MB,
	maxsize=50MB,
	filegrowth=20%
)
log on (
	name='SmallWorks_log',
	filename='D:\NguyenThanhPhat\SmallWorks_log.ldf',
	size=10MB,
	maxsize=20MB,
	filegrowth=10%
)

use SmallWorks

-- 3 Dùng SSMS để xem kết quả: Click phải trên tên của CSDL vừa tạo
--a. Chọn filegroups, quan sát kết quả:
-- Có bao nhiêu filegroup, liệt kê tên các filegroup hiện tại
-- Filegroup mặc định là gì?
--b. Chọn file, quan sát có bao nhiêu database file?

--Trả lời:
-- a: Có 3 filegroup: primary, swuserdata1, swuserdata2
-- Filegroup default là: primary
-- b: Có 4 databse file như đã tạo ở trên

-- 4 Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add
--thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1.
--Dùng SSMS xem kết quả.
alter database SmallWorks
add filegroup Test1FG1

go
alter database SmallWorks
add file (
	name='SmallWorksfiledat1',
	filename='D:\NguyenThanhPhat\filedat1.ndf',
	size=5MB
) to filegroup Test1FG1

go
alter database SmallWorks
add file (
	name='SmallWorksfiledat2',
	filename='D:\NguyenThanhPhat\filedat2.ndf',
	size=5MB
) to filegroup Test1FG1

go
sp_helpfile

-- 5 Dùng T-SQL tạo thêm một một file thứ cấp filedat3.ndf dung lượng 3MB trong
--filegroup Test1FG1. Sau đó sửa kích thước tập tin này lên 5MB. Dùng SSMS xem
--kết quả. Dùng T-SQL xóa file thứ cấp filedat3.ndf. Dùng SSMS xem kết quả
go
alter database SmallWorks
add file (
	name='SmallWorksfiledat3',
	filename='D:\NguyenThanhPhat\filedat3.ndf',
	size=3MB
) to filegroup Test1FG1

go
alter database SmallWorks
modify file (
	name='SmallWorksfiledat3',
	size=5MB
)

go
sp_helpfile
sp_helpfilegroup

go
alter database SmallWorks
remove file SmallWorksfiledat3

go
sp_helpfile

-- 6 Xóa filegroup Test1FG1? Bạn có xóa được không? Nếu không giải thích? Muốn xóa
--được bạn phải làm gì?
alter database SmallWorks
remove filegroup Test1FG1
-- Không xoá được vì file hiện tài có chứa dữ liệu
-- Muốn xoá được thì phải xoá các file trong filegroup Test1FG1 này

-- 7 Xem lại thuộc tính (properties) của CSDL SmallWorks bằng cửa sổ thuộc tính
--properties và bằng thủ tục hệ thống sp_helpDb, sp_spaceUsed, sp_helpFile.
--Quan sát và cho biết các trang thể hiện thông tin gì?.
-- Thể hiện tất cả thông tin của database
sp_helpdb

-- Thể hiện thông tin cụ thể database
sp_spaceused

-- Thể hiện thông tin cụ thể của tất cả file trong database
sp_helpfile

-- 8 Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó
--đóng cửa sổ properties. Quan sát màu sắc của CSDL. Dùng lệnh T-SQL gỡ bỏ
--thuộc tính ReadOnly và đặt thuộc tính cho phép nhiều người sử dụng CSDL
--SmallWorks.
ALTER DATABASE SmallWorks SET READ_ONLY

ALTER DATABASE SmallWorks SET READ_WRITE

-- 9 Trong CSDL SmallWorks, tạo 2 bảng mới theo cấu trúc như sau:
create table Person (
	PersonID int not null,
	FirstName varchar(50) not null,
	MiddleName nvarchar(50) null,
	LastName varchar(50) not null,
	EmailAddress nvarchar(50) null
) on SWUserData1

create table Product (
	ProductID int not null,
	ProductName varchar(50) not null,
	ProductNumber nvarchar(25) not null,
	StandardCost money not null,
	ListPrice money not null
) on SWUserData2

-- 10 Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng Person và bảng Product trong
--AdventureWorks2008 (lưu ý: chỉ rõ tên cơ sở dữ liệu và lược đồ), dùng lệnh
--Insert…Select... Dùng lệnh Select * để xem dữ liệu trong 2 bảng Person và bảng
--Product trong SmallWorks.
go
use AdventureWorks2008R2

select * from Person.Person
select * from Production.Product

use SmallWorks

insert into Person (PersonID, FirstName, MiddleName, LastName)
	select p.BusinessEntityID,p.FirstName, 
		   p.MiddleName, p.LastName
	from AdventureWorks2008R2.Person.Person as p

go
insert into Product
	select p.ProductID, p.Name, p.ProductNumber, 
		   p.StandardCost, p.ListPrice
	from AdventureWorks2008R2.Production.Product as p

go
select * from Person
select * from Product

-- 11 Dùng SSMS, Detach cơ sở dữ liệu SmallWorks ra khỏi phiên làm việc của SQL

--Kick all users off of the database NOW
use master
ALTER DATABASE SmallWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE

exec master.dbo.sp_detach_db 'SmallWorks', 'true'

-- 12 Dùng SSMS, Attach cơ sở dữ liệu SmallWorks vào SQL
create database SmallWorks on
( filename='D:\NguyenThanhPhat\SmallWorks.mdf'),
( filename='D:\NguyenThanhPhat\SmallWorks_log.ldf' ) 
for attach
go


-- Phần 2 Dùng T-SQL tạo CSDL T:\HoTen\Sales, các thông số tùy ý, trong CSDL Sales
--thực hiện các công việc sau:
create database Sales
on primary (
	name = 'salePrimary',
	filename = 'D:\NguyenThanhPhat\Sales\salePrimary.mdf',
	size=15MB,
	filegrowth=20%,
	maxsize=50MB
),
filegroup saleGroup1 (
	name='saleGroup1',
	filename='D:\NguyenThanhPhat\Sales\saleGroup1.ndf',
	size=15MB,
	filegrowth=20%,
	maxsize=50MB
)
LOG ON (
	name='saleGroup_log',
	filename='D:\NguyenThanhPhat\Sales\saleGroup_log.ldf',
	size=15MB,
	filegrowth=20%,
	maxsize=50MB
)

use sales
-- 1 Tạo các kiểu dữ liệu người dùng sau:

exec sp_addtype 'Mota', 'nvarchar(40)', 'NUll'
exec sp_addtype 'IDKH', 'char(10)', 'NOT NULL' 
exec sp_addtype 'DT', 'char(12)', 'NULL'
 
-- 2 Tạo các bảng theo cấu trúc sau:
create table SanPham (
	Masp char(6) not null,
	Tensp varchar(20),
	NgayNhap date,
	DVT char(10),
	SoLuongTon int,
	DonGiaNhap money
)

create table KhachHang (
	MaKH IDKH not null,
	TenKH nvarchar(30),
	DiaChi nvarchar(40),
	Dienthoai DT
)

create table HoaDon (
	MaHD char(10) not null,
	NgayLap date,
	NgayGiao date,
	Makh IDKH not null,
	DienGiai Mota
)

create table ChiTietHD (
	MaHD char(10) not null,
	Masp char(6) not null,
	Soluong int
)

-- 3 Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
alter table HoaDon
alter column DienGiai nvarchar(100)

-- 4 Thêm vào bảng SanPham cột TyLeHoaHong float
alter table SanPham
add TyLeHoaHong float

--5 Xóa cột NgayNhap trong bảng SanPham
alter table SanPham
drop column NgayNhap
select * from SanPham

--6 Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
alter table SanPham
add primary key(Masp)

alter table KhachHang
add primary key(MaKH)

alter table HoaDon
add primary key(MaHD)

alter table ChiTietHD 
add primary key(MaHD, Masp)

-- Khoá ngoại
alter table HoaDon
	add foreign key(MaKH) references KhachHang(MaKH)

alter table ChiTietHD 
	add foreign key(MaHD) references HoaDon(MaHD),
		foreign key(Masp) references SanPham(Masp)

--7 Thêm vào bảng HoaDon các ràng buộc sau:
-- NgayGiao >= NgayLap
-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
alter table HoaDon
	add constraint NgayGiao_NgayLap_ck check (NgayGiao >= NgayLap)

alter table HoaDon
	add constraint MaHD_check check (MaHD like('[A-Z][A-Z][0-9][0-9][0-9][0-9]'))

alter table HoaDon
	add constraint NgayLap_def default getdate() for NgayLap

--8 Thêm vào bảng Sản phẩm các ràng buộc sau:
-- SoLuongTon chỉ nhập từ 0 đến 500
-- DonGiaNhap lớn hơn 0
-- Giá trị mặc định cho NgayNhap là ngày hiện hành
-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
alter table SanPham
	add constraint soLuongTon_ck check (SoLuongTon BETWEEN 0 AND 500)

alter table SanPham
	add constraint donGiaNhap_ck check (DonGiaNhap>0)
-- Vì ở câu 5 đã yêu cầu xoá rồi nên kô còn tồn tại cột NgayNhap nữa 
-- Vậy ta ko thể thêm constraint vào cột này
alter table SanPham
	add constraint NgayNhap_ck default getdate() for NgayNhap

alter table SanPham
add constraint DVT_ck check (DVT in ('KG', N'Thùng', N'Hộp', N'Cái'))

--9 Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng
--buộc của mỗi Table
-- Insert SanPham
insert into SanPham (Masp, Tensp, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong)
	values ('sp01', 'Tivi', 'KG', 5, 1200000, 0.2)
insert into SanPham (Masp, Tensp, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong)
	values ('sp02', N'Máy giặt', N'Cái', 5, 350000, 0.1)
insert into SanPham (Masp, Tensp, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong)
	values ('sp03', N'Tủ lạnh', N'Thùng', 2, 850000, 0.6)
insert into SanPham (Masp, Tensp, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong)
	values ('sp04', N'Khăn lau mặt', 'KG', 23, 75000, 0.7)

select * from SanPham

-- Insert KhachHang
insert into KhachHang (MaKH, TenKH, DiaChi, Dienthoai)
	values ('kh01', N'Châu Quang Ngọc', N'Gò Vấp', '090132456')
insert into KhachHang (MaKH, TenKH, DiaChi, Dienthoai)
	values ('kh02', N'Lại Thanh Tú', N'Vùng Tàu', '090132457')
insert into KhachHang (MaKH, TenKH, DiaChi, Dienthoai)
	values ('kh03', N'Phan Tấn Khang', N'Đồng Nai', '090132458')
insert into KhachHang (MaKH, TenKH, DiaChi, Dienthoai)
	values ('kh04', N'Trần Thiên An', N'Hồ Chí Minh', '090132459')

select * from KhachHang

-- Insert HoaDon
insert into HoaDon (MaHD, NgayLap, NgayGiao, Makh, DienGiai)
	values ('HD0001', '2021-08-10', '2021-08-14', 'kh04', 'ASS')
insert into HoaDon (MaHD, NgayLap, NgayGiao, Makh, DienGiai)
	values ('HD0002', '2021-12-10', '2021-12-15', 'kh03', 'DSS')
insert into HoaDon (MaHD, NgayLap, NgayGiao, Makh, DienGiai)
	values ('HD0003', '2021-10-10', '2021-10-18', 'kh02', 'CSS')
insert into HoaDon (MaHD, NgayLap, NgayGiao, Makh, DienGiai)
	values ('HD0004', '2021-09-22', '2021-09-24', 'kh01', 'VSS')

select * from ChiTietHD
select * from HoaDon

-- Insert ChiTietHD
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('HD0001', 'sp04', 1)
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('HD0002', 'sp03', 2)
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('HD0003', 'sp02', 1)
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('HD0004', 'sp01', 3)

select * from ChiTietHD

-- 10 Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu
--vẫn muốn xóa thì phải dùng cách nào? 
alter table ChiTietHD
drop constraint FK__ChiTietHD__MaHD__173876EA

delete from HoaDon
where MaHD='HD0001'

-- 11  Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và
--MaHD=’1234567890’. Có nhập được không? Tại sao?
 --Không được vì chỉ được chứa 10 ký tự trong này tận 11 ký tự nên ko dc
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('HD999999999', 'sp04', 3)

 -- Được vì bạn vừa xoá ràng buộc constraint ở câu 10
 -- nên mặc dù 2 ký tự đầu phải bắt đầu từ A-Z{2} vẫn sẽ nhập được
insert into ChiTietHD (MaHD, Masp, Soluong)
	values ('1234567890', 'sp03', 2)

-- 12 Đổi tên CSDL Sales thành BanHang
alter database sales
modify name=BanHang

-- 13 Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao
--chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao
--chép, bạn thực hiện Attach CSDL vào lại SQL.
--14 Tạo bản BackUp cho CSDL BanHang
backup database BanHang
to disk='D:\NguyenThanhPhat\QLBH\banhang.bak'
with name ='banhang_FULL', init;

-- 15 Xóa CSDL BanHang
use master
drop database BanHang

-- 16 Phục hồi lại CSDL BanHang
restore database BanHang
from disk='D:\NguyenThanhPhat\QLBH\banhang.bak'
