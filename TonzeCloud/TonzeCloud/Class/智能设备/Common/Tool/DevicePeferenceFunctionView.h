//
//  DevicePeferenceFunctionView.h
//  TonzeCloud
//
//  Created by vision on 17/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDeviceModel.h"

@protocol DevicePeferenceFunctionViewDelegate <NSObject>

-(void)devicePeferenceFunctionViewChangePeferenceMenuAction;

-(void)devicePeferenceFunctionViewDidSelectedFunctionWithTag:(NSInteger)tag;

@end

@interface DevicePeferenceFunctionView : UIView

@property(nonatomic,weak)id<DevicePeferenceFunctionViewDelegate>viewDelegate;

@property(nonatomic,strong)TCDeviceModel *model;

-(void)showForGetDevicePreference;

-(void)getCloudMenuDetailWithMenuDict:(NSDictionary *)menuDict;

@end
