//
//  TCRecordSportViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCSportRecordModel.h"


@interface TCRecordSportViewController : BaseViewController


@property (nonatomic,strong)TCSportRecordModel *sportModel;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@end
