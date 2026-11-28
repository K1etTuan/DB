DELIMITER ;
SET NAMES utf8mb4;

-- 1.1: Tao CSDL, bang, khoa chinh/ngoai, CHECK va cot dan xuat.
SOURCE 1.1_schema.sql;
USE ShopeeDB;

-- 1.1: Cai cac rang buoc ngu nghia can trigger.
SOURCE 1.1_Semantic_constraints_trigger.sql;
-- File tren ket thuc voi DELIMITER $$; phai tra ve ; truoc file tiep theo.
DELIMITER ;

-- 2.1: Thu tuc them, sua, xoa san pham.
SOURCE 2.1_product_crud_procedures.sql;
DELIMITER ;

-- 2.2: Trigger nghiep vu, tinh tong tien va cap nhat ton kho.
SOURCE 2.2_triggers.sql;
DELIMITER ;

-- 2.3: Thu tuc tim kiem san pham va thong ke doanh thu.
SOURCE 2.3_procedures.sql;
-- File tren cung chua tra DELIMITER ve ;.
DELIMITER ;

-- 2.4: Hai ham tinh so luong da mua va goi y nhap hang.
SOURCE 2.4.sql;
DELIMITER ;

