//
//  TCBeFocusModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "result": [
 {
 "news_follow_id": 3,
 "follow_user_id": 6,
 "followed_user_id": 5,
 "add_time": 1502695289,
 "is_follow_tog": 1,
 "role_type": 0,
 "follow_user_info": {
 "sex": 1,
 "nick_name": "腩腩",
 "label": "",
 "diabetes_type": "2型糖尿病",
 "image_url": "http://360tjytangshi.osscnshanghai.aliyuncs.com/201704/f821916d7f2b654d187f2b088b93f680.png",
 "diagnosis_time": "11月"
 }
 }
 ],
 */
#import <Foundation/Foundation.h>

@interface TCBeFocusModel : NSObject
/// 关注索引id
@property (nonatomic ,assign)NSInteger news_follow_id;
/// 关注人id
@property (nonatomic ,assign)NSInteger follow_user_id;
/// 被关注人id
@property (nonatomic ,assign)NSInteger followed_user_id;
/// 关注时间
@property (nonatomic ,copy)NSString *add_time;
/// 是否互相关注
@property (nonatomic ,assign)NSInteger is_follow_tog;
/// 关注人类型
@property (nonatomic ,assign)NSInteger role_type;
/// 关注人信息
@property (nonatomic ,strong)NSDictionary *follow_user_info;

@end
