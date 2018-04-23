//
//  TCGlycosylateModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGlycosylateModel : NSObject

@property (nonatomic, assign) NSInteger gh_id;
@property (nonatomic, copy) NSString *measure_time;
@property (nonatomic, assign) float measure_value;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *day;

@end
