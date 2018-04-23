//
//  TCBindingModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCBindingModel : NSObject

@property (nonatomic,copy)NSString      *call;
@property (nonatomic,copy)NSString      *family_mobile;
@property (nonatomic,assign)BOOL         is_start;
@property (nonatomic,assign)NSInteger    family_id;
@property (nonatomic,assign)NSInteger    user_id;
@property (nonatomic,assign)NSInteger    edit_time;

@end
