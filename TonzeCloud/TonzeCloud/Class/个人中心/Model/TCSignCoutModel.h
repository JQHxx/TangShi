//
//  TCSignCoutModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSignCoutModel : NSObject
/// 时间
@property (nonatomic, copy) NSString *time;
/// 状态 （0 未签到， 1 已签到）
@property (nonatomic, assign) NSInteger   status;

@end
