# FlashSaleX 已完成任务修改建议

## 文档概述
**编写人**: 资深产品经理 + 后端架构师 + 测试负责人  
**编写时间**: 2026-01-07  
**基于文档**: TDD_PHASE1_INFRASTRUCTURE_PRD.md  
**目的**: 基于Phase 1 PRD要求，对已完成的Task 1-3进行修改建议

---

## 1. 修改建议总览

### 1.1 总体评估
✅ **数据库设计**: 完全符合PRD要求，无需修改  
✅ **实体类设计**: 基本符合要求，需要少量扩展  
⚠️ **Mapper接口**: 需要扩展业务查询方法  
⚠️ **缺失组件**: 需要添加PRD中定义的新组件

### 1.2 修改优先级
🔴 **P0 (必须修改)**: Mapper接口扩展、缺失字段补充  
🟡 **P1 (建议修改)**: 实体类验证注解、描述字段  
🟢 **P2 (可选修改)**: 代码注释完善、性能优化

---

## 2. 实体类修改建议

### 2.1 SeckillActivity 实体扩展

**当前状态**: 缺少重要的业务字段
**需要添加的字段**:

```java
/**
 * 活动库存总数
 */
@TableField("total_stock")
private Integer totalStock;

/**
 * 秒杀价格
 */
@TableField("seckill_price")
private BigDecimal seckillPrice;
```

**修改原因**: PRD中明确要求活动需要管理库存和秒杀价格

**修改建议**:
<replace_in_file>
<path>src/main/java/com/flashsalex/entity/SeckillActivity.java</path>
<diff>
------- SEARCH
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
=======
    /**
     * 每用户限购数量
     */
    @TableField("limit_per_user")
    private Integer limitPerUser;

    /**
     * 活动库存总数
     */
    @TableField("total_stock")
    private Integer totalStock;

    /**
     * 秒杀价格
     */
    @TableField("seckill_price")
    private BigDecimal seckillPrice;

    /**
     * 活动状态
     */
    @TableField("status")
    private ActivityStatus status;
+++++++ REPLACE
</diff>
</replace_in_file>

### 2.2 Product 实体扩展

**当前状态**: 缺少商品描述字段
**需要添加的字段**:

```java
/**
 * 商品描述
 */
@TableField("description")
private String description;
```

**修改建议**:
<replace_in_file>
<path>src/main/java/com/flashsalex/entity/Product.java</path>
<diff>
------- SEARCH
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
=======
    /**
     * 商品价格
     */
    @TableField("price")
    private BigDecimal price;

    /**
     * 商品描述
     */
    @TableField("description")
    private String description;

    /**
     * 商品状态
     */
    @TableField("status")
    private ProductStatus status;
+++++++ REPLACE
</diff>
</replace_in_file>

---

## 3. Mapper接口扩展建议

### 3.1 UserMapper 扩展

**当前状态**: 只有基础CRUD方法
**需要添加的方法**: 按邮箱查询用户

**修改建议**:
<replace_in_file>
<path>src/main/java/com/flashsalex/mapper/UserMapper.java</path>
<diff>
------- SEARCH
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
}
=======
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
    
    /**
     * 根据邮箱查询用户
     * @param email 邮箱
     * @return 用户信息
     */
    User selectByEmail(@Param("email") String email);
}
+++++++ REPLACE
</diff>
</replace_in_file>

### 3.2 OrderMapper 扩展

**当前状态**: 只有基础CRUD方法
**需要添加的方法**: 按幂等键查询、按订单号查询

**修改建议**:
<replace_in_file>
<path>src/main/java/com/flashsalex/mapper/OrderMapper.java</path>
<diff>
------- SEARCH
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.Order;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单Mapper接口
 */
@Mapper
public interface OrderMapper extends BaseMapper<Order> {
}
=======
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单Mapper接口
 */
@Mapper
public interface OrderMapper extends BaseMapper<Order> {
    
    /**
     * 根据幂等键查询订单
     * @param idemKey 幂等键
     * @return 订单信息
     */
    Order selectByIdempotencyKey(@Param("idemKey") String idemKey);
    
    /**
     * 根据订单号查询订单
     * @param orderNo 订单号
     * @return 订单信息
     */
    Order selectByOrderNo(@Param("orderNo") String orderNo);
    
    /**
     * 查询超时订单
     * @param timeoutBefore 超时时间点
     * @return 超时订单列表
     */
    List<Order> selectTimeoutOrders(@Param("timeoutBefore") LocalDateTime timeoutBefore);
}
+++++++ REPLACE
</diff>
</replace_in_file>

### 3.3 PaymentMapper 扩展

**当前状态**: 只有基础CRUD方法
**需要添加的方法**: 按第三方交易流水号查询

**修改建议**:
<replace_in_file>
<path>src/main/java/com/flashsalex/mapper/PaymentMapper.java</path>
<diff>
------- SEARCH
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.Payment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 支付Mapper接口
 */
@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {
}
=======
package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.Payment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 支付Mapper接口
 */
@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {
    
    /**
     * 根据第三方交易流水号查询支付记录
     * @param providerTxnId 第三方交易流水号
     * @return 支付记录
     */
    Payment selectByProviderTxnId(@Param("providerTxnId") String providerTxnId);
    
    /**
     * 根据订单ID查询支付记录
     * @param orderId 订单ID
     * @return 支付记录
     */
    Payment selectByOrderId(@Param("orderId") Long orderId);
}
+++++++ REPLACE
</diff>
</replace_in_file>

---

## 4. 数据库表结构验证

### 4.1 需要验证的表结构

基于PRD要求，需要确认以下表是否包含所需字段：

#### 4.1.1 seckill_activity 表
**需要确认的字段**:
- `total_stock` INT - 活动库存总数
- `seckill_price` DECIMAL(10,2) - 秒杀价格

#### 4.1.2 product 表
**需要确认的字段**:
- `description` TEXT - 商品描述

**验证SQL**:
```sql
-- 检查 seckill_activity 表结构
DESCRIBE seckill_activity;

-- 检查 product 表结构  
DESCRIBE product;

-- 如果字段不存在，需要添加
ALTER TABLE seckill_activity 
ADD COLUMN total_stock INT NOT NULL DEFAULT 0 COMMENT '活动库存总数',
ADD COLUMN seckill_price DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '秒杀价格';

ALTER TABLE product 
ADD COLUMN description TEXT COMMENT '商品描述';
```

---

## 5. 新增组件建议

### 5.1 需要创建的目录结构

```
src/main/java/com/flashsalex/
├── dto/                    # 数据传输对象
│   ├── request/           # 请求DTO
│   └── response/          # 响应DTO
├── exception/             # 异常类
├── service/               # 服务层
├── util/                  # 工具类
└── validator/             # 验证器
```

### 5.2 Maven依赖检查

**需要确认的依赖**:
```xml
<!-- 参数验证 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- 测试依赖 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

---

## 6. 配置文件扩展建议

### 6.1 application.yml 扩展

**需要添加的配置**:
```yaml
# JWT配置
jwt:
  secret: flashsalex-secret-key-2024
  expiration: 86400000 # 24小时

# 订单配置
order:
  timeout-minutes: 30 # 订单超时时间（分钟）

# 定时任务配置
scheduling:
  enabled: true
  
# 日志配置
logging:
  level:
    com.flashsalex: DEBUG
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

---

## 7. 测试环境准备

### 7.1 测试依赖配置

**需要添加的测试依赖**:
```xml
<!-- Mockito -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <scope>test</scope>
</dependency>

<!-- AssertJ -->
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <scope>test</scope>
</dependency>

<!-- TestContainers -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>mysql</artifactId>
    <scope>test</scope>
</dependency>
```

### 7.2 测试配置文件

**创建 application-test.yml**:
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  jpa:
    hibernate:
      ddl-auto: create-drop
  redis:
    host: localhost
    port: 6379
    database: 1

logging:
  level:
    com.flashsalex: DEBUG
```

---

## 8. 修改执行计划

### 8.1 立即执行 (P0)

1. **扩展实体类字段**
   - SeckillActivity 添加 totalStock 和 seckillPrice 字段
   - Product 添加 description 字段

2. **扩展Mapper接口**
   - UserMapper 添加 selectByEmail 方法
   - OrderMapper 添加业务查询方法
   - PaymentMapper 添加业务查询方法

3. **验证数据库表结构**
   - 确认新增字段是否存在
   - 如不存在则执行ALTER TABLE语句

### 8.2 短期执行 (P1)

1. **创建目录结构**
   - 创建 dto、exception、service、util、validator 包

2. **添加Maven依赖**
   - 验证和添加必要的依赖项

3. **扩展配置文件**
   - 添加JWT、订单、定时任务等配置

### 8.3 中期执行 (P2)

1. **完善测试环境**
   - 添加测试依赖
   - 创建测试配置文件

2. **代码质量提升**
   - 添加参数验证注解
   - 完善代码注释

---

## 9. 风险评估

### 9.1 低风险修改
✅ **Mapper接口扩展**: 只是添加方法声明，不影响现有功能  
✅ **实体类字段添加**: 向后兼容，不影响现有数据  
✅ **配置文件扩展**: 只是添加新配置，不修改现有配置

### 9.2 中风险修改
⚠️ **数据库表结构修改**: 需要谨慎执行，建议先备份数据  
⚠️ **Maven依赖添加**: 可能存在版本冲突，需要测试验证

### 9.3 修改建议
1. **分步执行**: 按优先级分批次执行修改
2. **充分测试**: 每次修改后进行充分测试
3. **版本控制**: 每次修改前创建Git分支
4. **回滚准备**: 准备回滚方案以防出现问题

---

## 10. 总结

### 10.1 修改必要性
基于TDD Phase 1 PRD的要求，现有的Task 1-3完成度较高，但需要进行以下关键修改：
- **实体类字段补充**: 确保支持PRD中定义的所有业务功能
- **Mapper接口扩展**: 提供PRD中要求的业务查询能力
- **基础设施准备**: 为Phase 1的TDD开发做好准备

### 10.2 修改影响
- **正面影响**: 完全符合PRD要求，为后续开发奠定坚实基础
- **风险控制**: 修改都是向后兼容的扩展，风险较低
- **开发效率**: 一次性完成修改，避免后续重复工作

### 10.3 执行建议
建议立即执行P0级别的修改，确保在开始Task 4之前完成所有必要的基础设施准备工作。这样可以确保TDD开发过程的顺利进行。

---
**文档版本**: v1.0  
**建议执行时间**: Task 4 开始前  
**预计修改时间**: 2-4小时
