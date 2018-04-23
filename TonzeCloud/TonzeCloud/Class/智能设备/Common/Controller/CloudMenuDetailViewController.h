//
//  CloudMenuDetailViewController.h
//  Product
//
//  Created by 肖栋 on 17/5/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "TCDeviceModel.h"

@interface CloudMenuDetailViewController : BaseViewController
/// 菜谱id
@property (nonatomic,assign) NSInteger menuid;

@property (nonatomic, copy )NSString *imageUrl;

@property (nonatomic,assign) BOOL  isLowerSugarCook;

@property (nonatomic, strong) TCDeviceModel *model;
@end
