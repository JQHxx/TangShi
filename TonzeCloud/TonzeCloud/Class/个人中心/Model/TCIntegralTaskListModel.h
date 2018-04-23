//
//  IntegralTaskListModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCIntegralTaskListModel : NSObject

/// 任务类型id
@property (nonatomic ,strong)  NSNumber *action_type;
/// 完成次数
@property (nonatomic ,assign) NSInteger click_num;
///
@property (nonatomic ,assign) NSInteger status;
///
@property (nonatomic ,strong) NSNumber *sort;
/// 任务名
@property (nonatomic, copy) NSString *action_name;
/// 总次数
@property (nonatomic ,assign) NSInteger sum_num;
/// 每次任务积分
@property (nonatomic ,strong) NSNumber *use_points;

@end
/*
 {
 "action_type": 14,
 "click_num": 0,
 "status": 0,
 "sort": 13,
 "action_name": "添加亲友",
 "sum_num": 3,
 "use_points": 50
 },
 
 */
