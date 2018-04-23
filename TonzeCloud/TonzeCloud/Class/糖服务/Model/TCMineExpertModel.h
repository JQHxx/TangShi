//
//  TCMineExpertModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "expert_id": 8,
 "name": "专家1",
 "head_portrait": "www.xx.com",
 "positional_titles": "一级",
 "brief_introduction": "这是一个优秀的医生"
 */

#import <Foundation/Foundation.h>

@interface TCMineExpertModel : NSObject
@property(nonatomic,strong)NSString  *name;                      //姓名
@property(nonatomic,strong)NSString  *positional_titles;         //职业
@property(nonatomic,strong)NSString  *head_portrait;             //头像
@property(nonatomic,strong)NSString  *brief_introduction;        //详情
@property(nonatomic,assign)NSInteger expert_id;                 //id

@end
