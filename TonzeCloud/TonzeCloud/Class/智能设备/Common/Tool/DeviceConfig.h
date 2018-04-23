//
//  DeviceConfig.h
//  TonzeCloud
//
//  Created by vision on 17/8/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#ifndef DeviceConfig_h
#define DeviceConfig_h


#endif /* DeviceConfig_h */

/*****产品ID***/
#define LowerSuagerCooker_ProductID   @"1607d2b1a4bdd8001607d2b1a4bdd801"          //降糖饭煲


/***************/
#define SDK_DOMAIN @"dev-link.360tj.com"




/******常用宏定义*******/
#define USER_ID         @"USER_ID"        //accountID 是通过接口返回的token经过base64解密获取到
#define USER_DIC        @"USER_DIC"        //云智易平台登录信息
#define XL_USER_ID      [NSUserDefaultsInfos getDicValueforKey:USER_DIC][@"user_id"]
#define XL_USER_TOKEN   [NSUserDefaultsInfos getDicValueforKey:USER_DIC][@"access_token"]
#define kThirdToken     @"kThirdToken"     //云智易平台token
//设备回调通知
#define kOnLogin                        @"kOnLogin"                  //登录回调
#define kOnGotDeviceByScan              @"kOnGotDeviceByScan"        //扫描设备状态回调
#define kOnSetDeviceAccessKey           @"kOnSetDeviceAccessKey"     //设置设备AccessKey回调
#define kOnGotSubkey                    @"kOnGotSubkey"              //获取到SUBKEY
#define kOnConnectDevice                @"kOnConnectDevice"          //连接设备回调
#define kOnSubscription                 @"kOnSubscription"           //设备订阅状态回调
#define kOnDeviceStateChanged           @"kOnDeviceStateChanged"     //设备状态改变回调
#define kOnSendPipeData                 @"kOnSendPipeData"           //发送云端透传数据结果回调
#define kOnSendLocalPipeData            @"kOnSendLocalPipeData"      //发送本地透传消息结果回调
#define kOnRecvLocalPipeData            @"kOnRecvLocalPipeData"      //接收本地设备发送的透传数据
#define kOnRecvPipeData                 @"kOnRecvPipeData"           //接收到云端设备发送回来的透传数据
#define kOnRecvPipeSyncData             @"kOnRecvPipeSyncData"       //接收到云端设备发送的广播透传数据
#define kOnNotifyWithFlag               @"kOnNotifyWithFlag"         //

#define KSetPeferenceMenuSuccess        @"KSetPeferenceMenuSuccess"



