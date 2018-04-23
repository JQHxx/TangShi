//
//  ExchangeRecordsDetailModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCExchangeRecordsDetailModel : NSObject

/// 订单id
@property (nonatomic ,strong) NSNumber *order_id;
/// 订单编号
@property (nonatomic ,strong) NSNumber *order_sn;
///
@property (nonatomic ,strong) NSNumber *good_id;
///
@property (nonatomic ,strong) NSNumber *user_id;
///
@property (nonatomic ,copy)  NSString *change_time;
/// 订单状态（0 未发货，1 已发货）
@property (nonatomic ,strong) NSNumber *delivery_status;
/// 添加订单时间
@property (nonatomic ,copy) NSString *add_time;
/// 兑换时间
@property (nonatomic, copy) NSString *edit_time;
/// 物流公司
@property (nonatomic, copy) NSString *logistics_company;
/// 运单编号
@property (nonatomic ,strong) NSNumber *tracking_number;

/// 详细地址信息
@property (nonatomic, copy) NSString *consignee_addr;
/// 区镇信息
@property (nonatomic, copy) NSString *consignee_area;
/// 市信息
@property (nonatomic, copy) NSString *consignee_city;
/// 省份信息
@property (nonatomic, copy) NSString *consignee_pro;
/// 收货人
@property (nonatomic, copy) NSString *consignee_name;
/// 手机号
@property (nonatomic, copy) NSString *consignee_phone;


@end
