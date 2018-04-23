//
//  TCExpertDetailModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/16.
//  Copyright © 2017年 tonze. All rights reserved.
//
/*
 "id": 16,
 "service_num": 1,
 "head_portrait": "http://360tjy-tangshi.oss-cn-shanghai.aliyuncs.com/31078d0ea40ee7424452e822a3404c5d.png",
 "name": "专家1",
 "positional_titles": "一级",
 "brief_introduction": "这是一个优秀的医生22222",
 "attention_count": 2,
 "focus_status": 1
 "customized_status": 1,
 "graphic_status": 0,
 */
#import <Foundation/Foundation.h>

@interface TCExpertDetailModel : NSObject

@property(nonatomic,strong)NSString  *name;                      //姓名
@property(nonatomic,strong)NSString  *positional_titles;         //职业
@property(nonatomic,strong)NSString  *head_portrait;             //头像
@property(nonatomic,strong)NSString  *brief_introduction;        //专家简介
@property(nonatomic,assign)NSInteger id;                        //id
@property(nonatomic,assign)NSInteger service_num;               //服务人数
@property(nonatomic,assign)NSInteger attention_count;           //关注人数
@property(nonatomic,assign)NSInteger focus_status;              //是否关注
@property(nonatomic,assign)NSInteger customized_status;         //医疗方案启用状态 1启用 0禁止
@property(nonatomic,assign)NSInteger graphic_status;            //图文咨询启用状态 1启用 0禁止
@property(nonatomic,assign)NSInteger commentNum;
@property(nonatomic,assign)NSArray  *commentList;


@end
