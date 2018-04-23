//
//  TCMangerRecordView.m
//  TonzeCloud
//
//  Created by vision on 17/3/6.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMangerRecordView.h"

@interface TCMangerRecordView ()<UUChartDataSource>{
    NSInteger     _type;
}

@end


@implementation TCMangerRecordView

-(instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];

        _type=type;
        
        NSString *title=nil;
        UUChartStyle style;
        if (type==0) {
            title=@"今日血糖值";
            style=UUChartStyleSpot;
        }else if (type==1){
            title=@"周饮食摄入";
            style=UUChartStyleBar;
        }else{
            title=@"周运动消耗";
            style=UUChartStyleBar;
        }
        
        self.titleView=[[TCManagerTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) title:title];
        [self addSubview:self.titleView];
        
        self.chartView = [[UUChart alloc] initWithFrame:CGRectMake(10, 40, kScreenWidth-20, 200)  dataSource:self style:style];
        [self.chartView showInView:self];
    }
    return self;
}

#pragma mark -- Private Methods
#pragma mark 获取数值数组


#pragma mark -- UUChartDataSource
#pragma mark 横坐标标题数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart{
    if (_type==0) {
        return [TCHelper sharedTCHelper].sugarPeriodArr;
    }else{
       return [[TCHelper sharedTCHelper] getDateFromTodayWithDays:7];    //最近一周时间
    }
}

#pragma mark 数值数组
- (id)chartConfigAxisYValue:(UUChart *)chart{
    return self.values;
}

#pragma mark 竖坐标最大值
-(NSInteger)chartYValueMax:(UUChart *)chart{
    return self.yMaxValue;
}

#pragma mark 竖坐标余量
-(NSInteger)chartYMarginValue:(UUChart *)chart{
    return self.yMarginValue;
}

#pragma mark 限制线
-(NSArray *)chartLimitLine:(UUChart *)chart{
    return kIsEmptyString(self.lineValueStr)?nil:[NSArray arrayWithObject:self.lineValueStr];
}

#pragma mark Setters and Getters
-(void)setValues:(id)values{
    _values=values;
}

-(void)setLineValueStr:(NSString *)lineValueStr{
    _lineValueStr=lineValueStr;
}

-(void)setYMaxValue:(NSInteger)yMaxValue{
    _yMaxValue=yMaxValue;
}

-(void)setYMarginValue:(NSInteger)yMarginValue{
    _yMarginValue=yMarginValue;
}

@end
