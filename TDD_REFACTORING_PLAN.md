# FlashSaleX TDD 重构计划文档

## 文档概述
**编写人**: 资深产品经理 + 后端架构师 + 测试负责人  
**编写时间**: 2026-01-07  
**基于文档**: CURRENT_MODULE_ARCHITECTURE.md  
**计划周期**: 4周 (Task 4-15)  
**开发方法**: 测试驱动开发 (TDD)

---

## 1. TDD 重构策略概述

### 1.1 TDD 核心原则
```
Red -> Green -> Refactor 循环
├── Red: 编写失败的测试用例
├── Green: 编写最少代码使测试通过
└── Refactor: 重构代码提升质量
```

### 1.2 重构目标
🎯 **功能目标**: 实现完整的秒杀系统功能  
🎯 **质量目标**: 测试覆盖率 > 80%，代码质量优秀  
🎯 **性能目标**: 支持1000 QPS，P95 < 200ms  
🎯 **安全目标**: 完整的认证授权和数据保护  

### 1.3 重构范围
- ✅ **保留**: Entity层、Mapper层、数据库设计
- 🔄 **重构**: Config层扩展和优化
- 🆕 **新增**: Service层、Controller层、DTO层、Exception层、Security层、Redis层、Util层

---

## 2. TDD 重构路线图

### 2.1 Phase 1: 基础设施层 (Week 1)
**目标**: 建立测试基础设施和核心配置

#### Task 4: 用户实体与认证基础 (TDD)
**TDD 流程**:
```
1. Red: 编写用户注册测试用例
   - 测试正常注册流程
   - 测试邮箱重复注册
   - 测试密码加密验证
   
2. Green: 实现最小功能
   - UserService.register()
   - PasswordEncoder配置
   - 基础异常处理
   
3. Refactor: 代码优化
   - 提取常量和配置
   - 优化异常处理
   - 添加日志记录
```

**测试用例设计**:
```java
@Test
void shouldRegisterUserSuccessfully() {
    // Given
    RegisterRequest request = new RegisterRequest("test@example.com", "password123");
    
    // When
    UserResponse response = userService.register(request);
    
    // Then
    assertThat(response.getUserId()).isNotNull();
    assertThat(response.getEmail()).isEqualTo("test@example.com");
    // 验证密码已加密
    User user = userRepository.findById(response.getUserId());
    assertThat(passwordEncoder.matches("password123", user.getPasswordHash())).isTrue();
}

@Test
void shouldThrowExceptionWhenEmailAlreadyExists() {
    // Given
    userService.register(new RegisterRequest("test@example.com", "password123"));
    
    // When & Then
    assertThatThrownBy(() -> 
        userService.register(new RegisterRequest("test@example.com", "password456"))
    ).isInstanceOf(EmailAlreadyExistsException.class);
}
```

#### Task 5: 商品和活动实体 (TDD)
**TDD 流程**:
```
1. Red: 编写商品和活动管理测试
   - 测试商品CRUD操作
   - 测试活动创建和状态管理
   - 测试活动时间验证
   
2. Green: 实现基础功能
   - ProductService基础方法
   - SeckillActivityService基础方法
   - 业务验证逻辑
   
3. Refactor: 优化设计
   - 提取业务规则
   - 优化查询性能
   - 完善异常处理
```

#### Task 6: 订单和支付实体 (TDD)
**TDD 流程**:
```
1. Red: 编写订单状态机测试
   - 测试订单创建
   - 测试状态流转
   - 测试幂等性处理
   
2. Green: 实现状态机
   - OrderService状态管理
   - PaymentService回调处理
   - 幂等性实现
   
3. Refactor: 完善设计
   - 状态机模式应用
   - 事务管理优化
   - 补偿机制实现
```

### 2.2 Phase 2: 核心业务层 (Week 2)

#### Task 7: 认证服务实现 (TDD)
**TDD 流程**:
```
1. Red: 编写认证流程测试
   - 测试用户登录
   - 测试JWT生成和验证
   - 测试权限控制
   
2. Green: 实现认证逻辑
   - AuthService完整实现
   - JwtUtil工具类
   - SecurityConfig配置
   
3. Refactor: 安全加固
   - JWT刷新机制
   - 安全配置优化
   - 异常处理完善
```

**核心测试用例**:
```java
@Test
void shouldLoginSuccessfully() {
    // Given
    userService.register(new RegisterRequest("test@example.com", "password123"));
    LoginRequest request = new LoginRequest("test@example.com", "password123");
    
    // When
    LoginResponse response = authService.login(request);
    
    // Then
    assertThat(response.getToken()).isNotNull();
    assertThat(response.getExpiresIn()).isEqualTo(86400);
    
    // 验证JWT有效性
    Claims claims = jwtUtil.parseToken(response.getToken());
    assertThat(claims.getSubject()).isEqualTo("test@example.com");
}

@Test
void shouldThrowExceptionForInvalidCredentials() {
    // Given
    LoginRequest request = new LoginRequest("test@example.com", "wrongpassword");
    
    // When & Then
    assertThatThrownBy(() -> authService.login(request))
        .isInstanceOf(InvalidCredentialsException.class);
}
```

#### Task 8: 商品和活动服务 (TDD)
**TDD 流程**:
```
1. Red: 编写业务逻辑测试
   - 测试商品查询和管理
   - 测试活动创建和查询
   - 测试权限控制
   
2. Green: 实现业务服务
   - ProductService完整实现
   - ActivityService完整实现
   - 权限验证逻辑
   
3. Refactor: 性能优化
   - 查询优化
   - 缓存策略
   - 分页处理
```

### 2.3 Phase 3: Redis集成与核心功能 (Week 3)

#### Task 9: Redis配置和基础操作 (TDD)
**TDD 流程**:
```
1. Red: 编写Redis操作测试
   - 测试基础CRUD操作
   - 测试序列化配置
   - 测试连接池配置
   
2. Green: 实现Redis服务
   - RedisConfig配置类
   - RedisService封装类
   - 连接和序列化配置
   
3. Refactor: 优化配置
   - 连接池参数调优
   - 序列化策略优化
   - 异常处理完善
```

**Redis测试用例**:
```java
@Test
void shouldSetAndGetValueSuccessfully() {
    // Given
    String key = "test:key";
    String value = "test:value";
    
    // When
    redisService.set(key, value, 3600);
    String result = redisService.get(key);
    
    // Then
    assertThat(result).isEqualTo(value);
    assertThat(redisService.getExpire(key)).isLessThanOrEqualTo(3600);
}

@Test
void shouldHandleComplexObjectSerialization() {
    // Given
    User user = new User();
    user.setEmail("test@example.com");
    user.setRole(User.UserRole.USER);
    
    // When
    redisService.setObject("user:1", user, 3600);
    User result = redisService.getObject("user:1", User.class);
    
    // Then
    assertThat(result.getEmail()).isEqualTo("test@example.com");
    assertThat(result.getRole()).isEqualTo(User.UserRole.USER);
}
```

#### Task 10: Lua脚本实现 (TDD)
**TDD 流程**:
```
1. Red: 编写Lua脚本测试
   - 测试秒杀核心逻辑
   - 测试限流算法
   - 测试补偿机制
   
2. Green: 实现Lua脚本
   - 秒杀购买脚本
   - 限流检查脚本
   - 补偿回滚脚本
   
3. Refactor: 脚本优化
   - 性能优化
   - 错误处理
   - 原子性保证
```

**Lua脚本测试**:
```java
@Test
void shouldExecuteSeckillLuaScriptSuccessfully() {
    // Given
    Long activityId = 1L;
    Long userId = 1L;
    String idempotencyKey = "test-key";
    String orderNo = "ORD001";
    
    // 初始化Redis数据
    redisService.set("activity_stock:" + activityId, "10");
    
    // When
    LuaScriptResult result = luaScriptService.executeSeckillScript(
        activityId, userId, idempotencyKey, orderNo, 
        System.currentTimeMillis() - 1000, 
        System.currentTimeMillis() + 3600000, 
        1, System.currentTimeMillis()
    );
    
    // Then
    assertThat(result.getCode()).isEqualTo(LuaScriptResult.SUCCESS);
    assertThat(result.getOrderNo()).isEqualTo(orderNo);
    
    // 验证Redis状态变化
    assertThat(redisService.get("activity_stock:" + activityId)).isEqualTo("9");
    assertThat(redisService.get("activity_user_bought:" + activityId + ":" + userId)).isEqualTo("1");
}
```

#### Task 11: 秒杀服务核心逻辑 (TDD)
**TDD 流程**:
```
1. Red: 编写秒杀业务测试
   - 测试正常秒杀流程
   - 测试各种边界条件
   - 测试并发场景
   
2. Green: 实现秒杀服务
   - SeckillService完整实现
   - 订单创建逻辑
   - 补偿机制实现
   
3. Refactor: 性能优化
   - 并发控制优化
   - 事务管理优化
   - 监控埋点添加
```

#### Task 12: 订单服务实现 (TDD)
**TDD 流程**:
```
1. Red: 编写订单管理测试
   - 测试订单查询
   - 测试状态更新
   - 测试权限控制
   
2. Green: 实现订单服务
   - OrderService完整实现
   - 状态管理逻辑
   - 查询优化
   
3. Refactor: 功能完善
   - 分页查询优化
   - 状态机完善
   - 性能监控
```

### 2.4 Phase 4: 高级功能与优化 (Week 4)

#### Task 13: 支付回调服务 (TDD)
**TDD 流程**:
```
1. Red: 编写支付回调测试
   - 测试正常回调处理
   - 测试幂等性处理
   - 测试异常场景
   
2. Green: 实现回调服务
   - PaymentService回调处理
   - 幂等性实现
   - 状态同步逻辑
   
3. Refactor: 可靠性提升
   - 重试机制
   - 异常恢复
   - 监控告警
```

#### Task 14: 限流和可观测性 (TDD)
**TDD 流程**:
```
1. Red: 编写限流和监控测试
   - 测试限流算法
   - 测试TraceId传递
   - 测试性能指标
   
2. Green: 实现限流和监控
   - RateLimitInterceptor实现
   - TraceId配置
   - 性能监控埋点
   
3. Refactor: 监控完善
   - 指标优化
   - 告警配置
   - 日志规范
```

#### Task 15: 测试完善和部署脚本 (TDD)
**TDD 流程**:
```
1. Red: 编写集成测试
   - 端到端测试用例
   - 性能测试脚本
   - 压力测试场景
   
2. Green: 实现测试套件
   - 集成测试实现
   - 性能测试脚本
   - 部署脚本编写
   
3. Refactor: 测试优化
   - 测试覆盖率提升
   - 测试性能优化
   - CI/CD集成
```

---

## 3. TDD 实施细节

### 3.1 测试分层策略

#### 3.1.1 单元测试 (Unit Tests)
**目标**: 测试单个类或方法的功能
**覆盖范围**: Service层、Util层、Config层
**工具**: JUnit 5, Mockito, AssertJ
**命名规范**: `should{ExpectedBehavior}When{StateUnderTest}`

```java
// 示例：用户服务单元测试
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserMapper userMapper;
    
    @Mock
    private PasswordEncoder passwordEncoder;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldRegisterUserSuccessfullyWhenValidInput() {
        // Given
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");
        when(userMapper.selectByEmail("test@example.com")).thenReturn(null);
        when(passwordEncoder.encode("password123")).thenReturn("hashedPassword");
        when(userMapper.insert(any(User.class))).thenReturn(1);
        
        // When
        UserResponse response = userService.register(request);
        
        // Then
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        verify(userMapper).insert(any(User.class));
    }
}
```

#### 3.1.2 集成测试 (Integration Tests)
**目标**: 测试多个组件协作的功能
**覆盖范围**: Controller层、Service层、数据库交互
**工具**: Spring Boot Test, TestContainers
**命名规范**: `{FeatureName}IntegrationTest`

```java
// 示例：认证集成测试
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class AuthIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("flashsalex_test")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCompleteAuthFlowSuccessfully() {
        // Given
        RegisterRequest registerRequest = new RegisterRequest("test@example.com", "password123");
        
        // When - 注册
        ResponseEntity<ApiResponse<UserResponse>> registerResponse = 
            restTemplate.postForEntity("/api/auth/register", registerRequest, 
                new ParameterizedTypeReference<ApiResponse<UserResponse>>() {});
        
        // Then - 验证注册成功
        assertThat(registerResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        
        // When - 登录
        LoginRequest loginRequest = new LoginRequest("test@example.com", "password123");
        ResponseEntity<ApiResponse<LoginResponse>> loginResponse = 
            restTemplate.postForEntity("/api/auth/login", loginRequest,
                new ParameterizedTypeReference<ApiResponse<LoginResponse>>() {});
        
        // Then - 验证登录成功
        assertThat(loginResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(loginResponse.getBody().getData().getToken()).isNotNull();
    }
}
```

#### 3.1.3 端到端测试 (E2E Tests)
**目标**: 测试完整的业务流程
**覆盖范围**: 完整的秒杀流程
**工具**: Spring Boot Test, WireMock
**命名规范**: `{BusinessScenario}E2ETest`

```java
// 示例：秒杀流程端到端测试
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SeckillE2ETest {
    
    @Test
    void shouldCompleteSeckillFlowSuccessfully() {
        // Given - 准备测试数据
        String adminToken = registerAndLogin("admin@test.com", "admin123", "ADMIN");
        String userToken = registerAndLogin("user@test.com", "user123", "USER");
        
        // When - 创建商品和活动
        Long productId = createProduct(adminToken, "iPhone 15", new BigDecimal("7999.00"));
        Long activityId = createSeckillActivity(adminToken, productId, 100);
        
        // When - 用户参与秒杀
        String orderNo = participateSeckill(userToken, activityId);
        
        // When - 支付回调
        processPaymentCallback(orderNo, "PAY001");
        
        // Then - 验证最终状态
        OrderResponse order = getOrder(userToken, orderNo);
        assertThat(order.getStatus()).isEqualTo("PAID");
        
        // 验证Redis状态
        assertThat(getActivityStock(activityId)).isEqualTo(99);
    }
}
```

### 3.2 测试数据管理

#### 3.2.1 测试数据构建器模式
```java
// 测试数据构建器
public class TestDataBuilder {
    
    public static class UserBuilder {
        private String email = "test@example.com";
        private String password = "password123";
        private User.UserRole role = User.UserRole.USER;
        
        public UserBuilder email(String email) {
            this.email = email;
            return this;
        }
        
        public UserBuilder password(String password) {
            this.password = password;
            return this;
        }
        
        public UserBuilder admin() {
            this.role = User.UserRole.ADMIN;
            return this;
        }
        
        public RegisterRequest buildRegisterRequest() {
            return new RegisterRequest(email, password);
        }
        
        public User buildEntity() {
            User user = new User();
            user.setEmail(email);
            user.setPasswordHash(password); // 在实际测试中会被加密
            user.setRole(role);
            return user;
        }
    }
    
    public static UserBuilder user() {
        return new UserBuilder();
    }
}

// 使用示例
@Test
void shouldRegisterAdminUser() {
    // Given
    RegisterRequest request = TestDataBuilder.user()
        .email("admin@test.com")
        .admin()
        .buildRegisterRequest();
    
    // When & Then
    UserResponse response = userService.register(request);
    assertThat(response.getRole()).isEqualTo("ADMIN");
}
```

#### 3.2.2 测试数据清理策略
```java
// 测试基类
@Transactional
@Rollback
public abstract class BaseIntegrationTest {
    
    @Autowired
    protected TestRestTemplate restTemplate;
    
    @Autowired
    protected RedisTemplate<String, Object> redisTemplate;
    
    @BeforeEach
    void setUp() {
        // 清理Redis测试数据
        Set<String> keys = redisTemplate.keys("test:*");
        if (!keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }
    
    @AfterEach
    void tearDown() {
        // 清理Redis测试数据
        Set<String> keys = redisTemplate.keys("test:*");
        if (!keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }
}
```

### 3.3 Mock策略

#### 3.3.1 外部依赖Mock
```java
// Redis Mock配置
@TestConfiguration
public class TestRedisConfig {
    
    @Bean
    @Primary
    public RedisTemplate<String, Object> redisTemplate() {
        // 使用嵌入式Redis或Mock
        return Mockito.mock(RedisTemplate.class);
    }
}

// 时间Mock
@Component
public class TimeProvider {
    public long currentTimeMillis() {
        return System.currentTimeMillis();
    }
    
    public LocalDateTime now() {
        return LocalDateTime.now();
    }
}

// 在测试中Mock时间
@Test
void shouldHandleActivityTimeCorrectly() {
    // Given
    LocalDateTime fixedTime = LocalDateTime.of(2024, 1, 1, 10, 0, 0);
    when(timeProvider.now()).thenReturn(fixedTime);
    
    // When & Then
    // 测试时间相关逻辑
}
```

#### 3.3.2 数据库Mock策略
```java
// 对于复杂查询，使用真实数据库
@DataJpaTest
class UserMapperTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserMapper userMapper;
    
    @Test
    void shouldFindUserByEmail() {
        // Given
        User user = TestDataBuilder.user().buildEntity();
        entityManager.persistAndFlush(user);
        
        // When
        User found = userMapper.selectByEmail("test@example.com");
        
        // Then
        assertThat(found).isNotNull();
        assertThat(found.getEmail()).isEqualTo("test@example.com");
    }
}
```

---

## 4. 代码质量保证

### 4.1 代码覆盖率目标
- **单元测试覆盖率**: > 80%
- **集成测试覆盖率**: > 60%
- **总体覆盖率**: > 75%

### 4.2 质量检查工具
```xml
<!-- Maven插件配置 -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.75</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### 4.3 代码审查清单
- [ ] 测试用例覆盖所有分支
- [ ] 异常场景有对应测试
- [ ] 边界条件测试完整
- [ ] Mock使用合理，不过度Mock
- [ ] 测试数据清理完整
- [ ] 测试命名清晰易懂
- [ ] 断言具体明确
- [ ] 测试独立性保证

---

## 5. 持续集成配置

### 5.1 GitHub Actions配置
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: flashsalex_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
      
      redis:
        image: redis:7.2-alpine
        ports:
          - 6379:6379
        options: --health-cmd="redis-cli ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 21
      uses: actions/setup-java@v3
      with:
        java-version: '21'
        distribution: 'temurin'
    
    - name: Cache Maven packages
      uses: actions/cache@v3
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: ${{ runner.os }}-m2
    
    - name: Run tests
      run: ./mvnw clean test
      env:
        SPRING_PROFILES_ACTIVE: test
        DB_HOST: localhost
        DB_PORT: 3306
        REDIS_HOST: localhost
        REDIS_PORT: 6379
    
    - name: Generate test report
      run: ./mvnw jacoco:report
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./target/site/jacoco/jacoco.xml
```

### 5.2 质量门禁
- 所有测试必须通过
- 代码覆盖率不低于75%
- 没有高危安全漏洞
- 代码规范检查通过

---

## 6. 风险管控

### 6.1 技术风险
**风险**: TDD开发周期可能延长  
**缓解**: 制定详细的时间计划，优先实现核心功能

**风险**: 测试用例维护成本高  
**缓解**: 建立测试用例规范，定期重构测试代码

**风险**: Mock过度导致测试失真  
**缓解**: 平衡单元测试和集成测试，关键路径使用真实依赖

### 6.2 进度风险
**风险**: 某个Task延期影响整体进度  
**缓解**: 每个Task设置缓冲时间，关键路径优先

**风险**: 测试环境不稳定  
**缓解**: 使用TestContainers保证环境一致性

### 6.3 质量风险
**风险**: 测试覆盖率不达标  
**缓解**: 每日检查覆盖率，及时补充测试用例

**风险**: 性能测试不充分  
**缓解**: 在Task 15中重点进行性能测试和优化

---

## 7. 成功标准

### 7.1 功能标准
- [ ] 所有PRD定义的功能完整实现
- [ ] 所有API接口正常工作
- [ ] 秒杀核心流程稳定运行
- [ ] 支付回调处理正确

### 7.2 质量标准
- [ ] 单元测试覆盖率 > 80%
- [ ] 集成测试覆盖率 > 60%
- [ ] 所有测试用例通过
- [ ] 代码规范检查通过

### 7.3 性能标准
- [ ] 支持1000 QPS并发
- [ ] P95响应时间 < 200ms
- [ ] 系统可用性 > 99%
- [ ] 库存一致性100%

### 7.4 安全标准
- [ ] 认证授权机制完整
- [ ] 输入验证全覆盖
- [ ] 敏感信息保护
- [ ] 安全漏洞扫描通过

---

## 8. 总结

### 8.1 TDD优势
✅ **质量保证**: 测试先行确保功能正确性  
✅ **设计改进**: 测试驱动促进更好的API设计  
✅ **重构安全**: 完整测试覆盖支持安全重构  
✅ **文档作用**: 测试用例作为活文档  

### 8.2 实施要点
🎯 **严格遵循**: Red-Green-Refactor循环  
🎯 **测试分层**: 单元-集成-端到端测试结合  
🎯 **质量监控**: 持续监控覆盖率和质量指标  
🎯 **团队协作**: 代码审查和知识分享  

### 8.3 预期成果
通过4周的TDD重构，FlashSaleX将从基础架构转变为**生产就绪的高质量秒杀系统**，具备完整的功能、优秀的代码质量、全面的测试覆盖和良好的可维护性。

---
**文档版本**: v1.0  
**执行开始**: Task 4 启动时  
**预期完成**: Task 15 结束时
