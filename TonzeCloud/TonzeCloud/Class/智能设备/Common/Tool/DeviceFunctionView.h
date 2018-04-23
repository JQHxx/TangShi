//
//  DeviceFunctionView.h
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceFunctionView;
@protocol DeviceFunctionViewDelegate <NSObject>

//立即启动
-(void)deviceFunctionViewStartNow;
//预约启动
-(void)deviceFunctionViewReserveStartup;
//设置属性
@optional
-(void)deviceFunctionViewSetPorperty;

@end

@interface DeviceFunctionView : UIView

@property (nonatomic,weak)id<DeviceFunctionViewDelegate>delegate;

@property (nonatomic, copy )NSString  *titleStr;
@property (nonatomic, copy )NSString  *detailStr;
@property (nonatomic,assign)BOOL      isSetProperty;   //是否设置属性

@end
