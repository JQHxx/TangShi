//
//  TCFoodAddModel.h
//  TonzeCloud
//
//  Created by vision on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCFoodAddModel : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy )NSString *image_url;
@property (nonatomic, copy )NSString *name;
@property (nonatomic, assign) NSInteger energykcal;

@property (nonatomic,strong)NSNumber *weight;
@property (nonatomic,strong)NSNumber *calory;
@property (nonatomic,strong)NSNumber *isSelected;



@end
