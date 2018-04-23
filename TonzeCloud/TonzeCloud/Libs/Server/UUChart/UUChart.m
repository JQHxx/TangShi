//
//  UUChart.m
//  UUChart
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUChart.h"

@interface UUChart ()

@property (strong, nonatomic) UULineChart * lineChart;

@property (strong, nonatomic) UUBarChart  * barChart;

@property (strong, nonatomic) UUSpotChart * spotChart;

@property (assign, nonatomic) id<UUChartDataSource> dataSource;

@end

@implementation UUChart

- (id)initWithFrame:(CGRect)rect dataSource:(id<UUChartDataSource>)dataSource style:(UUChartStyle)style
{
    self.dataSource = dataSource;
    self.chartStyle = style;
    
    return [self initWithFrame:rect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
    }
    return self;
}

-(void)setUpChart{
	if (self.chartStyle == UUChartStyleLine) {
        
        if (_lineChart) {
            [_lineChart removeFromSuperview];
        }
        
        _lineChart = [[UULineChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_lineChart];
    
        if ([self.dataSource respondsToSelector:@selector(chartLimitLine:)]) {
            [_lineChart setLimitLineValues:[self.dataSource chartLimitLine:self]];
        }

		[_lineChart setYLabels:[self.dataSource chartConfigAxisYlabel:self]];
		[_lineChart setXLabels:[self.dataSource chartConfigAxisXLabel:self]];
        [_lineChart setYValues:[self.dataSource chartConfigAxisYValue:self]];
        
		[_lineChart strokeChart];

	}else if (self.chartStyle == UUChartStyleBar){
        if (_barChart) {
            [_barChart removeFromSuperview];
        }
        
        _barChart = [[UUBarChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_barChart];
        
        if ([self.dataSource respondsToSelector:@selector(chartLimitLine:)]) {
            [_barChart setLimitLineValues:[self.dataSource chartLimitLine:self]];
        }
        
        [_barChart setYValueMax:[self.dataSource chartYValueMax:self]];
        [_barChart setYMarginValue:[self.dataSource chartYMarginValue:self]];
		[_barChart setYValues:[self.dataSource chartConfigAxisYValue:self]];
		[_barChart setXLabels:[self.dataSource chartConfigAxisXLabel:self]];
        
        [_barChart strokeChart];
        
    }else if (self.chartStyle == UUChartStyleSpot){
        if(_spotChart){
            [_spotChart removeFromSuperview];
        }
        
        _spotChart=[[UUSpotChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_spotChart];
        
        
        [_spotChart setYValues:[self.dataSource chartConfigAxisYValue:self]];
        [_spotChart setXLabels:[self.dataSource chartConfigAxisXLabel:self]];
        
        [_spotChart strokeChart];
    }
}

- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

-(void)strokeChart
{
	[self setUpChart];
	
}



@end
