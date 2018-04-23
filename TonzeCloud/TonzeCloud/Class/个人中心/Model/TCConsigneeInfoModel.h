//
//  ConsigneeInfoModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCConsigneeInfoModel : NSObject
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
