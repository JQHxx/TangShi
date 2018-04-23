//
//  TCMaxDynamicModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

 /*
 "news_comment_id": 19,
 "news_id": 15,
 "comment_user_id": 29,
 "commented_user_id": 55,
 "add_time": 1503039733,
 "like_count": 0,
 "role_type": 0,
 "role_type_ed": 0,
 "content": "哇、回复一下有惊喜15",
 "comment_nick": "木灵",
 "commented_nick": "啦啦    拉拢"
 */

#import <Foundation/Foundation.h>

@interface TCMaxDynamicModel : NSObject
/// 评论id
@property (nonatomic ,assign)NSInteger news_comment_id;
/// 动态消息id
@property (nonatomic ,assign)NSInteger news_id;
/// 评论者用户id
@property (nonatomic ,assign)NSInteger comment_user_id;
/// 被评论者用户id
@property (nonatomic ,assign)NSInteger commented_user_id;
/// 添加时间
@property (nonatomic ,copy)NSString  *add_time;
/// 点赞数
@property (nonatomic ,assign)NSInteger like_count;
/// 是否自己
@property (nonatomic ,assign)NSInteger is_self;
/// 角色类型
@property (nonatomic ,assign)NSInteger role_type;
/// 被评论者角色类型
@property (nonatomic ,assign)NSInteger role_type_ed;
/// 内容
@property (nonatomic ,copy)NSString  *content;
/// 评论者昵称
@property (nonatomic ,copy)NSString  *comment_nick;
/// 被评论者昵称
@property (nonatomic ,copy)NSString  *commented_nick;

@end
