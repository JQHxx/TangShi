//
//  TCServiceModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "plan_id": 1,
 "expert_id": "4",
 "shceme_name": "1",
 "cover": "",
 "num": 21,
 "edit_time": 1490067498
 */
#import <Foundation/Foundation.h>

@interface TCServiceModel : NSObject
@property(nonatomic,copy)NSString   *cover;         //疗养方案图
@property(nonatomic,copy)NSString   *shceme_name;   //标题
@property(nonatomic,copy)NSString   *head_portrait;
@property(nonatomic,copy)NSString   *expert_name;
@property(nonatomic,copy)NSString   *positional_titles;   
@property(nonatomic,assign)NSInteger plan_id;
@property(nonatomic,assign)NSInteger   expert_id;
@property(nonatomic,assign)NSInteger num;
@property(nonatomic,assign)NSInteger edit_time;
@property(nonatomic,assign)CGFloat customized_price;
@property(nonatomic,assign)CGFloat preferential_price;

@end
