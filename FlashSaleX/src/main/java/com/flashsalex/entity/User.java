package com.flashsalex.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("user")
public class User {

    /**
     * 用户ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 邮箱
     */
    @TableField("email")
    private String email;

    /**
     * 密码哈希
     */
    @TableField("password_hash")
    private String passwordHash;

    /**
     * 用户角色
     */
    @TableField("role")
    private UserRole role;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 用户角色枚举
     */
    public enum UserRole {
        USER, ADMIN
    }
}
