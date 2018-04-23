//
//  TCMyCommentsModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "news_info" =             {
 "at_json" =                 (
 {
 "nick_name" = "@\U8169\U8169";
 "role_type_ed" = 0;
 "user_id" = 6;
 },
 {
 "nick_name" = "@\U7cd6\U5c0f\U5b9d";
 "role_type_ed" = 0;
 "user_id" = 7;
 }
 );
 image =                 (
 );
 news = "@\U8169\U8169 @\U7cd6\U5c0f\U5b9d SK\U6d4b\U8bd5\U6570\U636e1";
 "role_type" = 0;
 "user_id" = 5;
 "user_info" =                 {
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "";
 "head_url" = "";
 label = "";
 "nick_name" = "\U6765\U6765\U6765";
 sex = 2;
 "user_id" = 5;
 };
 };
 */
#import <Foundation/Foundation.h>

@interface TCMyCommentsModel : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;
/// 动态消息id
@property (nonatomic ,assign)NSInteger news_id;
/// 索引
@property (nonatomic ,assign)NSInteger news_comment_id;
/// 评论/回复者id
@property (nonatomic ,assign)NSInteger comment_user_id;
/// 被评论/回复者id
@property (nonatomic ,assign)NSInteger commented_user_id;
/// 评论/回复时间
@property (nonatomic ,copy)NSString *add_time;
/// 评论/回复内容
@property (nonatomic ,copy)NSString *content;
/// 评论/回复者角色类型
@property (nonatomic ,assign)NSInteger role_type;
/// 被评论/回复者角色类型
@property (nonatomic ,assign)NSInteger role_type_ed;
/// 0是评论，非0是回复
@property (nonatomic ,assign)NSInteger parent_id;
/// 回复/评论所对应的评论状态，0被审核，1正确，2被删除
@property (nonatomic ,assign)NSInteger parent_comment_status;
/// 评论/回复者信息
@property (nonatomic ,strong)NSDictionary *comment_user_info;
/// 被评论/回复者信息
@property (nonatomic ,strong)NSDictionary *commented_user_info;
/// 上一条评论/回复信息
@property (nonatomic ,strong)NSDictionary *before_comment;
/// 动态消息信息
@property (nonatomic ,strong)NSDictionary *news_info;
/// 职称
@property (nonatomic ,strong)NSString *label;


@end
