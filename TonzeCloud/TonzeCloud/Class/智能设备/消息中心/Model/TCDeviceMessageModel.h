//
//  TCDeviceMessageModel.h
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 
 "device_id" = 1975562575;
 "expire_date" = 1503384324999;
 "from_id" = 452877266;
 "from_name" = "\U54e6\U54e6\U54e6";
 "from_user" = other6c8dba7d0df1c4a79dd07646be9a26c8;
 "gen_date" = 1503297924999;
 id = 2a07d2b335030800;
 "invite_code" = 1207d2b335030801;
 "share_mode" = app;
 state = pending;
 "to_user" = other0655f117444fc1911ab9c6f6b0139051;
 "user_id" = 452872171;
 visible = 0;
 */

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MessageTypeDeviceWork,
    MessageTypeDeviceShare,
    MessageTypeFaultMessage,
} MessageType;

@interface TCDeviceMessageModel : NSObject

@property (nonatomic,assign)NSInteger device_id;       //设备ID
@property (nonatomic, copy )NSString  *expire_date;    //分享过期时间
@property (nonatomic,assign)NSInteger from_id;         //分享者ID，一般都是设备管理员的ID
@property (nonatomic, copy )NSString  *from_user;      //分享者帐号
@property (nonatomic, copy )NSString  *from_name;      //分享者昵称
@property (nonatomic, copy )NSString  *gen_date;       //分享产生时间
@property (nonatomic, copy )NSString  *invite_code;    //分享ID
@property (nonatomic, copy )NSString  *share_mode;
@property (nonatomic, copy )NSString  *state;          //状态
@property (nonatomic,assign)NSInteger user_id;         //被分享者用户ID
@property (strong, nonatomic)NSNumber *to_id;          //被分享者ID
@property (nonatomic,assign)NSInteger visible;
@property (nonatomic, copy )NSString  *to_name;        //被分享者的昵称
@property (nonatomic, copy )NSString  *to_user;        //被分享者的帐号

@property (nonatomic, copy )NSString  *deviceName;    //设备名称
@property (nonatomic, copy )NSString  *deviceType;    //工作类型
@property (nonatomic, assign)BOOL     isWorkError;    //工作是否异常

@end
