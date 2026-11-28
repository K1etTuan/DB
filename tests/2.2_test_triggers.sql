USE ShopeeDB;

-- DON DEP DU LIEU TEST CU (neu co) theo dung thu tu khoa ngoai
DELETE FROM PAYMENT     WHERE payment_id LIKE 'T_%';
DELETE FROM ORDER_LINE  WHERE order_id   LIKE 'T_%';
DELETE FROM SHOP_ORDER  WHERE order_id   LIKE 'T_%';
DELETE FROM COUPON      WHERE coupon_id  LIKE 'T_%';
DELETE FROM ADDRESS     WHERE address_id LIKE 'T_%';
DELETE FROM VARIANT     WHERE variant_id LIKE 'T_%';
DELETE FROM PRODUCT     WHERE product_id LIKE 'T_%';
DELETE FROM STORE       WHERE store_id   LIKE 'T_%';
DELETE FROM CATEGORY    WHERE category_id LIKE 'T_%';
DELETE FROM BUYER       WHERE account_id LIKE 'T_%';
DELETE FROM SELLER      WHERE account_id LIKE 'T_%';
DELETE FROM ADMIN       WHERE account_id LIKE 'T_%';
DELETE FROM ACCOUNT     WHERE account_id LIKE 'T_%';


-- TAO DU LIEU MAU PHUC VU KIEM THU (TIEN TO T_)

INSERT INTO ACCOUNT (account_id, username, password, name, birth_date, email, status) VALUES
('T_ADM01', 't_admin01',  'pass123', 'Admin Test',      '1995-01-01', 't_admin01@shopee.vn',  'Active'),
('T_SEL01', 't_seller01', 'pass123', 'Chu Shop A',      '1992-05-10', 't_seller01@shopee.vn', 'Active'),
('T_SEL02', 't_seller02', 'pass123', 'Chu Shop B',      '1993-08-20', 't_seller02@shopee.vn', 'Active'),
('T_BUY01', 't_buyer01',  'pass123', 'Nguyen Van Test', '2002-03-15', 't_buyer01@gmail.com',  'Active');

INSERT INTO ADMIN (account_id, admin_role) VALUES ('T_ADM01', 'SuperAdmin');
INSERT INTO SELLER (account_id, seller_type) VALUES
('T_SEL01', 'Business'),
('T_SEL02', 'Individual');
INSERT INTO BUYER (account_id, membership_tier) VALUES ('T_BUY01', 'Gold');

INSERT INTO CATEGORY (category_id, category_name, description, parent_category_id) VALUES
('T_CAT01', 'Phu kien dien tu', 'Sac, cap, tai nghe', NULL);

INSERT INTO STORE (store_id, store_name, description, pickup_address, status, seller_id, approved_by, approved_at) VALUES
('T_ST01', 'Shop Tech A', 'Phu kien chinh hang A', 'Quan 10, TP.HCM',  'Active', 'T_SEL01', 'T_ADM01', '2026-10-01 09:00:00'),
('T_ST02', 'Shop Tech B', 'Thiet bi am thanh B',   'Thu Duc, TP.HCM',  'Active', 'T_SEL02', 'T_ADM01', '2026-10-01 10:00:00');

INSERT INTO PRODUCT (product_id, product_name, description, status, store_id, category_id) VALUES
('T_P01', 'Pin sac du phong 10000mAh', 'Sac nhanh 20W',     'Active',   'T_ST01', 'T_CAT01'),
('T_P02', 'Cap sac nhanh Type-C',      'Chieu dai 1m',      'Active',   'T_ST01', 'T_CAT01'),
('T_P03', 'Tai nghe Bluetooth Pro',    'Chong on chu dong', 'Active',   'T_ST02', 'T_CAT01'),
('T_P04', 'Op lung da ngung ban',      'Het hang vinh vien','Inactive', 'T_ST01', 'T_CAT01');

INSERT INTO VARIANT (variant_id, sku_code, color, size, unit_price, stock, status, product_id) VALUES
('T_V01', 'T-SKU-01', 'Den',   '10000mAh', 200000.00, 10, 'Active',   'T_P01'),
('T_V02', 'T-SKU-02', 'Trang', '1m',        50000.00, 20, 'Active',   'T_P02'),
('T_V03', 'T-SKU-03', 'Den',   'Std',      350000.00,  5, 'Active',   'T_P03'),
('T_V04', 'T-SKU-04', 'Do',    '10000mAh', 200000.00, 10, 'Inactive', 'T_P01'),
('T_V05', 'T-SKU-05', 'Trong', '15 Pro',    80000.00, 10, 'Active',   'T_P04');

INSERT INTO ADDRESS (address_id, receiver_name, phone_number, house_number, street_name, ward_commune, province_city, buyer_id) VALUES
('T_ADR01', 'Nguyen Van Test', '0901234567', '268', 'Ly Thuong Kiet', 'Phuong 14', 'TP.HCM', 'T_BUY01');

INSERT INTO COUPON (coupon_id, coupon_code, coupon_type, discount_value, min_order_value, start_time, end_time, status, store_id) VALUES
('T_CP01', 'T_GIAM50K', 'Store', 50000.00, 300000.00, '2026-01-01 00:00:00', '2028-12-31 23:59:59', 'Active', 'T_ST01');

INSERT INTO SHOP_ORDER (
    order_id, order_status, total_item_amount, shipping_fee, discount_amount,
    order_recipient_name, order_phone, delivery_address_at_order_time,
    buyer_id, store_id, address_id, coupon_id
) VALUES
('T_ORD01', 'Pending',   0.00, 30000.00, 0.00, 'Nguyen Van Test', '0901234567', '268 Ly Thuong Kiet, Phuong 14, TP.HCM', 'T_BUY01', 'T_ST01', 'T_ADR01', NULL),
('T_ORD02', 'Pending',   0.00, 30000.00, 0.00, 'Nguyen Van Test', '0901234567', '268 Ly Thuong Kiet, Phuong 14, TP.HCM', 'T_BUY01', 'T_ST01', 'T_ADR01', NULL),
('T_ORD03', 'Confirmed', 0.00, 30000.00, 0.00, 'Nguyen Van Test', '0901234567', '268 Ly Thuong Kiet, Phuong 14, TP.HCM', 'T_BUY01', 'T_ST01', 'T_ADR01', NULL),
('T_ORD04', 'Pending',   0.00, 30000.00, 0.00, 'Nguyen Van Test', '0901234567', '268 Ly Thuong Kiet, Phuong 14, TP.HCM', 'T_BUY01', 'T_ST01', 'T_ADR01', NULL);

INSERT INTO PAYMENT (payment_id, payment_method, amount, status, completion_time, order_id) VALUES
('T_PAY01', 'COD', 30000.00, 'Pending', NULL, 'T_ORD01'),
('T_PAY02', 'COD', 30000.00, 'Pending', NULL, 'T_ORD02'),
('T_PAY03', 'COD', 30000.00, 'Pending', NULL, 'T_ORD03'),
('T_PAY04', 'COD', 30000.00, 'Pending', NULL, 'T_ORD04');



-- TEST CASE 1: trg_order_line_check_insert (Phan loai Inactive)
-- Loi SQL (1644): Loi: San pham, phan loai hoac cua hang hien khong con hoat dong.

INSERT INTO ORDER_LINE VALUES
('T_ORD01', 1, 1, 200000.00, 'Pin sac du phong 10000mAh', 'Do - 10000mAh', 'T_V04');


-- =====================================================================
-- TEST CASE 2: trg_order_line_check_insert (Don hang khong o trang thai Pending)
--  Loi SQL (1644): Loi: Chi duoc them chi tiet khi don hang dang o trang thai Pending.
-- =====================================================================
INSERT INTO ORDER_LINE VALUES
('T_ORD03', 1, 1, 200000.00, 'Pin sac du phong 10000mAh', 'Den - 10000mAh', 'T_V01');



-- TEST CASE 3: trg_order_line_check_insert (Cong don so luong cung phan loai vuot ton kho)
-- Buoc 3a: Them dong 1 hop le (6 <= 10) -> Thanh cong
-- Buoc 3b: Them dong 2 cung T_V01 (6 <= 10 nhung 6 + 6 = 12 > 10) -> Loi SQL (1644)

INSERT INTO ORDER_LINE VALUES
('T_ORD01', 1, 6, 200000.00, 'Pin sac du phong 10000mAh', 'Den - 10000mAh', 'T_V01');

INSERT INTO ORDER_LINE VALUES
('T_ORD01', 2, 6, 200000.00, 'Pin sac du phong 10000mAh', 'Den - 10000mAh', 'T_V01');



-- TEST CASE 4: trg_order_line_check_update (Cap nhat so luong vuot ton kho)
--  Loi SQL (1644): Loi: Tong so luong dat mua vuot qua so luong ton kho hien tai.

UPDATE ORDER_LINE
SET quantity = 12
WHERE order_id = 'T_ORD01' AND sort_order = 1;


-- TEST CASE 5: trg_order_line_check_update (Doi sang phan loai khac cua hang)
--  Loi SQL (1644): Loi: Phan loai san pham khong thuoc cua hang nhan don hang.

UPDATE ORDER_LINE
SET variant_id = 'T_V03'
WHERE order_id = 'T_ORD01' AND sort_order = 1;



-- TEST CASE 6: trg_shop_order_check_update (Doi cua hang cua don da co chi tiet)
-- Mong doi: Loi SQL (1644): Loi: Khong the doi cua hang vi da co chi tiet thuoc cua hang khac.

UPDATE SHOP_ORDER
SET store_id = 'T_ST02'
WHERE order_id = 'T_ORD01';


-- TEST CASE 7: trg_shop_order_check_update (Chuyen trang thai don hang khong hop le)
--  Loi SQL (1644): Loi: Chuyen doi trang thai don hang khong hop le.

UPDATE SHOP_ORDER
SET order_status = 'Delivered'
WHERE order_id = 'T_ORD01';



-- TEST CASE 8: trg_order_line_after_insert & trg_shop_order_after_update
-- Mong doi: total_item_amount = 550000.00, total_payment_amount = 580000.00,
--           PAYMENT.amount = 580000.00

SELECT o.order_id, o.total_item_amount, o.shipping_fee, o.discount_amount,
       o.total_payment_amount, p.amount AS payment_amount
FROM SHOP_ORDER o
JOIN PAYMENT p ON o.order_id = p.order_id
WHERE o.order_id = 'T_ORD02';

INSERT INTO ORDER_LINE VALUES
('T_ORD02', 1, 2, 200000.00, 'Pin sac du phong 10000mAh', 'Den - 10000mAh', 'T_V01');

INSERT INTO ORDER_LINE VALUES
('T_ORD02', 2, 3, 50000.00, 'Cap sac nhanh Type-C', 'Trang - 1m', 'T_V02');

SELECT o.order_id, o.total_item_amount, o.shipping_fee, o.discount_amount,
       o.total_payment_amount, p.amount AS payment_amount
FROM SHOP_ORDER o
JOIN PAYMENT p ON o.order_id = p.order_id
WHERE o.order_id = 'T_ORD02';


-- TEST CASE 9: trg_order_line_after_update
-- Cap nhat so luong dong 1 tu 2 -> 3 (+200000): item = 750000, payment = 780000

UPDATE ORDER_LINE
SET quantity = 3
WHERE order_id = 'T_ORD02' AND sort_order = 1;

SELECT o.order_id, o.total_item_amount, o.shipping_fee, o.discount_amount,
       o.total_payment_amount, p.amount AS payment_amount
FROM SHOP_ORDER o
JOIN PAYMENT p ON o.order_id = p.order_id
WHERE o.order_id = 'T_ORD02';



-- TEST CASE 10: trg_order_line_after_delete (Tu dong tinh tien & go coupon)
-- Buoc 10a: Xoa dong 2 (-150000 -> item = 600000) va ap dung coupon T_CP01 (50000)
--           -> payment = 600000 + 30000 - 50000 = 580000
-- Buoc 10b: Xoa dong 1 -> item = 0 (< min_order_value 300000)
--           -> coupon_id tu ve NULL, discount_amount = 0, payment = 30000

DELETE FROM ORDER_LINE
WHERE order_id = 'T_ORD02' AND sort_order = 2;

UPDATE SHOP_ORDER
SET coupon_id = 'T_CP01', discount_amount = 50000.00
WHERE order_id = 'T_ORD02';

SELECT o.order_id, o.coupon_id, o.total_item_amount, o.discount_amount,
       o.total_payment_amount, p.amount AS payment_amount
FROM SHOP_ORDER o
JOIN PAYMENT p ON o.order_id = p.order_id
WHERE o.order_id = 'T_ORD02';

DELETE FROM ORDER_LINE
WHERE order_id = 'T_ORD02' AND sort_order = 1;

SELECT o.order_id, o.coupon_id, o.total_item_amount, o.discount_amount,
       o.total_payment_amount, p.amount AS payment_amount
FROM SHOP_ORDER o
JOIN PAYMENT p ON o.order_id = p.order_id
WHERE o.order_id = 'T_ORD02';



-- TEST CASE 11: trg_shop_order_after_update (Tru/Hoan ton kho) & trg_order_line_check_delete
-- Buoc 11a: Them 4 san pham T_V01 vao T_ORD04 va xac nhan don ('Confirmed')
--           -> stock cua T_V01 giam tu 10 xuong 6
-- Buoc 11b: Thu xoa chi tiet cua T_ORD04 khi da Confirmed -> Loi SQL (1644)
-- Buoc 11c: Huy don T_ORD04 ('Cancelled') -> stock cua T_V01 hoan lai 10

INSERT INTO ORDER_LINE VALUES
('T_ORD04', 1, 4, 200000.00, 'Pin sac du phong 10000mAh', 'Den - 10000mAh', 'T_V01');

UPDATE SHOP_ORDER
SET order_status = 'Confirmed'
WHERE order_id = 'T_ORD04';

SELECT variant_id, stock FROM VARIANT WHERE variant_id = 'T_V01';

-- (Chay rieng lenh DELETE nay de chup thong bao loi cua trg_order_line_check_delete)
DELETE FROM ORDER_LINE
WHERE order_id = 'T_ORD04' AND sort_order = 1;

UPDATE SHOP_ORDER
SET order_status = 'Cancelled'
WHERE order_id = 'T_ORD04';

SELECT variant_id, stock FROM VARIANT WHERE variant_id = 'T_V01';
