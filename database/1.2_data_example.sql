-- =====================================================================
-- BTL2 - MỤC 1.2: DỮ LIỆU MẪU CHO ShopeeDB (MySQL 8.x)
-- Chạy sau file schema (1.1). Thứ tự INSERT tuân theo quan hệ khóa ngoại.
-- =====================================================================
USE ShopeeDB;
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- GROUP 1: ACCOUNT (15 tài khoản: 5 admin, 5 seller, 5 buyer)
-- ---------------------------------------------------------------------
INSERT INTO ACCOUNT (account_id, username, password, name, birth_date, email, create_date, status) VALUES
('AD01', 'admin_hung',   'Adm@1234',  'Nguyễn Quốc Hưng',  '1985-04-12', 'hung.admin@shopee.vn',  '2023-01-05 08:00:00', 'Active'),
('AD02', 'admin_lan',    'Adm@2345',  'Trần Thị Lan',      '1990-09-23', 'lan.admin@shopee.vn',   '2023-01-05 08:30:00', 'Active'),
('AD03', 'mod_tuan',     'Mod@3456',  'Lê Minh Tuấn',      '1993-02-17', 'tuan.mod@shopee.vn',    '2023-03-10 09:00:00', 'Active'),
('AD04', 'mod_mai',      'Mod@4567',  'Phạm Thị Mai',      '1995-11-30', 'mai.mod@shopee.vn',     '2023-06-18 09:15:00', 'Active'),
('AD05', 'mod_khoa',     'Mod@5678',  'Võ Đăng Khoa',      '1992-07-08', 'khoa.mod@shopee.vn',    '2024-01-12 10:00:00', 'Inactive'),

('SL01', 'seller_thoitrang', 'Sel@1111', 'Đặng Hoàng Nam',   '1988-05-14', 'nam.dang@gmail.com',     '2024-02-01 10:00:00', 'Active'),
('SL02', 'seller_dienthoai', 'Sel@2222', 'Bùi Thanh Sơn',    '1986-12-02', 'son.bui@gmail.com',      '2024-02-10 11:00:00', 'Active'),
('SL03', 'seller_giadung',   'Sel@3333', 'Ngô Thị Hạnh',     '1991-03-27', 'hanh.ngo@gmail.com',     '2024-03-05 14:00:00', 'Active'),
('SL04', 'seller_bepviet',   'Sel@4444', 'Huỳnh Văn Tài',    '1994-08-19', 'tai.huynh@gmail.com',    '2024-04-20 15:30:00', 'Active'),
('SL05', 'seller_sachhay',   'Sel@5555', 'Lý Thu Trang',     '1997-01-09', 'trang.ly@gmail.com',     '2024-05-02 16:00:00', 'Active'),

('BY01', 'buyer_an',     'Buy@1010',  'Nguyễn Văn An',     '2000-06-15', 'an.nguyen@gmail.com',    '2024-06-01 09:00:00', 'Active'),
('BY02', 'buyer_binh',   'Buy@2020',  'Trần Thị Bình',     '1999-10-21', 'binh.tran@gmail.com',    '2024-06-03 10:20:00', 'Active'),
('BY03', 'buyer_cuong',  'Buy@3030',  'Lê Quốc Cường',     '2001-02-28', 'cuong.le@gmail.com',     '2024-07-11 13:45:00', 'Active'),
('BY04', 'buyer_dung',   'Buy@4040',  'Phạm Thùy Dung',    '1998-12-05', 'dung.pham@gmail.com',    '2024-08-19 17:10:00', 'Active'),
('BY05', 'buyer_em',     'Buy@5050',  'Hoàng Minh Em',     '2002-04-18', 'em.hoang@gmail.com',     '2024-09-25 19:00:00', 'Locked');

-- ---------------------------------------------------------------------
-- GROUP 2: BUYER, SELLER, ADMIN, PHONE_NUMBER
-- ---------------------------------------------------------------------
INSERT INTO BUYER (account_id, membership_tier) VALUES
('BY01', 'Gold'),
('BY02', 'Silver'),
('BY03', 'Silver'),
('BY04', 'Bronze'),
('BY05', 'Bronze');

INSERT INTO SELLER (account_id, seller_type) VALUES
('SL01', 'Business'),
('SL02', 'Business'),
('SL03', 'Business'),
('SL04', 'Individual'),
('SL05', 'Individual');

INSERT INTO ADMIN (account_id, admin_role) VALUES
('AD01', 'SuperAdmin'),
('AD02', 'SuperAdmin'),
('AD03', 'Moderator'),
('AD04', 'Moderator'),
('AD05', 'Moderator');

INSERT INTO PHONE_NUMBER (account_id, phone_number) VALUES
('AD01', '0901000001'),
('AD02', '0901000002'),
('AD03', '0901000003'),
('SL01', '0912000001'),
('SL01', '0912000011'),
('SL02', '0912000002'),
('SL03', '0912000003'),
('SL04', '0912000004'),
('SL05', '0912000005'),
('BY01', '0933000001'),
('BY01', '0933000011'),
('BY02', '0933000002'),
('BY03', '0933000003'),
('BY04', '0933000004'),
('BY05', '0933000005');

-- ---------------------------------------------------------------------
-- GROUP 3: CATEGORY (4 danh mục cha, 4 danh mục con), STORE
-- ---------------------------------------------------------------------
INSERT INTO CATEGORY (category_id, category_name, description, parent_category_id) VALUES
('CAT01', 'Thời trang',          'Quần áo, giày dép, phụ kiện thời trang', NULL),
('CAT02', 'Điện tử',             'Thiết bị và phụ kiện điện tử',           NULL),
('CAT03', 'Nhà cửa & Đời sống',  'Đồ dùng gia đình, nhà bếp',              NULL),
('CAT04', 'Sách & Văn phòng phẩm','Sách giáo trình, sách tham khảo',       NULL);

INSERT INTO CATEGORY (category_id, category_name, description, parent_category_id) VALUES
('CAT05', 'Áo thun',              'Áo thun nam nữ các loại',              'CAT01'),
('CAT06', 'Điện thoại',           'Điện thoại thông minh',                'CAT02'),
('CAT07', 'Phụ kiện điện tử',     'Tai nghe, sạc, cáp',                   'CAT02'),
('CAT08', 'Đồ dùng nhà bếp',      'Nồi, chảo, dao, dụng cụ nấu ăn',       'CAT03');

INSERT INTO STORE (store_id, store_name, description, pickup_address, created_date, status, seller_id, approved_by, approved_at) VALUES
('ST01', 'Nam Fashion',      'Thời trang nam chính hãng',          '12 Nguyễn Trãi, P. Bến Thành, Q.1, TP.HCM',          '2024-02-05 09:00:00', 'Active', 'SL01', 'AD01', '2024-02-06 10:00:00'),
('ST02', 'Sơn Mobile',       'Điện thoại và phụ kiện chính hãng',  '45 Lê Văn Việt, P. Hiệp Phú, TP. Thủ Đức, TP.HCM',  '2024-02-12 09:30:00', 'Active', 'SL02', 'AD01', '2024-02-13 10:00:00'),
('ST03', 'Hạnh Home',        'Đồ gia dụng thông minh',             '88 Cách Mạng Tháng 8, P.5, Q.3, TP.HCM',             '2024-03-08 14:00:00', 'Active', 'SL03', 'AD02', '2024-03-09 09:00:00'),
('ST04', 'Bếp Việt',         'Dụng cụ nhà bếp cho gia đình Việt',  '5 Hoàng Hoa Thám, P.6, Q. Bình Thạnh, TP.HCM',       '2024-04-22 15:00:00', 'Active', 'SL04', 'AD03', '2024-04-23 08:30:00'),
('ST05', 'Sách Hay Trang Ly','Sách giáo trình đại học',            '20 Đường D1, Khu phố 6, P. Linh Trung, TP. Thủ Đức', '2024-05-04 16:00:00', 'Active', 'SL05', 'AD02', '2024-05-05 11:00:00');

-- ---------------------------------------------------------------------
-- GROUP 4: PRODUCT, ADDRESS, CART, COUPON
-- ---------------------------------------------------------------------
INSERT INTO PRODUCT (product_id, product_name, description, created_at, status, store_id, category_id) VALUES
('P01', 'Áo thun cotton basic',              'Áo thun cotton 100%, form regular',               '2024-02-20 09:00:00', 'Active',   'ST01', 'CAT05'),
('P02', 'Quần jean nam slimfit',             'Quần jean co giãn, màu xanh đậm',                 '2024-02-22 09:00:00', 'Active',   'ST01', 'CAT01'),
('P03', 'Điện thoại Galaxy A55',             'Màn hình Super AMOLED 6.6 inch, camera 50MP',     '2024-03-01 10:00:00', 'Active',   'ST02', 'CAT06'),
('P04', 'Tai nghe Bluetooth TWS',            'Chống ồn chủ động, pin 24 giờ',                   '2024-03-03 10:00:00', 'Active',   'ST02', 'CAT07'),
('P05', 'Sạc nhanh Type-C',                  'Củ sạc nhanh chuẩn PD, an toàn quá nhiệt',        '2024-03-20 11:00:00', 'Active',   'ST03', 'CAT07'),
('P06', 'Nồi chiên không dầu 5L',            'Công suất 1500W, 8 chế độ nấu',                   '2024-03-25 11:30:00', 'Active',   'ST03', 'CAT08'),
('P07', 'Bộ dao nhà bếp 5 món',              'Thép không gỉ, kèm đế cắm',                       '2024-05-01 08:00:00', 'Active',   'ST04', 'CAT08'),
('P08', 'Sách Cấu trúc dữ liệu và giải thuật','Giáo trình đại học, tái bản mới nhất',           '2024-05-10 08:30:00', 'Active',   'ST05', 'CAT04'),
('P09', 'Sách Hệ cơ sở dữ liệu',             'Giáo trình môn Hệ CSDL, có bài tập SQL',          '2024-05-12 08:30:00', 'Active',   'ST05', 'CAT04'),
('P10', 'Áo khoác gió',                      'Áo khoác gió 2 lớp chống nước (ngừng kinh doanh)','2024-06-01 09:00:00', 'Inactive', 'ST01', 'CAT01');

INSERT INTO ADDRESS (address_id, receiver_name, phone_number, house_number, street_name, ward_commune, province_city, buyer_id) VALUES
('AR01', 'Nguyễn Văn An',  '0933000001', '25',   'Lý Thường Kiệt',      'Phường 7',        'TP. Hồ Chí Minh', 'BY01'),
('AR02', 'Trần Thị Bình',  '0933000002', '102',  'Nguyễn Văn Cừ',       'Phường 4',        'TP. Hồ Chí Minh', 'BY02'),
('AR03', 'Lê Quốc Cường',  '0933000003', '7/3',  'Võ Văn Ngân',         'Phường Linh Chiểu','TP. Thủ Đức',    'BY03'),
('AR04', 'Phạm Thùy Dung', '0933000004', '58',   'Trần Hưng Đạo',       'Phường Cầu Ông Lãnh','TP. Hồ Chí Minh','BY04'),
('AR05', 'Hoàng Minh Em',  '0933000005', '14',   'Hai Bà Trưng',        'Phường Tân Định', 'TP. Hồ Chí Minh', 'BY05'),
('AR06', 'Nguyễn Văn An',  '0933000011', '9',    'Điện Biên Phủ',       'Phường 15',       'TP. Hồ Chí Minh', 'BY01');

INSERT INTO CART (cart_id, buyer_id) VALUES
('CT01', 'BY01'),
('CT02', 'BY02'),
('CT03', 'BY03'),
('CT04', 'BY04'),
('CT05', 'BY05');

INSERT INTO COUPON (coupon_id, coupon_code, coupon_type, discount_value, min_order_value, start_time, end_time, status, store_id) VALUES
('CP01', 'SYS20K',    'System', 20000, 100000, '2025-01-01 00:00:00', '2026-12-31 23:59:59', 'Active',   NULL),
('CP02', 'FREESHIP',  'System', 15000, 0,      '2025-01-01 00:00:00', '2026-12-31 23:59:59', 'Active',   NULL),
('CP03', 'NAM30K',    'Store',  30000, 200000, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 'Active',   'ST01'),
('CP04', 'SONMOBILE', 'Store',  100000,5000000,'2025-01-01 00:00:00', '2025-12-31 23:59:59', 'Active',   'ST02'),
('CP05', 'HOME50K',   'Store',  50000, 1000000,'2024-06-01 00:00:00', '2024-12-31 23:59:59', 'Inactive', 'ST03');

-- ---------------------------------------------------------------------
-- GROUP 5: VARIANT, PRODUCT_IMAGE
-- ---------------------------------------------------------------------
INSERT INTO VARIANT (variant_id, sku_code, color, size, unit_price, stock, status, product_id) VALUES
('V01', 'TSHIRT-BLK-M',  'Đen',    'M',     120000, 50,  'Active',   'P01'),
('V02', 'TSHIRT-WHT-L',  'Trắng',  'L',     120000, 40,  'Active',   'P01'),
('V03', 'TSHIRT-BLK-L',  'Đen',    'L',     125000, 35,  'Active',   'P01'),
('V04', 'JEAN-BLU-30',   'Xanh',   '30',    450000, 25,  'Active',   'P02'),
('V05', 'JEAN-BLU-32',   'Xanh',   '32',    450000, 20,  'Active',   'P02'),
('V06', 'A55-BLK-128',   'Đen',    '128GB', 8500000,10,  'Active',   'P03'),
('V07', 'A55-SLV-256',   'Bạc',    '256GB', 9900000,5,   'Active',   'P03'),
('V08', 'TWS-WHT',       'Trắng',  NULL,    350000, 60,  'Active',   'P04'),
('V09', 'CHG-20W-WHT',   'Trắng',  '20W',   180000, 100, 'Active',   'P05'),
('V10', 'AIRFRY-5L-BLK', 'Đen',    '5L',    1650000,15,  'Active',   'P06'),
('V11', 'KNIFE-SET5',    NULL,     '5 món', 420000, 30,  'Active',   'P07'),
('V12', 'BOOK-DSA',      NULL,     NULL,    95000,  40,  'Active',   'P08'),
('V13', 'BOOK-DBS',      NULL,     NULL,    110000, 35,  'Active',   'P09'),
('V14', 'WIND-GRN-M',    'Xanh lá','M',     280000, 0,   'Inactive', 'P10'),
('V15', 'CHG-25W-BLK',   'Đen',    '25W',   250000, 45,  'Active',   'P05');

INSERT INTO PRODUCT_IMAGE (product_id, display_order, image_path, is_thumbnail) VALUES
('P01', 1, '/images/products/p01_1.jpg', TRUE),
('P01', 2, '/images/products/p01_2.jpg', FALSE),
('P02', 1, '/images/products/p02_1.jpg', TRUE),
('P03', 1, '/images/products/p03_1.jpg', TRUE),
('P03', 2, '/images/products/p03_2.jpg', FALSE),
('P04', 1, '/images/products/p04_1.jpg', TRUE),
('P05', 1, '/images/products/p05_1.jpg', TRUE),
('P06', 1, '/images/products/p06_1.jpg', TRUE),
('P07', 1, '/images/products/p07_1.jpg', TRUE),
('P08', 1, '/images/products/p08_1.jpg', TRUE),
('P09', 1, '/images/products/p09_1.jpg', TRUE),
('P10', 1, '/images/products/p10_1.jpg', TRUE);

-- ---------------------------------------------------------------------
-- GROUP 6: CART_ITEM, SHOP_ORDER
-- ---------------------------------------------------------------------
INSERT INTO CART_ITEM (cart_id, variant_id, so_luong) VALUES
('CT01', 'V08', 1),
('CT01', 'V12', 2),
('CT02', 'V06', 1),
('CT02', 'V09', 2),
('CT03', 'V10', 1),
('CT04', 'V01', 3),
('CT04', 'V13', 1),
('CT05', 'V11', 1);

-- total_payment_amount là cột sinh tự động (GENERATED) nên không INSERT.
-- total_item_amount = tổng (quantity * unit_price_at_order) của ORDER_LINE.
INSERT INTO SHOP_ORDER (order_id, order_time, order_status, total_item_amount, shipping_fee, discount_amount,
                        order_recipient_name, order_phone, delivery_address_at_order_time,
                        buyer_id, store_id, address_id, coupon_id) VALUES
('O01', '2025-03-10 10:15:00', 'Delivered', 690000,  20000, 0,     'Nguyễn Văn An',  '0933000001', '25 Lý Thường Kiệt, Phường 7, TP. Hồ Chí Minh',           'BY01', 'ST01', 'AR01', NULL),
('O02', '2025-05-15 14:30:00', 'Delivered', 575000,  20000, 30000, 'Trần Thị Bình',  '0933000002', '102 Nguyễn Văn Cừ, Phường 4, TP. Hồ Chí Minh',           'BY02', 'ST01', 'AR02', 'CP03'),
('O03', '2025-06-20 09:45:00', 'Delivered', 8850000, 30000, 20000, 'Lê Quốc Cường',  '0933000003', '7/3 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức',        'BY03', 'ST02', 'AR03', 'CP01'),
('O04', '2025-08-05 19:20:00', 'Delivered', 2190000, 25000, 0,     'Phạm Thùy Dung', '0933000004', '58 Trần Hưng Đạo, Phường Cầu Ông Lãnh, TP. Hồ Chí Minh', 'BY04', 'ST03', 'AR04', NULL),
('O05', '2025-09-12 08:05:00', 'Delivered', 300000,  15000, 15000, 'Hoàng Minh Em',  '0933000005', '14 Hai Bà Trưng, Phường Tân Định, TP. Hồ Chí Minh',      'BY05', 'ST05', 'AR05', 'CP02'),
('O06', '2025-10-01 11:00:00', 'Shipping',  420000,  20000, 0,     'Nguyễn Văn An',  '0933000011', '9 Điện Biên Phủ, Phường 15, TP. Hồ Chí Minh',            'BY01', 'ST04', 'AR06', NULL),
('O07', '2025-11-02 21:10:00', 'Pending',   9900000, 30000, 0,     'Trần Thị Bình',  '0933000002', '102 Nguyễn Văn Cừ, Phường 4, TP. Hồ Chí Minh',           'BY02', 'ST02', 'AR02', NULL),
('O08', '2025-11-10 15:40:00', 'Cancelled', 500000,  25000, 0,     'Lê Quốc Cường',  '0933000003', '7/3 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức',        'BY03', 'ST03', 'AR03', NULL),
('O09', '2026-01-15 13:25:00', 'Delivered', 360000,  20000, 0,     'Phạm Thùy Dung', '0933000004', '58 Trần Hưng Đạo, Phường Cầu Ông Lãnh, TP. Hồ Chí Minh', 'BY04', 'ST01', 'AR04', NULL);

-- ---------------------------------------------------------------------
-- GROUP 7: ORDER_LINE, PAYMENT, SHIPMENT
-- ---------------------------------------------------------------------
INSERT INTO ORDER_LINE (order_id, sort_order, quantity, unit_price_at_order, product_name_at_order, variant_name_at_order, variant_id) VALUES
('O01', 1, 2, 120000,  'Áo thun cotton basic',              'Đen - M',          'V01'),
('O01', 2, 1, 450000,  'Quần jean nam slimfit',             'Xanh - 30',        'V04'),
('O02', 1, 1, 125000,  'Áo thun cotton basic',              'Đen - L',          'V03'),
('O02', 2, 1, 450000,  'Quần jean nam slimfit',             'Xanh - 32',        'V05'),
('O03', 1, 1, 8500000, 'Điện thoại Galaxy A55',             'Đen - 128GB',      'V06'),
('O03', 2, 1, 350000,  'Tai nghe Bluetooth TWS',            'Trắng',            'V08'),
('O04', 1, 3, 180000,  'Sạc nhanh Type-C',                  'Trắng - 20W',      'V09'),
('O04', 2, 1, 1650000, 'Nồi chiên không dầu 5L',            'Đen - 5L',         'V10'),
('O05', 1, 2, 95000,   'Sách Cấu trúc dữ liệu và giải thuật','Mặc định',        'V12'),
('O05', 2, 1, 110000,  'Sách Hệ cơ sở dữ liệu',             'Mặc định',         'V13'),
('O06', 1, 1, 420000,  'Bộ dao nhà bếp 5 món',              '5 món',            'V11'),
('O07', 1, 1, 9900000, 'Điện thoại Galaxy A55',             'Bạc - 256GB',      'V07'),
('O08', 1, 2, 250000,  'Sạc nhanh Type-C',                  'Đen - 25W',        'V15'),
('O09', 1, 3, 120000,  'Áo thun cotton basic',              'Trắng - L',        'V02');

-- amount = total_payment_amount của đơn tương ứng
INSERT INTO PAYMENT (payment_id, payment_method, amount, status, completion_time, order_id) VALUES
('PM01', 'COD',          710000,  'Paid',    '2025-03-13 16:00:00', 'O01'),
('PM02', 'BankTransfer', 565000,  'Paid',    '2025-05-15 14:32:00', 'O02'),
('PM03', 'BankTransfer', 8860000, 'Paid',    '2025-06-20 09:47:00', 'O03'),
('PM04', 'COD',          2215000, 'Paid',    '2025-08-08 10:30:00', 'O04'),
('PM05', 'COD',          300000,  'Paid',    '2025-09-14 17:00:00', 'O05'),
('PM06', 'COD',          440000,  'Pending', NULL,                  'O06'),
('PM07', 'BankTransfer', 9930000, 'Pending', NULL,                  'O07'),
('PM08', 'BankTransfer', 525000,  'Failed',  NULL,                  'O08'),
('PM09', 'COD',          380000,  'Paid',    '2026-01-18 11:15:00', 'O09');

INSERT INTO SHIPMENT (shipment_id, tracking_number, status, start_time, delivery_time, order_id) VALUES
('SH01', 'VN2025031001', 'Delivered',     '2025-03-11 08:00:00', '2025-03-13 16:00:00', 'O01'),
('SH02', 'VN2025051501', 'Delivered',     '2025-05-16 08:00:00', '2025-05-18 15:00:00', 'O02'),
('SH03', 'VN2025062001', 'Delivered',     '2025-06-21 08:30:00', '2025-06-23 12:00:00', 'O03'),
('SH04', 'VN2025080501', 'Delivered',     '2025-08-06 09:00:00', '2025-08-08 10:30:00', 'O04'),
('SH05', 'VN2025091201', 'Delivered',     '2025-09-13 08:00:00', '2025-09-14 17:00:00', 'O05'),
('SH06', 'VN2025100101', 'Shipping',      '2025-10-02 09:00:00', NULL,                  'O06'),
('SH07', 'VN2026011501', 'Delivered',     '2026-01-16 08:00:00', '2026-01-18 11:15:00', 'O09');

-- ---------------------------------------------------------------------
-- GROUP 8: REVIEW (chỉ đánh giá các dòng đơn đã giao)
-- ---------------------------------------------------------------------
INSERT INTO REVIEW (review_id, rating_score, content, reviewed_at_time, order_id, sort_order) VALUES
('RV01', 5, 'Áo mặc thoải mái, vải mát, giao hàng nhanh.',          '2025-03-15 20:00:00', 'O01', 1),
('RV02', 4, 'Quần đẹp, đúng size nhưng hơi dày.',                    '2025-03-15 20:05:00', 'O01', 2),
('RV03', 5, 'Quần jean co giãn tốt, shop đóng gói cẩn thận.',        '2025-05-20 09:30:00', 'O02', 2),
('RV04', 5, 'Điện thoại chính hãng, máy mới nguyên seal.',           '2025-06-25 18:00:00', 'O03', 1),
('RV05', 4, 'Nồi chiên chạy êm, dễ vệ sinh.',                        '2025-08-12 21:00:00', 'O04', 2),
('RV06', 5, 'Sách in rõ, nội dung đầy đủ, rất hữu ích cho môn học.', '2025-09-16 10:00:00', 'O05', 1),
('RV07', 3, 'Áo bình thường, màu hơi khác ảnh.',                     '2026-01-20 08:45:00', 'O09', 1);

-- =====================================================================
-- Kiểm tra nhanh số dòng mỗi bảng (yêu cầu: >= 5)
-- =====================================================================
SELECT 'ACCOUNT' AS tbl, COUNT(*) AS n FROM ACCOUNT UNION ALL
SELECT 'BUYER', COUNT(*) FROM BUYER UNION ALL
SELECT 'SELLER', COUNT(*) FROM SELLER UNION ALL
SELECT 'ADMIN', COUNT(*) FROM ADMIN UNION ALL
SELECT 'PHONE_NUMBER', COUNT(*) FROM PHONE_NUMBER UNION ALL
SELECT 'CATEGORY', COUNT(*) FROM CATEGORY UNION ALL
SELECT 'STORE', COUNT(*) FROM STORE UNION ALL
SELECT 'PRODUCT', COUNT(*) FROM PRODUCT UNION ALL
SELECT 'ADDRESS', COUNT(*) FROM ADDRESS UNION ALL
SELECT 'CART', COUNT(*) FROM CART UNION ALL
SELECT 'COUPON', COUNT(*) FROM COUPON UNION ALL
SELECT 'VARIANT', COUNT(*) FROM VARIANT UNION ALL
SELECT 'PRODUCT_IMAGE', COUNT(*) FROM PRODUCT_IMAGE UNION ALL
SELECT 'CART_ITEM', COUNT(*) FROM CART_ITEM UNION ALL
SELECT 'SHOP_ORDER', COUNT(*) FROM SHOP_ORDER UNION ALL
SELECT 'ORDER_LINE', COUNT(*) FROM ORDER_LINE UNION ALL
SELECT 'PAYMENT', COUNT(*) FROM PAYMENT UNION ALL
SELECT 'SHIPMENT', COUNT(*) FROM SHIPMENT UNION ALL
SELECT 'REVIEW', COUNT(*) FROM REVIEW;