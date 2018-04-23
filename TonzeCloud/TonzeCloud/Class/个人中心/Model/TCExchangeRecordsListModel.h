//
//  ExchangeRecordsListModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCExchangeRecordsListModel : NSObject

/// 商品Id
@property (nonatomic ,strong) NSNumber *good_id;
/// 添加时间
@property (nonatomic, copy) NSString *add_time;
/// 积分
@property (nonatomic ,strong) NSNumber *change_points;
/// 商品标题
@property (nonatomic, copy) NSString *good_name;
/// 商品信息
@property (nonatomic ,strong) NSDictionary *goods;
/// 订单id
@property (nonatomic ,strong) NSNumber *order_id;
/// 订单状态
@property (nonatomic ,strong) NSNumber *delivery_status;

@end


/*
 "order_id": 11,
 "order_sn": "3020170612133929VODd",
 "good_id": 9,
 "user_id": 15,
 "change_time": 1497245969,
 "delivery_status": 0,
 "logistics_company": "",
 "tracking_number": "",
 "add_time": "2017-06-12 13:39",
 "edit_time": 1497245969,
 "goods": {
 "good_id": 9,
 "good_name": "大白菜",
 "good_image": "bcf08cf38fcec8a2aa7b799bcb344247",
 "change_points": 11,
 "image_url": "http://360tjy-health.oss-cn-shanghai.aliyuncs.com/image/test/201705/e04ce029fa28a6f7814a6ac1902bb18e.png"
 }
 
 */
