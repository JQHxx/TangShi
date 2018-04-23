//
//  TCLookFoMyModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/16.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "result": [
 {
 "news_id": 2,
 "news_at_id": 1,
 "at_user_id": 5,
 "ated_user_id": 5,
 "add_time": 1502849055,
 "role_type": 0,
 "role_type_ed": 0,
 "id": 5,
 "sex": 2,
 "nick_name": "刚哈冷咯啦咯啦咯啦咯啦",
 "label": "",
 "diabetes_type": "1型糖尿病",
 "head_url": "",
 "diagnosis_time": "10月",
 "news_info": {
 "news": "@核黄素 测试数据1",
 "user_id": 5,
 "role_type": 2,
 "image": []
 }
 }
 ],
 */
#import <Foundation/Foundation.h>

@interface TCLookFoMyModel : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;

/// 动态消息id
@property (nonatomic ,assign)NSInteger news_id;
/// 索引id
@property (nonatomic ,assign)NSInteger news_at_id;
/// at人的用户id
@property (nonatomic ,assign)NSInteger at_user_id;
/// 被at的用户id
@property (nonatomic ,assign)NSInteger ated_user_id;
/// at时间
@property (nonatomic ,copy)NSString *add_time;
/// at人的用户角色
@property (nonatomic ,assign)NSInteger role_type;
/// 被at人的用户角色
@property (nonatomic ,assign)NSInteger role_type_ed;
/// at人的用户id
@property (nonatomic ,assign)NSInteger id;
/// at人的用户性别
@property (nonatomic ,assign)NSInteger sex;
/// at人的用户昵称
@property (nonatomic ,copy)NSString *nick_name;
/// at人的用户职称
@property (nonatomic ,copy)NSString *label;
/// at人的用户病症
@property (nonatomic ,copy)NSString *diabetes_type;
/// at人的用户头像
@property (nonatomic ,copy)NSString *head_url;
/// at人的用户得病时间
@property (nonatomic ,copy)NSString *diagnosis_time;
/// 话题名称
@property (nonatomic ,copy)NSString *topic;
/// 话题id
@property (nonatomic ,assign)NSInteger topic_id;
/// 是否精华 1精华 0未精华
@property (nonatomic, assign) NSInteger is_essence;
/// 是否推荐 1推荐  0未推荐
@property (nonatomic, assign) NSInteger  is_recommend;
/// 是否置顶 1置顶 0未置顶
@property (nonatomic, assign) NSInteger is_top;
/// 是否置顶 动态消息
@property (nonatomic ,strong)NSDictionary *news_info;

@end
