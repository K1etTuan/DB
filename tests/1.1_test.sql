USE ShopeeDB;
START TRANSACTION;

-- 1. ACCOUNT: 1 Admin, 2 Seller, 2 Buyer
INSERT INTO ACCOUNT (account_id, username, `password`, name, birth_date, email, status) VALUES
('T_ADM',   't_admin',   'test123', 'Quan tri vien test', '1990-01-01', 't_admin@example.com', 'Active'),
('T_SELL1', 't_seller1', 'test123', 'Nguoi ban 1',       '1992-02-02', 't_sell1@example.com', 'Active'),
('T_SELL2', 't_seller2', 'test123', 'Nguoi ban 2',       '1993-03-03', 't_sell2@example.com', 'Active'),
('T_BUY1',  't_buyer1',  'test123', 'Nguoi mua 1',       '2002-04-04', 't_buy1@example.com',  'Active'),
('T_BUY2',  't_buyer2',  'test123', 'Nguoi mua 2',       '2003-05-05', 't_buy2@example.com',  'Active');

-- 2. Cac bang chuyen biet va so dien thoai
INSERT INTO ADMIN (account_id, admin_role) VALUES ('T_ADM', 'Moderator');
INSERT INTO SELLER (account_id, seller_type) VALUES
('T_SELL1', 'Individual'), ('T_SELL2', 'Business');
INSERT INTO BUYER (account_id, membership_tier) VALUES
('T_BUY1', 'Bronze'), ('T_BUY2', 'Silver');
INSERT INTO PHONE_NUMBER (account_id, phone_number) VALUES
('T_ADM', '0900000001'), ('T_SELL1', '0900000002'), ('T_SELL2', '0900000003'),
('T_BUY1', '0900000004'), ('T_BUY2', '0900000005');

-- 3. CATEGORY (danh muc goc va danh muc con)
INSERT INTO CATEGORY (category_id, category_name, description, parent_category_id) VALUES
('T_CAT1', 'Thoi trang test', 'Danh muc goc', NULL),
('T_CAT2', 'Ao thun test', 'Danh muc con', 'T_CAT1');

-- 4. STORE: mot cua hang CHO DUYET, mot cua hang DA DUYET
INSERT INTO STORE (store_id, store_name, pickup_address, status, seller_id, approved_by, approved_at) VALUES
('T_STORE1', 'Shop cho duyet', 'Quan 1, TP.HCM', 'Pending', 'T_SELL1', NULL, NULL),
('T_STORE2', 'Shop da duyet', 'Quan 3, TP.HCM', 'Active', 'T_SELL2', 'T_ADM', NOW());

-- 5. PRODUCT: san pham Active, Inactive va san pham cua shop Pending
INSERT INTO PRODUCT (product_id, product_name, description, status, store_id, category_id) VALUES
('T_PROD1', 'Ao thun active',  'San pham dang ban', 'Active',   'T_STORE2', 'T_CAT2'),
('T_PROD2', 'Ao thun inactive','San pham tam an',   'Inactive', 'T_STORE2', 'T_CAT2'),
('T_PROD3', 'Ao cua shop cho', 'Shop chua duyet',  'Active',   'T_STORE1', 'T_CAT2');

-- 6. PRODUCT_IMAGE: moi san pham toi da mot thumbnail
-- Duong dan gia chi dung de kiem thu database.
INSERT INTO PRODUCT_IMAGE (product_id, display_order, image_path, is_thumbnail) VALUES
('T_PROD1', 1, '/images/test_ao_mat_truoc.jpg', 1),
('T_PROD1', 2, '/images/test_ao_mat_sau.jpg',   0),
('T_PROD2', 1, '/images/test_ao_inactive.jpg',  1),
('T_PROD3', 1, '/images/test_ao_cho_duyet.jpg',1);

-- 7. VARIANT: Active, Inactive, stock it, va thuoc store cho duyet
INSERT INTO VARIANT (variant_id, sku_code, color, size, unit_price, stock, status, product_id) VALUES
('T_VAR1', 'T-SKU-001', 'Den',   'M', 100000, 20, 'Active',   'T_PROD1'),
('T_VAR2', 'T-SKU-002', 'Trang', 'L', 120000,  5, 'Inactive', 'T_PROD2'),
('T_VAR3', 'T-SKU-003', 'Xanh',  'M',  90000, 15, 'Active',   'T_PROD3'),
('T_VAR4', 'T-SKU-004', 'Den',   'L', 110000,  2, 'Active',   'T_PROD1');

-- 8. ADDRESS: moi Buyer co dia chi rieng
INSERT INTO ADDRESS (
    address_id, receiver_name, phone_number, house_number,
    street_name, ward_commune, province_city, buyer_id
) VALUES
('T_ADDR1', 'Nguoi mua 1', '0900000004', '12', 'Nguyen Trai', 'Phuong 1', 'TP.HCM', 'T_BUY1'),
('T_ADDR2', 'Nguoi mua 2', '0900000005', '34', 'Le Loi',      'Phuong 2', 'TP.HCM', 'T_BUY2');

-- 9. CART va CART_ITEM: chi them variant thuoc shop/product dang Active
INSERT INTO CART (cart_id, buyer_id) VALUES
('T_CART1', 'T_BUY1'), ('T_CART2', 'T_BUY2');
INSERT INTO CART_ITEM (cart_id, variant_id, so_luong) VALUES
('T_CART1', 'T_VAR1', 1);

-- 10. COUPON: ma toan he thong, ma cua shop, ma het han
INSERT INTO COUPON (
    coupon_id, coupon_code, coupon_type, discount_value,
    min_order_value, start_time, end_time, status, store_id
) VALUES
('T_CPSYS',   'TTEST_SYSTEM', 'System', 10000, 100000, '2020-01-01', '2030-12-31', 'Active', NULL),
('T_CPSTORE', 'TTEST_STORE',  'Store',  15000, 100000, '2020-01-01', '2030-12-31', 'Active', 'T_STORE2'),
('T_CPEXPIRE','TTEST_EXPIRE', 'System', 10000, 100000, '2020-01-01', '2021-01-01', 'Active', NULL);

-- 11. SHOP_ORDER: mot don Pending chua co ORDER_LINE; mot don de tao lich su mua
-- Quan trong: don moi total_item_amount=0, coupon_id=NULL, discount_amount=0.
INSERT INTO SHOP_ORDER (
    order_id, order_status, total_item_amount, shipping_fee, discount_amount,
    order_recipient_name, order_phone, delivery_address_at_order_time,
    buyer_id, store_id, address_id, coupon_id
) VALUES
('T_ORDNEW', 'Pending', 0, 5000, 0,
 'Nguoi mua 1', '0900000004', '12 Nguyen Trai, Phuong 1, TP.HCM',
 'T_BUY1', 'T_STORE2', 'T_ADDR1', NULL),
('T_ORDDONE', 'Pending', 0, 10000, 0,
 'Nguoi mua 2', '0900000005', '34 Le Loi, Phuong 2, TP.HCM',
 'T_BUY2', 'T_STORE2', 'T_ADDR2', NULL);

-- 12. ORDER_LINE: thanh tien = 2 * 100000 = 200000
-- Neu da cai trigger tinh tong va tru stock, MySQL tu cap nhat.
INSERT INTO ORDER_LINE (
    order_id, sort_order, quantity, unit_price_at_order,
    product_name_at_order, variant_name_at_order, variant_id
) VALUES
('T_ORDDONE', 1, 2, 100000, 'Ao thun active', 'Den - M', 'T_VAR1');

-- De bo du lieu nen dung ngay ca khi CHUA cai trigger tinh tong.
-- Neu da co trigger, tong tien da la 200000; UPDATE nay van hop le.
UPDATE SHOP_ORDER
SET total_item_amount = 200000
WHERE order_id = 'T_ORDDONE' AND total_item_amount = 0;

-- 13. PAYMENT: 200000 tien hang + 10000 phi van chuyen = 210000
INSERT INTO PAYMENT (payment_id, payment_method, amount, status, completion_time, order_id)
VALUES ('T_PAY1', 'COD', 210000, 'Paid', NOW(), 'T_ORDDONE');

-- 14. SHIPMENT: chi tao sau khi don da Confirmed
UPDATE SHOP_ORDER SET order_status = 'Confirmed' WHERE order_id = 'T_ORDDONE';
INSERT INTO SHIPMENT (shipment_id, tracking_number, status, start_time, delivery_time, order_id)
VALUES ('T_SHIP1', 'T_TRACK_001', 'WaitingPickup', NOW(), NULL, 'T_ORDDONE');
UPDATE SHOP_ORDER SET order_status = 'Shipping' WHERE order_id = 'T_ORDDONE';
UPDATE SHIPMENT SET status = 'Delivered', delivery_time = NOW() WHERE shipment_id = 'T_SHIP1';
UPDATE SHOP_ORDER SET order_status = 'Delivered' WHERE order_id = 'T_ORDDONE';

-- 15. REVIEW: chi duoc tao cho don Delivered
INSERT INTO REVIEW (review_id, rating_score, content, order_id, sort_order)
VALUES ('T_REV1', 5, 'San pham dung mo ta', 'T_ORDDONE', 1);

-- Test ràng buộc 1: Cửa hàng chỉ được chuyển sang trạng thái hoạt động sau khi được quản trị viên phê duyệt.
UPDATE STORE
SET status = 'Active'
WHERE store_id = 'T_STORE1';

-- Test ràng buộc 2: Mỗi sản phẩm có tối đa một hình ảnh được xác định là hình ảnh đại diện.
INSERT INTO PRODUCT_IMAGE (
    product_id,
    display_order,
    image_path,
    is_thumbnail
)
VALUES (
    'T_PROD1',
    3,
    '/images/test_thumbnail_2.jpg',
    1
);

-- Test ràng buộc 3: Người mua chỉ được thêm vào giỏ hàng những phân loại sản phẩm đang hoạt động và thuộc sản phẩm, cửa hàng đang hoạt động.
INSERT INTO CART_ITEM (cart_id, variant_id, so_luong)
VALUES ('T_CART1', 'T_VAR2', 1);

-- Test ràng buộc 4:  Các phân loại sản phẩm trong cùng một đơn hàng phải thuộc cửa hàng nhận đơn hàng đó.
INSERT INTO ORDER_LINE (
    order_id,
    sort_order,
    quantity,
    unit_price_at_order,
    product_name_at_order,
    variant_name_at_order,
    variant_id
)
VALUES (
    'T_ORDNEW',
    1,
    1,
    90000,
    'Ao cua shop cho',
    'Xanh - M',
    'T_VAR3'
);
-- Test ràng buộc 5: Số lượng đặt mua của mỗi phân loại sản phẩm không được vượt quá số lượng tồn kho tại thời điểm đặt hàng
INSERT INTO ORDER_LINE (
    order_id,
    sort_order,
    quantity,
    unit_price_at_order,
    product_name_at_order,
    variant_name_at_order,
    variant_id
)
VALUES (
    'T_ORDNEW',
    1,
    3,
    110000,
    'Ao thun active',
    'Den - L',
    'T_VAR4'
);
-- Test ràng buộc 6: Người mua chỉ được sử dụng địa chỉ nhận hàng thuộc tài khoản của chính mình khi đặt hàng.
UPDATE SHOP_ORDER
SET address_id = 'T_ADDR2'
WHERE order_id = 'T_ORDNEW';

-- Test ràng buộc 7: Mã giảm giá chỉ được áp dụng khi còn hiệu lực và đơn hàng đáp ứng giá trị tối thiểu. Mã giảm giá của cửa hàng chỉ được áp dụng cho đơn hàng thuộc cửa hàng đó.
UPDATE SHOP_ORDER
SET coupon_id = 'T_CPSYS'
WHERE order_id = 'T_ORDNEW';

-- Test ràng buộc 8: Tổng tiền thanh toán phải bằng tổng tiền sản phẩm cộng phí vận chuyển và trừ số tiền giảm giá. Số tiền giảm không được vượt quá tổng tiền sản phẩm.
-- TEST 8.1: Co tinh gan sai tong thanh toan
UPDATE SHOP_ORDER
SET total_payment_amount = 1
WHERE order_id = 'T_ORDDONE';
-- TEST 8.2: Giam gia lon hon tien hang
UPDATE SHOP_ORDER
SET discount_amount = total_item_amount + 1
WHERE order_id = 'T_ORDDONE';

-- Test ràng buộc 9: Thông tin vận chuyển chỉ được tạo sau khi đơn hàng đã được người bán xác nhận.
INSERT INTO SHIPMENT (
    shipment_id,
    tracking_number,
    status,
    start_time,
    delivery_time,
    order_id
)
VALUES (
    'T_SHIP_TEST9',
    'T_TRACK_TEST9',
    'WaitingPickup',
    NOW(),
    NULL,
    'T_ORDNEW'
);

-- Test ràng buộc 10:  Một đánh giá chỉ được tạo cho chi tiết đơn hàng thuộc đơn hàng đã được giao thành công.
INSERT INTO REVIEW (
    review_id,
    rating_score,
    content,
    order_id,
    sort_order
)
VALUES (
    'T_REV_TEST10',
    5,
    'San pham rat tot',
    'T_ORDNEW',
    1
);

ROLLBACK;