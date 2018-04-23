//
//  TCGPRSDeviceListModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGPRSDeviceListModel : NSObject

/// 设备号
@property (nonatomic, copy) NSString *sn;
/// 用户id
@property (nonatomic, assign) NSInteger  user_id;
/// 添加时间
@property (nonatomic, copy) NSString *add_time;
/// 设备名称
@property (nonatomic, copy) NSString *device_name;
/// 有效时限
@property (nonatomic, copy) NSString *valid_date;
/// 最近一次测量记录
@property (nonatomic ,strong) NSDictionary *latest;
/// 测量统计数据
@property (nonatomic ,strong) NSDictionary *sugar_data;



@end
/*
 
 "sn": "14F000029",
 "user_id": 29,
 "add_time": 1510297486,
 "device_name": "而无法大师风范水电费撒旦",
 "valid_date": 0,
 "latest": {
 "time_slot": "beforeDinner",
 "glucose": "20.8",
 "measurement_time": 1498128360
 },
 "sugar_data": {
 "low_num": 0,
 "high_num": 73,
 "normal_num": 11,
 "total": 84
 }
*/
