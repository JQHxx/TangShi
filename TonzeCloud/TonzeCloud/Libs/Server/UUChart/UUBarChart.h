//
//  UUBarChart.h
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUChartConst.h"

@interface UUBarChart : UIView

@property (strong, nonatomic) NSArray * xLabels;
@property (strong, nonatomic) NSArray * yValues;
@property (strong, nonatomic) NSArray *limitLineValues;

@property (assign, nonatomic)NSInteger yValueMax;
@property (assign, nonatomic)NSInteger yMarginValue;

- (NSArray *)chartLabelsForX;

- (void)strokeChart;

@end
