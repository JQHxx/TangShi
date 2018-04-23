//
//  TCMineDynamicModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/24.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "3\U6708";
 "follow_num" = 1;
 "followed_num" = 2;
 "head_url" = "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201708/88f42d766669242465a928590ca39ce4.jpeg";
 "is_follow" = 0;
 "is_self" = 1;
 label = "";
 "nick_name" = "\U7cd6\U53cb_8411";
 sex = 1;
 "user_id" = 173;
 */
#import <Foundation/Foundation.h>

@interface TCMineDynamicModel : NSObject
/// 糖尿病类型
@property (nonatomic ,copy) NSString *diabetes_type;
/// 治疗时间
@property (nonatomic ,copy) NSString *diagnosis_time;
/// 关注人数
@property (nonatomic ,assign) NSInteger follow_num;
/// 被关注人数
@property (nonatomic ,assign) NSInteger followed_num;
/// 头像
@property (nonatomic ,copy) NSString *head_url;
// 是否关注 0: 未关注，1：已关注 2：互相关注
@property (nonatomic ,assign) NSInteger is_follow;
/// 是否自己：0为否，1为是，否时展示关注按钮
@property (nonatomic ,assign) NSInteger is_self;
/// 标签
@property (nonatomic ,copy) NSString *label;
///昵称
@property (nonatomic ,copy) NSString *nick_name;
///性别
@property (nonatomic ,assign) NSInteger sex;
///用户id
@property (nonatomic ,assign) NSInteger user_id;
/// 用户角色 
@property (nonatomic, assign) NSInteger  role_type;

@property (nonatomic, assign) NSInteger  role_type_ed;
@end
