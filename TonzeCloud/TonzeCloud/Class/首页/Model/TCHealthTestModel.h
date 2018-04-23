//
//  TCHealthTestModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "assess_id": 93,
 "name": "方面名称41443343",
 "brief": "",
 "image_url": ""
 */
#import <Foundation/Foundation.h>

@interface TCHealthTestModel : NSObject

@property(nonatomic ,strong)NSString *name;
@property(nonatomic ,strong)NSString *brief;
@property(nonatomic ,strong)NSString *image_url;
@property(nonatomic ,assign)NSInteger assess_id;
@end
