//
//  DeviceCloudMenuModel.h
//  TonzeCloud
//
//  Created by vision on 17/9/5.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceCloudMenuModel : NSObject

@property(nonatomic ,assign)NSInteger cook_id;              //菜谱编号
@property(nonatomic , copy )NSString *name;                 //菜谱名称
@property(nonatomic , copy )NSString *abstract;             //菜谱摘要
@property(nonatomic , copy )NSString *image_id_cover;       //菜谱封面
@property(nonatomic ,assign)NSInteger reading_number;       //阅读数
@property(nonatomic ,assign)NSInteger like_number;          //点赞数
@property(nonatomic ,assign)NSInteger is_yun;               //是否云菜谱

@end
