//
//  AppDelegate.h
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong)BaseTabBarViewController  *tabbarVC;

-(void)updateAccessToken;

@end

