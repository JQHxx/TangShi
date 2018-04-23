//
//  LocialNotificationManager.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLocialNotificationManager.h"
#import "JPUSHService.h"
#import "TCRegularRemindersModel.h"

static TCLocialNotificationManager *_instance;

@interface TCLocialNotificationManager ()

@property (nonatomic, strong) NSMutableArray *remindArray;

@end

@implementation TCLocialNotificationManager

+ (instancetype)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [self new];
        }
    });
    return _instance;
}

- (void)setJPUSHLocationNotificationContentWithWeekday:(NSInteger)weakday hour:(NSInteger )hour minute:(NSInteger)minute body:(NSString *)body time_reminder_id:(NSInteger)time_reminder_id{
    
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    content.body = body;
    content.action = body;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = weakday;
    components.hour = hour;
    components.minute = minute;
    
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        if (weakday == 0) {// 设定单次提醒推送消息
            trigger.timeInterval = [self getTimeIntervalWithHour:hour minute:minute];
        }else{ // 设定重复周期推送消息
            trigger.dateComponents = components;
            trigger.repeat = YES;
        }
    }else {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        dateComponents.hour = hour;
        dateComponents.minute = minute;
        NSDate *fireDate = [calendar dateFromComponents:dateComponents];
        trigger.fireDate = fireDate; // iOS10以下有效
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;
    // 设定推送标识（测试血糖特殊处理）
    if ([body isEqualToString:@"测量血糖时间已到，请勤记录以便更好的控糖"]) {
        request.requestIdentifier = @"testBloodSugar";
    }else{
        request.requestIdentifier = [NSString stringWithFormat:@"%ld%ld",weakday,time_reminder_id];
    }
    request.completionHandler = ^(id result) {
        NSLog(@"%@", result); // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil;iOS10以下成功result为UILocalNotification对象，失败则result为nil
        if (result) {
            void (^block)() = ^() {
                MyLog(@"设置本地通知提醒成功");
            };
            if ([NSThread isMainThread]) {
                block();
            }else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        }
    };
    [JPUSHService addNotification:request];
}
#pragma mark ====== 计算当前时间到指定时间的时间间隔 =======
- (NSTimeInterval )getTimeIntervalWithHour:(NSInteger )hour minute:(NSInteger)minute{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponent = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    dateComponent.hour = hour;
    dateComponent.minute = minute;
    NSDate *fireDate = [calendar dateFromComponents:dateComponent];
    
    NSDate *nowDate = [NSDate date]; // 当前日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH-mm";
    NSDate *creat = [formatter dateFromString:[formatter stringFromDate:fireDate]];// 将传入的字符串转化成时间
    NSTimeInterval startTime = [nowDate timeIntervalSince1970]*1;
    NSTimeInterval endTime = [creat timeIntervalSince1970]*1;
    NSTimeInterval timeBetween = endTime - startTime;
    // 判断时间大小，当小于0 则时间为设定的时间小于当前时间，推后24小时即可
    NSTimeInterval value = 0.0;
    if (timeBetween > 0) {
        value = timeBetween;
    }else{
        NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:creat];//后一天
        NSTimeInterval nextTime = [nextDay timeIntervalSince1970]*1;
        value = nextTime - startTime;
    }
    return value;
}
#pragma mark ====== 删除所有本地通知 =======
- (void)cleanJPUSHLocationNotificationContent{
     [JPUSHService removeNotification:nil];
    MyLog(@"----取消极光本地推送成功");
}
#pragma mark ====== 设定推送消息提醒 =======
// 用于用户登录
- (void)setLocationNotification{
    
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:KReminderList success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            
            for (NSDictionary *dic in resultArray) {
                TCRegularRemindersModel *reminderListModel = [TCRegularRemindersModel new];
                [reminderListModel setValues:dic];
                [weakSelf.remindArray addObject:reminderListModel];
            }
            // 数据处理
            for (NSInteger i = 0; i < self.remindArray.count; i++) {
                TCRegularRemindersModel *reminderListModel = self.remindArray[i];
                if (reminderListModel.status == 1) {
                    NSMutableArray *weekdayArr =[[TCLocialNotificationManager manager]getRepeatType:reminderListModel.repeat_type];
                    for (NSInteger j = 0; j < weekdayArr.count; j++) {
                        NSInteger day = [weekdayArr[j] integerValue];
                        NSString *body = [[TCLocialNotificationManager manager]getReminderTypeStr:reminderListModel.reminder_type];
                        [self setJPUSHLocationNotificationContentWithWeekday:day hour:reminderListModel.hour minute:reminderListModel.minute body:body time_reminder_id:reminderListModel.time_reminder_id];
                    }
                }
            }
            
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark ====== 处理推送提醒文本文字 =======

- (NSString *)getReminderTypeStr:(NSString *)reminderType{
    NSString *reminderTypeStr;
    if ([reminderType isEqualToString:@"测量血糖"]) {
        reminderTypeStr = @"测量血糖时间已到，请勤记录以便更好的控糖";
    }else if ([reminderType isEqualToString:@"去运动"]){
        reminderTypeStr = @"去运动时间已到，请保持良好的运动习惯";
    }else if ([reminderType isEqualToString:@"服药"]){
        reminderTypeStr = @"服药时间已到，请按时按量服用";
    }else if ([reminderType isEqualToString:@"注射胰岛素"]){
        reminderTypeStr = @"注射胰岛素时间已到，请确认剂量后注射。";
    }else if ([reminderType isEqualToString:@"量血压"]){
        reminderTypeStr = @"量血压时间已到，请静坐一会后再测量";
    }
    return reminderTypeStr;
}
#pragma mark ====== 处理星期时间 =======
- (NSMutableArray *)getRepeatType:(NSString *)repeatType{
    NSMutableArray *repeatArray = [NSMutableArray array];
    if ([repeatType isEqualToString:@"每天"]) {
        repeatArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
    }else if ([repeatType isEqualToString:@"工作日"]){
        repeatArray = [NSMutableArray arrayWithObjects:@"2",@"3",@"4",@"5",@"6", nil];
    }else if([repeatType isEqualToString:@"从不"]){
        repeatArray = [NSMutableArray arrayWithObjects:@"0", nil];
    }else{
        NSArray *dayArr =[repeatType componentsSeparatedByString:@" "];
        for (NSInteger i = 0; i < dayArr.count; i++) {
            NSString *dsyStr =dayArr[i];
            if ([dsyStr isEqualToString:@"周日"]) {
                [repeatArray addObject:@"1"];
            }else if ([dsyStr isEqualToString:@"周一"]){
                [repeatArray addObject:@"2"];
            }else if ([dsyStr isEqualToString:@"周二"]){
                [repeatArray addObject:@"3"];
            }else if ([dsyStr isEqualToString:@"周三"]){
                [repeatArray addObject:@"4"];
            }else if ([dsyStr isEqualToString:@"周四"]){
                [repeatArray addObject:@"5"];
            }else if ([dsyStr isEqualToString:@"周五"]){
                [repeatArray addObject:@"6"];
            }else if ([dsyStr isEqualToString:@"周六"]){
                [repeatArray addObject:@"7"];
            }
        }
    }
    return repeatArray;
}
#pragma mark ====== Getter =======
- (NSMutableArray *)remindArray{
    if (!_remindArray) {
        _remindArray = [NSMutableArray array];
    }
    return _remindArray;
}
@end
