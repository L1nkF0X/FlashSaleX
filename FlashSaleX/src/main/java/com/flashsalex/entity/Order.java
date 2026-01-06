package com.flashsalex.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("`order`")
public class Order {

    /**
     * 订单ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 订单号
     */
    @TableField("order_no")
    private String orderNo;

    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 商品ID
     */
    @TableField("product_id")
    private Long productId;

    /**
     * 活动ID
     */
    @TableField("activity_id")
    private Long activityId;

    /**
     * 订单状态
     */
    @TableField("status")
    private OrderStatus status;

    /**
     * 订单金额
     */
    @TableField("amount")
    private BigDecimal amount;

    /**
     * 幂等键
     */
    @TableField("idem_key")
    private String idemKey;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /**
     * 订单状态枚举
     */
    public enum OrderStatus {
        NEW, PAID, CANCELLED, TIMEOUT
    }
}
