USE ShopeeDB;
START TRANSACTION;

DELETE FROM ORDER_LINE
WHERE order_id IN ('F1_O1', 'F1_O2', 'F1_O3', 'F1_O4', 'F1_O5');

DELETE FROM SHOP_ORDER
WHERE order_id IN ('F1_O1', 'F1_O2', 'F1_O3', 'F1_O4', 'F1_O5');

DELETE FROM ADDRESS WHERE address_id IN ('F1_ADDR', 'F1_ADDR_C');
DELETE FROM VARIANT WHERE variant_id IN ('F1_VAR1', 'F1_VAR2', 'F1_VAR3');
DELETE FROM PRODUCT WHERE product_id = 'F1_PROD';
DELETE FROM STORE WHERE store_id = 'F1_STORE';
DELETE FROM CATEGORY WHERE category_id = 'F1_CAT';
DELETE FROM BUYER WHERE account_id IN ('F1_BUY_A', 'F1_BUY_B', 'F1_BUY_C');
DELETE FROM SELLER WHERE account_id = 'F1_SELL';
DELETE FROM ADMIN WHERE account_id = 'F1_ADM';
DELETE FROM ACCOUNT
WHERE account_id IN ('F1_ADM', 'F1_SELL', 'F1_BUY_A', 'F1_BUY_B', 'F1_BUY_C');

-- 1. Tao tai khoan va vai tro: 1 admin, 1 seller, 3 buyers.
--    Buyer A dung test Function 1; Buyer B chua co don; Buyer C dung test Function 2.
INSERT INTO ACCOUNT
    (account_id, username, `password`, name, birth_date, email, status)
VALUES
    ('F1_ADM',   'f1_admin_26',  'test123', 'Admin test 2.4',  '1990-01-01', 'f1_admin@example.com',  'Active'),
    ('F1_SELL',  'f1_seller_26', 'test123', 'Seller test 2.4', '1992-01-01', 'f1_seller@example.com', 'Active'),
    ('F1_BUY_A', 'f1_buy_a_26',  'test123', 'Buyer A',         '2001-01-01', 'f1_buya@example.com',   'Active'),
    ('F1_BUY_B', 'f1_buy_b_26',  'test123', 'Buyer B',         '2002-01-01', 'f1_buyb@example.com',   'Active'),
    ('F1_BUY_C', 'f1_buy_c_26',  'test123', 'Buyer C',         '2003-01-01', 'f1_buyc@example.com',   'Active');

INSERT INTO ADMIN (account_id, admin_role)
VALUES ('F1_ADM', 'Moderator');

INSERT INTO SELLER (account_id, seller_type)
VALUES ('F1_SELL', 'Individual');

INSERT INTO BUYER (account_id, membership_tier)
VALUES ('F1_BUY_A', 'Bronze'), ('F1_BUY_B', 'Bronze'), ('F1_BUY_C', 'Bronze');

-- 2. Cua hang, san pham, ba Variant va dia chi.
INSERT INTO CATEGORY (category_id, category_name, description, parent_category_id)
VALUES ('F1_CAT', 'Danh muc Function 2.4', 'Du lieu rieng cho hai Function', NULL);

INSERT INTO STORE
    (store_id, store_name, pickup_address, status, seller_id, approved_by, approved_at)
VALUES
    ('F1_STORE', 'Store test 2.4', 'TP.HCM', 'Active', 'F1_SELL', 'F1_ADM', NOW());

INSERT INTO PRODUCT
    (product_id, product_name, description, status, store_id, category_id)
VALUES
    ('F1_PROD', 'Ao thun test 2.4', 'San pham chung cho hai Function',
     'Active', 'F1_STORE', 'F1_CAT');

INSERT INTO VARIANT
    (variant_id, sku_code, color, size, unit_price, stock, status, product_id)
VALUES
    ('F1_VAR1', 'F1-SKU-001', 'Den',   'M', 100000, 100, 'Active', 'F1_PROD'),
    ('F1_VAR2', 'F1-SKU-002', 'Trang', 'L', 100000, 100, 'Active', 'F1_PROD'),
    -- Kho ban dau du lon de tao lich su ban 21 + 7 cai (RB so 5).
    ('F1_VAR3', 'F1-SKU-003', 'Xanh',  'XL',100000,  50, 'Active', 'F1_PROD');

INSERT INTO ADDRESS
    (address_id, receiver_name, phone_number, house_number,
     street_name, ward_commune, province_city, buyer_id)
VALUES
    ('F1_ADDR',   'Buyer A', '0901234567', '12', 'Nguyen Trai', 'Phuong 1', 'TP.HCM', 'F1_BUY_A'),
    ('F1_ADDR_C', 'Buyer C', '0901234568', '34', 'Le Loi',      'Phuong 2', 'TP.HCM', 'F1_BUY_C');

-- 3. Don hang.
--    F1_O1, O2: Buyer A - Delivered, Function 1 se dem 2+1+3=6.
--    F1_O3: Buyer A - Pending, Function 1 KHONG dem 4.
--    F1_O4: Buyer C - Delivered, dat hang 3 ngay truoc (21 cai F1_VAR3).
--    F1_O5: Buyer C - Delivered, dat hang 10 ngay truoc (7 cai F1_VAR3).
--    Tao Pending/tong tien 0 truoc de tuong thich trigger SHOP_ORDER.
INSERT INTO SHOP_ORDER
    (order_id, order_time, order_status,
     total_item_amount, shipping_fee, discount_amount,
     order_recipient_name, order_phone, delivery_address_at_order_time,
     buyer_id, store_id, address_id, coupon_id)
VALUES
    ('F1_O1', NOW() - INTERVAL 2 DAY,  'Pending', 0, 0, 0,
     'Buyer A', '0901234567', '12 Nguyen Trai, TP.HCM', 'F1_BUY_A', 'F1_STORE', 'F1_ADDR', NULL),
    ('F1_O2', NOW() - INTERVAL 4 DAY,  'Pending', 0, 0, 0,
     'Buyer A', '0901234567', '12 Nguyen Trai, TP.HCM', 'F1_BUY_A', 'F1_STORE', 'F1_ADDR', NULL),
    ('F1_O3', NOW() - INTERVAL 1 DAY,  'Pending', 0, 0, 0,
     'Buyer A', '0901234567', '12 Nguyen Trai, TP.HCM', 'F1_BUY_A', 'F1_STORE', 'F1_ADDR', NULL),
    ('F1_O4', NOW() - INTERVAL 3 DAY,  'Pending', 0, 0, 0,
     'Buyer C', '0901234568', '34 Le Loi, TP.HCM', 'F1_BUY_C', 'F1_STORE', 'F1_ADDR_C', NULL),
    ('F1_O5', NOW() - INTERVAL 10 DAY, 'Pending', 0, 0, 0,
     'Buyer C', '0901234568', '34 Le Loi, TP.HCM', 'F1_BUY_C', 'F1_STORE', 'F1_ADDR_C', NULL);

-- 4. Them dong hang. Tat ca Variant deu thuoc F1_STORE, stock ban dau du.
INSERT INTO ORDER_LINE
    (order_id, sort_order, quantity, unit_price_at_order,
     product_name_at_order, variant_name_at_order, variant_id)
VALUES
    ('F1_O1', 1,  2, 100000, 'Ao thun test 2.4', 'Den M',   'F1_VAR1'),
    ('F1_O1', 2,  1, 100000, 'Ao thun test 2.4', 'Trang L', 'F1_VAR2'),
    ('F1_O2', 1,  3, 100000, 'Ao thun test 2.4', 'Den M',   'F1_VAR1'),
    ('F1_O3', 1,  4, 100000, 'Ao thun test 2.4', 'Den M',   'F1_VAR1'),
    ('F1_O4', 1, 21, 100000, 'Ao thun test 2.4', 'Xanh XL', 'F1_VAR3'),
    ('F1_O5', 1,  7, 100000, 'Ao thun test 2.4', 'Xanh XL', 'F1_VAR3');

-- 5. Cap nhat tong tien hang dung va trang thai Delivered.
--    Neu Trigger tu tinh total_item_amount da chay thi day van la gia tri dung.
UPDATE SHOP_ORDER
SET total_item_amount = CASE order_id
        WHEN 'F1_O1' THEN  300000
        WHEN 'F1_O2' THEN  300000
        WHEN 'F1_O3' THEN  400000
        WHEN 'F1_O4' THEN 2100000
        WHEN 'F1_O5' THEN  700000
    END,
    order_status = CASE
        WHEN order_id = 'F1_O3' THEN 'Pending'
        ELSE 'Delivered'
    END
WHERE order_id IN ('F1_O1', 'F1_O2', 'F1_O3', 'F1_O4', 'F1_O5');

-- 6. Mo phong ton kho HIEN TAI cua F1_VAR3 = 8.
--    Lam SAU khi tao ORDER_LINE de ket qua giong nhau du DB co hay
--    khong co Trigger tu tru stock khi dat hang.
UPDATE VARIANT
SET stock = 8
WHERE variant_id = 'F1_VAR3';

-- ============================================================
-- DOI CHIEU DU LIEU / KIEM THU HAI FUNCTION
-- ============================================================

-- Xem 5 don va so luong tung don.
SELECT o.order_id, o.buyer_id, o.order_time, o.order_status,
       SUM(ol.quantity) AS total_quantity
FROM SHOP_ORDER o
JOIN ORDER_LINE ol ON ol.order_id = o.order_id
WHERE o.order_id IN ('F1_O1', 'F1_O2', 'F1_O3', 'F1_O4', 'F1_O5')
GROUP BY o.order_id, o.buyer_id, o.order_time, o.order_status
ORDER BY o.order_id;


-- TEST FUNCTION 1
SELECT fn_total_purchased_quantity('F1_BUY_A') AS fn1_test1_expected_6;
SELECT fn_total_purchased_quantity('F1_BUY_B') AS fn1_test2_expected_0;
SELECT fn_total_purchased_quantity('F1_BUY_NOT_FOUND') AS fn1_test3_expected_minus_1;

-- TEST FUNCTION 2: V01 (F1_VAR3) co Q_gan = 21, Q_truoc = 7, stock = 8.

-- p_days = 7 -> ceil((21*0.7+7*0.3)/7*7)-8 = 9.

SELECT variant_id, stock FROM VARIANT WHERE variant_id = 'F1_VAR3';
SELECT fn_suggest_restock('F1_VAR3', 7) AS fn2_test1_expected_9;

-- p_days=1: ceil(2.4)-8 <= 0 -> 0 (chua can nhap them).

SELECT fn_suggest_restock('F1_VAR3', 1) AS fn2_test2_expected_0;

-- Tham so sai -> -1.

SELECT fn_suggest_restock('F1_VAR3', 0) AS fn2_test3_expected_minus_1;
SELECT fn_suggest_restock('F1_VAR_NOT_EXIST', 7) AS fn2_test4_expected_minus_1;

ROLLBACK;
