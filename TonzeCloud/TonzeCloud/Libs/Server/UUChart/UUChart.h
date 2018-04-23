//
//  UUChart.h
//	Version 0.1
//  UUChart
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUChart.h"
#import "UUChartConst.h"
#import "UULineChart.h"
#import "UUBarChart.h"
#import "UUSpotChart.h"

typedef NS_ENUM(NSInteger, UUChartStyle){
    UUChartStyleLine = 0,
    UUChartStyleBar =1 <<0,
    UUChartStyleSpot=2 <<0
};

@class UUChart;
@protocol UUChartDataSource <NSObject>

@required
//横坐标标题数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart;

//数值数组或字典
- (id)chartConfigAxisYValue:(UUChart *)chart;

@optional
//限制线
-(NSArray *)chartLimitLine:(UUChart *)chart;

//竖坐标数值数组
- (NSArray *)chartConfigAxisYlabel:(UUChart *)chart;

//竖坐标最大值
-(NSInteger)chartYValueMax:(UUChart *)chart;

//竖坐标顶部差额
-(NSInteger)chartYMarginValue:(UUChart *)chart;

@end


@interface UUChart : UIView

@property (nonatomic) UUChartStyle chartStyle;


- (id)initWithFrame:(CGRect)rect dataSource:(id<UUChartDataSource>)dataSource style:(UUChartStyle)style;

- (void)showInView:(UIView *)view;

- (void)strokeChart;

@end
