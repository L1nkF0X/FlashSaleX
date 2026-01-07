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
