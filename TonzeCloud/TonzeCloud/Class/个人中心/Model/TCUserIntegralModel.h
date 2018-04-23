//
//  UserIntegralModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserIntegralModel : NSObject
///流水号
@property (nonatomic, copy) NSString *task_sn;
///用户id
@property (nonatomic ,strong) NSNumber *user_id;
///任务类型id
@property (nonatomic ,strong) NSNumber *action_type;
///任务名
@property (nonatomic, copy) NSString *action_name;
///获得积分
@property (nonatomic ,strong) NSNumber *use_points;
///积分状态（1 为获得积分 2为消耗积分）
@property (nonatomic ,strong) NSNumber *use_type;
///时间
@property (nonatomic, copy) NSString *time;

@end
