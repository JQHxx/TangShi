//
//  TCScanFriendViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ScanFriendResultBlock)(NSString *result);

@interface TCScanFriendViewController : BaseViewController

@property (nonatomic, copy )ScanFriendResultBlock scanBlock;

/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@end
