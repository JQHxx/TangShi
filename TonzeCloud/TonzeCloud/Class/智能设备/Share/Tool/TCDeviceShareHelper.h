//
//  TCDeviceShareHelper.h
//  TonzeCloud
//
//  Created by vision on 17/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"

@interface TCDeviceShareHelper : NSObject

singleton_interface(TCDeviceShareHelper)

@property (nonatomic,assign)BOOL  isReloadShareList;

//获取设备分享推送
-(void)getLastestDeviceShareData;

//接受分享
-(void)acceptShare;

//拒绝分享
-(void)refuseShare;

/*
 *#pragma mark 保存设备缓存到本地
 */
+(void)saveDeviceToLocal:(DeviceEntity *)device;

@end
