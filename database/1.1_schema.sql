DROP DATABASE IF EXISTS ShopeeDB;
CREATE DATABASE ShopeeDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE ShopeeDB;

-- =============================================
-- GROUP 1: ACCOUNT
-- =============================================

CREATE TABLE ACCOUNT (
    account_id VARCHAR(20) NOT NULL,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(100) NOT NULL,
    create_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_account
        PRIMARY KEY (account_id),

    -- Unique Constraints
    CONSTRAINT uq_account_username
        UNIQUE (username),

    -- Check Constraints
    CONSTRAINT chk_account_username
        CHECK (TRIM(username) <> ''),

    CONSTRAINT chk_account_password
        CHECK (TRIM(password) <> ''),

    CONSTRAINT chk_account_name
        CHECK (TRIM(name) <> ''),

    CONSTRAINT chk_account_email
        CHECK (TRIM(email) <> ''),
        
	CONSTRAINT chk_account_status
    CHECK (status IN ('Active', 'Inactive', 'Locked'))
);

-- =============================================
-- GROUP 2: BUYER, SELLER, ADMIN, PHONE_NUMBER
-- =============================================

-- 1. BUYER
CREATE TABLE BUYER (
    account_id VARCHAR(20) NOT NULL,
    membership_tier VARCHAR(20) NOT NULL DEFAULT 'Bronze',

    CONSTRAINT pk_buyer
        PRIMARY KEY (account_id),

    CONSTRAINT fk_buyer_account
        FOREIGN KEY (account_id)
        REFERENCES ACCOUNT(account_id),

    CONSTRAINT chk_membership_tier
        CHECK (membership_tier IN ('Bronze', 'Silver', 'Gold'))
);

-- 2. SELLER
CREATE TABLE SELLER (
    account_id VARCHAR(20) NOT NULL,
    seller_type VARCHAR(20) NOT NULL,

    CONSTRAINT pk_seller
        PRIMARY KEY (account_id),

    CONSTRAINT fk_seller_account
        FOREIGN KEY (account_id)
        REFERENCES ACCOUNT(account_id),

    CONSTRAINT chk_seller_type
        CHECK (seller_type IN ('Individual', 'Business'))
);

-- 3. ADMIN
CREATE TABLE ADMIN (
    account_id VARCHAR(20) NOT NULL,
    admin_role VARCHAR(20) NOT NULL,

    CONSTRAINT pk_admin
        PRIMARY KEY (account_id),

    CONSTRAINT fk_admin_account
        FOREIGN KEY (account_id)
        REFERENCES ACCOUNT(account_id),

    CONSTRAINT chk_admin_role
        CHECK (admin_role IN ('SuperAdmin', 'Moderator'))
);
-- 4. PHONE_NUMBER
CREATE TABLE PHONE_NUMBER (
    account_id VARCHAR(20) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,

    CONSTRAINT pk_phone_number
        PRIMARY KEY (account_id, phone_number),

    CONSTRAINT fk_phone_number_account
        FOREIGN KEY (account_id)
        REFERENCES ACCOUNT(account_id)
);

-- =============================================
-- GROUP 3: CATEGORY, STORE
-- =============================================

-- 1. CATEGORY
CREATE TABLE CATEGORY (
    category_id VARCHAR(20) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id VARCHAR(20),

    -- Primary Key
    CONSTRAINT pk_category
        PRIMARY KEY (category_id),

    -- Foreign Key (Self-reference)
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES CATEGORY(category_id),

    -- Check Constraints
    CONSTRAINT chk_category_name
        CHECK (TRIM(category_name) <> ''),

    CONSTRAINT chk_category_parent
        CHECK (
            parent_category_id IS NULL
            OR parent_category_id <> category_id
        )
);

-- 2. STORE
CREATE TABLE STORE (
    store_id VARCHAR(20) NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    description TEXT,
    pickup_address VARCHAR(255) NOT NULL,
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    seller_id VARCHAR(20) NOT NULL,
    approved_by VARCHAR(20),
    approved_at DATETIME,

    -- Primary Key
    CONSTRAINT pk_store
        PRIMARY KEY (store_id),

    -- Unique Constraints
    -- 1 seller chỉ có 1 cửa hàng duy nhất
    CONSTRAINT uq_store_seller
        UNIQUE (seller_id),

    -- Foreign Keys
    CONSTRAINT fk_store_seller
        FOREIGN KEY (seller_id)
        REFERENCES SELLER(account_id),

    CONSTRAINT fk_store_admin
        FOREIGN KEY (approved_by)
        REFERENCES ADMIN(account_id),

    -- Check Constraints
    CONSTRAINT chk_store_name
        CHECK (TRIM(store_name) <> ''),

    CONSTRAINT chk_store_status
        CHECK (status IN ('Pending', 'Active', 'Rejected')),
-- ràng buộc 1
    CONSTRAINT chk_store_approval
        CHECK (
            status <> 'Active'
            OR (
                approved_by IS NOT NULL
                AND approved_at IS NOT NULL
            )
        )
);

-- =============================================
-- GROUP 4: PRODUCT, ADDRESS, CART, COUPON
-- =============================================

-- 1. PRODUCT
CREATE TABLE PRODUCT (
    product_id VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    store_id VARCHAR(20) NOT NULL,
    category_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_product
        PRIMARY KEY (product_id),

    -- Foreign Keys
    CONSTRAINT fk_product_store
        FOREIGN KEY (store_id)
        REFERENCES STORE(store_id),

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES CATEGORY(category_id),

    -- Check Constraints
    CONSTRAINT chk_product_name
        CHECK (TRIM(product_name) <> ''),

    CONSTRAINT chk_product_status
        CHECK (status IN ('Active', 'Inactive'))
);


-- 2. ADDRESS
CREATE TABLE ADDRESS (
    address_id VARCHAR(20) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    house_number VARCHAR(30) NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    ward_commune VARCHAR(100) NOT NULL,
    province_city VARCHAR(100) NOT NULL,
    buyer_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_address
        PRIMARY KEY (address_id),

    -- Unique Constraint
    CONSTRAINT uq_address_buyer
        UNIQUE (address_id, buyer_id),

    -- Foreign Key
    CONSTRAINT fk_address_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES BUYER(account_id),

    -- Check Constraints
    CONSTRAINT chk_address_receiver
        CHECK (TRIM(receiver_name) <> ''),

    CONSTRAINT chk_address_phone
        CHECK (TRIM(phone_number) <> '')
);


-- 3. CART
CREATE TABLE CART (
    cart_id VARCHAR(20) NOT NULL,
    buyer_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_cart
        PRIMARY KEY (cart_id),

    -- Unique Constraint
    CONSTRAINT uq_cart_buyer
        UNIQUE (buyer_id),

    -- Foreign Key
    CONSTRAINT fk_cart_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES BUYER(account_id)
);


-- 4. COUPON
CREATE TABLE COUPON (
    coupon_id VARCHAR(20) NOT NULL,
    coupon_code VARCHAR(50) NOT NULL,
    coupon_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    min_order_value DECIMAL(12,2) NOT NULL DEFAULT 0,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    store_id VARCHAR(20),

    -- Primary Key
    CONSTRAINT pk_coupon
        PRIMARY KEY (coupon_id),

    -- Unique Constraint
    CONSTRAINT uq_coupon_code
        UNIQUE (coupon_code),

    -- Foreign Key
    CONSTRAINT fk_coupon_store
        FOREIGN KEY (store_id)
        REFERENCES STORE(store_id),

    -- Check Constraints
    CONSTRAINT chk_coupon_type
        CHECK (coupon_type IN ('Store', 'System')),

    CONSTRAINT chk_coupon_discount
        CHECK (discount_value > 0),

    CONSTRAINT chk_coupon_min_order
        CHECK (min_order_value >= 0),

    CONSTRAINT chk_coupon_time
        CHECK (end_time > start_time),

    CONSTRAINT chk_coupon_status
        CHECK (status IN ('Active', 'Inactive')),

    CONSTRAINT chk_coupon_store_type
        CHECK (
            (coupon_type = 'Store' AND store_id IS NOT NULL)
            OR
            (coupon_type = 'System' AND store_id IS NULL)
        )
);

-- =============================================
-- GROUP 5: VARIANT, PRODUCT_IMAGE
-- =============================================

-- 1. VARIANT
CREATE TABLE VARIANT (
    variant_id VARCHAR(20) NOT NULL,
    sku_code VARCHAR(50) NOT NULL,
    color VARCHAR(50),
    size VARCHAR(50),
    unit_price DECIMAL(12,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    product_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_variant
        PRIMARY KEY (variant_id),

    -- Unique Constraint
    CONSTRAINT uq_variant_sku
        UNIQUE (sku_code),

    -- Foreign Key
    CONSTRAINT fk_variant_product
        FOREIGN KEY (product_id)
        REFERENCES PRODUCT(product_id),

    -- Check Constraints
    CONSTRAINT chk_variant_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_variant_stock
        CHECK (stock >= 0),

    CONSTRAINT chk_variant_status
        CHECK (status IN ('Active', 'Inactive'))
);


-- 2. PRODUCT_IMAGE
CREATE TABLE PRODUCT_IMAGE (
    product_id VARCHAR(20) NOT NULL,
    display_order INT NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    is_thumbnail BOOLEAN NOT NULL DEFAULT FALSE,

    -- Primary Key
    CONSTRAINT pk_product_image
        PRIMARY KEY (product_id, display_order),

    -- Foreign Key
    CONSTRAINT fk_product_image_product
        FOREIGN KEY (product_id)
        REFERENCES PRODUCT(product_id),

    -- Unique Constraint
    UNIQUE KEY uq_product_image_thumbnail (
        (CASE WHEN is_thumbnail = 1
              THEN product_id ELSE NULL END)
    ),

    -- Check Constraints
    CONSTRAINT chk_image_order
        CHECK (display_order > 0),

    CONSTRAINT chk_image_path
        CHECK (TRIM(image_path) <> ''),

    CONSTRAINT chk_image_thumbnail
        CHECK (is_thumbnail IN (0, 1))
);

-- =============================================
-- GROUP 6: CART_ITEM, SHOP_ORDER
-- =============================================

-- 1. CART_ITEM
CREATE TABLE CART_ITEM (
    cart_id VARCHAR(20) NOT NULL,
    variant_id VARCHAR(20) NOT NULL,
    so_luong INT NOT NULL,

    -- Primary Key
    CONSTRAINT pk_cart_item
        PRIMARY KEY (cart_id, variant_id),

    -- Foreign Keys
    CONSTRAINT fk_cart_item_cart
        FOREIGN KEY (cart_id)
        REFERENCES CART(cart_id),

    CONSTRAINT fk_cart_item_variant
        FOREIGN KEY (variant_id)
        REFERENCES VARIANT(variant_id),

    -- Check Constraints
    CONSTRAINT chk_cart_item_quantity
        CHECK (so_luong > 0)
);


-- 2. SHOP_ORDER
CREATE TABLE SHOP_ORDER (
    order_id VARCHAR(20) NOT NULL,
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20) NOT NULL DEFAULT 'Pending',

    total_item_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    order_recipient_name VARCHAR(100) NOT NULL,
    order_phone VARCHAR(15) NOT NULL,
    delivery_address_at_order_time VARCHAR(500) NOT NULL,

    buyer_id VARCHAR(20) NOT NULL,
    store_id VARCHAR(20) NOT NULL,
    address_id VARCHAR(20) NOT NULL,
    coupon_id VARCHAR(20),

    -- Primary Key
    CONSTRAINT pk_shop_order
        PRIMARY KEY (order_id),

    -- Foreign Keys
    CONSTRAINT fk_order_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES BUYER(account_id),

    CONSTRAINT fk_order_store
        FOREIGN KEY (store_id)
        REFERENCES STORE(store_id),

    CONSTRAINT fk_order_address_buyer
        FOREIGN KEY (address_id, buyer_id)
        REFERENCES ADDRESS(address_id, buyer_id),

    CONSTRAINT fk_order_coupon
        FOREIGN KEY (coupon_id)
        REFERENCES COUPON(coupon_id),

    -- Check Constraints
    CONSTRAINT chk_order_status
        CHECK (order_status IN (
            'Pending',
            'Confirmed',
            'Shipping',
            'Delivered',
            'Cancelled'
        )),

    CONSTRAINT chk_order_amount
        CHECK (
            total_item_amount >= 0
            AND shipping_fee >= 0
            AND discount_amount >= 0
            AND discount_amount <= total_item_amount
        ),

    CONSTRAINT chk_order_recipient
        CHECK (TRIM(order_recipient_name) <> ''),

    CONSTRAINT chk_order_phone
        CHECK (TRIM(order_phone) <> ''),

    CONSTRAINT chk_order_address
        CHECK (TRIM(delivery_address_at_order_time) <> '')
);

-- =============================================
-- GROUP 7: ORDER_LINE, PAYMENT, SHIPMENT
-- =============================================

-- 1. ORDER_LINE
CREATE TABLE ORDER_LINE (
    order_id VARCHAR(20) NOT NULL,
    sort_order INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_order DECIMAL(12,2) NOT NULL,
    product_name_at_order VARCHAR(100) NOT NULL,
    variant_name_at_order VARCHAR(100) NOT NULL,
    variant_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_order_line
        PRIMARY KEY (order_id, sort_order),

    -- Foreign Keys
    CONSTRAINT fk_order_line_order
        FOREIGN KEY (order_id)
        REFERENCES SHOP_ORDER(order_id),

    CONSTRAINT fk_order_line_variant
        FOREIGN KEY (variant_id)
        REFERENCES VARIANT(variant_id),

    -- Check Constraints
    CONSTRAINT chk_order_line_sort
        CHECK (sort_order > 0),

    CONSTRAINT chk_order_line_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_line_price
        CHECK (unit_price_at_order >= 0)
);


-- 2. PAYMENT
CREATE TABLE PAYMENT (
    payment_id VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    completion_time DATETIME,
    order_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_payment
        PRIMARY KEY (payment_id),

    -- Unique Constraint
    CONSTRAINT uq_payment_order
        UNIQUE (order_id),

    -- Foreign Key
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES SHOP_ORDER(order_id),

    -- Check Constraints
    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('COD', 'BankTransfer')),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0),

    CONSTRAINT chk_payment_status
        CHECK (status IN ('Pending', 'Paid', 'Failed')),

    CONSTRAINT chk_payment_completion
        CHECK (
            status <> 'Paid'
            OR completion_time IS NOT NULL
        )
);


-- 3. SHIPMENT
CREATE TABLE SHIPMENT (
    shipment_id VARCHAR(20) NOT NULL,
    tracking_number VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'WaitingPickup',
    start_time DATETIME,
    delivery_time DATETIME,
    order_id VARCHAR(20) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_shipment
        PRIMARY KEY (shipment_id),

    -- Unique Constraints
    CONSTRAINT uq_shipment_tracking
        UNIQUE (tracking_number),

    CONSTRAINT uq_shipment_order
        UNIQUE (order_id),

    -- Foreign Key
    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES SHOP_ORDER(order_id),

    -- Check Constraints
    CONSTRAINT chk_shipment_status
        CHECK (status IN (
            'WaitingPickup',
            'Shipping',
            'Delivered'
        )),

    CONSTRAINT chk_shipment_time
        CHECK (
            delivery_time IS NULL
            OR (
                start_time IS NOT NULL
                AND delivery_time >= start_time
            )
        ),

    CONSTRAINT chk_shipment_delivered
        CHECK (
            status <> 'Delivered'
            OR delivery_time IS NOT NULL
        )
);

-- =============================================
-- GROUP 8: REVIEW
-- =============================================

CREATE TABLE REVIEW (
    review_id VARCHAR(20) NOT NULL,
    rating_score INT NOT NULL,
    content TEXT,
    reviewed_at_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_id VARCHAR(20) NOT NULL,
    sort_order INT NOT NULL,

    -- Primary Key
    CONSTRAINT pk_review
        PRIMARY KEY (review_id),

    -- Unique Constraint
    CONSTRAINT uq_review_order_line
        UNIQUE (order_id, sort_order),

    -- Foreign Key
    CONSTRAINT fk_review_order_line
        FOREIGN KEY (order_id, sort_order)
        REFERENCES ORDER_LINE(order_id, sort_order),

    -- Check Constraint
    CONSTRAINT chk_review_rating
        CHECK (rating_score BETWEEN 1 AND 5)
);
