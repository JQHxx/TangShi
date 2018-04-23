//
//  TCChartHeadView.m
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCChartHeadView.h"
#import "TCChartView.h"

#define kCellHeight (kScreenWidth-20)/10

@interface TCChartHeadView ()<ChartDataSource>

@property(nonatomic,retain)TCChartView * chartView;

@end

@implementation TCChartHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:self.chartView];
        
        [self.chartView setNeedsDisplay];
    }
    return self;
}

#pragma mark 
-(TCChartView *)chartView{
    if(!_chartView)
    {
        _chartView = [[TCChartView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kCellHeight*2)];
        _chartView.rows = 2;
        _chartView.lines = 9;
        _chartView.rowHeight = kCellHeight;
        _chartView.dataSource = self;
        _chartView.backgroundColor = [UIColor  whiteColor];
        
    }
    return _chartView;
}

#pragma mark ChartDataSource
-(NSString *)contentOfEachCell:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        NSArray *arr=@[@"1",@"1",@"早餐",@"1",@"午餐",@"1",@"晚餐",@"1",@"1"];
        return [arr[indexPath.section] isEqualToString:@"1"]?@"":arr[indexPath.section];
    }else{
        NSArray *arr=@[@"日期",@"凌晨",@"前",@"后",@"前",@"后",@"前",@"后",@"睡前"];
        return arr[indexPath.section];
    }
}

-(UIColor *)contentColorOfEachCell:(NSIndexPath *)indexPath
{
    return  [UIColor darkGrayColor];
}

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath;
{
    return NO;
}


@end
