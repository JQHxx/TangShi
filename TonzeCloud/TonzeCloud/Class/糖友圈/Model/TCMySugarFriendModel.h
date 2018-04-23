//
//  TCMySugarFriendModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 result =     {
 ated = 0;
 commented = 0;
 follow = 1;
 followed = 1;
 liked = 0;
 "new_followed" = 0;
 news = 1;
 "user_info" =         {
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "10\U6708";
 "head_url" = "";
 id = 5;
 label = "";
 "nick_name" = "\U521a\U54c8\U51b7\U54af\U5566\U54af\U5566\U54af\U5566\U54af\U5566";
 sex = 2;
 };
 };
 */
#import <Foundation/Foundation.h>

@interface TCMySugarFriendModel : NSObject
// @我的
@property (nonatomic ,assign)NSInteger ated;
// 评论我的
@property (nonatomic ,assign)NSInteger commented;
// 关注量
@property (nonatomic ,assign)NSInteger follow;
// 被关注量
@property (nonatomic ,assign)NSInteger followed;
// 赞我的
@property (nonatomic ,assign)NSInteger liked;
// 新朋友
@property (nonatomic ,assign)NSInteger new_followed;
@property (nonatomic ,assign)NSInteger news;
@property (nonatomic ,strong)NSDictionary *user_info;
//禁言时间
@property (nonatomic ,assign)NSInteger gag_time;
//是否禁言
@property (nonatomic ,assign)NSInteger is_gag;
/// 动态文字限制字数
@property (nonatomic, assign) NSInteger  word_limit;


@end
