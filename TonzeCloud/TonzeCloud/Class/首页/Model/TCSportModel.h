//
//  TCSportModel.h
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSportModel : NSObject

@property (nonatomic, copy )NSString    *icon;
@property (nonatomic, copy )NSString    *name;
@property (nonatomic,strong)NSNumber    *minute;
@property (nonatomic,strong)NSNumber    *calories;
@property (nonatomic, copy )NSString    *start_time;
@property (nonatomic,strong)NSNumber    *step_count;           //步数
@property (nonatomic,strong)NSNumber    *target_step_count;    //目标步数


@end
