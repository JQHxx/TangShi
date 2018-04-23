//
//  TCSportAddModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/6.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSportAddModel : NSObject

@property (nonatomic,strong)NSNumber *sportId;
@property (nonatomic, copy )NSString *image;
@property (nonatomic, copy )NSString *name;
@property (nonatomic,strong)NSString *calory;

@property (nonatomic,strong)NSString *minute;
@property (nonatomic,strong)NSString *beginTime;

@end
