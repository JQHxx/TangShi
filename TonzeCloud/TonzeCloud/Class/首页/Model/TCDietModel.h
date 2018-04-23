//
//  TCDietModel.h
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCDietModel : NSObject

@property (nonatomic,strong)NSNumber  *recipe_id;
@property (nonatomic, copy )NSString  *icon;
@property (nonatomic, copy )NSString  *title;
@property (nonatomic,strong)NSNumber  *weight;
@property (nonatomic,strong)NSNumber  *energy;        //每100g多少能量
@property (nonatomic, copy )NSString  *diet_time;     //饮食记录时间
@property (nonatomic,strong)NSNumber  *total_energy;  //摄入总能量
@property (nonatomic,strong)NSNumber  *isSelected;    //是否已选

@end
