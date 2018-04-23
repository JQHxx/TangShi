//
//  TCMyMessageModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCMyMessageModel : NSObject

@property (nonatomic ,copy)NSString *add_time;
@property (nonatomic ,copy)NSString *edit_time;
@property (nonatomic ,assign)NSInteger applying_user_id;
@property (nonatomic ,assign)NSInteger applyed_user_id;
@property (nonatomic ,assign)NSInteger apply_family_id;
@property (nonatomic ,assign)NSInteger state;
@property (nonatomic ,strong)NSDictionary *family;

@end
