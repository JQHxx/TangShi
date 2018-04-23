//
//  TCSugarFriendsRankModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "user_id": 203,
 "role_type": 0,
 "num": 2,
 "is_self": 0,
 "focus_status": 0,
 "focus_status_desc": "未关注",
 "sex": 1,
 "nick_name": "猪猪",
 "label": "",
 "diabetes_type": "特殊型",
 "head_url": "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201711/dd8d70881f239d1a3da1586ddb8ed86f.png",
 "diagnosis_time": ""
 */
#import <Foundation/Foundation.h>

@interface TCSugarFriendsRankModel : NSObject
//用户id
@property (nonatomic ,assign)NSInteger user_id;
//角色类型
@property (nonatomic ,assign)NSInteger role_type;
//活跃数
@property (nonatomic ,assign)NSInteger num;
//是否自己
@property (nonatomic ,assign)NSInteger is_self;
//关注状态
@property (nonatomic ,assign)NSInteger focus_status;
//关注描述
@property (nonatomic ,strong)NSString *focus_status_desc;
//性别
@property (nonatomic ,assign)NSInteger sex;
//昵称
@property (nonatomic ,strong)NSString *nick_name;
//标签
@property (nonatomic ,strong)NSString *label;
//血糖类型
@property (nonatomic ,strong)NSString *diabetes_type;
//头像
@property (nonatomic ,strong)NSString *head_url;
//治疗时间
@property (nonatomic ,strong)NSString *diagnosis_time;

@end
