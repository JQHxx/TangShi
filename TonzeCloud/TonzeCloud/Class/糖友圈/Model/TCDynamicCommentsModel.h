//
//  TCDynamicCommentsModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 {
 "add_time" = 1503035730;
 "comment_user_id" = 5;
 content = "\U8bc4\U8bba\U4e00\U4e0b2";
 "diabetes_type" = "1\U578b\U7cd6\U5c3f\U75c5";
 "diagnosis_time" = "10\U6708";
 "head_url" = "";
 label = "";
 "like_count" = 0;
 "news_comment_id" = 11;
 "news_id" = 35;
 "nick_name" = "\U6765\U6765\U6765";
 "role_type" = 0;
 "role_type_ed" = 0;
 sex = 2;
 "user_id" = 5;
 }
 */
#import <Foundation/Foundation.h>

@interface TCDynamicCommentsModel : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic ,copy)NSString     *add_time;               //添加时间
@property (nonatomic ,assign)NSInteger   comment_user_id;        //评论者用户id
@property (nonatomic ,assign)NSInteger   commented_user_id;      //被评论者用户id
@property (nonatomic ,copy)NSString     *diabetes_type;          //糖尿病类型
@property (nonatomic ,copy)NSString     *diagnosis_time;         //确诊时间
@property (nonatomic ,copy)NSString     *head_url;               //头像
@property (nonatomic ,copy)NSString     *label;                  //标签
@property (nonatomic ,assign)NSInteger   like_count;             //点赞数
@property (nonatomic ,assign)NSInteger   like_status;            //是否点赞 1.已点赞 0.未点赞
@property (nonatomic ,assign)NSInteger   news_id;                //消息id
@property (nonatomic ,assign)NSInteger   news_comment_id;        //
@property (nonatomic ,assign)NSInteger   user_id;                //用户id
@property (nonatomic ,copy)NSString     *nick_name;              //昵称
@property (nonatomic ,assign)NSInteger   role_type;              //评论者角色类型
@property (nonatomic ,assign)NSInteger   role_type_ed;           //被评论者角色类型
@property (nonatomic ,assign)NSInteger   sex;                    //性别
@property (nonatomic ,strong)NSArray    *reply;                  //回复数据集
@property (nonatomic ,assign)NSInteger   reply_num;              //回复数量
@property (nonatomic ,copy)NSString     *content;                //内容
@property (nonatomic ,assign)BOOL         is_self;                 //是否自己

@end


@interface TCCommentReplyModel : NSObject

@property (nonatomic , copy )NSString     *add_time;               //添加时间
@property (nonatomic , copy )NSString     *comment_nick;           //评论者昵称
@property (nonatomic ,assign)NSInteger    comment_user_id;         //评论者用户id
@property (nonatomic , copy )NSString     *commented_nick;         //被评论者昵称
@property (nonatomic ,assign)NSInteger    commented_user_id;       //被评论者用户id
@property (nonatomic , copy )NSString     *content;                //评论内容
@property (nonatomic ,assign)BOOL         is_self;                 //是否自己
@property (nonatomic ,assign)NSInteger    like_count;              //点赞数
@property (nonatomic ,assign)NSInteger    news_comment_id;         //评论编号
@property (nonatomic ,assign)NSInteger    news_id;                 //动态编号
@property (nonatomic ,assign)NSInteger    role_type;                //评论者角色类型
@property (nonatomic ,assign)NSInteger    role_type_ed;             //被评论者角色类型
//@property (nonatomic ,assign)NSInteger    label;                    //标签



@end


