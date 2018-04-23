//
//  TCMyFriendModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCMyFriendModel : NSObject

@property (nonatomic, copy) NSDictionary *blood_glucose_info;

@property (nonatomic, copy) NSDictionary *family_info;

@property (nonatomic, copy) NSString *family_mobile;

@property (nonatomic, copy) NSString *call;

@property (nonatomic, assign) NSInteger is_read;


@end
