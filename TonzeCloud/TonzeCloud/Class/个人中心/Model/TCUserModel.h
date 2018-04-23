//
//  TCUserModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/6.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserModel : NSObject

@property (nonatomic, copy) NSString *nick_name;

@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *height;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *weight;

@property (nonatomic, copy) NSString *birthday;

@property (nonatomic, copy) NSString *photo;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *labour_intensity;

@property (nonatomic, copy) NSString *im_username;

@property (nonatomic, copy) NSString *im_password;

@property (nonatomic, copy) NSString *token;


@end
