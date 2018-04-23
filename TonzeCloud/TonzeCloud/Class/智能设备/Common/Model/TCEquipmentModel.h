//
//  TCEquipmentModel.h
//  TonzeCloud
//
//  Created by vision on 17/9/6.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCEquipmentModel : NSObject

/// 设备指令
@property (nonatomic,  copy ) NSString   *code ;
/// 烹饪时间
@property (nonatomic, assign) NSInteger  cook_equipment_time ;
/// 设备id
@property (nonatomic, assign) NSInteger  equipment_cat_id ;
/// 设备mac
@property (nonatomic,  copy ) NSString   *equipment_sn ;
/// 设备名称
@property (nonatomic,  copy ) NSString   *equipment_name ;

@end
