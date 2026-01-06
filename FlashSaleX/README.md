# FlashSaleX 秒杀系统

高并发秒杀系统，基于 Spring Boot 3 + Redis + MySQL 构建。

## 项目概述

FlashSaleX 是一个高性能的秒杀系统，旨在解决电商场景下的库存超卖、重复下单、系统雪崩等核心问题。

### 核心特性

- 🚀 **高并发**: 支持 1000+ QPS，P95 响应时间 < 200ms
- 🔒 **防超卖**: 基于 Redis Lua 脚本的原子操作，确保库存一致性
- 🛡️ **幂等性**: 支持请求幂等，防止重复下单
- 🚦 **限流保护**: 基于 Redis 的令牌桶限流算法
- 📊 **可观测性**: 完整的链路追踪和关键指标监控

### 技术栈

- **后端框架**: Spring Boot 3.2.1
- **数据库**: MySQL 8.0
- **缓存**: Redis 7.2
- **ORM**: MyBatis-Plus 3.5.5
- **安全**: Spring Security + JWT
- **构建工具**: Maven 3.9+
- **Java版本**: Java 21 LTS

## 环境要求

### 开发环境

- **操作系统**: Windows 10/11 (x64)
- **JDK**: Java 21.0.9 (Temurin 21 LTS)
- **构建工具**: Maven Wrapper (mvnw)
- **IDE**: Visual Studio Code (推荐)
- **容器**: Docker Desktop (最新稳定版)

### 运行时依赖

- **MySQL**: 8.0.x
- **Redis**: 7.2.x

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd FlashSaleX
```

### 2. 启动基础服务

```bash
# 启动 MySQL 和 Redis (需要先创建 docker-compose.yml)
docker compose up -d
```

### 3. 编译项目

```bash
# Windows
./mvnw.cmd clean compile

# Linux/Mac
./mvnw clean compile
```

### 4. 运行测试

```bash
# Windows
./mvnw.cmd test

# Linux/Mac
./mvnw test
```

### 5. 启动应用

```bash
# Windows
./mvnw.cmd spring-boot:run

# Linux/Mac
./mvnw spring-boot:run
```

应用将在 `http://localhost:8080` 启动。

## 项目结构

```
FlashSaleX/
├── src/
│   ├── main/
│   │   ├── java/com/flashsalex/
│   │   │   ├── FlashSaleXApplication.java    # 主应用类
│   │   │   ├── config/                       # 配置类
│   │   │   ├── controller/                   # 控制器
│   │   │   ├── service/                      # 服务层
│   │   │   ├── entity/                       # 实体类
│   │   │   ├── mapper/                       # 数据访问层
│   │   │   └── common/                       # 通用组件
│   │   └── resources/
│   │       ├── application.yml               # 配置文件
│   │       ├── lua/                          # Lua 脚本
│   │       └── db/migration/                 # 数据库迁移脚本
│   └── test/                                 # 测试代码
├── .mvn/wrapper/                             # Maven Wrapper
├── mvnw / mvnw.cmd                           # Maven Wrapper 脚本
├── pom.xml                                   # Maven 配置
├── docker-compose.yml                        # Docker 编排文件
└── README.md                                 # 项目说明
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DB_HOST` | localhost | 数据库主机 |
| `DB_PORT` | 3306 | 数据库端口 |
| `DB_NAME` | flashsalex | 数据库名称 |
| `DB_USERNAME` | root | 数据库用户名 |
| `DB_PASSWORD` | password | 数据库密码 |
| `REDIS_HOST` | localhost | Redis 主机 |
| `REDIS_PORT` | 6379 | Redis 端口 |
| `REDIS_PASSWORD` | (空) | Redis 密码 |
| `JWT_SECRET` | flashsalex-jwt-secret-key-2024 | JWT 签名密钥 |
| `JWT_EXPIRATION` | 86400 | JWT 有效期(秒) |

### 应用配置

主要配置项在 `application.yml` 中：

- **数据库连接池**: HikariCP 配置
- **Redis 连接池**: Lettuce 配置  
- **JWT 配置**: 密钥和有效期
- **限流配置**: 每用户每秒请求限制
- **日志配置**: 链路追踪和日志格式

## 开发指南

### 代码规范

- 使用 Java 21 语法特性
- 遵循 Spring Boot 最佳实践
- 使用 Lombok 减少样板代码
- 统一异常处理和响应格式

### 分支策略

- `main`: 主分支，用于生产环境
- `develop`: 开发分支，用于集成测试
- `feature/*`: 功能分支，用于新功能开发
- `hotfix/*`: 热修复分支，用于紧急修复

### 提交规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

类型说明：
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发送邮件至: [your-email@example.com]

---

**注意**: 这是一个 MVP 版本，专注于核心功能实现。生产环境使用前请进行充分的性能测试和安全评估。
