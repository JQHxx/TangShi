//
//  TCLowerSuagrDetailViewController.h
//  TonzeCloud
//
//  Created by vision on 17/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCDeviceModel.h"

typedef enum : NSUInteger {
    LowerSugarWorkTypeRice,        //降糖饭
    LowerSugarWorkTypeCook,        //降糖煮
    LowerSugarWorkTypeCooking,     //蒸煮
    LowerSugarWorkTypePorridge,    //煲粥
    LowerSugarWorkTypeGrains,      //杂粮粥
    LowerSugarWorkTypeCookRice,    //煮饭
    LowerSugarWorkTypeSoup,        //煲粥
    LowerSugarWorkTypeHotMeal,     //热饭
    LowerSugarWorkTypeInsulation,  //保温
    LowerSugarWorkTypeCloudMenu,   //云菜谱
} LowerSugarWorkType;

@interface TCLowerSuagrDetailViewController : BaseViewController


@property (nonatomic,strong)TCDeviceModel *deviceModel;
@property (nonatomic,assign)NSInteger     totalCalories;


@end
