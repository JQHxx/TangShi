//
//  TCShareModel.h
//  TonzeCloud
//
//  Created by vision on 17/8/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCShareModel : NSObject

@property (strong, nonatomic) NSString  *invite_code;  //分享邀请码
@property (strong, nonatomic) NSNumber  *from_id;      //分享者ID
@property (nonatomic, copy ) NSString  *from_user;    //分享者帐号
@property (nonatomic, copy )NSString    *from_name;    //分享者昵称
@property (strong, nonatomic) NSNumber  *to_id;        //被分享者ID
@property (strong, nonatomic) NSString  *to_user;      //被分享者帐号
@property (strong, nonatomic) NSNumber  *device_id;    //设备ID
@property (strong, nonatomic) NSString  *state;        //分享状态
@property (strong, nonatomic) NSNumber  *create_date;  //分享产生时间
@property (strong, nonatomic) NSString  *expire_date;  //分享过期时间
@property (strong, nonatomic) NSNumber  *user_id;      //被分享者ID
@property (strong, nonatomic) NSString  *share_mode;   //分享方式
@property (strong, nonatomic) NSString  *user_nickname;//昵称

@end
