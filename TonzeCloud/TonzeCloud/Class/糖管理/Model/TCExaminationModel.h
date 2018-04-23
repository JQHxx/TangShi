//
//  TCExaminationModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCExaminationModel : NSObject

@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, assign) NSInteger es_id;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, copy) NSArray  *image;

@end
