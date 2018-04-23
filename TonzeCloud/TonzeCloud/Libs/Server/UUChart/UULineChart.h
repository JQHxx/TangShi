//
//  UULineChart.h
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UUChartConst.h"

@interface UULineChart : UIView

@property (strong, nonatomic) NSArray * xLabels;    //横坐标数组
@property (strong, nonatomic) NSArray * yLabels;    
@property (strong, nonatomic) NSArray * yValues;
@property (strong, nonatomic) NSArray *limitLineValues;


-(void)strokeChart;

- (NSArray *)chartLabelsForX;

@end
