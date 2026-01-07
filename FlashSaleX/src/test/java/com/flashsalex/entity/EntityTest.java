package com.flashsalex.entity;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 实体类测试
 */
public class EntityTest {

    @Test
    public void testUserEntity() {
        User user = new User();
        user.setEmail("test@example.com");
        user.setPasswordHash("hashedPassword");
        user.setRole(User.UserRole.USER);
        user.setCreatedAt(LocalDateTime.now());

        assertEquals("test@example.com", user.getEmail());
        assertEquals("hashedPassword", user.getPasswordHash());
        assertEquals(User.UserRole.USER, user.getRole());
        assertNotNull(user.getCreatedAt());
    }

    @Test
    public void testProductEntity() {
        Product product = new Product();
        product.setTitle("Test Product");
        product.setPrice(new BigDecimal("99.99"));
        product.setDescription("Test product description");
        product.setStatus(Product.ProductStatus.ON);
        product.setCreatedAt(LocalDateTime.now());

        assertEquals("Test Product", product.getTitle());
        assertEquals(new BigDecimal("99.99"), product.getPrice());
        assertEquals("Test product description", product.getDescription());
        assertEquals(Product.ProductStatus.ON, product.getStatus());
        assertNotNull(product.getCreatedAt());
    }

    @Test
    public void testSeckillActivityEntity() {
        SeckillActivity activity = new SeckillActivity();
        activity.setProductId(1L);
        activity.setStartAt(LocalDateTime.now());
        activity.setEndAt(LocalDateTime.now().plusHours(1));
        activity.setLimitPerUser(1);
        activity.setTotalStock(100);
        activity.setSeckillPrice(new BigDecimal("89.99"));
        activity.setStatus(SeckillActivity.ActivityStatus.ACTIVE);
        activity.setCreatedAt(LocalDateTime.now());

        assertEquals(1L, activity.getProductId());
        assertEquals(1, activity.getLimitPerUser());
        assertEquals(100, activity.getTotalStock());
        assertEquals(new BigDecimal("89.99"), activity.getSeckillPrice());
        assertEquals(SeckillActivity.ActivityStatus.ACTIVE, activity.getStatus());
        assertNotNull(activity.getStartAt());
        assertNotNull(activity.getEndAt());
        assertNotNull(activity.getCreatedAt());
    }

    @Test
    public void testOrderEntity() {
        Order order = new Order();
        order.setOrderNo("ORD20240101001");
        order.setUserId(1L);
        order.setProductId(1L);
        order.setActivityId(1L);
        order.setStatus(Order.OrderStatus.NEW);
        order.setAmount(new BigDecimal("99.99"));
        order.setIdemKey("idem-key-123");
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        assertEquals("ORD20240101001", order.getOrderNo());
        assertEquals(1L, order.getUserId());
        assertEquals(1L, order.getProductId());
        assertEquals(1L, order.getActivityId());
        assertEquals(Order.OrderStatus.NEW, order.getStatus());
        assertEquals(new BigDecimal("99.99"), order.getAmount());
        assertEquals("idem-key-123", order.getIdemKey());
        assertNotNull(order.getCreatedAt());
        assertNotNull(order.getUpdatedAt());
    }

    @Test
    public void testPaymentEntity() {
        Payment payment = new Payment();
        payment.setOrderId(1L);
        payment.setPayStatus(Payment.PayStatus.SUCCESS);
        payment.setProviderTxnId("PAY20240101001");
        payment.setCreatedAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());

        assertEquals(1L, payment.getOrderId());
        assertEquals(Payment.PayStatus.SUCCESS, payment.getPayStatus());
        assertEquals("PAY20240101001", payment.getProviderTxnId());
        assertNotNull(payment.getCreatedAt());
        assertNotNull(payment.getUpdatedAt());
    }
}
