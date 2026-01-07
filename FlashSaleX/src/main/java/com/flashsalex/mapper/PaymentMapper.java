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
