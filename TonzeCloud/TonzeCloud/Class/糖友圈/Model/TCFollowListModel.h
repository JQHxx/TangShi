//
//  TCFollowListModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCFollowListModel : NSObject

/// 关注时间
@property (nonatomic, copy) NSString *add_time ;
/// 被关注人病症
@property (nonatomic, copy) NSString *diabetes_type ;
/// 被关注人病发时间
@property (nonatomic, copy) NSString *diagnosis_time ;
/// 被关注人头像
@property (nonatomic, copy) NSString *head_url ;
/// 被关注人职位标签
@property (nonatomic, copy) NSString *label ;
/// 被关注人昵称
@property (nonatomic, copy) NSString *nick_name ;
/// 关注人类型
@property (nonatomic, assign) NSInteger role_type;
/// 关注人id
@property (nonatomic, assign) NSInteger  followed_user_id ;
/// 被关注人id
@property (nonatomic, assign) NSInteger  user_id ;
/// 是否为互相关注
@property (nonatomic, assign) NSInteger  is_follow_tog ;
/// 关注索引id
@property (nonatomic, assign) NSInteger  news_follow_id ;
/// 被关注人类型
@property (nonatomic, assign) NSInteger   role_type_ed;
/// 被关注人性别
@property (nonatomic, assign) NSInteger  sex;

@end
/*
 
 "add_time" = 1502960588;
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "10\U6708";
 "follow_user_id" = 21;
 "followed_user_id" = 5;
 "head_url" = "";
 id = 5;
 "is_follow_tog" = 1;
 label = "";
 "news_follow_id" = 7;
 "nick_name" = "\U6765\U6765\U6765";
 "role_type" = 0;
 "role_type_ed" = 0;
 sex = 2;
 

 */
