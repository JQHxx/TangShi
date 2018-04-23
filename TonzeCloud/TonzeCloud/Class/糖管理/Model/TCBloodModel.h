//
//  TCBloodModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/14.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
"blood_record_id" = 4;
"diastolic_pressure" = 91;
"measure_data" = "2017-07-17";
"measure_time" = 1500258660;
remark = "";
"systolic_pressure" = 107;
"user_id" = 173;
way = 1;
 */
#import <Foundation/Foundation.h>

@interface TCBloodModel : NSObject

@property (nonatomic, assign) NSInteger blood_record_id;
@property (nonatomic, assign) NSInteger diastolic_pressure;
@property (nonatomic, assign) NSInteger systolic_pressure;
@property (nonatomic, assign) NSInteger way;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *measure_time;
@property (nonatomic, copy) NSString *measure_data;
@property (nonatomic, copy) NSString *remark;

@end
