//
//  TCServiceDetailModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/16.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 (
 {
 "add_time" = "<null>";
 "content_images" =             (
 );
 cover = "<null>";
 "customized_content" = "<null>";
 "customized_price" = "<null>";
 "customized_service_time" = "<null>";
 "edit_time" = "<null>";
 "expert_id" = "<null>";
 "expert_name" = 31313;
 "head_portrait" = "";
 id = "<null>";
 "is_used" = "\U5173\U95ed";
 name = "<null>";
 "positional_titles" = adasd;
 }
 );
 */
#import <Foundation/Foundation.h>

@interface TCServiceDetailModel : NSObject
@property(nonatomic,copy)NSString  *head_portrait;               //头像
@property(nonatomic,copy)NSString  *expert_name;                 //姓名
@property(nonatomic,copy)NSString  *positional_titles;           //职业
@property(nonatomic,copy)NSArray  *content_images;               //服务内容
@property(nonatomic,copy)NSString  *cover;                       //服务图片
@property(nonatomic,copy)NSString  *name;                        //服务名称
@property(nonatomic,copy)NSString  *customized_service_time;     //服务周期
@property(nonatomic,assign)NSInteger id;                         //方案id
@property(nonatomic,assign)NSInteger expert_id;                  //专家id
@property(nonatomic,copy)NSString *customized_price;             //服务价值
@property(nonatomic,copy)NSString *preferential_price;           //折扣价值
@property(nonatomic,copy)NSString *delete_price;                 //折扣价值

@property(nonatomic,assign)NSTimeInterval add_time;              //开始时间
@property(nonatomic,assign)NSTimeInterval edit_time;             //结束时间
@property(nonatomic,copy)NSString *is_used;                      //是否启动
@property(nonatomic,copy)NSString *customized_content;           //是否启动

@end
