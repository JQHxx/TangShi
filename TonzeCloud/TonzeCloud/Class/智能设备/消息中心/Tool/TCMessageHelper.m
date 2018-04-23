//
//  TCMessageHelper.m
//  TonzeCloud
//
//  Created by vision on 17/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMessageHelper.h"
#import "DeviceEntity.h"
#import "TCMainDeviceHelper.h"
#import "DeviceHeader.h"
#import "NSData+Extension.h"

@interface TCMessageHelper (){
    UILocalNotification   *notification;
    TCDeviceMessageModel  *lastMessageModel;
}


@end

@implementation TCMessageHelper

singleton_implementation(TCMessageHelper)

#pragma mark -- Private methods
#pragma mark  解析消息
-(TCDeviceMessageModel *)getMessageForHandlerNofication:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    const Byte *buf = (Byte *)[recvData bytes];

    MyLog(@"messageOnRecvPipeData mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,[recvData hexString]);
    if (buf[5]==D_REPORT_DEVICE_STA) {
        NSString *funtionType=@"";   //工作类型
        NSString *content=@"";
        BOOL  isWorkError = NO;
        
        
        NSDictionary *dic = [[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateDicWithDevice:device Data:recvData];
        if (kIsDictionary(dic)) {
            if (![dic[@"state"] isEqualToString:@"空闲"]) {
                if ([dic[@"state"] isEqualToString:@"云菜谱"]) {
                    if (dic[@"name"]) {
                        funtionType=dic[@"name"];
                    }
                }else{
                    funtionType= dic[@"state"];
                }
                
                [NSUserDefaultsInfos putKey:@"name" andValue:[dic objectForKey:@"name"]];
                [NSUserDefaultsInfos putKey:@"commandType" andValue:dic[@"state"]];
            }
        }
        
        int feedback=buf[8];
        if (feedback==0x01) {
            isWorkError=NO;
            int Type=buf[9];
            NSString *commandType=[NSUserDefaultsInfos getValueforKey:@"commandType"];
            if ([dic[@"state"] isEqualToString:@"空闲"]&&!kIsEmptyString(commandType)) {
                if ([commandType isEqualToString:@"云菜谱"]) {
                    funtionType=[NSUserDefaultsInfos getValueforKey:@"name"];
                }else{
                    funtionType=commandType;
                }
            }
            
            content=[self getReminderTypeWithCommand:Type];
        }else if (feedback==0x02) {
            isWorkError=YES;
            content=@"传感器异常";
        }else if (feedback==0x03){
            isWorkError=YES;
            content=@"干烧报警";
        }else{
            isWorkError=NO;
            if (feedback==0x14) {
                int Type=buf[9];
                NSString *commandType=[NSUserDefaultsInfos getValueforKey:@"commandType"];
                if ([commandType isEqualToString:@"云菜谱"]) {
                    funtionType=[NSUserDefaultsInfos getValueforKey:@"name"];
                }else{
                    funtionType=[NSUserDefaultsInfos getValueforKey:@"commandType"];
                }
                content=[self getReminderTypeWithCommand:Type];
            }
        }
        
        if (feedback==0x01||feedback==0x02||feedback==0x03||feedback==0x14) {
            if (!kIsEmptyString(content)) {
                TCDeviceMessageModel *model=[[TCDeviceMessageModel alloc] init];
                model.device_id=[[NSString stringWithFormat:@"%i",device.deviceID] integerValue];
                model.deviceName=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getDeviceNameFormDeviceID:model.device_id];
                model.isWorkError=isWorkError;
                model.gen_date=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
                model.state=content;
                model.deviceType=funtionType;
                return model;
            }
        }
    }
    return nil;
}

#pragma mark 获取设备状态
-(NSString *)getReminderTypeWithCommand:(int)command{
    switch (command) {
        case 0:
            return @"已取消";
        case 1:
            return @"烹饪开始";
        case 2:
            return @"烹饪结束";
        case 3:
            return @"加食材";
        case 4:
            return @"加水";
        case 5:
            return @"盖盖子";
        default:
            return @"";
    }
}

-(void)configNotification:(NSString *)alertBody withType:(NSString *)typeStr{
    if (!notification) {
        notification=[[UILocalNotification alloc] init];
    }
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        //        notification.fireDate=[now dateByAddingTimeInterval:10];//10秒后通知
        notification.fireDate=now;//通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber+=1; //应用的红色数字
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody=alertBody;//提示信息 弹出提示框
        notification.alertAction = @"确定";  //提示框按钮
        notification.alertTitle =typeStr;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


@end
