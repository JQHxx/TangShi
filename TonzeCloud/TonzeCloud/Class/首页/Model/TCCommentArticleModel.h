//
//  TCCommentArticleModel.h
//  TonzeCloud
//
//  Created by vision on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

/*
 "article_comment_id": 2,
 "article_id": 39,
 "comment_user_id": 29,
 "commented_user_id": 0,
 "add_time": 1508290913,
 "role_type": 0,
 "role_type_ed": 0,
 "content": "测试文章评论系统",
 "is_examine": 1,
 "comment_status": 1,
 "is_self": 1,
 "reply": [],
 "reply_num": 0,
 "user_id": 29,
 "sex": 3,
 "nick_name": "木灵",
 "label": "",
 "diabetes_type": "",
 "head_url": "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201707/f20afa738b123b9b996ed1ba94477086.png",
 "diagnosis_time": ""
 
 */

#import <Foundation/Foundation.h>

@interface TCCommentArticleModel : NSObject

@property (nonatomic,assign) NSInteger   article_comment_id;       //评论ID
@property (nonatomic,assign) NSInteger   article_id;               //文章ID
@property (nonatomic,assign) NSInteger   comment_user_id;          //评论或回复者用户ID
@property (nonatomic,assign) NSInteger   role_type;                //评论或回复者角色
@property (nonatomic,assign) NSInteger   commented_user_id;        //被回复者用户ID
@property (nonatomic,assign) NSInteger   role_type_ed;             //被回复者角色
@property (nonatomic, copy ) NSString    *add_time;                //评价时间
@property (nonatomic, copy ) NSString    *content;                 //评价或回复内容
@property (nonatomic,assign) NSString    *is_self;                 //是否自己
@property (nonatomic, copy ) NSString    *nick_name;               //昵称
@property (nonatomic, copy ) NSString    *label;                   //标签
@property (nonatomic, copy ) NSString    *diabetes_type;           //糖尿病类型
@property (nonatomic, copy ) NSString    *head_url;                //头像
@property (nonatomic,strong) NSArray     *reply;                   //回复列表
@property (nonatomic,assign) NSInteger   reply_num;                //回复数量
@property (nonatomic,assign) BOOL        islookAllComment;         //查看全部回复

@end

@interface TCArticleReplyModel : NSObject

@property (nonatomic, copy ) NSString    *add_time;                //回复时间
@property (nonatomic,assign) NSInteger   article_comment_id;       //文章评论ID
@property (nonatomic, copy ) NSString    *comment_nick;            //评论者昵称
@property (nonatomic,assign) NSInteger   comment_user_id;          //评论者用户ID
@property (nonatomic, copy ) NSString    *commented_nick;          //回复者昵称
@property (nonatomic,assign) NSInteger   commented_user_id;        //回复者用户ID
@property (nonatomic, copy ) NSString    *content;                 //回复内容
@property (nonatomic,assign) NSString    *is_self;                 //是否自己
@property (nonatomic,assign) NSInteger   role_type;                //评论者角色
@property (nonatomic,assign) NSInteger   role_type_ed;             //被回复者角色

@end




