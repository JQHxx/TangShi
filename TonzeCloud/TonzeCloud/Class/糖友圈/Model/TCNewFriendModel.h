//
//  TCNewFriendModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 result =     (
 {
 "news_follow_id": 3,
 "follow_user_id": 6,
 "followed_user_id": 5,
 "add_time": 1502695289,
 "is_follow_tog": 1,
 "role_type": 0,
 "user_id": 6,
 "sex": 1,
 "nick_name": "腩腩",
 "label": "",
 "diabetes_type": "2型糖尿病",
 "head_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201704/f821916d7f2b654d187f2b088b93f680.png",
 "diagnosis_time": "11月"
 }
 );
 */
#import <Foundation/Foundation.h>

@interface TCNewFriendModel : NSObject
/// 关注人id
@property (nonatomic ,assign)NSInteger follow_user_id;
/// 被关注人id
@property (nonatomic ,assign)NSInteger followed_user_id;
/// 是否互相关注
@property (nonatomic ,assign)NSInteger is_follow_tog;
/// 关注索引id
@property (nonatomic ,assign)NSInteger news_follow_id;
/// 关注人类型
@property (nonatomic ,assign)NSInteger role_type;
/// 被关注人类型
@property (nonatomic ,assign)NSInteger role_type_ed;
/// 关注人用户id
@property (nonatomic ,assign)NSInteger user_id;
/// 关注时间
@property (nonatomic ,copy)NSString    *add_time;
/// 关注时间
@property (nonatomic ,assign)NSInteger  id;
/// 昵称
@property (nonatomic ,copy)NSString    *nick_name;
/// 性别
@property (nonatomic ,assign)NSInteger  sex;
/// 职称
@property (nonatomic ,copy)NSString    *label;
/// 头像
@property (nonatomic ,copy)NSString    *head_url;
/// 患病时间
@property (nonatomic ,copy)NSString    *diagnosis_time;
/// 病型
@property (nonatomic ,copy)NSString    *diabetes_type;
/// 关注状态
@property (nonatomic, assign) NSInteger  focus_status ;

@end
