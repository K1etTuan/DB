USE ShopeeDB;

-- Xoa trigger cu cua phan 2.2 neu da ton tai (tranh loi trung ten khi chay lai)
DROP TRIGGER IF EXISTS trg_order_line_check_insert;
DROP TRIGGER IF EXISTS trg_order_line_check_update;
DROP TRIGGER IF EXISTS trg_order_line_check_delete;
DROP TRIGGER IF EXISTS trg_shop_order_check_update;
DROP TRIGGER IF EXISTS trg_order_line_after_insert;
DROP TRIGGER IF EXISTS trg_order_line_after_update;
DROP TRIGGER IF EXISTS trg_order_line_after_delete;
DROP TRIGGER IF EXISTS trg_shop_order_after_update;

DELIMITER $$
=
-- NHOM A: TRIGGER KIEM TRA RANG BUOC NGU NGHIA / NGHIEP VU (BEFORE)
-- (Bo sung day du va khong trung lap voi 1.1Semantic_constraints_trigger.sql)


-- 1. Kiem tra rang buoc ngu nghia khi them chi tiet don hang (ORDER_LINE)
--    - Don hang phai ton tai va dang o trang thai 'Pending'
--    - San pham (PRODUCT), phan loai (VARIANT) va cua hang (STORE) phai 'Active'
--    - Phan loai san pham phai thuoc dung cua hang nhan don hang
--    - Tong so luong cong don cua cung phan loai trong don <= ton kho
CREATE TRIGGER trg_order_line_check_insert
BEFORE INSERT ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_order_store VARCHAR(20) DEFAULT NULL;
    DECLARE v_order_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_variant_store VARCHAR(20) DEFAULT NULL;
    DECLARE v_store_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_product_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_variant_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_existing_qty INT DEFAULT 0;

    SELECT o.store_id, o.order_status
    INTO v_order_store, v_order_status
    FROM SHOP_ORDER o
    WHERE o.order_id = NEW.order_id;

    IF v_order_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Đơn hàng không tồn tại.';
    END IF;

    IF v_order_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Chỉ được thêm chi tiết khi đơn hàng đang ở trạng thái Pending.';
    END IF;

    SELECT p.store_id, s.status, p.status, v.status, v.stock
    INTO v_variant_store, v_store_status, v_product_status, v_variant_status, v_stock
    FROM VARIANT v
    JOIN PRODUCT p ON v.product_id = p.product_id
    JOIN STORE s ON p.store_id = s.store_id
    WHERE v.variant_id = NEW.variant_id;

    IF v_variant_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Phân loại sản phẩm không tồn tại.';
    END IF;

    IF v_variant_status <> 'Active'
       OR v_product_status <> 'Active'
       OR v_store_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Sản phẩm, phân loại hoặc cửa hàng hiện không còn hoạt động.';
    END IF;

    IF v_variant_store <> v_order_store THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Phân loại sản phẩm không thuộc cửa hàng nhận đơn hàng.';
    END IF;

    SELECT COALESCE(SUM(quantity), 0)
    INTO v_existing_qty
    FROM ORDER_LINE
    WHERE order_id = NEW.order_id
      AND variant_id = NEW.variant_id;

    IF (v_existing_qty + NEW.quantity) > v_stock THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Tổng số lượng đặt mua vượt quá số lượng tồn kho hiện tại.';
    END IF;
END$$


-- 2. Kiem tra rang buoc ngu nghia khi cap nhat chi tiet don hang (ORDER_LINE)
CREATE TRIGGER trg_order_line_check_update
BEFORE UPDATE ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_old_order_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_new_order_store VARCHAR(20) DEFAULT NULL;
    DECLARE v_new_order_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_variant_store VARCHAR(20) DEFAULT NULL;
    DECLARE v_store_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_product_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_variant_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_existing_qty INT DEFAULT 0;

    SELECT o.order_status
    INTO v_old_order_status
    FROM SHOP_ORDER o
    WHERE o.order_id = OLD.order_id;

    IF v_old_order_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Chỉ được sửa chi tiết khi đơn hàng đang ở trạng thái Pending.';
    END IF;

    SELECT o.store_id, o.order_status
    INTO v_new_order_store, v_new_order_status
    FROM SHOP_ORDER o
    WHERE o.order_id = NEW.order_id;

    IF v_new_order_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Đơn hàng mới không tồn tại.';
    END IF;

    IF v_new_order_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Đơn hàng đích phải đang ở trạng thái Pending.';
    END IF;

    SELECT p.store_id, s.status, p.status, v.status, v.stock
    INTO v_variant_store, v_store_status, v_product_status, v_variant_status, v_stock
    FROM VARIANT v
    JOIN PRODUCT p ON v.product_id = p.product_id
    JOIN STORE s ON p.store_id = s.store_id
    WHERE v.variant_id = NEW.variant_id;

    IF v_variant_store IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Phân loại sản phẩm không tồn tại.';
    END IF;

    IF v_variant_status <> 'Active'
       OR v_product_status <> 'Active'
       OR v_store_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Sản phẩm, phân loại hoặc cửa hàng hiện không còn hoạt động.';
    END IF;

    IF v_variant_store <> v_new_order_store THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Phân loại sản phẩm không thuộc cửa hàng nhận đơn hàng.';
    END IF;

    SELECT COALESCE(SUM(quantity), 0)
    INTO v_existing_qty
    FROM ORDER_LINE
    WHERE order_id = NEW.order_id
      AND variant_id = NEW.variant_id
      AND NOT (order_id = OLD.order_id AND sort_order = OLD.sort_order);

    IF (v_existing_qty + NEW.quantity) > v_stock THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Tổng số lượng đặt mua vượt quá số lượng tồn kho hiện tại.';
    END IF;
END$$


-- 3. Ngan chan xoa chi tiet don hang khi don da qua trang thai Pending
CREATE TRIGGER trg_order_line_check_delete
BEFORE DELETE ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_order_status VARCHAR(20) DEFAULT NULL;

    SELECT o.order_status
    INTO v_order_status
    FROM SHOP_ORDER o
    WHERE o.order_id = OLD.order_id;

    IF v_order_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Chỉ được xóa chi tiết khi đơn hàng đang ở trạng thái Pending.';
    END IF;
END$$


-- 4. Kiem tra rang buoc khi cap nhat don hang (SHOP_ORDER)
--    - Chan doi store_id neu don da co chi tiet thuoc cua hang khac
--    - Kiem tra vong doi chuyen trang thai order_status hop le
--    - Khi chuyen Pending -> Confirmed: don phai co san pham, con Active va du ton kho
CREATE TRIGGER trg_shop_order_check_update
BEFORE UPDATE ON SHOP_ORDER
FOR EACH ROW
BEGIN
    IF NEW.store_id <> OLD.store_id THEN
        IF EXISTS (
            SELECT 1
            FROM ORDER_LINE ol
            JOIN VARIANT v ON ol.variant_id = v.variant_id
            JOIN PRODUCT p ON v.product_id = p.product_id
            WHERE ol.order_id = NEW.order_id
              AND p.store_id <> NEW.store_id
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lỗi: Không thể đổi cửa hàng vì đã có chi tiết thuộc cửa hàng khác.';
        END IF;
    END IF;

    IF NEW.order_status <> OLD.order_status THEN
        IF NOT (
            (OLD.order_status = 'Pending'   AND NEW.order_status IN ('Confirmed', 'Cancelled'))
         OR (OLD.order_status = 'Confirmed' AND NEW.order_status IN ('Shipping', 'Cancelled'))
         OR (OLD.order_status = 'Shipping'  AND NEW.order_status = 'Delivered')
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lỗi: Chuyển đổi trạng thái đơn hàng không hợp lệ.';
        END IF;

        IF OLD.order_status = 'Pending' AND NEW.order_status = 'Confirmed' THEN
            IF NOT EXISTS (
                SELECT 1
                FROM ORDER_LINE
                WHERE order_id = NEW.order_id
            ) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Lỗi: Không thể xác nhận đơn hàng chưa có sản phẩm nào.';
            END IF;

            IF EXISTS (
                SELECT 1
                FROM (
                    SELECT ol.variant_id, SUM(ol.quantity) AS req_qty
                    FROM ORDER_LINE ol
                    WHERE ol.order_id = NEW.order_id
                    GROUP BY ol.variant_id
                ) req
                JOIN VARIANT v ON v.variant_id = req.variant_id
                JOIN PRODUCT p ON p.product_id = v.product_id
                JOIN STORE s ON s.store_id = p.store_id
                WHERE v.stock < req.req_qty
                   OR v.status <> 'Active'
                   OR p.status <> 'Active'
                   OR s.status <> 'Active'
            ) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Lỗi: Đơn có sản phẩm không đủ tồn kho hoặc ngừng hoạt động.';
            END IF;
        END IF;
    END IF;
END$$



-- NHOM B: TRIGGER TINH TOAN THUOC TINH DAN XUAT VA DONG BO DU LIEU (AFTER)


-- 5. Tu dong cap nhat total_item_amount sau khi them chi tiet don hang
CREATE TRIGGER trg_order_line_after_insert
AFTER INSERT ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2) DEFAULT 0;

    SELECT COALESCE(SUM(quantity * unit_price_at_order), 0)
    INTO v_new_total
    FROM ORDER_LINE
    WHERE order_id = NEW.order_id;

    UPDATE SHOP_ORDER
    SET
        total_item_amount = v_new_total,
        discount_amount = LEAST(discount_amount, v_new_total)
    WHERE order_id = NEW.order_id;
END$$


-- 6. Tu dong cap nhat total_item_amount (va coupon) sau khi sua chi tiet don hang
CREATE TRIGGER trg_order_line_after_update
AFTER UPDATE ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_old_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_new_coupon_id VARCHAR(20) DEFAULT NULL;
    DECLARE v_new_min_order DECIMAL(12,2) DEFAULT 0;
    DECLARE v_old_coupon_id VARCHAR(20) DEFAULT NULL;
    DECLARE v_old_min_order DECIMAL(12,2) DEFAULT 0;

    SELECT COALESCE(SUM(quantity * unit_price_at_order), 0)
    INTO v_new_total
    FROM ORDER_LINE
    WHERE order_id = NEW.order_id;

    SELECT o.coupon_id, COALESCE(c.min_order_value, 0)
    INTO v_new_coupon_id, v_new_min_order
    FROM SHOP_ORDER o
    LEFT JOIN COUPON c ON o.coupon_id = c.coupon_id
    WHERE o.order_id = NEW.order_id;

    UPDATE SHOP_ORDER
    SET
        total_item_amount = v_new_total,
        coupon_id = CASE
            WHEN v_new_coupon_id IS NOT NULL AND v_new_total < v_new_min_order THEN NULL
            ELSE coupon_id
        END,
        discount_amount = CASE
            WHEN v_new_coupon_id IS NOT NULL AND v_new_total < v_new_min_order THEN 0
            ELSE LEAST(discount_amount, v_new_total)
        END
    WHERE order_id = NEW.order_id;

    IF OLD.order_id <> NEW.order_id THEN
        SELECT COALESCE(SUM(quantity * unit_price_at_order), 0)
        INTO v_old_total
        FROM ORDER_LINE
        WHERE order_id = OLD.order_id;

        SELECT o.coupon_id, COALESCE(c.min_order_value, 0)
        INTO v_old_coupon_id, v_old_min_order
        FROM SHOP_ORDER o
        LEFT JOIN COUPON c ON o.coupon_id = c.coupon_id
        WHERE o.order_id = OLD.order_id;

        UPDATE SHOP_ORDER
        SET
            total_item_amount = v_old_total,
            coupon_id = CASE
                WHEN v_old_coupon_id IS NOT NULL AND v_old_total < v_old_min_order THEN NULL
                ELSE coupon_id
            END,
            discount_amount = CASE
                WHEN v_old_coupon_id IS NOT NULL AND v_old_total < v_old_min_order THEN 0
                ELSE LEAST(discount_amount, v_old_total)
            END
        WHERE order_id = OLD.order_id;
    END IF;
END$$


-- 7. Tu dong cap nhat total_item_amount (va coupon) sau khi xoa chi tiet don hang
CREATE TRIGGER trg_order_line_after_delete
AFTER DELETE ON ORDER_LINE
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_coupon_id VARCHAR(20) DEFAULT NULL;
    DECLARE v_min_order DECIMAL(12,2) DEFAULT 0;

    SELECT COALESCE(SUM(quantity * unit_price_at_order), 0)
    INTO v_new_total
    FROM ORDER_LINE
    WHERE order_id = OLD.order_id;

    SELECT o.coupon_id, COALESCE(c.min_order_value, 0)
    INTO v_coupon_id, v_min_order
    FROM SHOP_ORDER o
    LEFT JOIN COUPON c ON o.coupon_id = c.coupon_id
    WHERE o.order_id = OLD.order_id;

    UPDATE SHOP_ORDER
    SET
        total_item_amount = v_new_total,
        coupon_id = CASE
            WHEN v_coupon_id IS NOT NULL AND v_new_total < v_min_order THEN NULL
            ELSE coupon_id
        END,
        discount_amount = CASE
            WHEN v_coupon_id IS NOT NULL AND v_new_total < v_min_order THEN 0
            ELSE LEAST(discount_amount, v_new_total)
        END
    WHERE order_id = OLD.order_id;
END$$


-- 8. Tu dong dong bo PAYMENT.amount va VARIANT.stock khi SHOP_ORDER cap nhat
CREATE TRIGGER trg_shop_order_after_update
AFTER UPDATE ON SHOP_ORDER
FOR EACH ROW
BEGIN
    IF NEW.total_item_amount <> OLD.total_item_amount
       OR NEW.shipping_fee <> OLD.shipping_fee
       OR NEW.discount_amount <> OLD.discount_amount THEN
        UPDATE PAYMENT
        SET amount = NEW.total_item_amount + NEW.shipping_fee - NEW.discount_amount
        WHERE order_id = NEW.order_id
          AND status = 'Pending';
    END IF;

    IF OLD.order_status = 'Pending' AND NEW.order_status = 'Confirmed' THEN
        UPDATE VARIANT v
        JOIN (
            SELECT variant_id, SUM(quantity) AS total_qty
            FROM ORDER_LINE
            WHERE order_id = NEW.order_id
            GROUP BY variant_id
        ) agg ON v.variant_id = agg.variant_id
        SET v.stock = v.stock - agg.total_qty;
    END IF;

    IF OLD.order_status = 'Confirmed' AND NEW.order_status = 'Cancelled' THEN
        UPDATE VARIANT v
        JOIN (
            SELECT variant_id, SUM(quantity) AS total_qty
            FROM ORDER_LINE
            WHERE order_id = NEW.order_id
            GROUP BY variant_id
        ) agg ON v.variant_id = agg.variant_id
        SET v.stock = v.stock + agg.total_qty;
    END IF;
END$$

DELIMITER ;
