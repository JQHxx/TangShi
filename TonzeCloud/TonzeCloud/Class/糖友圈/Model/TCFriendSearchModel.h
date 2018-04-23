//
//  TCFriendSearchModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "add_time" = 1506651154;
 "diabetes_type" = "";
 "diagnosis_time" = "";
 "head_url" = "";
 label = "";
 "nick_name" = "\U7cd6\U53cb_9090";
 "role_type" = 0;
 sex = 3;
 "user_id" = 237;
 */
#import <Foundation/Foundation.h>

@interface TCFriendSearchModel : NSObject
//时间
@property (nonatomic ,assign)NSInteger add_time;
//患病类型
@property (nonatomic ,strong)NSString *diabetes_type;
//患病时间
@property (nonatomic ,strong)NSString *diagnosis_time;
//头像
@property (nonatomic ,strong)NSString *head_url;
//
@property (nonatomic ,strong)NSString *label;
//昵称
@property (nonatomic ,strong)NSString *nick_name;
//
@property (nonatomic ,assign)NSInteger role_type;
//性别
@property (nonatomic ,assign)NSInteger sex;
//用户id
@property (nonatomic ,assign)NSInteger user_id;

@end
