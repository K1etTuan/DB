-- Prerequisites: database/1.1_schema.sql and database/2.1_product_crud_procedures.sql.
-- Run this file in MySQL Workbench; all fixture data is rolled back.
USE ShopeeDB;

DROP PROCEDURE IF EXISTS sp_test_2_1_expect_error;
DROP PROCEDURE IF EXISTS sp_test_2_1_product_crud;

DELIMITER $$

CREATE PROCEDURE sp_test_2_1_expect_error (
    IN p_test_case VARCHAR(40)
)
BEGIN
    DECLARE v_error_caught BOOLEAN DEFAULT FALSE;
    DECLARE v_error_message VARCHAR(128);

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
            SET v_error_caught = TRUE;

        CASE p_test_case
            WHEN 'duplicate_id' THEN
                CALL sp_ThemSanPham(
                    'T21_PRODUCT', 'Duplicate Product', NULL,
                    'Active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'empty_name' THEN
                CALL sp_ThemSanPham(
                    'T21_EMPTY', '   ', NULL,
                    'Active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'long_id' THEN
                CALL sp_ThemSanPham(
                    'T21_XXXXXXXXXXXXXXXXX', 'Long ID', NULL,
                    'Active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'long_name' THEN
                CALL sp_ThemSanPham(
                    'T21_LONG_NAME', REPEAT('N', 101), NULL,
                    'Active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'invalid_status' THEN
                CALL sp_ThemSanPham(
                    'T21_STATUS', 'Invalid Status', NULL,
                    'active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'unknown_store' THEN
                CALL sp_ThemSanPham(
                    'T21_STORE_ERR', 'Unknown Store', NULL,
                    'Active', 'T21_MISSING', 'T21_CATEGORY'
                );
            WHEN 'unknown_category' THEN
                CALL sp_ThemSanPham(
                    'T21_CATEGORY_ERR', 'Unknown Category', NULL,
                    'Active', 'T21_STORE', 'T21_MISSING'
                );
            WHEN 'missing_update' THEN
                CALL sp_CapNhatSanPham(
                    'T21_MISSING', 'Missing Product', NULL,
                    'Active', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'empty_update_status' THEN
                CALL sp_CapNhatSanPham(
                    'T21_PRODUCT', 'Updated Product', NULL,
                    '', 'T21_STORE', 'T21_CATEGORY'
                );
            WHEN 'missing_delete' THEN
                CALL sp_XoaSanPham('T21_MISSING');
            WHEN 'delete_with_variant' THEN
                CALL sp_XoaSanPham('T21_PRODUCT');
            WHEN 'delete_with_image' THEN
                CALL sp_XoaSanPham('T21_PRODUCT');
            ELSE
                SET v_error_message = CONCAT(
                    'Unknown 2.1 test case: ', p_test_case
                );
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = v_error_message;
        END CASE;
    END;

    IF NOT v_error_caught THEN
        SET v_error_message = CONCAT(
            'Expected validation error was not raised for: ', p_test_case
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_error_message;
    END IF;
END$$

CREATE PROCEDURE sp_test_2_1_product_crud ()
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);
    DECLARE v_error_message VARCHAR(128);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF EXISTS (
        SELECT 1
        FROM ACCOUNT
        WHERE account_id = 'T21_SELLER'
    ) OR EXISTS (
        SELECT 1
        FROM STORE
        WHERE store_id = 'T21_STORE'
    ) OR EXISTS (
        SELECT 1
        FROM CATEGORY
        WHERE category_id = 'T21_CATEGORY'
    ) OR EXISTS (
        SELECT 1
        FROM PRODUCT
        WHERE product_id LIKE 'T21_%'
    ) OR EXISTS (
        SELECT 1
        FROM VARIANT
        WHERE variant_id = 'T21_VARIANT'
    ) OR EXISTS (
        SELECT 1
        FROM PRODUCT_IMAGE
        WHERE product_id = 'T21_PRODUCT'
    ) THEN
        SET v_error_message =
            'Reserved T21_ test IDs already exist; remove them before running this test.';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_error_message;
    END IF;

    INSERT INTO ACCOUNT (
        account_id, username, `password`, name, birth_date, email, status
    )
    VALUES (
        'T21_SELLER', 't21_seller', 'testpass', 'Test Seller',
        '1990-01-01', 't21_seller@example.com', 'Active'
    );

    INSERT INTO SELLER (account_id, seller_type)
    VALUES ('T21_SELLER', 'Individual');

    INSERT INTO STORE (
        store_id, store_name, pickup_address, status, seller_id
    )
    VALUES (
        'T21_STORE', 'Test Store', 'Test address', 'Pending', 'T21_SELLER'
    );

    INSERT INTO CATEGORY (category_id, category_name)
    VALUES ('T21_CATEGORY', 'Test Category');

    CALL sp_ThemSanPham(
        'T21_PRODUCT', 'Test Product', 'Initial description',
        '', 'T21_STORE', 'T21_CATEGORY'
    );

    SELECT COUNT(*), MAX(status)
    INTO v_count, v_status
    FROM PRODUCT
    WHERE product_id = 'T21_PRODUCT';

    IF v_count <> 1 OR v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Create test failed: product/default status mismatch.';
    END IF;

    CALL sp_CapNhatSanPham(
        'T21_PRODUCT', 'Updated Product', 'Updated description',
        'Inactive', 'T21_STORE', 'T21_CATEGORY'
    );

    SELECT COUNT(*), MAX(status)
    INTO v_count, v_status
    FROM PRODUCT
    WHERE product_id = 'T21_PRODUCT'
      AND product_name = 'Updated Product'
      AND description = 'Updated description';

    IF v_count <> 1 OR v_status <> 'Inactive' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update test failed: product values were not updated.';
    END IF;

    CALL sp_test_2_1_expect_error('duplicate_id');
    CALL sp_test_2_1_expect_error('empty_name');
    CALL sp_test_2_1_expect_error('long_id');
    CALL sp_test_2_1_expect_error('long_name');
    CALL sp_test_2_1_expect_error('invalid_status');
    CALL sp_test_2_1_expect_error('unknown_store');
    CALL sp_test_2_1_expect_error('unknown_category');
    CALL sp_test_2_1_expect_error('missing_update');
    CALL sp_test_2_1_expect_error('empty_update_status');
    CALL sp_test_2_1_expect_error('missing_delete');

    SELECT status
    INTO v_status
    FROM PRODUCT
    WHERE product_id = 'T21_PRODUCT';

    IF v_status <> 'Inactive' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rejected update changed the existing product.';
    END IF;

    INSERT INTO VARIANT (
        variant_id, sku_code, unit_price, stock, status, product_id
    )
    VALUES (
        'T21_VARIANT', 'T21-SKU', 1.00, 0, 'Active', 'T21_PRODUCT'
    );

    CALL sp_test_2_1_expect_error('delete_with_variant');

    DELETE FROM VARIANT
    WHERE variant_id = 'T21_VARIANT';

    INSERT INTO PRODUCT_IMAGE (
        product_id, display_order, image_path, is_thumbnail
    )
    VALUES (
        'T21_PRODUCT', 1, 'test/t21-product.jpg', TRUE
    );

    CALL sp_test_2_1_expect_error('delete_with_image');

    DELETE FROM PRODUCT_IMAGE
    WHERE product_id = 'T21_PRODUCT';

    CALL sp_XoaSanPham('T21_PRODUCT');

    SELECT COUNT(*)
    INTO v_count
    FROM PRODUCT
    WHERE product_id = 'T21_PRODUCT';

    IF v_count <> 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Delete test failed: product still exists.';
    END IF;

    ROLLBACK;

    SELECT 'PASS: 2.1 product CRUD tests completed; fixture data rolled back.'
        AS test_result;
END$$

DELIMITER ;

CALL sp_test_2_1_product_crud();

DROP PROCEDURE IF EXISTS sp_test_2_1_product_crud;
DROP PROCEDURE IF EXISTS sp_test_2_1_expect_error;
