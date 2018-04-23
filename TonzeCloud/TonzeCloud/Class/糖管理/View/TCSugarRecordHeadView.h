//
//  TCSugarRecordHeadView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCSugarRecordDelegate <NSObject>

-(void)TCSugarRecordForIndex:(NSInteger)type;
-(void)TCAddRecordForIndex:(NSInteger)type;

@end
@interface TCSugarRecordHeadView : UIView
@property (nonatomic,weak)id<TCSugarRecordDelegate>delegate;

@property(nonatomic,assign)NSDictionary *data;
@property(nonatomic,assign)NSInteger type;
@property(nonatomic,assign)NSInteger num;
@property(nonatomic,assign)NSInteger bloodNum;

- (instancetype)initWithFrame:(CGRect)frame leftDict:(NSDictionary *)leftDict rightDict:(NSDictionary *)rightDict;
@end
