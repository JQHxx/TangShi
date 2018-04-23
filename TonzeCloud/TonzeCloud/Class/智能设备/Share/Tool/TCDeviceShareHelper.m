//
//  TCDeviceShareHelper.m
//  TonzeCloud
//
//  Created by vision on 17/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDeviceShareHelper.h"
#import "HttpRequest.h"
#import "TCShareModel.h"
#import "DeviceEntity.h"
#import "AppDelegate.h"
#import "TCMessageHelper.h"
#import "SVProgressHUD.h"

@interface TCDeviceShareHelper (){
    NSString      *curInviteCode;
    NSString      *inviteCode;
    AppDelegate   *appDelegate;
}

@end

@implementation TCDeviceShareHelper

singleton_implementation(TCDeviceShareHelper)

#pragma mark 获取最新分享设备信息
-(void)getLastestDeviceShareData{
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        NSArray *arr=(NSArray *)result;
        NSDictionary *dic=[arr lastObject];
        if ([[dic objectForKey:@"share_mode"]isEqualToString:@"app"]&&[[dic objectForKey:@"state"]isEqualToString:@"pending"]) {
            NSString *fromName=[NSString stringWithFormat:@"%@",[dic objectForKey:@"from_name"]];
            inviteCode=[dic objectForKey:@"invite_code"];
            if ([curInviteCode isEqualToString:inviteCode]) {
                return;
            }
            NSInteger fromId= [[dic objectForKey:@"from_id"] integerValue];
            NSInteger userId=[[userDic valueForKey:@"user_id"] integerValue];
            if (fromId!=userId) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kOnNotifyWithFlag object:nil userInfo:@{@"receiveNewNotify":[NSNumber numberWithBool:YES]}];
                [[TCMessageHelper sharedTCMessageHelper] configNotification:[NSString stringWithFormat:@"%@向您分享了设备",fromName] withType:@"设备分享"];
                curInviteCode = inviteCode;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    curInviteCode = nil;
                });
            }
        }
    }];
}

#pragma mark 接受分享
-(void)acceptShare{
    [SVProgressHUD show];
    [HttpRequest acceptShareWithInviteCode:inviteCode withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (!err) {
            NSDictionary *dic = (NSDictionary *)result;
            if (kIsDictionary(dic)&&dic.count>0) {
                [self addNewDevice:dic];
            }
        }else{
            if (err.code==4031003) {
                appDelegate=kAppDelegate;
                [appDelegate updateAccessToken];
            }
        }
    }];
}



#pragma mark 拒绝分享
-(void)refuseShare{
    [SVProgressHUD show];
    [HttpRequest denyShareWithInviteCode:inviteCode withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        
    }];
}

#pragma mark 添加设备
-(void)addNewDevice:(NSDictionary *)dic{
    [HttpRequest getShareListWithAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (!err) {
            NSArray *tem = (NSArray *)result;
            for (NSDictionary *newsDict in tem) {
                TCDeviceMessageModel *model = [[TCDeviceMessageModel alloc] init];
                [model setValuesForKeysWithDictionary:newsDict];
                model.to_id = newsDict[@"user_id"];
                if ([model.invite_code isEqualToString:inviteCode]){
                    for (NSDictionary *deviceDic in dic[@"list"]) {
                        if ([deviceDic[@"id"] integerValue]==model.device_id) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            [TCDeviceShareHelper saveDeviceToLocal:newDevice];
                            break;
                        }
                    }
                }
            }
        }else{
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            MyLog(@"");
           
        }
    }];
}


#pragma mark - 保存设备缓存到本地(NSUserDefaults的@“devices”)
+(void)saveDeviceToLocal:(DeviceEntity *)device{
    NSDictionary *dic=[device getDictionaryFormat];
    NSMutableDictionary *DeviceDic=[[NSMutableDictionary alloc] initWithDictionary:dic];
    [DeviceDic setObject:[dic objectForKey:@"macAddress"] forKey:@"mac"];
    [DeviceDic setObject:[dic objectForKey:@"deviceID"] forKey:@"deviceid"];
    
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:DeviceDic];
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    BOOL hadOldDevice=NO;
    for (NSDictionary *dic in deviceArr) {
        if ([[dic objectForKey:@"macAddress"] isEqualToString:[deviceDic objectForKey:@"macAddress"]]) {
            hadOldDevice=YES;
            break;
        }
    }
    if (!hadOldDevice) {
        [deviceArr addObject:deviceDic];
    }else{
        for (int i=0;i<deviceArr.count;i++) {
            NSDictionary *dic=[deviceArr objectAtIndex:i];
            if ([[dic objectForKey:@"macAddress"] isEqual:[deviceDic objectForKey:@"macAddress"]]) {
                [deviceArr replaceObjectAtIndex:i withObject:deviceDic];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
