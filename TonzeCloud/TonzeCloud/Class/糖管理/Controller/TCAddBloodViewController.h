//
//  TCAddBloodViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCBloodModel.h"

@interface TCAddBloodViewController : BaseViewController

@property (nonatomic ,strong)TCBloodModel *bloodModel;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@end
