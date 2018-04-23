//
//  TCRecordDietViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCFoodRecordModel.h"

@interface TCRecordDietViewController : BaseViewController

@property (nonatomic,strong)TCFoodRecordModel *foodRecordModel;

/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTadkListLogin;

@end
