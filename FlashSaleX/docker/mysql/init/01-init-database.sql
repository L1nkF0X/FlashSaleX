-- FlashSaleX Database Initialization Script
-- This script creates the database schema and initial data

-- Set character set and collation
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Use the flashsalex database
USE flashsalex;

-- =============================================
-- Table: user
-- =============================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `email` VARCHAR(255) NOT NULL COMMENT '邮箱',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
  `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER' COMMENT '用户角色',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =============================================
-- Table: product
-- =============================================
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `title` VARCHAR(255) NOT NULL COMMENT '商品标题',
  `price` DECIMAL(10,2) NOT NULL COMMENT '商品价格',
  `status` ENUM('ON', 'OFF') NOT NULL DEFAULT 'ON' COMMENT '商品状态',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- =============================================
-- Table: seckill_activity
-- =============================================
DROP TABLE IF EXISTS `seckill_activity`;
CREATE TABLE `seckill_activity` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `start_at` DATETIME NOT NULL COMMENT '开始时间',
  `end_at` DATETIME NOT NULL COMMENT '结束时间',
  `limit_per_user` INT NOT NULL DEFAULT 1 COMMENT '每用户限购数量',
  `status` ENUM('PENDING', 'ACTIVE', 'ENDED') NOT NULL DEFAULT 'PENDING' COMMENT '活动状态',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_time_range` (`start_at`, `end_at`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='秒杀活动表';

-- =============================================
-- Table: order
-- =============================================
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `activity_id` BIGINT NULL COMMENT '活动ID',
  `status` ENUM('NEW', 'PAID', 'CANCELLED', 'TIMEOUT') NOT NULL DEFAULT 'NEW' COMMENT '订单状态',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '订单金额',
  `idem_key` VARCHAR(64) NOT NULL COMMENT '幂等键',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  UNIQUE KEY `uk_idem_key` (`idem_key`),
  KEY `idx_user_created` (`user_id`, `created_at`),
  KEY `idx_activity_id` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- =============================================
-- Table: payment
-- =============================================
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '支付ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `pay_status` ENUM('SUCCESS', 'FAILED') NOT NULL COMMENT '支付状态',
  `provider_txn_id` VARCHAR(64) NOT NULL COMMENT '第三方交易流水号',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  UNIQUE KEY `uk_provider_txn_id` (`provider_txn_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付表';

-- =============================================
-- Initial Data
-- =============================================

-- Insert default admin user
-- Password: admin123 (BCrypt hash with strength 10)
INSERT INTO `user` (`email`, `password_hash`, `role`) VALUES 
('admin@flashsalex.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKXIGkjJNdRjS6jKpOKOmyuXWpJG', 'ADMIN');

-- Insert sample products
INSERT INTO `product` (`title`, `price`, `status`) VALUES 
('iPhone 15 Pro', 7999.00, 'ON'),
('MacBook Pro M3', 12999.00, 'ON'),
('AirPods Pro', 1999.00, 'ON'),
('iPad Air', 4599.00, 'ON'),
('Apple Watch Series 9', 2999.00, 'ON');

-- Insert sample test user
-- Password: user123 (BCrypt hash with strength 10)
INSERT INTO `user` (`email`, `password_hash`, `role`) VALUES 
('user@flashsalex.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'USER');

-- =============================================
-- Indexes for Performance
-- =============================================

-- Additional indexes for better query performance
ALTER TABLE `seckill_activity` ADD INDEX `idx_product_status_time` (`product_id`, `status`, `start_at`, `end_at`);
ALTER TABLE `order` ADD INDEX `idx_status_created` (`status`, `created_at`);
ALTER TABLE `order` ADD INDEX `idx_user_activity` (`user_id`, `activity_id`);

-- =============================================
-- Views for Common Queries
-- =============================================

-- View for active seckill activities with product info
CREATE OR REPLACE VIEW `v_active_seckill_activities` AS
SELECT 
    sa.id AS activity_id,
    sa.product_id,
    p.title AS product_title,
    p.price AS product_price,
    sa.start_at,
    sa.end_at,
    sa.limit_per_user,
    sa.status AS activity_status,
    sa.created_at AS activity_created_at
FROM seckill_activity sa
INNER JOIN product p ON sa.product_id = p.id
WHERE sa.status = 'ACTIVE' 
  AND p.status = 'ON'
  AND NOW() BETWEEN sa.start_at AND sa.end_at;

-- View for order details with user and product info
CREATE OR REPLACE VIEW `v_order_details` AS
SELECT 
    o.id AS order_id,
    o.order_no,
    o.user_id,
    u.email AS user_email,
    o.product_id,
    p.title AS product_title,
    o.activity_id,
    o.status AS order_status,
    o.amount,
    o.created_at AS order_created_at,
    o.updated_at AS order_updated_at,
    CASE 
        WHEN p2.pay_status IS NOT NULL THEN p2.pay_status
        ELSE 'PENDING'
    END AS payment_status
FROM `order` o
INNER JOIN `user` u ON o.user_id = u.id
INNER JOIN `product` p ON o.product_id = p.id
LEFT JOIN `payment` p2 ON o.id = p2.order_id;

-- =============================================
-- Stored Procedures for Common Operations
-- =============================================

DELIMITER $$

-- Procedure to get user order statistics
CREATE PROCEDURE GetUserOrderStats(IN p_user_id BIGINT)
BEGIN
    SELECT 
        COUNT(*) as total_orders,
        COUNT(CASE WHEN status = 'NEW' THEN 1 END) as pending_orders,
        COUNT(CASE WHEN status = 'PAID' THEN 1 END) as paid_orders,
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled_orders,
        COUNT(CASE WHEN status = 'TIMEOUT' THEN 1 END) as timeout_orders,
        COALESCE(SUM(CASE WHEN status = 'PAID' THEN amount END), 0) as total_paid_amount
    FROM `order` 
    WHERE user_id = p_user_id;
END$$

-- Procedure to get activity statistics
CREATE PROCEDURE GetActivityStats(IN p_activity_id BIGINT)
BEGIN
    SELECT 
        COUNT(*) as total_orders,
        COUNT(CASE WHEN status = 'PAID' THEN 1 END) as successful_orders,
        COALESCE(SUM(amount), 0) as total_amount,
        COUNT(DISTINCT user_id) as unique_users
    FROM `order` 
    WHERE activity_id = p_activity_id;
END$$

DELIMITER ;

-- =============================================
-- Enable Foreign Key Checks
-- =============================================
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- Show Tables and Status
-- =============================================
SHOW TABLES;

SELECT 'Database initialization completed successfully!' AS status;
