# FlashSaleX 秒杀系统

高性能秒杀系统，基于 Spring Boot 3 + MyBatis-Plus + MySQL + Redis 构建。

## 项目概述

FlashSaleX 是一个完整的秒杀系统 MVP，实现了以下核心功能：
- 用户认证与授权（JWT）
- 商品管理
- 秒杀活动管理
- 防超卖的订单处理
- 支付回调处理
- 限流与可观测性

## 技术栈

- **后端框架**: Spring Boot 3.2.1
- **数据库**: MySQL 8.0
- **缓存**: Redis
- **ORM**: MyBatis-Plus 3.5.5
- **认证**: JWT (JJWT 0.12.3)
- **密码加密**: BCrypt
- **构建工具**: Maven 3.9.6
- **Java版本**: JDK 17

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+ (或使用项目自带的 Maven Wrapper)
- MySQL 8.0+
- Redis 6.0+

### 构建项目

```bash
# 使用 Maven Wrapper (推荐)
./mvnw clean compile

# 或使用本地 Maven
mvn clean compile
```

### 运行测试

```bash
./mvnw test
```

### 查看依赖树

```bash
./mvnw dependency:tree
```

## 项目结构

```
FlashSaleX/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/flashsalex/
│   │   │       └── FlashSaleXApplication.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
│       ├── java/
│       │   └── com/flashsalex/
│       │       └── FlashSaleXApplicationTests.java
│       └── resources/
│           └── application-test.yml
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md
```

## 配置说明

### 应用配置 (application.yml)

主要配置项：
- 数据库连接配置
- Redis 连接配置
- JWT 配置
- 限流配置
- 日志配置

### 环境变量

支持以下环境变量配置：
- `DB_HOST`: 数据库主机 (默认: localhost)
- `DB_PORT`: 数据库端口 (默认: 3306)
- `DB_NAME`: 数据库名称 (默认: flashsalex)
- `DB_USERNAME`: 数据库用户名 (默认: root)
- `DB_PASSWORD`: 数据库密码 (默认: password)
- `REDIS_HOST`: Redis 主机 (默认: localhost)
- `REDIS_PORT`: Redis 端口 (默认: 6379)
- `REDIS_PASSWORD`: Redis 密码 (默认: 空)
- `JWT_SECRET`: JWT 签名密钥
- `JWT_EXPIRATION`: JWT 有效期（秒）

## 开发进度

### ✅ Task 1: 项目初始化与基础配置 (已完成)

- [x] 创建 Spring Boot 3 项目结构
- [x] 配置 Maven 依赖 (Spring Boot, MyBatis-Plus, Redis, JWT 等)
- [x] 创建主启动类
- [x] 配置 application.yml
- [x] 创建测试配置
- [x] 添加 Maven Wrapper
- [x] 验证项目编译成功

**验收标准**: ✅ `./mvnw clean compile` 成功执行  
**验收命令**: ✅ `./mvnw dependency:tree` 显示完整依赖树

### 🔄 后续任务

参考 [PRD_TechnicalSpec_MVP.md](./PRD_TechnicalSpec_MVP.md) 中的 H. Delivery Plan 章节，包含：

- Task 2: Docker Compose 环境搭建
- Task 3: 数据库表结构设计与创建
- Task 4-6: 核心业务实体
- Task 7-8: 基础服务层
- Task 9-10: Redis 集成与 Lua 脚本
- Task 11-12: 秒杀核心功能
- Task 13-14: 支付和限流
- Task 15: 测试完善和部署脚本

## 文档

- [技术规格文档](./PRD_TechnicalSpec_MVP.md) - 完整的产品需求和技术规格
- [API 文档](./PRD_TechnicalSpec_MVP.md#e-api-contract) - 详细的 API 接口规范
- [数据库设计](./PRD_TechnicalSpec_MVP.md#c-data-design-mysql-8) - 数据表结构和索引设计

## 许可证

本项目仅用于学习和演示目的。
