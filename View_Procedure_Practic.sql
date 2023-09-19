
use quanlyshop;
/*
	1. Tạo bảng Danh mục sản phẩm gồm các thông tin sau:
    - Mã danh mục - int - PK - auto increment
    - Tên danh mục - varchar(50) - not null - unique
    - Mô tả - text
    - Trạng thái - bit - default 1
*/
create table danhmucsp(
madm int primary key auto_increment,
tendm varchar(50) not null unique,
mota text,
trangthai bit default 1
);
/*
   2. Tạo bảng sản phẩm gồm các thông tin sau:
    - Mã sản phẩm - varchar(5) - PK
    - Tên sản phẩm - varchar(100) - not null - unique
    - Ngày tạo - date - default currentDate
    - Giá - float - default 0
    - Mô tả sản phẩm - text
    - Tiêu đề - varchar(200)
    - Mã danh mục - int - FK references Danh mục
    - Trạng thái - bit - default 1
*/
create table sanpham(
masp varchar(5) primary key,
tensp varchar(100) not null unique,
ngaytao datetime default now(),
gia float default 0,
motasp text,
tieude varchar(200),
madm int,
foreign key(madm) references danhmucsp(madm),
trangthai bit default 1
);
/*
3. Thêm các dữ liệu vào 2 bảng
*/
insert into danhmucsp (tendm, mota, trangthai)
values  ("Quan Ao","danh muc quan ao",1),
		("Giay Dep","danh muc giay dep",0),
        ("Trang Suc","danh muc trang suc",1),
        ("Nuoc Hoa","danh muc nuoc hoa",1);
select * from sanpham;
insert into sanpham
values  ("SP001","Ao dai","2021-09-12",12,null,"ao dai viet nam",1,1),
		("SP002","Giay Tay","2022-01-12",32,null,"Giay nike", 2,0),
        ("SP003","Day Chuyen","2023-12-12",200,null,"day chuyen vang", 3,1),
        ("SP004","Nhan","2023-09-23",98,null,"nhan cuoi", 3,1);
/*
    4. Tạo view gồm các sản phẩm có giá lớn hơn 20 $ gồm các thông tin sau: 
    mã danh mục, tên danh mục, trạng thái danh mục, mã sản phẩm, tên sản phẩm, 
    giá sản phẩm, trạng thái sản phẩm
*/
create view vw_sanpham_price 
as 
select dm.madm, dm.tendm, dm.trangthai as "trạng thái danh mục",
 sp.masp, sp.tensp, sp.trangthai as "trạng thái sản phẩm"
from sanpham sp join danhmucsp dm on sp.madm = dm.madm
where sp.gia > 20 ;
select * from vw_sanpham_price ;
/*
    5. Tạo các procedure sau:
    - procedure cho phép thêm, sửa, xóa, lấy tất cả dữ liệu, lấy dữ liệu theo mã
    của bảng danh mục và sản phẩm
    - procedure cho phép lấy ra tất cả các phẩm có trạng thái là 1
    bao gồm mã sản phẩm, tên sản phẩm, giá, tên danh mục, trạng thái sản phẩm
    - procedure cho phép thống kê số sản phẩm theo từng mã danh mục
    - procedure cho phép tìm kiếm sản phẩm theo tên sản phầm: mã sản phẩm, tên
    sản phẩm, giá, trạng thái sản phẩm, tên danh mục, trạng thái danh mục
*/
select * from danhmucsp;
-- 新しいレコードを挿入する
delimiter //
create procedure insert_danhmuc(
	ten_dm varchar(50),
    mo_ta text,
    trang_thai bit
)
begin
	insert into danhmucsp(tendm,mota,trangthai)
    values (ten_dm,mo_ta,trang_thai);
end //
delimiter ;
call insert_danhmuc("Phu Kien","phu kien kem",1);
-- テーブル内の既存のレコードを変更する
delimiter //
create procedure update_danhmuc(
	ma_dm int,
	ten_dm varchar(50),
    mo_ta text,
    trang_thai bit
)
begin
	update danhmucsp
    set tendm = ten_dm,
		mota = mo_ta,
        trangthai = trang_thai
	where madm = ma_dm;
end //
delimiter ;
call update_danhmuc(5,"Sach","sach hoc",0);
-- レコードを削除する
delimiter //
create procedure delete_danhmuc(
	ma_dm int
)
begin
	delete from danhmucsp where madm = ma_dm;
end //
delimiter ;
call delete_danhmuc(6);
-- 全レコードを選択する
delimiter //
-- drop procedure if exists data_danhmuc_sanpham;
create procedure data_danhmuc_sanpham()
begin
	select  dm.madm, dm.tendm,dm.mota,sp.masp,sp.tensp,sp.ngaytao,sp.gia,sp.tieude
    from danhmucsp dm join sanpham sp on dm.madm = sp.madm;
end //
delimiter ;
call data_danhmuc_sanpham();
-- status(1)の値を選択
delimiter //
create procedure status_data_dmsp(
	trangthai_sp bit
)
begin
	select sp.masp,sp.tensp,sp.gia,dm.tendm,sp.trangthai
    from sanpham sp join danhmucsp dm on sp.madm = dm.madm
    where sp.trangthai = trangthai_sp;
end //
delimiter ;
call status_data_dmsp(1);
-- sanphamのmadmから累計
delimiter //
create procedure total_danhmuc()
begin
	select madm, count(masp) as "so luong"
    from sanpham
    group by madm;
end //
delimiter ;
call total_danhmuc();
-- 検索
delimiter //
create procedure search_data_dmsp(
	ten_sp varchar(100)
)
begin
	-- 宣言　name_search
	declare name_search varchar(102);
    set name_search = concat("%",ten_sp,"%");
    --
    select sp.masp,sp.tensp,sp.gia,sp.trangthai,dm.tendm,dm.trangthai as "trang thai dm"
    from sanpham sp join danhmucsp dm on sp.madm = dm.madm
    where sp.tensp like name_search ;
end //
delimiter ;
call search_data_dmsp("nhan");