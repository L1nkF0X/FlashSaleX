package com.flashsalex;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 应用启动测试
 */
@SpringBootTest
@ActiveProfiles("test")
class FlashSaleXApplicationTests {

    @Test
    void contextLoads() {
        // 测试 Spring 上下文是否能正常加载
    }
}
