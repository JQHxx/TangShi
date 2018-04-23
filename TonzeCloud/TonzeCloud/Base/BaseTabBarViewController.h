//
//  BaseTabBarViewController.h
//  Tianjiyun
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <Hyphenate/Hyphenate.h>
#import "TCNewHomeViewController.h"
#import "TCServiceViewController.h"

@interface BaseTabBarViewController : UITabBarController

@property (nonatomic,strong)TCNewHomeViewController *homeVC;
@property (nonatomic,strong)TCServiceViewController *serviceVC;
// 处理推送通知
-(void)handerUserNotificationWithUserInfo:(NSDictionary *)userInfo;
// 处理定时血糖提醒推送通知
-(void)pushRecordSugarVC;

@end
