//
//  DeviceCloudMenuViewController.h
//  Product
//
//  Created by Feng on 16/3/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDeviceModel.h"
#import "BaseViewController.h"

@interface DeviceCloudMenuViewController : BaseViewController

@property (nonatomic, copy )NSString *titleText;


@property (nonatomic,strong)TCDeviceModel *model;


@end
