//
//  TCRecordSugarViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCSugarModel.h"

@interface TCRecordSugarViewController : BaseViewController

@property (nonatomic,assign)BOOL     isHomeIn;
@property (nonatomic, copy )NSString *sugarPeriodEn;
@property (nonatomic, copy )NSString *sugarMeasureTime;
@property (nonatomic,strong)TCSugarModel *sugarModel;
@property (nonatomic,assign)NSInteger way;

@property (nonatomic ,assign)NSInteger sugar_data;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;
@end
