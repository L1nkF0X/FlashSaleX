# FlashSaleX TDD Phase 1: 基础设施层 - 产品需求文档 (PRD)

## 文档概述
**编写人**: 资深产品经理 + 后端架构师 + 测试负责人  
**编写时间**: 2026-01-07  
**基于文档**: TDD_REFACTORING_PLAN.md, CURRENT_MODULE_ARCHITECTURE.md  
**执行周期**: Week 1 (Task 4-6)  
**开发方法**: 测试驱动开发 (TDD)  
**文档版本**: v1.0

---

## 1. Phase 1 总体目标

### 1.1 核心目标
🎯 **建立测试基础设施**: 构建完整的TDD开发环境和测试框架  
🎯 **实现核心实体服务**: 完成用户、商品、活动、订单、支付的基础业务逻辑  
🎯 **建立配置基础**: 扩展和优化现有配置层，支持后续功能开发  
🎯 **确保代码质量**: 通过TDD确保80%+的测试覆盖率和优秀的代码质量

### 1.2 成功标准
- [ ] 所有实体的基础CRUD操作完整实现
- [ ] 用户注册登录流程可正常工作
- [ ] 商品和活动管理功能可正常工作
- [ ] 订单状态机和支付回调机制可正常工作
- [ ] 单元测试覆盖率达到80%以上
- [ ] 所有测试用例通过
- [ ] 代码质量检查通过

### 1.3 技术债务清理
- ✅ 保留: Entity层、Mapper层、数据库设计 (已完成)
- 🔄 重构: Config层扩展和优化
- 🆕 新增: Service层基础实现、DTO层、Exception层基础、Util层基础

---

## 2. Task 4: 用户实体与认证基础 (TDD)

### 2.1 功能需求

#### 2.1.1 用户注册功能
**业务描述**: 新用户通过邮箱和密码注册账户

**输入参数**:
```java
public class RegisterRequest {
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20位之间")
    private String password;
}
```

**输出结果**:
```java
public class UserResponse {
    private Long userId;
    private String email;
    private String role;
    private LocalDateTime createdAt;
}
```

**业务规则**:
1. 邮箱必须唯一，不能重复注册
2. 密码必须使用BCrypt加密存储
3. 默认角色为USER
4. 注册成功后返回用户基本信息（不包含密码）

**异常处理**:
- `EmailAlreadyExistsException`: 邮箱已存在
- `InvalidInputException`: 输入参数验证失败

#### 2.1.2 用户登录功能
**业务描述**: 用户通过邮箱和密码登录获取访问令牌

**输入参数**:
```java
public class LoginRequest {
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @NotBlank(message = "密码不能为空")
    private String password;
}
```

**输出结果**:
```java
public class LoginResponse {
    private String token;
    private String tokenType = "Bearer";
    private Long expiresIn = 86400L; // 24小时
    private UserResponse user;
}
```

**业务规则**:
1. 验证邮箱和密码的正确性
2. 生成JWT访问令牌
3. 令牌有效期24小时
4. 返回用户基本信息和令牌

**异常处理**:
- `InvalidCredentialsException`: 邮箱或密码错误
- `UserNotFoundException`: 用户不存在

#### 2.1.3 用户信息查询功能
**业务描述**: 根据用户ID或邮箱查询用户信息

**输入参数**:
- `Long userId` 或 `String email`

**输出结果**:
- `UserResponse` 用户基本信息

**业务规则**:
1. 支持按ID和邮箱查询
2. 不返回敏感信息（密码哈希）
3. 用户不存在时抛出异常

**异常处理**:
- `UserNotFoundException`: 用户不存在

### 2.2 技术需求

#### 2.2.1 Service层实现
```java
@Service
@Transactional
public class UserService {
    
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    
    public UserResponse register(RegisterRequest request);
    public LoginResponse login(LoginRequest request);
    public UserResponse getUserById(Long userId);
    public UserResponse getUserByEmail(String email);
    public boolean existsByEmail(String email);
}
```

#### 2.2.2 配置类扩展
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public JwtUtil jwtUtil() {
        return new JwtUtil();
    }
}
```

#### 2.2.3 工具类实现
```java
@Component
public class JwtUtil {
    
    private String secret = "flashsalex-secret-key";
    private long expiration = 86400000; // 24小时
    
    public String generateToken(String email, String role);
    public Claims parseToken(String token);
    public boolean validateToken(String token);
    public String getEmailFromToken(String token);
    public String getRoleFromToken(String token);
}
```

#### 2.2.4 异常类定义
```java
public class EmailAlreadyExistsException extends BusinessException {
    public EmailAlreadyExistsException(String email) {
        super("邮箱已存在: " + email);
    }
}

public class InvalidCredentialsException extends BusinessException {
    public InvalidCredentialsException() {
        super("邮箱或密码错误");
    }
}

public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(String identifier) {
        super("用户不存在: " + identifier);
    }
}
```

### 2.3 TDD测试用例设计

#### 2.3.1 用户注册测试用例
```java
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
        assertThat(response.getRole()).isEqualTo("USER");
        assertThat(response.getUserId()).isNotNull();
        verify(userMapper).insert(any(User.class));
    }
    
    @Test
    void shouldThrowExceptionWhenEmailAlreadyExists() {
        // Given
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");
        User existingUser = new User();
        existingUser.setEmail("test@example.com");
        when(userMapper.selectByEmail("test@example.com")).thenReturn(existingUser);
        
        // When & Then
        assertThatThrownBy(() -> userService.register(request))
            .isInstanceOf(EmailAlreadyExistsException.class)
            .hasMessage("邮箱已存在: test@example.com");
    }
    
    @Test
    void shouldEncryptPasswordWhenRegistering() {
        // Given
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");
        when(userMapper.selectByEmail("test@example.com")).thenReturn(null);
        when(passwordEncoder.encode("password123")).thenReturn("hashedPassword");
        when(userMapper.insert(any(User.class))).thenReturn(1);
        
        // When
        userService.register(request);
        
        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userMapper).insert(userCaptor.capture());
        User savedUser = userCaptor.getValue();
        assertThat(savedUser.getPasswordHash()).isEqualTo("hashedPassword");
    }
}
```

#### 2.3.2 用户登录测试用例
```java
@Test
void shouldLoginSuccessfullyWhenValidCredentials() {
    // Given
    LoginRequest request = new LoginRequest("test@example.com", "password123");
    User user = TestDataBuilder.user()
        .email("test@example.com")
        .passwordHash("hashedPassword")
        .buildEntity();
    
    when(userMapper.selectByEmail("test@example.com")).thenReturn(user);
    when(passwordEncoder.matches("password123", "hashedPassword")).thenReturn(true);
    when(jwtUtil.generateToken("test@example.com", "USER")).thenReturn("jwt-token");
    
    // When
    LoginResponse response = userService.login(request);
    
    // Then
    assertThat(response.getToken()).isEqualTo("jwt-token");
    assertThat(response.getTokenType()).isEqualTo("Bearer");
    assertThat(response.getExpiresIn()).isEqualTo(86400L);
    assertThat(response.getUser().getEmail()).isEqualTo("test@example.com");
}

@Test
void shouldThrowExceptionWhenInvalidPassword() {
    // Given
    LoginRequest request = new LoginRequest("test@example.com", "wrongpassword");
    User user = TestDataBuilder.user()
        .email("test@example.com")
        .passwordHash("hashedPassword")
        .buildEntity();
    
    when(userMapper.selectByEmail("test@example.com")).thenReturn(user);
    when(passwordEncoder.matches("wrongpassword", "hashedPassword")).thenReturn(false);
    
    // When & Then
    assertThatThrownBy(() -> userService.login(request))
        .isInstanceOf(InvalidCredentialsException.class)
        .hasMessage("邮箱或密码错误");
}

@Test
void shouldThrowExceptionWhenUserNotFound() {
    // Given
    LoginRequest request = new LoginRequest("nonexistent@example.com", "password123");
    when(userMapper.selectByEmail("nonexistent@example.com")).thenReturn(null);
    
    // When & Then
    assertThatThrownBy(() -> userService.login(request))
        .isInstanceOf(UserNotFoundException.class)
        .hasMessage("用户不存在: nonexistent@example.com");
}
```

#### 2.3.3 JWT工具类测试用例
```java
@ExtendWith(MockitoExtension.class)
class JwtUtilTest {
    
    private JwtUtil jwtUtil;
    
    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil();
    }
    
    @Test
    void shouldGenerateValidToken() {
        // Given
        String email = "test@example.com";
        String role = "USER";
        
        // When
        String token = jwtUtil.generateToken(email, role);
        
        // Then
        assertThat(token).isNotNull();
        assertThat(token).isNotEmpty();
        
        Claims claims = jwtUtil.parseToken(token);
        assertThat(claims.getSubject()).isEqualTo(email);
        assertThat(claims.get("role")).isEqualTo(role);
    }
    
    @Test
    void shouldValidateTokenCorrectly() {
        // Given
        String token = jwtUtil.generateToken("test@example.com", "USER");
        
        // When & Then
        assertThat(jwtUtil.validateToken(token)).isTrue();
    }
    
    @Test
    void shouldExtractEmailFromToken() {
        // Given
        String email = "test@example.com";
        String token = jwtUtil.generateToken(email, "USER");
        
        // When
        String extractedEmail = jwtUtil.getEmailFromToken(token);
        
        // Then
        assertThat(extractedEmail).isEqualTo(email);
    }
    
    @Test
    void shouldRejectInvalidToken() {
        // Given
        String invalidToken = "invalid.jwt.token";
        
        // When & Then
        assertThat(jwtUtil.validateToken(invalidToken)).isFalse();
    }
}
```

### 2.4 验收标准

#### 2.4.1 功能验收
- [ ] 用户可以成功注册新账户
- [ ] 重复邮箱注册会被拒绝
- [ ] 密码正确加密存储
- [ ] 用户可以成功登录获取令牌
- [ ] 错误的邮箱或密码会被拒绝
- [ ] JWT令牌可以正确生成和验证
- [ ] 用户信息查询功能正常

#### 2.4.2 测试验收
- [ ] 单元测试覆盖率 > 80%
- [ ] 所有测试用例通过
- [ ] 边界条件测试完整
- [ ] 异常场景测试覆盖

#### 2.4.3 代码质量验收
- [ ] 代码规范检查通过
- [ ] 没有代码重复
- [ ] 异常处理完整
- [ ] 日志记录规范

---

## 3. Task 5: 商品和活动实体 (TDD)

### 3.1 功能需求

#### 3.1.1 商品管理功能
**业务描述**: 管理员可以创建、更新、查询商品信息

**商品创建**:
```java
public class CreateProductRequest {
    @NotBlank(message = "商品标题不能为空")
    @Size(max = 255, message = "商品标题不能超过255字符")
    private String title;
    
    @NotNull(message = "商品价格不能为空")
    @DecimalMin(value = "0.01", message = "商品价格必须大于0")
    @Digits(integer = 8, fraction = 2, message = "价格格式不正确")
    private BigDecimal price;
    
    private String description;
}
```

**商品更新**:
```java
public class UpdateProductRequest {
    @NotNull(message = "商品ID不能为空")
    private Long productId;
    
    private String title;
    private BigDecimal price;
    private String description;
    private Product.ProductStatus status;
}
```

**商品响应**:
```java
public class ProductResponse {
    private Long productId;
    private String title;
    private BigDecimal price;
    private String description;
    private String status;
    private LocalDateTime createdAt;
}
```

**业务规则**:
1. 只有管理员可以创建和更新商品
2. 商品标题不能为空且不能超过255字符
3. 商品价格必须大于0，最多2位小数
4. 商品状态包括：ON（上架）、OFF（下架）
5. 软删除：下架商品不删除，只修改状态

#### 3.1.2 秒杀活动管理功能
**业务描述**: 管理员可以创建、更新、查询秒杀活动

**活动创建**:
```java
public class CreateSeckillActivityRequest {
    @NotNull(message = "商品ID不能为空")
    private Long productId;
    
    @NotNull(message = "开始时间不能为空")
    @Future(message = "开始时间必须是未来时间")
    private LocalDateTime startAt;
    
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime endAt;
    
    @NotNull(message = "限购数量不能为空")
    @Min(value = 1, message = "限购数量必须大于0")
    private Integer limitPerUser;
    
    @NotNull(message = "活动库存不能为空")
    @Min(value = 1, message = "活动库存必须大于0")
    private Integer totalStock;
    
    @NotNull(message = "秒杀价格不能为空")
    @DecimalMin(value = "0.01", message = "秒杀价格必须大于0")
    private BigDecimal seckillPrice;
}
```

**活动响应**:
```java
public class SeckillActivityResponse {
    private Long activityId;
    private ProductResponse product;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private Integer limitPerUser;
    private Integer totalStock;
    private Integer remainingStock;
    private BigDecimal seckillPrice;
    private String status;
    private LocalDateTime createdAt;
}
```

**业务规则**:
1. 只有管理员可以创建和管理活动
2. 活动开始时间必须是未来时间
3. 活动结束时间必须晚于开始时间
4. 同一商品同一时间段只能有一个活动
5. 活动状态自动管理：PENDING（待开始）、ACTIVE（进行中）、ENDED（已结束）
6. 秒杀价格必须低于商品原价

#### 3.1.3 商品和活动查询功能
**商品查询**:
- 分页查询所有商品
- 按状态查询商品
- 按ID查询单个商品

**活动查询**:
- 分页查询所有活动
- 按状态查询活动
- 查询当前进行中的活动
- 按商品ID查询活动历史

### 3.2 技术需求

#### 3.2.1 Service层实现
```java
@Service
@Transactional
public class ProductService {
    
    private final ProductMapper productMapper;
    
    public ProductResponse createProduct(CreateProductRequest request);
    public ProductResponse updateProduct(UpdateProductRequest request);
    public ProductResponse getProductById(Long productId);
    public Page<ProductResponse> getProducts(ProductQueryRequest request);
    public void deleteProduct(Long productId);
}

@Service
@Transactional
public class SeckillActivityService {
    
    private final SeckillActivityMapper activityMapper;
    private final ProductMapper productMapper;
    
    public SeckillActivityResponse createActivity(CreateSeckillActivityRequest request);
    public SeckillActivityResponse updateActivity(UpdateSeckillActivityRequest request);
    public SeckillActivityResponse getActivityById(Long activityId);
    public Page<SeckillActivityResponse> getActivities(ActivityQueryRequest request);
    public List<SeckillActivityResponse> getCurrentActiveActivities();
    public void updateActivityStatus();
}
```

#### 3.2.2 定时任务配置
```java
@Component
@EnableScheduling
public class ActivityStatusScheduler {
    
    private final SeckillActivityService activityService;
    
    @Scheduled(fixedRate = 60000) // 每分钟执行一次
    public void updateActivityStatus() {
        activityService.updateActivityStatus();
    }
}
```

#### 3.2.3 业务验证器
```java
@Component
public class ActivityValidator {
    
    public void validateActivityTime(LocalDateTime startAt, LocalDateTime endAt);
    public void validateProductAvailability(Long productId);
    public void validateActivityConflict(Long productId, LocalDateTime startAt, LocalDateTime endAt);
    public void validateSeckillPrice(Long productId, BigDecimal seckillPrice);
}
```

### 3.3 TDD测试用例设计

#### 3.3.1 商品服务测试用例
```java
@ExtendWith(MockitoExtension.class)
class ProductServiceTest {
    
    @Mock
    private ProductMapper productMapper;
    
    @InjectMocks
    private ProductService productService;
    
    @Test
    void shouldCreateProductSuccessfullyWhenValidInput() {
        // Given
        CreateProductRequest request = new CreateProductRequest();
        request.setTitle("iPhone 15");
        request.setPrice(new BigDecimal("7999.00"));
        request.setDescription("最新iPhone");
        
        when(productMapper.insert(any(Product.class))).thenReturn(1);
        
        // When
        ProductResponse response = productService.createProduct(request);
        
        // Then
        assertThat(response.getTitle()).isEqualTo("iPhone 15");
        assertThat(response.getPrice()).isEqualTo(new BigDecimal("7999.00"));
        assertThat(response.getStatus()).isEqualTo("ON");
        verify(productMapper).insert(any(Product.class));
    }
    
    @Test
    void shouldUpdateProductSuccessfullyWhenValidInput() {
        // Given
        Long productId = 1L;
        UpdateProductRequest request = new UpdateProductRequest();
        request.setProductId(productId);
        request.setTitle("iPhone 15 Pro");
        request.setPrice(new BigDecimal("8999.00"));
        
        Product existingProduct = TestDataBuilder.product()
            .id(productId)
            .title("iPhone 15")
            .price(new BigDecimal("7999.00"))
            .buildEntity();
        
        when(productMapper.selectById(productId)).thenReturn(existingProduct);
        when(productMapper.updateById(any(Product.class))).thenReturn(1);
        
        // When
        ProductResponse response = productService.updateProduct(request);
        
        // Then
        assertThat(response.getTitle()).isEqualTo("iPhone 15 Pro");
        assertThat(response.getPrice()).isEqualTo(new BigDecimal("8999.00"));
        verify(productMapper).updateById(any(Product.class));
    }
    
    @Test
    void shouldThrowExceptionWhenProductNotFound() {
        // Given
        Long productId = 999L;
        when(productMapper.selectById(productId)).thenReturn(null);
        
        // When & Then
        assertThatThrownBy(() -> productService.getProductById(productId))
            .isInstanceOf(ProductNotFoundException.class)
            .hasMessage("商品不存在: " + productId);
    }
}
```

#### 3.3.2 秒杀活动服务测试用例
```java
@ExtendWith(MockitoExtension.class)
class SeckillActivityServiceTest {
    
    @Mock
    private SeckillActivityMapper activityMapper;
    
    @Mock
    private ProductMapper productMapper;
    
    @Mock
    private ActivityValidator activityValidator;
    
    @InjectMocks
    private SeckillActivityService activityService;
    
    @Test
    void shouldCreateActivitySuccessfullyWhenValidInput() {
        // Given
        CreateSeckillActivityRequest request = new CreateSeckillActivityRequest();
        request.setProductId(1L);
        request.setStartAt(LocalDateTime.now().plusHours(1));
        request.setEndAt(LocalDateTime.now().plusHours(2));
        request.setLimitPerUser(1);
        request.setTotalStock(100);
        request.setSeckillPrice(new BigDecimal("6999.00"));
        
        Product product = TestDataBuilder.product()
            .id(1L)
            .title("iPhone 15")
            .price(new BigDecimal("7999.00"))
            .buildEntity();
        
        when(productMapper.selectById(1L)).thenReturn(product);
        when(activityMapper.insert(any(SeckillActivity.class))).thenReturn(1);
        
        // When
        SeckillActivityResponse response = activityService.createActivity(request);
        
        // Then
        assertThat(response.getProduct().getProductId()).isEqualTo(1L);
        assertThat(response.getTotalStock()).isEqualTo(100);
        assertThat(response.getSeckillPrice()).isEqualTo(new BigDecimal("6999.00"));
        assertThat(response.getStatus()).isEqualTo("PENDING");
        
        verify(activityValidator).validateActivityTime(any(), any());
        verify(activityValidator).validateProductAvailability(1L);
        verify(activityValidator).validateSeckillPrice(1L, new BigDecimal("6999.00"));
        verify(activityMapper).insert(any(SeckillActivity.class));
    }
    
    @Test
    void shouldThrowExceptionWhenEndTimeBeforeStartTime() {
        // Given
        CreateSeckillActivityRequest request = new CreateSeckillActivityRequest();
        request.setStartAt(LocalDateTime.now().plusHours(2));
        request.setEndAt(LocalDateTime.now().plusHours(1)); // 结束时间早于开始时间
        
        doThrow(new InvalidActivityTimeException("结束时间必须晚于开始时间"))
            .when(activityValidator).validateActivityTime(any(), any());
        
        // When & Then
        assertThatThrownBy(() -> activityService.createActivity(request))
            .isInstanceOf(InvalidActivityTimeException.class)
            .hasMessage("结束时间必须晚于开始时间");
    }
    
    @Test
    void shouldUpdateActivityStatusCorrectly() {
        // Given
        LocalDateTime now = LocalDateTime.now();
        List<SeckillActivity> activities = Arrays.asList(
            TestDataBuilder.seckillActivity()
                .status(SeckillActivity.ActivityStatus.PENDING)
                .startAt(now.minusMinutes(5))
                .endAt(now.plusHours(1))
                .buildEntity(),
            TestDataBuilder.seckillActivity()
                .status(SeckillActivity.ActivityStatus.ACTIVE)
                .startAt(now.minusHours(2))
                .endAt(now.minusMinutes(5))
                .buildEntity()
        );
        
        when(activityMapper.selectList(any())).thenReturn(activities);
        
        // When
        activityService.updateActivityStatus();
        
        // Then
        verify(activityMapper, times(2)).updateById(any(SeckillActivity.class));
    }
}
```

#### 3.3.3 业务验证器测试用例
```java
@ExtendWith(MockitoExtension.class)
class ActivityValidatorTest {
    
    @Mock
    private ProductMapper productMapper;
    
    @Mock
    private SeckillActivityMapper activityMapper;
    
    @InjectMocks
    private ActivityValidator activityValidator;
    
    @Test
    void shouldPassWhenValidActivityTime() {
        // Given
        LocalDateTime startAt = LocalDateTime.now().plusHours(1);
        LocalDateTime endAt = LocalDateTime.now().plusHours(2);
        
        // When & Then
        assertThatCode(() -> activityValidator.validateActivityTime(startAt, endAt))
            .doesNotThrowAnyException();
    }
    
    @Test
    void shouldThrowExceptionWhenEndTimeBeforeStartTime() {
        // Given
        LocalDateTime startAt = LocalDateTime.now().plusHours(2);
        LocalDateTime endAt = LocalDateTime.now().plusHours(1);
        
        // When & Then
        assertThatThrownBy(() -> activityValidator.validateActivityTime(startAt, endAt))
            .isInstanceOf(InvalidActivityTimeException.class)
            .hasMessage("结束时间必须晚于开始时间");
    }
    
    @Test
    void shouldThrowExceptionWhenStartTimeInPast() {
        // Given
        LocalDateTime startAt = LocalDateTime.now().minusHours(1);
        LocalDateTime endAt = LocalDateTime.now().plusHours(1);
        
        // When & Then
        assertThatThrownBy(() -> activityValidator.validateActivityTime(startAt, endAt))
            .isInstanceOf(InvalidActivityTimeException.class)
            .hasMessage("开始时间不能是过去时间");
    }
    
    @Test
    void shouldThrowExceptionWhenSeckillPriceHigherThanOriginal() {
        // Given
        Long productId = 1L;
        BigDecimal seckillPrice = new BigDecimal("8999.00");
        
        Product product = TestDataBuilder.product()
            .id(productId)
            .price(new BigDecimal("7999.00"))
            .buildEntity();
        
        when(productMapper.selectById(productId)).thenReturn(product);
        
        // When & Then
        assertThatThrownBy(() -> activityValidator.validateSeckillPrice(productId, seckillPrice))
            .isInstanceOf(InvalidSeckillPriceException.class)
            .hasMessage("秒杀价格不能高于商品原价");
    }
}
```

### 3.4 验收标准

#### 3.4.1 功能验收
- [ ] 管理员可以成功创建商品
- [ ] 管理员可以更新商品信息
- [ ] 商品状态可以正确切换
- [ ] 管理员可以创建秒杀活动
- [ ] 活动时间验证正确
- [ ] 活动状态自动更新
- [ ] 商品和活动查询功能正常

#### 3.4.2 测试验收
- [ ] 单元测试覆盖率 > 80%
- [ ] 业务验证逻辑测试完整
- [ ] 定时任务测试覆盖
- [ ] 异常场景测试完整

---

## 4. Task 6: 订单和支付实体 (TDD)

### 4.1 功能需求

#### 4.1.1 订单创建功能
**业务描述**: 用户参与秒杀或普通购买时创建订单

**订单创建请求**:
```java
public class CreateOrderRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @NotNull(message = "商品ID不能为空")
    private Long productId;
    
    private Long activityId; // 秒杀活动ID，可为空
    
    @NotNull(message = "购买数量不能为空")
    @Min(value = 1, message = "购买数量必须大于0")
    private Integer quantity;
    
    @NotBlank(message = "幂等键不能为空")
    private String idempotencyKey;
}
```

**订单响应**:
```java
public class OrderResponse {
    private Long orderId;
    private String orderNo;
    private Long userId;
    private ProductResponse product;
    private SeckillActivityResponse activity;
    private Integer quantity;
    private BigDecimal amount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

**业务规则**:
1. 订单号自动生成，格式：ORD + yyyyMMddHHmmss + 6位随机数
2. 支持幂等性，相同幂等键不重复创建订单
3. 秒杀订单需要验证活动有效性和库存
4. 普通订单直接按商品原价计算
5. 订单创建后状态为NEW

#### 4.1.2 订单状态管理功能
**订单状态流转**:
```
NEW (新建) -> PAID (已支付) -> COMPLETED (已完成)
NEW (新建) -> CANCELLED (已取消)
NEW (新建) -> TIMEOUT (超时)
```

**状态更新请求**:
```java
public class UpdateOrderStatusRequest {
    @NotNull(message = "订单ID不能为空")
    private Long orderId;
    
    @NotNull(message = "目标状态不能为空")
    private Order.OrderStatus targetStatus;
    
    private String reason; // 状态变更原因
}
```

**业务规则**:
1. 状态流转必须符合业务规则
2. 已支付订单不能取消
3. 超时订单自动取消（30分钟）
4. 状态变更记录操作日志

#### 4.1.3 订单查询功能
**查询类型**:
- 按用户ID查询订单列表
- 按订单号查询单个订单
- 按活动ID查询参与订单
- 按状态查询订单

**查询请求**:
```java
public class OrderQueryRequest {
    private Long userId;
    private Long activityId;
    private Order.OrderStatus status;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer page = 1;
    private Integer size = 10;
}
```

#### 4.1.4 支付回调处理功能
**支付回调请求**:
```java
public class PaymentCallbackRequest {
    @NotBlank(message = "订单号不能为空")
    private String orderNo;
    
    @NotNull(message = "支付状态不能为空")
    private Payment.PayStatus payStatus;
    
    @NotBlank(message = "第三方交易流水号不能为空")
    private String providerTxnId;
    
    @NotNull(message = "支付金额不能为空")
    private BigDecimal amount;
    
    private String paymentMethod;
    private LocalDateTime payTime;
}
```

**业务规则**:
1. 支持幂等性，相同流水号不重复处理
2. 验证支付金额与订单金额一致
3. 支付成功后更新订单状态为PAID
4. 支付失败后可重试或取消订单
5. 记录支付流水和状态变更日志

### 4.2 技术需求

#### 4.2.1 Service层实现
```java
@Service
@Transactional
public class OrderService {
    
    private final OrderMapper orderMapper;
    private final ProductMapper productMapper;
    private final SeckillActivityMapper activityMapper;
    private final OrderNumberGenerator orderNumberGenerator;
    
    public OrderResponse createOrder(CreateOrderRequest request);
    public OrderResponse updateOrderStatus(UpdateOrderStatusRequest request);
    public OrderResponse getOrderById(Long orderId);
    public OrderResponse getOrderByOrderNo(String orderNo);
    public Page<OrderResponse> getOrders(OrderQueryRequest request);
    public void cancelTimeoutOrders();
}

@Service
@Transactional
public class PaymentService {
    
    private final PaymentMapper paymentMapper;
    private final OrderService orderService;
    
    public void handlePaymentCallback(PaymentCallbackRequest request);
    public PaymentResponse getPaymentByOrderId(Long orderId);
    public PaymentResponse getPaymentByTxnId(String providerTxnId);
}
```

#### 4.2.2 工具类实现
```java
@Component
public class OrderNumberGenerator {
    
    private final RedisTemplate<String, String> redisTemplate;
    
    public String generateOrderNumber() {
        String prefix = "ORD";
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String sequence = generateSequence();
        return prefix + timestamp + sequence;
    }
    
    private String generateSequence() {
        String key = "order:sequence:" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        Long sequence = redisTemplate.opsForValue().increment(key);
        redisTemplate.expire(key, Duration.ofDays(1));
        return String.format("%06d", sequence % 1000000);
    }
}

@Component
public class OrderStateMachine {
    
    public boolean canTransition(Order.OrderStatus from, Order.OrderStatus to) {
        // 实现状态转换规则
    }
    
    public void validateTransition(Order.OrderStatus from, Order.OrderStatus to) {
        if (!canTransition(from, to)) {
            throw new InvalidOrderStatusTransitionException(from, to);
        }
    }
}
```

#### 4.2.3 定时任务
```java
@Component
public class OrderTimeoutScheduler {
    
    private final OrderService orderService;
    
    @Scheduled(fixedRate = 300000) // 每5分钟执行一次
    public void cancelTimeoutOrders() {
        orderService.cancelTimeoutOrders();
    }
}
```

### 4.3 TDD测试用例设计

#### 4.3.1 订单服务测试用例
```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    
    @Mock
    private OrderMapper orderMapper;
    
    @Mock
    private ProductMapper productMapper;
    
    @Mock
    private SeckillActivityMapper activityMapper;
    
    @Mock
    private OrderNumberGenerator orderNumberGenerator;
    
    @Mock
    private OrderStateMachine orderStateMachine;
    
    @InjectMocks
    private OrderService orderService;
    
    @Test
    void shouldCreateOrderSuccessfullyWhenValidInput() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest();
        request.setUserId(1L);
        request.setProductId(1L);
        request.setQuantity(1);
        request.setIdempotencyKey("test-key-001");
        
        Product product = TestDataBuilder.product()
            .id(1L)
            .price(new BigDecimal("7999.00"))
            .buildEntity();
        
        when(orderMapper.selectByIdempotencyKey("test-key-001")).thenReturn(null);
        when(productMapper.selectById(1L)).thenReturn(product);
        when(orderNumberGenerator.generateOrderNumber()).thenReturn("ORD20240107120000123456");
        when(orderMapper.insert(any(Order.class))).thenReturn(1);
        
        // When
        OrderResponse response = orderService.createOrder(request);
        
        // Then
        assertThat(response.getOrderNo()).isEqualTo("ORD20240107120000123456");
        assertThat(response.getAmount()).isEqualTo(new BigDecimal("7999.00"));
        assertThat(response.getStatus()).isEqualTo("NEW");
        verify(orderMapper).insert(any(Order.class));
    }
    
    @Test
    void shouldReturnExistingOrderWhenDuplicateIdempotencyKey() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest();
        request.setIdempotencyKey("test-key-001");
        
        Order existingOrder = TestDataBuilder.order()
            .orderNo("ORD20240107120000123456")
            .idempotencyKey("test-key-001")
            .buildEntity();
        
        when(orderMapper.selectByIdempotencyKey("test-key-001")).thenReturn(existingOrder);
        
        // When
        OrderResponse response = orderService.createOrder(request);
        
        // Then
        assertThat(response.getOrderNo()).isEqualTo("ORD20240107120000123456");
        verify(orderMapper, never()).insert(any(Order.class));
    }
    
    @Test
    void shouldCreateSeckillOrderWithActivityValidation() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest();
        request.setUserId(1L);
        request.setProductId(1L);
        request.setActivityId(1L);
        request.setQuantity(1);
        request.setIdempotencyKey("test-key-002");
        
        Product product = TestDataBuilder.product().id(1L).buildEntity();
        SeckillActivity activity = TestDataBuilder.seckillActivity()
            .id(1L)
            .productId(1L)
            .status(SeckillActivity.ActivityStatus.ACTIVE)
            .seckillPrice(new BigDecimal("6999.00"))
            .buildEntity();
        
        when(orderMapper.selectByIdempotencyKey("test-key-002")).thenReturn(null);
        when(productMapper.selectById(1L)).thenReturn(product);
        when(activityMapper.selectById(1L)).thenReturn(activity);
        when(orderNumberGenerator.generateOrderNumber()).thenReturn("ORD20240107120000123457");
        when(orderMapper.insert(any(Order.class))).thenReturn(1);
        
        // When
        OrderResponse response = orderService.createOrder(request);
        
        // Then
        assertThat(response.getAmount()).isEqualTo(new BigDecimal("6999.00"));
        assertThat(response.getActivity().getActivityId()).isEqualTo(1L);
    }
    
    @Test
    void shouldUpdateOrderStatusSuccessfully() {
        // Given
        Long orderId = 1L;
        UpdateOrderStatusRequest request = new UpdateOrderStatusRequest();
        request.setOrderId(orderId);
        request.setTargetStatus(Order.OrderStatus.PAID);
        request.setReason("支付成功");
        
        Order existingOrder = TestDataBuilder.order()
            .id(orderId)
            .status(Order.OrderStatus.NEW)
            .buildEntity();
        
        when(orderMapper.selectById(orderId)).thenReturn(existingOrder);
        when(orderStateMachine.canTransition(Order.OrderStatus.NEW, Order.OrderStatus.PAID)).thenReturn(true);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);
        
        // When
        OrderResponse response = orderService.updateOrderStatus(request);
        
        // Then
        assertThat(response.getStatus()).isEqualTo("PAID");
        verify(orderStateMachine).validateTransition(Order.OrderStatus.NEW, Order.OrderStatus.PAID);
        verify(orderMapper).updateById(any(Order.class));
    }
    
    @Test
    void shouldThrowExceptionWhenInvalidStatusTransition() {
        // Given
        Long orderId = 1L;
        UpdateOrderStatusRequest request = new UpdateOrderStatusRequest();
        request.setOrderId(orderId);
        request.setTargetStatus(Order.OrderStatus.NEW);
        
        Order existingOrder = TestDataBuilder.order()
            .id(orderId)
            .status(Order.OrderStatus.PAID)
            .buildEntity();
        
        when(orderMapper.selectById(orderId)).thenReturn(existingOrder);
        doThrow(new InvalidOrderStatusTransitionException(Order.OrderStatus.PAID, Order.OrderStatus.NEW))
            .when(orderStateMachine).validateTransition(Order.OrderStatus.PAID, Order.OrderStatus.NEW);
        
        // When & Then
        assertThatThrownBy(() -> orderService.updateOrderStatus(request))
            .isInstanceOf(InvalidOrderStatusTransitionException.class);
    }
}
```

#### 4.3.2 支付服务测试用例
```java
@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {
    
    @Mock
    private PaymentMapper paymentMapper;
    
    @Mock
    private OrderService orderService;
    
    @InjectMocks
    private PaymentService paymentService;
    
    @Test
    void shouldHandlePaymentCallbackSuccessfully() {
        // Given
        PaymentCallbackRequest request = new PaymentCallbackRequest();
        request.setOrderNo("ORD20240107120000123456");
        request.setPayStatus(Payment.PayStatus.SUCCESS);
        request.setProviderTxnId("TXN123456789");
        request.setAmount(new BigDecimal("7999.00"));
        
        OrderResponse order = TestDataBuilder.orderResponse()
            .orderId(1L)
            .orderNo("ORD20240107120000123456")
            .amount(new BigDecimal("7999.00"))
            .status("NEW")
            .build();
        
        when(orderService.getOrderByOrderNo("ORD20240107120000123456")).thenReturn(order);
        when(paymentMapper.selectByProviderTxnId("TXN123456789")).thenReturn(null);
        when(paymentMapper.insert(any(Payment.class))).thenReturn(1);
        
        // When
        paymentService.handlePaymentCallback(request);
        
        // Then
        verify(paymentMapper).insert(any(Payment.class));
        verify(orderService).updateOrderStatus(any(UpdateOrderStatusRequest.class));
    }
    
    @Test
    void shouldIgnoreDuplicatePaymentCallback() {
        // Given
        PaymentCallbackRequest request = new PaymentCallbackRequest();
        request.setProviderTxnId("TXN123456789");
        
        Payment existingPayment = TestDataBuilder.payment()
            .providerTxnId("TXN123456789")
            .buildEntity();
        
        when(paymentMapper.selectByProviderTxnId("TXN123456789")).thenReturn(existingPayment);
        
        // When
        paymentService.handlePaymentCallback(request);
        
        // Then
        verify(paymentMapper, never()).insert(any(Payment.class));
        verify(orderService, never()).updateOrderStatus(any(UpdateOrderStatusRequest.class));
    }
    
    @Test
    void shouldThrowExceptionWhenAmountMismatch() {
        // Given
        PaymentCallbackRequest request = new PaymentCallbackRequest();
        request.setOrderNo("ORD20240107120000123456");
        request.setAmount(new BigDecimal("6999.00")); // 金额不匹配
        
        OrderResponse order = TestDataBuilder.orderResponse()
            .orderNo("ORD20240107120000123456")
            .amount(new BigDecimal("7999.00"))
            .build();
        
        when(orderService.getOrderByOrderNo("ORD20240107120000123456")).thenReturn(order);
        
        // When & Then
        assertThatThrownBy(() -> paymentService.handlePaymentCallback(request))
            .isInstanceOf(PaymentAmountMismatchException.class)
            .hasMessage("支付金额与订单金额不匹配");
    }
}
```

#### 4.3.3 订单状态机测试用例
```java
class OrderStateMachineTest {
    
    private OrderStateMachine orderStateMachine;
    
    @BeforeEach
    void setUp() {
        orderStateMachine = new OrderStateMachine();
    }
    
    @Test
    void shouldAllowValidTransitions() {
        // Given & When & Then
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.NEW, Order.OrderStatus.PAID)).isTrue();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.NEW, Order.OrderStatus.CANCELLED)).isTrue();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.NEW, Order.OrderStatus.TIMEOUT)).isTrue();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.PAID, Order.OrderStatus.COMPLETED)).isTrue();
    }
    
    @Test
    void shouldRejectInvalidTransitions() {
        // Given & When & Then
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.PAID, Order.OrderStatus.NEW)).isFalse();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.PAID, Order.OrderStatus.CANCELLED)).isFalse();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.CANCELLED, Order.OrderStatus.PAID)).isFalse();
        assertThat(orderStateMachine.canTransition(Order.OrderStatus.TIMEOUT, Order.OrderStatus.PAID)).isFalse();
    }
    
    @Test
    void shouldThrowExceptionForInvalidTransition() {
        // Given
        Order.OrderStatus from = Order.OrderStatus.PAID;
        Order.OrderStatus to = Order.OrderStatus.NEW;
        
        // When & Then
        assertThatThrownBy(() -> orderStateMachine.validateTransition(from, to))
            .isInstanceOf(InvalidOrderStatusTransitionException.class)
            .hasMessage("无效的订单状态转换: PAID -> NEW");
    }
}
```

### 4.4 验收标准

#### 4.4.1 功能验收
- [ ] 订单可以成功创建
- [ ] 幂等性机制正常工作
- [ ] 订单状态流转正确
- [ ] 支付回调处理正确
- [ ] 超时订单自动取消
- [ ] 订单查询功能正常

#### 4.4.2 测试验收
- [ ] 单元测试覆盖率 > 80%
- [ ] 状态机逻辑测试完整
- [ ] 幂等性测试覆盖
- [ ] 异常场景测试完整

---

## 5. 整体技术架构

### 5.1 分层架构设计
```
┌─────────────────────────────────────────┐
│                Controller               │ ← Task 7-8 实现
├─────────────────────────────────────────┤
│                 Service                 │ ← Phase 1 实现
├─────────────────────────────────────────┤
│                 Mapper                  │ ← 已完成
├─────────────────────────────────────────┤
│                 Entity                  │ ← 已完成
├─────────────────────────────────────────┤
│                Database                 │ ← 已完成
└─────────────────────────────────────────┘
```

### 5.2 依赖注入配置
```java
@Configuration
public class ServiceConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public JwtUtil jwtUtil() {
        return new JwtUtil();
    }
    
    @Bean
    public OrderNumberGenerator orderNumberGenerator(RedisTemplate<String, String> redisTemplate) {
        return new OrderNumberGenerator(redisTemplate);
    }
    
    @Bean
    public OrderStateMachine orderStateMachine() {
        return new OrderStateMachine();
    }
}
```

### 5.3 异常处理体系
```java
// 基础业务异常
public abstract class BusinessException extends RuntimeException {
    private final String code;
    
    public BusinessException(String message) {
        super(message);
        this.code = this.getClass().getSimpleName();
    }
}

// 具体业务异常
public class EmailAlreadyExistsException extends BusinessException { }
public class InvalidCredentialsException extends BusinessException { }
public class UserNotFoundException extends BusinessException { }
public class ProductNotFoundException extends BusinessException { }
public class InvalidActivityTimeException extends BusinessException { }
public class InvalidSeckillPriceException extends BusinessException { }
public class InvalidOrderStatusTransitionException extends BusinessException { }
public class PaymentAmountMismatchException extends BusinessException { }
```

### 5.4 测试数据构建器
```java
public class TestDataBuilder {
    
    public static class UserBuilder {
        private String email = "test@example.com";
        private String passwordHash = "hashedPassword";
        private User.UserRole role = User.UserRole.USER;
        
        public UserBuilder email(String email) { this.email = email; return this; }
        public UserBuilder admin() { this.role = User.UserRole.ADMIN; return this; }
        
        public User buildEntity() {
            User user = new User();
            user.setEmail(email);
            user.setPasswordHash(passwordHash);
            user.setRole(role);
            return user;
        }
    }
    
    public static class ProductBuilder {
        private Long id = 1L;
        private String title = "Test Product";
        private BigDecimal price = new BigDecimal("99.99");
        private Product.ProductStatus status = Product.ProductStatus.ON;
        
        public ProductBuilder id(Long id) { this.id = id; return this; }
        public ProductBuilder title(String title) { this.title = title; return this; }
        public ProductBuilder price(BigDecimal price) { this.price = price; return this; }
        
        public Product buildEntity() {
            Product product = new Product();
            product.setId(id);
            product.setTitle(title);
            product.setPrice(price);
            product.setStatus(status);
            return product;
        }
    }
    
    // 其他实体的Builder...
    
    public static UserBuilder user() { return new UserBuilder(); }
    public static ProductBuilder product() { return new ProductBuilder(); }
    public static SeckillActivityBuilder seckillActivity() { return new SeckillActivityBuilder(); }
    public static OrderBuilder order() { return new OrderBuilder(); }
    public static PaymentBuilder payment() { return new PaymentBuilder(); }
}
```

---

## 6. 质量保证

### 6.1 代码覆盖率要求
- **单元测试覆盖率**: > 80%
- **分支覆盖率**: > 70%
- **方法覆盖率**: > 90%

### 6.2 代码质量检查
```xml
<!-- Maven插件配置 -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <configuration>
        <rules>
            <rule>
                <element>BUNDLE</element>
                <limits>
                    <limit>
                        <counter>LINE</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.80</minimum>
                    </limit>
                    <limit>
                        <counter>BRANCH</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.70</minimum>
                    </limit>
                </limits>
            </rule>
        </rules>
    </configuration>
</plugin>
```

### 6.3 测试执行策略
```bash
# 执行所有测试
mvn clean test

# 生成覆盖率报告
mvn jacoco:report

# 检查覆盖率是否达标
mvn jacoco:check
```

---

## 7. 风险管控

### 7.1 技术风险
**风险**: TDD开发周期可能延长  
**缓解**: 
- 制定详细的时间计划
- 优先实现核心功能
- 并行开发测试用例

**风险**: 测试用例维护成本高  
**缓解**: 
- 建立测试用例规范
- 使用测试数据构建器
- 定期重构测试代码

### 7.2 进度风险
**风险**: 某个Task延期影响整体进度  
**缓解**: 
- 每个Task设置缓冲时间
- 关键路径优先
- 每日进度检查

### 7.3 质量风险
**风险**: 测试覆盖率不达标  
**缓解**: 
- 每日检查覆盖率
- 及时补充测试用例
- 代码审查机制

---

## 8. 验收标准

### 8.1 功能验收标准
- [ ] 用户注册登录功能完整可用
- [ ] 商品管理功能完整可用
- [ ] 秒杀活动管理功能完整可用
- [ ] 订单创建和状态管理功能完整可用
- [ ] 支付回调处理功能完整可用
- [ ] 所有业务规则正确实现
- [ ] 异常处理机制完整

### 8.2 测试验收标准
- [ ] 单元测试覆盖率 ≥ 80%
- [ ] 分支覆盖率 ≥ 70%
- [ ] 所有测试用例通过
- [ ] 边界条件测试完整
- [ ] 异常场景测试覆盖
- [ ] 幂等性测试通过

### 8.3 代码质量验收标准
- [ ] 代码规范检查通过
- [ ] 没有代码重复
- [ ] 异常处理完整
- [ ] 日志记录规范
- [ ] 注释清晰完整
- [ ] 方法复杂度合理

### 8.4 性能验收标准
- [ ] 单个服务方法响应时间 < 100ms
- [ ] 数据库查询优化合理
- [ ] 内存使用合理
- [ ] 无明显性能瓶颈

---

## 9. 后续任务准备

### 9.1 为Phase 2准备的基础
- ✅ 完整的Service层实现
- ✅ 基础的异常处理机制
- ✅ JWT工具类和密码加密
- ✅ 订单状态机和支付回调
- ✅ 完整的测试基础设施

### 9.2 Phase 2需要的扩展
- 🔄 Controller层实现（REST API）
- 🔄 Spring Security配置
- 🔄 Redis缓存策略
- 🔄 全局异常处理
- 🔄 参数验证机制

### 9.3 技术债务清理
- ✅ Service层业务逻辑实现
- ✅ 基础配置扩展
- ✅ 异常处理体系建立
- ✅ 测试框架搭建
- ⚠️ 性能优化（Phase 3处理）

---

## 10. 总结

### 10.1 Phase 1目标达成
通过Task 4-6的TDD开发，FlashSaleX将完成：
- 🎯 **基础设施层建设**: 完整的Service层和配置层
- 🎯 **核心业务逻辑**: 用户、商品、活动、订单、支付的基础功能
- 🎯 **测试基础设施**: 完整的TDD测试框架和高覆盖率
- 🎯 **代码质量保证**: 规范的代码结构和异常处理

### 10.2 技术价值
- ✅ **可测试性**: 通过TDD确保代码可测试性
- ✅ **可维护性**: 清晰的分层架构和异常处理
- ✅ **可扩展性**: 为后续功能开发奠定基础
- ✅ **可靠性**: 完整的业务规则和状态管理

### 10.3 业务价值
- ✅ **用户管理**: 支持用户注册登录和权限管理
- ✅ **商品管理**: 支持商品的完整生命周期管理
- ✅ **活动管理**: 支持秒杀活动的创建和状态管理
- ✅ **订单管理**: 支持订单的创建、状态流转和查询
- ✅ **支付处理**: 支持支付回调和幂等性处理

Phase 1完成后，FlashSaleX将具备完整的业务逻辑基础，为Phase 2的API层开发和Phase 3的Redis集成做好准备。

---
**文档版本**: v1.0  
**执行开始**: Task 4 启动时  
**预期完成**: Task 6 结束时  
**下一阶段**: Phase 2 - 核心业务层 (Task 7-8)
