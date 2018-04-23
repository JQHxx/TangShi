//
//  TCPlanModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/9/8.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "content_images" =         (

 );
 "delete_price" = 12;
 "expert_name" = "\U6b66\U8d85";
 "graphic_preferential_price" = 11;
 "graphic_price" = 11;
 "graphic_speciality" = 13414212;
 "graphic_status" = "\U542f\U52a8";
 "head_portrait" = "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/201706/96c1ea41b738398c21f3193a7a408874.jpg";
 id = 143;
 "positional_titles" = "\U6d4b\U8bd5";
 */
#import <Foundation/Foundation.h>

@interface TCPlanModel : NSObject

@property (nonatomic ,strong)NSArray *content_images;   //图片集合

@property (nonatomic ,assign)CGFloat delete_price;     //划线价格大于0时展示

@property (nonatomic ,strong)NSString *expert_name;      //专家名

@property (nonatomic ,assign)CGFloat graphic_preferential_price;  //

@property (nonatomic ,assign)CGFloat graphic_price;   //

@property (nonatomic ,strong)NSString *graphic_speciality;

@property (nonatomic ,strong)NSString *graphic_status;

@property (nonatomic ,strong)NSString *head_portrait;

@property (nonatomic ,assign)NSInteger id;
@property (nonatomic ,strong)NSString *positional_titles;

@end
