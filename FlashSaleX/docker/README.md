# FlashSaleX Docker Environment

这个目录包含了FlashSaleX项目的Docker环境配置，包括MySQL 8.0和Redis 7.2的完整设置。

## 目录结构

```
docker/
├── README.md                    # 本文件
├── mysql/
│   ├── conf/
│   │   └── my.cnf              # MySQL配置文件
│   └── init/
│       └── 01-init-database.sql # 数据库初始化脚本
└── redis/
    └── conf/
        └── redis.conf          # Redis配置文件
```

## 快速开始

### 1. 启动基础服务

```bash
# Windows
scripts\docker-env.cmd start

# Linux/Mac
./scripts/docker-env.sh start
```

### 2. 启动服务和管理工具

```bash
# Windows
scripts\docker-env.cmd start-tools

# Linux/Mac
./scripts/docker-env.sh start-tools
```

启动后可以通过以下地址访问管理工具：
- **phpMyAdmin**: http://localhost:8080
- **Redis Commander**: http://localhost:8081

### 3. 检查服务状态

```bash
# Windows
scripts\docker-env.cmd status

# Linux/Mac
./scripts/docker-env.sh status
```

## 服务配置

### MySQL 8.0

- **容器名**: `flashsalex-mysql`
- **端口**: `3306`
- **数据库**: `flashsalex`
- **用户**: 
  - root用户: `root` / `password`
  - 应用用户: `flashsalex` / `flashsalex123`
- **字符集**: `utf8mb4`
- **时区**: `Asia/Shanghai`

#### 连接信息

```yaml
Host: localhost
Port: 3306
Database: flashsalex
Username: root
Password: password
```

#### 应用配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/flashsalex?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: password
```

### Redis 7.2

- **容器名**: `flashsalex-redis`
- **端口**: `6379`
- **数据库**: `0` (默认)
- **密码**: 无
- **持久化**: AOF + RDB

#### 连接信息

```yaml
Host: localhost
Port: 6379
Database: 0
Password: (无)
```

#### 应用配置

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      database: 0
```

## 数据库初始化

MySQL容器启动时会自动执行以下初始化操作：

1. **创建数据库表**：
   - `user` - 用户表
   - `product` - 商品表
   - `seckill_activity` - 秒杀活动表
   - `order` - 订单表
   - `payment` - 支付表

2. **插入初始数据**：
   - 默认管理员用户: `admin@flashsalex.com` / `admin123`
   - 测试用户: `user@flashsalex.com` / `user123`
   - 示例商品数据

3. **创建视图和存储过程**：
   - `v_active_seckill_activities` - 活跃秒杀活动视图
   - `v_order_details` - 订单详情视图
   - `GetUserOrderStats` - 用户订单统计存储过程
   - `GetActivityStats` - 活动统计存储过程

## 常用命令

### 服务管理

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
docker compose logs -f mysql
docker compose logs -f redis
```

### 数据库操作

```bash
# 连接MySQL
docker exec -it flashsalex-mysql mysql -u root -ppassword flashsalex

# 连接Redis
docker exec -it flashsalex-redis redis-cli

# 备份数据库
docker exec flashsalex-mysql mysqldump -u root -ppassword flashsalex > backup.sql

# 恢复数据库
docker exec -i flashsalex-mysql mysql -u root -ppassword flashsalex < backup.sql
```

### 数据管理

```bash
# 查看MySQL数据卷
docker volume inspect flashsalex_mysql_data

# 查看Redis数据卷
docker volume inspect flashsalex_redis_data

# 清理所有数据（谨慎使用）
docker compose down -v
```

## 性能优化

### MySQL优化

- **连接池**: HikariCP，最大连接数200
- **缓冲区**: InnoDB缓冲池256MB
- **日志**: 慢查询日志启用，阈值2秒
- **字符集**: utf8mb4，支持emoji
- **时区**: Asia/Shanghai

### Redis优化

- **内存策略**: volatile-lru，最大内存256MB
- **持久化**: AOF + RDB混合模式
- **网络**: TCP keepalive 60秒
- **Lua脚本**: 超时时间10秒
- **客户端缓冲区**: 针对高并发优化

## 故障排除

### 常见问题

1. **Docker Desktop未启动**
   ```
   Error: Docker is not running
   ```
   解决方案：启动Docker Desktop

2. **端口冲突**
   ```
   Error: Port 3306 is already in use
   ```
   解决方案：修改docker-compose.yml中的端口映射

3. **MySQL连接失败**
   ```
   Error: Access denied for user 'root'@'localhost'
   ```
   解决方案：检查密码，等待MySQL完全启动

4. **Redis连接失败**
   ```
   Error: Could not connect to Redis at localhost:6379
   ```
   解决方案：检查Redis容器状态，确认端口映射

### 健康检查

服务包含健康检查机制：

- **MySQL**: 每10秒检查一次，启动后40秒开始检查
- **Redis**: 每5秒检查一次，启动后10秒开始检查

查看健康状态：
```bash
docker compose ps
```

### 日志分析

查看详细日志：
```bash
# 查看所有服务日志
docker compose logs -f

# 查看MySQL日志
docker compose logs -f mysql

# 查看Redis日志
docker compose logs -f redis

# 查看最近100行日志
docker compose logs --tail=100 mysql
```

## 开发建议

1. **数据持久化**: 使用Docker卷确保数据不丢失
2. **配置管理**: 通过环境变量管理敏感配置
3. **网络隔离**: 使用自定义网络确保服务间通信安全
4. **健康检查**: 利用健康检查确保服务可用性
5. **日志监控**: 定期查看日志排查问题

## 生产环境注意事项

1. **安全性**:
   - 修改默认密码
   - 启用SSL/TLS
   - 限制网络访问

2. **性能**:
   - 调整内存分配
   - 优化连接池配置
   - 启用监控

3. **备份**:
   - 定期备份数据
   - 测试恢复流程
   - 异地存储备份

4. **监控**:
   - 设置告警
   - 监控资源使用
   - 性能指标收集
