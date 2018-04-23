//
//  TCMyDynamicModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "result": {
 "news_id": 3,
 "user_id": 165,
 "news": "分享图片",
 "role_type": 0,
 "is_recommend": 0,
 "is_essence": 0,
 "is_top": 0,
 "pro": "广东省",
 "city": "深圳市",
 "comment_count": 0,
 "like_count": 0,
 "add_time": 1502762869,
 "is_read": 0,
 "image": [],
""at_user_id": [],
 "sex": 1,
 "nick_name": "糖友_5489",
 "label": "",
 "diabetes_type": "",
 "head_url": "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201708/495857f7934ff0b353f8d2b1235eedfa.png",
 "diagnosis_time": ""
 }
 */
#import <Foundation/Foundation.h>

@interface TCMyDynamicModel : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
/// 动态id
@property (nonatomic, assign)  NSInteger  news_id ;
/// 用户id
@property (nonatomic, assign)  NSInteger  user_id ;
/// 动态内容
@property (nonatomic, copy) NSString *news;
/// 用户类型 （0: 用户,1：专家，2：营养师）
@property (nonatomic, assign) NSInteger  role_type;
/// 是否精华 1精华 0未精华
@property (nonatomic, assign) NSInteger is_essence;
/// 是否推荐 1推荐  0未推荐
@property (nonatomic, assign) NSInteger  is_recommend;
/// 是否置顶 1置顶 0未置顶
@property (nonatomic, assign) NSInteger is_top;
/// 评论数
@property (nonatomic, assign) NSInteger comment_count ;
/// 省
@property (nonatomic, copy) NSString *pro;
/// 市
@property (nonatomic, copy) NSString *city;
/// 点赞数
@property (nonatomic, assign) NSInteger  like_count;
/// 是否点赞
@property (nonatomic, assign) NSInteger  like_status;
/// 是否关注
@property (nonatomic, assign) NSInteger  focus_status;
/// 发布时间
@property (nonatomic, copy) NSString *add_time;
/// 是否已读
@property (nonatomic, assign) BOOL  is_read;
/// 性别
@property (nonatomic, assign) NSInteger  sex;
/// 用户名
@property (nonatomic, copy) NSString *nick_name;
/// 用户类型（官方 ，营养师）
@property (nonatomic, copy) NSString *label;
/// 糖尿病类型
@property (nonatomic, copy) NSString *diabetes_type ;
/// 头像 url
@property (nonatomic, copy) NSString *head_url ;
/// 用户治疗时长
@property (nonatomic, copy) NSString *diagnosis_time;
//  图片数组
@property (nonatomic, strong) NSArray *image;
//  at好友数组
@property (nonatomic, strong) NSArray *at_user_id;
//  话题标题
@property (nonatomic,copy)NSString *topic;
/// 话题Id
@property (nonatomic, assign) NSInteger  topic_id;
/// 话题是否删除
@property (nonatomic, assign) BOOL  topic_delete_status;
///
@property (nonatomic, assign) NSInteger  commented_user_id;
/// 是否为自己发布的动态 （ 0：他人发布 1: 自己发布）
@property (nonatomic, assign) NSInteger  is_self;
/// 内容展开和关闭 （请求完数据设置为： No）
@property (nonatomic,assign)BOOL    isOpen;

///  cell 高度缓存
@property (nonatomic, assign) CGFloat  cellHight;

@property (nonatomic,copy)NSString *headImage;
@property (nonatomic,copy)NSString *nickName;
@property (nonatomic,copy)NSString *sugarType;
@property (nonatomic,copy)NSString *position;

@end

/*
 "news_id": 3,
 "user_id": 165,
 "news": "分享图片",
 "role_type": 0,
 "is_recommend": 0,
 "is_essence": 0,
 "is_top": 0,
 "pro": "广东省",
 "city": "深圳市",
 "comment_count": 0,
 "like_count": 0,
 "add_time": 1502762869,
 "is_read": 0,
 "sex": 1,
 "nick_name": "糖友_5489",
 "label": "",
 "diabetes_type": "",
 "head_url": "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201708/495857f7934ff0b353f8d2b1235eedfa.png",
 "diagnosis_time": ""
 
 */
