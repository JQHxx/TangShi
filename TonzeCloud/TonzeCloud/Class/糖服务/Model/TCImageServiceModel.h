//
//  TCImageServiceModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/9/8.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "expert_id" = 192;
 "expert_name" = "rf ";
 "graphic_preferential_price" = 0;
 "graphic_price" = "0.01";
 "graphic_speciality" = "";
 "head_portrait" = "";
 num = 1;
 "positional_titles" = gvf;
 */
#import <Foundation/Foundation.h>

@interface TCImageServiceModel : NSObject

@property (nonatomic ,assign)NSInteger expert_id;
@property (nonatomic ,strong)NSString  *expert_name;
@property (nonatomic ,assign)float      graphic_preferential_price;
@property (nonatomic ,assign)float      graphic_price;
@property (nonatomic ,strong)NSString  *graphic_speciality;
@property (nonatomic ,strong)NSString  *head_portrait;
@property (nonatomic ,assign)NSInteger  num;
@property (nonatomic ,strong)NSString  *positional_titles;

@end
