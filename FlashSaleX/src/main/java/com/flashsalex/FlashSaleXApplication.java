package com.flashsalex;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.flashsalex.mapper")
public class FlashSaleXApplication {

    public static void main(String[] args) {
        SpringApplication.run(FlashSaleXApplication.class, args);
    }

}
