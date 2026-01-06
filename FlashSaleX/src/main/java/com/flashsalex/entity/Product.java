package com.flashsalex.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("product")
public class Product {

    /**
     * 商品ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 商品标题
     */
    @TableField("title")
    private String title;

    /**
     * 商品价格
     */
    @TableField("price")
    private BigDecimal price;

    /**
     * 商品状态
     */
    @TableField("status")
    private ProductStatus status;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 商品状态枚举
     */
    public enum ProductStatus {
        ON, OFF
    }
}
