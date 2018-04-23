//
//  TCMangerRecordView.h
//  TonzeCloud
//
//  Created by vision on 17/3/6.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCManagerTitleView.h"
#import "UUChart.h"

@interface TCMangerRecordView : UIView

@property (nonatomic,strong)TCManagerTitleView *titleView;
@property (nonatomic,strong)UUChart            *chartView;
@property (nonatomic,strong)id                 values;
@property (nonatomic, copy )NSString           *lineValueStr;
@property (nonatomic,assign)NSInteger          yMaxValue;
@property (nonatomic,assign)NSInteger          yMarginValue;

-(instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type;

@end
