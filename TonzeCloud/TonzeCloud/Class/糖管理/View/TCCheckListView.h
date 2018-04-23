//
//  TCCheckListView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCCheckListRecordDelegate <NSObject>

-(void)TCCheckListRecordForIndex:(NSInteger)type;
-(void)TCAddCheckListForIndex:(NSInteger)type;

@end
@interface TCCheckListView : UIView

@property (nonatomic,weak)id<TCCheckListRecordDelegate>delegate;

@property(nonatomic,assign)NSInteger type;
@property(nonatomic,strong)NSArray *imgArr;
@property(nonatomic,strong)NSString *timeText;

- (instancetype)initWithFrame:(CGRect)frame rightCheckDict:(NSDictionary *)rightDict;
@end
