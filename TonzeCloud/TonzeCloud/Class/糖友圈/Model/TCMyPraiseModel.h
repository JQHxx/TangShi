//
//  TCMyPraiseModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 {
 "news_like_id": 89,
 "like_user_id": 5,
 "liked_user_id": 29,
 "add_time": 1503037543,
 "role_type": 0,
 "role_type_ed": 0,
 "type": 0,
 "user_id": 5,
 "sex": 2,
 "nick_name": "来来来",
 "label": "",
 "diabetes_type": "1型糖尿病",
 "head_url": "",
 "diagnosis_time": "10月",
 "comment_info": {},
 "news_info": {
 "news_id": 15,
 "news": "今天真是个令人愉快的一天",
 "user_id": 29,
 "role_type": 0,
 "at_json": [
 23,
 29,
 44,
 45
 ],
 "user_info": {
 "user_id": 29,
 "sex": 3,
 "nick_name": "木灵",
 "label": "",
 "diabetes_type": "",
 "head_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201707/f20afa738b123b9b996ed1ba94477086.png",
 "diagnosis_time": ""
 },
 "image": [
 {
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201708/04fb7e0696776211e5394ae1e6796b6c.png",
 "image_id": "7269f376716ce932455bfcfcd7c2efb3"
 },
 {
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201708/819d44e31f0c905a415cad9c1cebaf66.png",
 "image_id": "8d3f44d451c2043f23c2b3c1d62a98ad"
 },
 {
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201708/3b6aa229bf85bb5e668bfe50ed775cae.png",
 "image_id": "17bdc0e5033f54bed3a9dd0d178bfd50"
 },
 {
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201708/8e15f6752cd6d36077e49b2dc1bae85b.png",
 "image_id": "c74ec058cd08b933fa8932d1365a32e5"
 },
 {
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201708/d8dec52c4a49359414f850014a21e1d2.png",
 "image_id": "67cc2c9b0371652220b18bc0a6f3ee43"
 }
 ]
 },
 "news_id": 15
 },
 */
#import <Foundation/Foundation.h>

@interface TCMyPraiseModel : NSObject

/// 索引id
@property (nonatomic ,assign)NSInteger news_like_id;
/// 点赞的用户id
@property (nonatomic ,assign)NSInteger like_user_id;
/// 被点赞的用户id
@property (nonatomic ,assign)NSInteger liked_user_id;
/// 点赞时间
@property (nonatomic ,copy)NSString *add_time;
/// 点赞的用户角色类型
@property (nonatomic ,assign)NSInteger role_type;
/// 被点赞的用户角色类型
@property (nonatomic ,assign)NSInteger role_type_ed;
/// 0是评论，1是点赞
@property (nonatomic ,assign)NSInteger type;
/// 点赞的用户id
@property (nonatomic ,assign)NSInteger user_id;
/// 点赞的用户性别
@property (nonatomic ,assign)NSInteger sex;
/// 点赞的用户昵称
@property (nonatomic ,copy)NSString *nick_name;
/// 点赞的用户职称
@property (nonatomic ,copy)NSString *label;
/// 点赞的用户病症
@property (nonatomic ,copy)NSString *diabetes_type;
/// 点赞的用户头像
@property (nonatomic ,copy)NSString *head_url;
/// 点赞的用户得病时间
@property (nonatomic ,copy)NSString *diagnosis_time;
/// 被评论/回复信息
@property (nonatomic ,strong)NSDictionary *comment_info;
/// 动态消息
@property (nonatomic ,strong)NSDictionary *news_info;
/// 动态消息id
@property (nonatomic ,assign)NSInteger news_id;

@end
