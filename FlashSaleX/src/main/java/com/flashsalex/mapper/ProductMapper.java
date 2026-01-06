package com.flashsalex.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.flashsalex.entity.Product;
import org.apache.ibatis.annotations.Mapper;

/**
 * 商品Mapper接口
 */
@Mapper
public interface ProductMapper extends BaseMapper<Product> {
}
