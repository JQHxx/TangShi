//
//  TCDynamicPraiseModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "result": [
 {
 "add_time" = 1503044583;
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "2\U6708";
 "head_url" = "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201708/88f42d766669242465a928590ca39ce4.jpeg";
 label = "";
 "like_user_id" = 173;
 "news_id" = 35;
 "news_like_id" = 90;
 "nick_name" = "\U7cd6\U53cb_8411";
 "role_type" = 0;
 "role_type_ed" = 0;
 sex = 1;
 "user_id" = 173; },
 */
#import <Foundation/Foundation.h>

@interface TCDynamicPraiseModel : NSObject
/// 动态id
@property (nonatomic ,assign)NSInteger news_id;
/// 点赞的用户id
@property (nonatomic ,assign)NSInteger like_user_id;
/// 索引id
@property (nonatomic ,assign)NSInteger news_like_id;
/// 点赞的用户id
@property (nonatomic ,assign)NSInteger user_id;
/// 点赞时间
@property (nonatomic ,copy)NSString *add_time;
/// 点赞的用户角色类型
@property (nonatomic ,assign)NSInteger role_type;
/// 被点赞的用户角色类型
@property (nonatomic ,assign)NSInteger role_type_ed;
/// 点赞的用户性别
@property (nonatomic ,assign)NSInteger sex;
/// 点赞的用户昵称
@property (nonatomic ,copy)NSString *nick_name;
/// 点赞的用户职称
@property (nonatomic ,copy)NSString *label;
/// 点赞的用户病症
@property (nonatomic ,copy)NSString *diabetes_type;
/// 点赞的用户头像
@property (nonatomic ,copy)NSString *head_url;
/// 点赞的用户得病时间
@property (nonatomic ,copy)NSString *diagnosis_time;

@end
