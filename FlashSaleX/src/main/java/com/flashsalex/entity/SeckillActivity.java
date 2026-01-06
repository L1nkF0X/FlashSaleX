package com.flashsalex.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 秒杀活动实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("seckill_activity")
public class SeckillActivity {

    /**
     * 活动ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 商品ID
     */
    @TableField("product_id")
    private Long productId;

    /**
     * 开始时间
     */
    @TableField("start_at")
    private LocalDateTime startAt;

    /**
     * 结束时间
     */
    @TableField("end_at")
    private LocalDateTime endAt;

    /**
     * 每用户限购数量
     */
    @TableField("limit_per_user")
    private Integer limitPerUser;

    /**
     * 活动状态
     */
    @TableField("status")
    private ActivityStatus status;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 活动状态枚举
     */
    public enum ActivityStatus {
        PENDING, ACTIVE, ENDED
    }
}
