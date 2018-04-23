//
//  TCCommentNewsModel.h
//  TonzeCloud
//
//  Created by vision on 17/10/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCommentNewsModel : NSObject

@property (nonatomic,assign)NSInteger    article_id;           //文章id
@property (nonatomic,assign)NSInteger    article_comment_id;   //文章评论id
@property (nonatomic,assign)NSInteger    comment_user_id;       //评论者id
@property (nonatomic,assign)NSInteger    commented_user_id;     //被评论或回复者id
@property (nonatomic, copy )NSString     *add_time;             //时间
@property (nonatomic,assign)NSInteger    role_type;             //评论者角色
@property (nonatomic,assign)NSInteger    role_type_ed;          //被评论者角色
@property (nonatomic,assign)NSInteger    parent_id;             //上级id
@property (nonatomic, copy )NSString     *content;              //评论内容
@property (nonatomic,assign)NSInteger    parent_comment_id;     //上一条评论ID

@property (nonatomic,strong)NSDictionary  *comment_user_info;            //评论者用户信息
@property (nonatomic,strong)NSDictionary  *commented_user_info;          //被回复者用户信息
@property (nonatomic,strong)NSDictionary  *before_comment;               //上一条评论
@property (nonatomic,strong)NSDictionary  *article_info;                 //文章信息

@property (nonatomic,assign)NSInteger     before_comment_status;

@end

@interface TCCommentUserModel : NSObject

@property (nonatomic,assign)NSInteger    user_id;          //用户id
@property (nonatomic, copy )NSString     *nick_name;       //昵称
@property (nonatomic, copy )NSString     *head_url;        //头像
@property (nonatomic, copy )NSString     *label;           //标签

@end
