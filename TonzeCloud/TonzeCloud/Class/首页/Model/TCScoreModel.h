//
//  TCScoreModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "assess_rules_id": 92,
 "begin_score": 0,
 "end_score": 59,
 "brief": "不及格",
 "assess_id": 93
 */
#import <Foundation/Foundation.h>

@interface TCScoreModel : NSObject
@property(nonatomic ,assign)NSInteger assess_rules_id;
@property(nonatomic ,assign)NSInteger begin_score;
@property(nonatomic ,assign)NSInteger end_score;
@property(nonatomic ,strong)NSString *brief;
@property(nonatomic ,assign)NSInteger assess_id;
@end
