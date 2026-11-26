USE ShopeeDB;

DROP PROCEDURE IF EXISTS sp_TimKiemSanPham;
DROP PROCEDURE IF EXISTS sp_ThongKeDoanhThuCuaHang;

DELIMITER $$

-- =====================================================================
-- THỦ TỤC 1: Tìm kiếm sản phẩm (kèm biến thể, danh mục, cửa hàng)
--   Tham số (NULL hoặc '' = không lọc):
--     p_keyword     : từ khóa trong tên sản phẩm hoặc mã SKU
--     p_category_id : mã danh mục
--     p_store_id    : mã cửa hàng
--     p_status      : trạng thái sản phẩm ('Active' / 'Inactive')
--     p_min_price   : giá biến thể tối thiểu
--     p_max_price   : giá biến thể tối đa
-- =====================================================================
CREATE PROCEDURE sp_TimKiemSanPham (
    IN p_keyword     VARCHAR(100),
    IN p_category_id VARCHAR(20),
    IN p_store_id    VARCHAR(20),
    IN p_status      VARCHAR(20),
    IN p_min_price   DECIMAL(12,2),
    IN p_max_price   DECIMAL(12,2)
)
BEGIN
    -- Chuẩn hóa tham số: chuỗi rỗng coi như không lọc
    SET p_keyword     = NULLIF(TRIM(p_keyword), '');
    SET p_category_id = NULLIF(TRIM(p_category_id), '');
    SET p_store_id    = NULLIF(TRIM(p_store_id), '');
    SET p_status      = NULLIF(TRIM(p_status), '');

    -- Kiểm tra tham số đầu vào
    IF p_status IS NOT NULL AND p_status NOT IN ('Active', 'Inactive') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Trạng thái sản phẩm không hợp lệ: chỉ nhận Active hoặc Inactive.';
    END IF;

    IF p_min_price IS NOT NULL AND p_min_price < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Giá tối thiểu không được là số âm.';
    END IF;

    IF p_max_price IS NOT NULL AND p_max_price < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Giá tối đa không được là số âm.';
    END IF;

    IF p_min_price IS NOT NULL AND p_max_price IS NOT NULL
       AND p_min_price > p_max_price THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Giá tối thiểu không được lớn hơn giá tối đa.';
    END IF;

    IF p_category_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM CATEGORY WHERE category_id = p_category_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không tồn tại.';
    END IF;

    IF p_store_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM STORE WHERE store_id = p_store_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không tồn tại.';
    END IF;

    -- Truy vấn hiển thị
    SELECT
        P.product_id,
        P.product_name,
        C.category_id,
        C.category_name,
        S.store_id,
        S.store_name,
        V.variant_id,
        V.sku_code,
        V.color,
        V.size,
        V.unit_price,
        V.stock,
        P.status AS product_status,
        V.status AS variant_status,
        P.created_at
    FROM PRODUCT  P
    JOIN STORE    S ON S.store_id    = P.store_id
    JOIN CATEGORY C ON C.category_id = P.category_id
    JOIN VARIANT  V ON V.product_id  = P.product_id
    WHERE (p_keyword     IS NULL
            OR P.product_name LIKE CONCAT('%', p_keyword, '%') COLLATE utf8mb4_0900_as_ci
            OR V.sku_code     LIKE CONCAT('%', p_keyword, '%') COLLATE utf8mb4_0900_as_ci)
      AND (p_category_id IS NULL OR P.category_id = p_category_id)
      AND (p_store_id    IS NULL OR P.store_id    = p_store_id)
      AND (p_status      IS NULL OR P.status      = p_status)
      AND (p_min_price   IS NULL OR V.unit_price >= p_min_price)
      AND (p_max_price   IS NULL OR V.unit_price <= p_max_price)
    ORDER BY P.product_name ASC, V.unit_price ASC;
END$$


-- =====================================================================
-- THỦ TỤC 2: Thống kê doanh thu theo cửa hàng
--   Tham số:
--     p_from_date   : từ ngày (bắt buộc)
--     p_to_date     : đến ngày, tính cả ngày này (bắt buộc)
--     p_seller_type : 'Individual' / 'Business' (NULL = tất cả)
--     p_min_revenue : doanh thu tối thiểu để cửa hàng được liệt kê
--                     (HAVING; NULL = 0)
-- =====================================================================
CREATE PROCEDURE sp_ThongKeDoanhThuCuaHang (
    IN p_from_date   DATE,
    IN p_to_date     DATE,
    IN p_seller_type VARCHAR(20),
    IN p_min_revenue DECIMAL(12,2)
)
BEGIN
    SET p_seller_type = NULLIF(TRIM(p_seller_type), '');
    SET p_min_revenue = IFNULL(p_min_revenue, 0);

    -- Kiểm tra tham số đầu vào
    IF p_from_date IS NULL OR p_to_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phải nhập đầy đủ từ ngày nào đến ngày nào.';
    END IF;

    IF p_from_date > p_to_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vui lòng nhập khoảng thời gian hợp lệ.';
    END IF;

    IF p_seller_type IS NOT NULL
       AND p_seller_type NOT IN ('Individual', 'Business') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loại người bán không hợp lệ: chỉ nhận Individual hoặc Business.';
    END IF;

    IF p_min_revenue < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Doanh thu tối thiểu không được là số âm.';
    END IF;

    -- Truy vấn hiển thị
    SELECT
        S.store_id,
        S.store_name,
        SE.seller_type,
        COUNT(DISTINCT O.order_id)                    AS total_orders,
        SUM(OL.quantity)                              AS total_items_sold,
        SUM(OL.quantity * OL.unit_price_at_order)     AS total_revenue,
        ROUND(SUM(OL.quantity * OL.unit_price_at_order)
              / COUNT(DISTINCT O.order_id), 2)        AS avg_revenue_per_order
    FROM STORE      S
    JOIN SELLER     SE ON SE.account_id = S.seller_id
    JOIN SHOP_ORDER O  ON O.store_id    = S.store_id
    JOIN ORDER_LINE OL ON OL.order_id   = O.order_id
    WHERE O.order_status = 'Delivered'
      AND O.order_time  >= p_from_date
      AND O.order_time  <  DATE_ADD(p_to_date, INTERVAL 1 DAY)
      AND (p_seller_type IS NULL OR SE.seller_type = p_seller_type)
    GROUP BY S.store_id, S.store_name, SE.seller_type
    HAVING SUM(OL.quantity * OL.unit_price_at_order) >= p_min_revenue
    ORDER BY total_revenue DESC, S.store_name ASC;
END$$

