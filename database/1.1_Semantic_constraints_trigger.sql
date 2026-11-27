DELIMITER $$

-- Ràng buộc 3:

-- 1. Kiem tra khi INSERT vao CART_ITEM
CREATE TRIGGER trg_cart_item_bi
BEFORE INSERT ON CART_ITEM
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM VARIANT v
        JOIN PRODUCT p ON v.product_id = p.product_id
        JOIN STORE s ON p.store_id = s.store_id
        WHERE v.variant_id = NEW.variant_id
          AND v.status = 'Active'
          AND p.status = 'Active'
          AND s.status = 'Active'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Khong the them san pham khong hoat dong vao gio';
    END IF;
END$$

-- Ràng buộc 4:
DELIMITER $$
CREATE TRIGGER trg_order_line_bi
BEFORE INSERT ON ORDER_LINE
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM SHOP_ORDER o
        JOIN VARIANT v
            ON v.variant_id = NEW.variant_id
        JOIN PRODUCT p
            ON p.product_id = v.product_id
        WHERE o.order_id = NEW.order_id
          AND p.store_id = o.store_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Variant khong thuoc store nhan don hang';
    END IF;
END$$

-- Ràng buộc 5:
DELIMITER $$
CREATE TRIGGER trg_order_line_stock_bi
BEFORE INSERT ON ORDER_LINE
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM VARIANT v
        WHERE v.variant_id = NEW.variant_id
          AND v.stock >= NEW.quantity
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'So luong dat mua vuot qua ton kho';
    END IF;
END$$

-- Ràng buộc 7: 
DELIMITER $$
CREATE TRIGGER trg_coupon_bu
BEFORE UPDATE ON SHOP_ORDER
FOR EACH ROW
BEGIN
    IF NEW.coupon_id IS NOT NULL
       AND NOT (NEW.coupon_id <=> OLD.coupon_id) THEN

        IF NOT EXISTS (
            SELECT 1
            FROM COUPON c
            WHERE c.coupon_id = NEW.coupon_id
              AND c.status = 'Active'
              AND NEW.order_time BETWEEN c.start_time AND c.end_time
              AND NEW.total_item_amount >= c.min_order_value
              AND (
                  c.coupon_type = 'System'
                  OR (
                      c.coupon_type = 'Store'
                      AND c.store_id = NEW.store_id
                  )
              )
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Ma giam gia khong du dieu kien ap dung';
        END IF;

    END IF;
END$$

-- Ràng buộc 9: 
DELIMITER $$
CREATE TRIGGER trg_shipment_bi
BEFORE INSERT ON SHIPMENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM SHOP_ORDER o
        WHERE o.order_id = NEW.order_id
          AND o.order_status IN (
              'Confirmed', 'Shipping', 'Delivered'
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Don chua Confirmed, khong duoc tao Shipment';
    END IF;
END$$

-- Ràng buộc 10:
DELIMITER $$
CREATE TRIGGER trg_review_bi
BEFORE INSERT ON REVIEW
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM ORDER_LINE ol
        JOIN SHOP_ORDER o
            ON ol.order_id = o.order_id
        WHERE ol.order_id = NEW.order_id
          AND ol.sort_order = NEW.sort_order
          AND o.order_status = 'Delivered'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Don hang chua Delivered, khong the danh gia';
    END IF;
END$$