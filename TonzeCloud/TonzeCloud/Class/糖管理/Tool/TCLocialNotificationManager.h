//
//  LocialNotificationManager.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCLocialNotificationManager : NSObject

+ (instancetype)manager;

/**
 *    注册本地通知
 *    @alertTime 延迟通知时间
 *    @key       用于后面取消通知
 **/
- (void)registerLocalNotification:(NSInteger)alertTime key:(NSString*)key;
/*
 *  用户登录设定消息提醒
 *
 */
- (void)setLocationNotification;

/**
 *   取消某个本地推送通知
 **/
- (void)cancelLocalNotificationWithKey:(NSString *)key;

/**
 *   极光本地推送设定
 *   @weakday      重复周期（1：周日，2 周一。。。）
 *   @hour         时钟
 *   @minute       分钟
 *   @body         推送的内容
 *
 **/
- (void)setJPUSHLocationNotificationContentWithWeekday:(NSInteger)weakday hour:(NSInteger )hour minute:(NSInteger)minute body:(NSString *)body time_reminder_id:(NSInteger)time_reminder_id;
/**
 *   取消极光本地推送
 *
 **/
-(void)cleanJPUSHLocationNotificationContent;
/*
 *  处理推送提醒文本文字
 */
- (NSString *)getReminderTypeStr:(NSString *)reminderType;
/*
 * 处理星期时间
 */
- (NSMutableArray *)getRepeatType:(NSString *)repeatType;


@end
