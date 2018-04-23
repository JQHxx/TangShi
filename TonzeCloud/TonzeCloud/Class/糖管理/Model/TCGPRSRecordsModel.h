//
//  TCGPRSRecordsModel.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGPRSRecordsModel : NSObject
/// 血糖值
@property (nonatomic, copy) NSString *glucose ;
/// 时间
@property (nonatomic, copy) NSString *measurement_time;
/// 时间节点
@property (nonatomic, copy) NSString *time_slot;
/// 血糖值状态 0 偏低 1正常 2偏高
@property (nonatomic, assign) NSInteger  state;

@end
