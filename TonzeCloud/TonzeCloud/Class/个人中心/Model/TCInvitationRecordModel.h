//
//  TCInvitationRecordModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "invite_id": 5,
 "invited_mobile": "130****4584",
 "status": 2,
 "add_time": 1510718281,
 "edit_time": 1510718319
 */
#import <Foundation/Foundation.h>

@interface TCInvitationRecordModel : NSObject
///邀请id
@property (nonatomic ,strong)NSString *invite_id;
///手机号码
@property (nonatomic ,strong)NSString *invited_mobile;
///状态
@property (nonatomic ,assign)NSInteger status;
///邀请时间
@property (nonatomic ,strong)NSString  *add_time;
///注册时间
@property (nonatomic ,strong)NSString  *edit_time;

@end
