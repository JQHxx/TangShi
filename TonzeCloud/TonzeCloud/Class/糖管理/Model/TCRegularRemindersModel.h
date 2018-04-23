//
//  TCRegularRemindersModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCRegularRemindersModel : NSObject

/// 提醒id
@property (nonatomic ,assign) NSInteger time_reminder_id;
/// 小时
@property (nonatomic, assign) NSInteger  hour;
/// 分钟
@property (nonatomic, assign) NSInteger  minute;
/// 提醒类型
@property (nonatomic, copy) NSString *reminder_type;
/// 提醒周期
@property (nonatomic, copy) NSString *repeat_type;
/// 添加时间
@property (nonatomic, copy) NSString *add_time;
/// 编辑时间
@property (nonatomic, copy) NSString *edit_time;
///
@property (nonatomic, assign) NSInteger  user_id;
/// 1 开启 0关闭
@property (nonatomic, assign) NSInteger  status;

@end


/*
 "time_reminder_id": 1,
 "hour": 12,
 "minute": 34,
 "reminder_type": "测量血糖",
 "repeat_type": "周一，周二，周三，周四",
 "add_time": 1500361404,
 "edit_time": 1500361404,
 "user_id": 24
 
 */
