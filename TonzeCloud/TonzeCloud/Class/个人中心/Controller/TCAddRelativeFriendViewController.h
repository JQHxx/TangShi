//
//  TCAddRelativeFriendViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCAddFriendModel.h"

@interface TCAddRelativeFriendViewController : BaseViewController

/** 接收扫描的二维码信息 */
@property (nonatomic, strong) TCAddFriendModel *FriendModel;

/// 是否为积分任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@end
