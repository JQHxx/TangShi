//
//  UserIntegralDetailModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCIntegralDetailModel : NSObject
///流水号
@property (nonatomic, copy) NSString *task_sn;
///任务名
@property (nonatomic, copy) NSString *action_name;
///类型
@property (nonatomic, copy) NSString *use_type;
///时间
@property (nonatomic, copy) NSString *time;
///剩余积分数
@property (nonatomic ,strong) NSNumber *rest_integral;
///积分数
@property (nonatomic ,strong) NSNumber *use_points;

@end
