//
//  TCFocusOnModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 result =     (
 {
 "add_time" = 1503298146;
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "\U4e0d\U8db31\U6708";
 "follow_user_id" = 173;
 "followed_user_id" = 55;
 "head_url" = "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201708/c22ec7b1fa54d4f26d8e58960751734f.png";
 "is_follow_tog" = 0;
 label = "";
 "news_follow_id" = 15;
 "nick_name" = "\U5566\U5566    \U62c9\U62e2";
 "role_type" = 0;
 "role_type_ed" = 0;
 sex = 3;
 "user_id" = 55;
 }
 );
 */

#import <Foundation/Foundation.h>

@interface TCFocusOnModel : NSObject
/// 关注时间
@property (nonatomic,copy)NSString *add_time;
/// 关注人id
@property (nonatomic,assign)NSInteger follow_user_id;
/// 被关注人id
@property (nonatomic,assign)NSInteger followed_user_id;
/// 是否互相关注
@property (nonatomic,assign)NSInteger is_follow_tog;
/// 关注索引id
@property (nonatomic,assign)NSInteger news_follow_id;
/// 关注人类型
@property (nonatomic,assign)NSInteger role_type;
/// 被关注人类型
@property (nonatomic,assign)NSInteger role_type_ed;
@property (nonatomic,assign)NSInteger  id;
/// 性别
@property (nonatomic,assign)NSInteger  sex;
/// 关注人id
@property (nonatomic,assign)NSInteger  user_id;
/// 关注人昵称
@property (nonatomic,copy)NSString  *nick_name;
/// 关注人职称
@property (nonatomic,copy)NSString  *label;
/// 关注人病型
@property (nonatomic,copy)NSString  *diabetes_type;
/// 关注人头像
@property (nonatomic,copy)NSString  *head_url;
/// 关注人患病时间
@property (nonatomic,copy)NSString  *diagnosis_time;
/// 是否自己
@property (nonatomic,assign)NSInteger  is_self;
/// 是否互相关注
@property (nonatomic,assign)NSInteger focus_status;
@end
