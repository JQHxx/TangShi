//
//  TCInformationModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "name": "叶剑武",
 "sex": 1,
 "birthday": "2017-03-06",
 "height": "60",
 "weight": "180",
 "labour_intensity": "中体力"
 }
 */
#import <Foundation/Foundation.h>

@interface TCInformationModel : NSObject

@property(nonatomic,copy)NSString *name;            //姓名
@property(nonatomic,assign)NSInteger sex;           //性别
@property(nonatomic,copy)NSString *birthday;        //生日
@property(nonatomic,copy)NSString *height;          //身高
@property(nonatomic,copy)NSString *weight;          //体重
@property(nonatomic,copy)NSString *labour_intensity;//工作强度
@end
