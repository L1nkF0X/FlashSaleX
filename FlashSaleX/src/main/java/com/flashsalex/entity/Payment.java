package com.flashsalex.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 支付实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("payment")
public class Payment {

    /**
     * 支付ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 订单ID
     */
    @TableField("order_id")
    private Long orderId;

    /**
     * 支付状态
     */
    @TableField("pay_status")
    private PayStatus payStatus;

    /**
     * 第三方交易流水号
     */
    @TableField("provider_txn_id")
    private String providerTxnId;

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
     * 支付状态枚举
     */
    public enum PayStatus {
        SUCCESS, FAILED
    }
}
