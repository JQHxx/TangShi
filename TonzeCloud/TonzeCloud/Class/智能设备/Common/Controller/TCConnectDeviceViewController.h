//
//  TCConnectDeviceViewController.h
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@protocol TCConnectDeviceViewControllerDelegate <NSObject>

-(void)connectingViewControllerNetworkFailed;

@end

@interface TCConnectDeviceViewController : BaseViewController

@property (nonatomic,assign)id<TCConnectDeviceViewControllerDelegate>delegate;

@property (nonatomic, copy )NSString  *wifiName;
@property (nonatomic, copy )NSString  *wifiPwd;

@end
