//
//  TCIntensityViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
@protocol TCIntensityDelegate

- (void)intensityViewControllerDidSelectLaborIntensity:(NSString *)selectLabor;

@end
@interface TCIntensityViewController : BaseViewController

@property(nonatomic, copy )NSString * laborIntensity;  //工作级别
@property (nonatomic, weak) id <TCIntensityDelegate> controllerDelegate;
@end
