USE ShopeeDB;

DELIMITER $$

CREATE FUNCTION fn_total_purchased_quantity(
    p_buyer_id VARCHAR(20)
)
RETURNS INT
READS SQL DATA
BEGIN
    -- 1. Khai bao bien
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_quantity INT;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    -- 2. Khai bao Cursor
    DECLARE cur_order_lines CURSOR FOR
        SELECT ol.quantity
        FROM ORDER_LINE ol
        JOIN SHOP_ORDER o
            ON ol.order_id = o.order_id
        WHERE o.buyer_id = p_buyer_id
          AND o.order_status = 'Delivered';

    -- 3. Bao hieu khi Cursor het du lieu
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;

    -- 4. Kiem tra tham so dau vao
    IF p_buyer_id IS NULL OR TRIM(p_buyer_id) = '' THEN
        RETURN -1;
    END IF;

    SELECT COUNT(*)
    INTO v_exists
    FROM BUYER
    WHERE account_id = p_buyer_id;

    IF v_exists = 0 THEN
        RETURN -1;
    END IF;

    -- 5. Mo Cursor
    OPEN cur_order_lines;

    -- 6. Duyet tung dong san pham
    read_loop: LOOP
        FETCH cur_order_lines INTO v_quantity;

        IF v_done THEN
            LEAVE read_loop;
        END IF;

        SET v_total = v_total + v_quantity;
    END LOOP;

    -- 7. Dong Cursor
    CLOSE cur_order_lines;

    -- 8. Tra ve ket qua
    RETURN v_total;
END$$

DELIMITER ;

DELIMITER $$

-- FUNCTION 2: GOI Y SO LUONG NHAP THEM
CREATE FUNCTION fn_suggest_restock(
    p_variant_id VARCHAR(20),
    p_days INT
)
RETURNS INT
READS SQL DATA
BEGIN
    -- 1. Khai bao bien
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_quantity INT;
    DECLARE v_order_time DATETIME;

    DECLARE v_recent INT DEFAULT 0;
    DECLARE v_previous INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;

    DECLARE v_now DATETIME DEFAULT NOW();
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    -- 2. Khai bao Cursor
    DECLARE cur_sales CURSOR FOR
        SELECT ol.quantity, o.order_time
        FROM ORDER_LINE ol
        JOIN SHOP_ORDER o
            ON ol.order_id = o.order_id
        WHERE ol.variant_id = p_variant_id
          AND o.order_status = 'Delivered'
          AND o.order_time >= v_now - INTERVAL 14 DAY
          AND o.order_time <= v_now;

    -- 3. Handler khi Cursor het du lieu
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = TRUE;

    -- 4. Kiem tra tham so dau vao
    IF p_variant_id IS NULL
       OR TRIM(p_variant_id) = ''
       OR p_days IS NULL
       OR p_days <= 0 THEN
        RETURN -1;
    END IF;

    -- 5. Kiem tra Variant va lay ton kho
    SELECT COUNT(*), COALESCE(MAX(stock), 0)
    INTO v_exists, v_stock
    FROM VARIANT
    WHERE variant_id = p_variant_id;

    IF v_exists = 0 THEN
        RETURN -1;
    END IF;

    -- 6. Mo Cursor
    OPEN cur_sales;

    -- 7. Duyet lich su ban hang
    read_loop: LOOP
        FETCH cur_sales INTO v_quantity, v_order_time;

        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Ban trong 7 ngay gan nhat
        IF v_order_time >= v_now - INTERVAL 7 DAY THEN
            SET v_recent = v_recent + v_quantity;

        -- Ban trong 7 ngay truoc do
        ELSE
            SET v_previous = v_previous + v_quantity;
        END IF;

    END LOOP;

    -- 8. Dong Cursor
    CLOSE cur_sales;

    -- 9. Tinh so luong can nhap them
    SET v_result = GREATEST(
        0,
        CEIL(
            ((v_recent * 0.7 + v_previous * 0.3) / 7)
            * p_days
        ) - v_stock
    );

    -- 10. Tra ve ket qua
    RETURN v_result;
END$$

DELIMITER ;
