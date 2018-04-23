//
//  TCNewsetVersionViewController.h
//  TonzeCloud
//
//  Created by vision on 17/9/5.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCDeviceModel.h"

@interface TCNewsetVersionViewController : BaseViewController

@property (nonatomic,strong)TCDeviceModel  *device;
@property (nonatomic,strong)NSDictionary   *versionDict;

@end
