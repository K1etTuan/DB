USE ShopeeDB;

DROP PROCEDURE IF EXISTS sp_ThemSanPham;
DROP PROCEDURE IF EXISTS sp_CapNhatSanPham;
DROP PROCEDURE IF EXISTS sp_XoaSanPham;

DELIMITER $$

CREATE PROCEDURE sp_ThemSanPham (
    IN p_product_id   VARCHAR(255),
    IN p_product_name VARCHAR(255),
    IN p_description  TEXT,
    IN p_status       VARCHAR(255),
    IN p_store_id     VARCHAR(255),
    IN p_category_id  VARCHAR(255)
)
BEGIN
    SET p_product_id   = NULLIF(TRIM(p_product_id), '');
    SET p_product_name = NULLIF(TRIM(p_product_name), '');
    SET p_status       = COALESCE(NULLIF(TRIM(p_status), ''), 'Active');
    SET p_store_id     = NULLIF(TRIM(p_store_id), '');
    SET p_category_id  = NULLIF(TRIM(p_category_id), '');

    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_product_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm không được dài quá 20 ký tự.';
    END IF;

    IF p_product_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tên sản phẩm không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_product_name) > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tên sản phẩm không được dài quá 100 ký tự.';
    END IF;

    IF BINARY p_status NOT IN (BINARY 'Active', BINARY 'Inactive') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Trạng thái sản phẩm không hợp lệ: chỉ nhận Active hoặc Inactive.';
    END IF;

    IF p_store_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_store_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không được dài quá 20 ký tự.';
    END IF;

    IF p_category_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_category_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không được dài quá 20 ký tự.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM PRODUCT
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm đã tồn tại; vui lòng chọn mã khác.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM STORE
        WHERE store_id = p_store_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không tồn tại; không thể tạo sản phẩm.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM CATEGORY
        WHERE category_id = p_category_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không tồn tại; không thể tạo sản phẩm.';
    END IF;

    INSERT INTO PRODUCT (
        product_id,
        product_name,
        description,
        status,
        store_id,
        category_id
    )
    VALUES (
        p_product_id,
        p_product_name,
        p_description,
        p_status,
        p_store_id,
        p_category_id
    );
END$$

CREATE PROCEDURE sp_CapNhatSanPham (
    IN p_product_id   VARCHAR(255),
    IN p_product_name VARCHAR(255),
    IN p_description  TEXT,
    IN p_status       VARCHAR(255),
    IN p_store_id     VARCHAR(255),
    IN p_category_id  VARCHAR(255)
)
BEGIN
    SET p_product_id   = NULLIF(TRIM(p_product_id), '');
    SET p_product_name = NULLIF(TRIM(p_product_name), '');
    SET p_status       = NULLIF(TRIM(p_status), '');
    SET p_store_id     = NULLIF(TRIM(p_store_id), '');
    SET p_category_id  = NULLIF(TRIM(p_category_id), '');

    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm cần cập nhật không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_product_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm không được dài quá 20 ký tự.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM PRODUCT
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không tìm thấy sản phẩm cần cập nhật.';
    END IF;

    IF p_product_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tên sản phẩm không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_product_name) > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tên sản phẩm không được dài quá 100 ký tự.';
    END IF;

    IF p_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Trạng thái sản phẩm không được để trống khi cập nhật.';
    END IF;

    IF BINARY p_status NOT IN (BINARY 'Active', BINARY 'Inactive') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Trạng thái sản phẩm không hợp lệ: chỉ nhận Active hoặc Inactive.';
    END IF;

    IF p_store_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_store_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không được dài quá 20 ký tự.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM STORE
        WHERE store_id = p_store_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã cửa hàng không tồn tại; không thể cập nhật sản phẩm.';
    END IF;

    IF p_category_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_category_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không được dài quá 20 ký tự.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM CATEGORY
        WHERE category_id = p_category_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã danh mục không tồn tại; không thể cập nhật sản phẩm.';
    END IF;

    UPDATE PRODUCT
    SET product_name = p_product_name,
        description  = p_description,
        status        = p_status,
        store_id      = p_store_id,
        category_id   = p_category_id
    WHERE product_id = p_product_id;
END$$

CREATE PROCEDURE sp_XoaSanPham (
    IN p_product_id VARCHAR(255)
)
BEGIN
    SET p_product_id = NULLIF(TRIM(p_product_id), '');

    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm cần xóa không được để trống.';
    END IF;

    IF CHAR_LENGTH(p_product_id) > 20 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã sản phẩm không được dài quá 20 ký tự.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM PRODUCT
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không tìm thấy sản phẩm cần xóa.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM VARIANT
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể xóa sản phẩm vì đã có phân loại liên kết; hãy chuyển trạng thái sản phẩm sang Inactive.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM PRODUCT_IMAGE
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể xóa sản phẩm vì vẫn còn hình ảnh liên kết; hãy xóa hình ảnh trước.';
    END IF;

    DELETE FROM PRODUCT
    WHERE product_id = p_product_id;
END$$

DELIMITER ;
