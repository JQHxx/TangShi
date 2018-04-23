//
//  TCHomeCenterModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/12/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCHomeCenterModel : NSObject
///设备名称
@property (nonatomic ,strong)NSString *deviceName;
///设备介绍
@property (nonatomic ,strong)NSString *deviceTitle;
///左图
@property (nonatomic ,strong)NSString *leftImage;
///左图地址
@property (nonatomic ,strong)NSString *leftImageUrl;
///右图
@property (nonatomic ,strong)NSString *rightImage;
///右图地址
@property (nonatomic ,strong)NSString *rightImageUrl;
///图文咨询名称
@property (nonatomic ,strong)NSString *imgTitle;
///图文咨询详情
@property (nonatomic ,strong)NSString *imgDetail;
///图文咨询图
@property (nonatomic ,strong)NSString *topImage;
///营养服务名称
@property (nonatomic ,strong)NSString *contentLabel;
///营养服务介绍
@property (nonatomic ,strong)NSString *ContentDetail;
///营养服务图
@property (nonatomic ,strong)NSString *bottomImg;
@end
