//
//  TCConsultModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "id": 13,
 "head_portrait": "图像12",
 "name": "名字12",
 "positional_titles": "职称12",
 "brief_introduction": "简介12"
 */

#import <Foundation/Foundation.h>

@interface TCConsultModel : NSObject

@property(nonatomic,strong)NSString *name;                      //姓名
@property(nonatomic,strong)NSString *positional_titles;         //职业
@property(nonatomic,strong)NSString  *head_portrait;            //头像
@property(nonatomic,strong)NSString *brief_introduction;        //详情
@property(nonatomic,assign)NSInteger id;                        //详情


@end
