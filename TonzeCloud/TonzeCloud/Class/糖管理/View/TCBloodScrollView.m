//
//  TCBloodScrollView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBloodScrollView.h"
#import "TCChartView.h"
#import <UIKit/UIKit.h>

@interface TCBloodScrollView()<ChartDataSource>
@property(nonatomic,assign)NSInteger  numOfRow;
@property(nonatomic,assign)NSInteger  numOfLine;
@property(nonatomic,assign)CGFloat  rowHeightOfCell;
@property(nonatomic,retain)TCChartView * chartView;

@end
@implementation TCBloodScrollView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self){
        self =  [super initWithFrame:frame];
        self.showsVerticalScrollIndicator=NO;
        self.scrollEnabled=NO;
    }
    return  self;
}

-(void)reloadChartView{
    self.chartView.rows = self.numOfRow;
    self.chartView.lines = self.numOfLine;
    self.chartView.frame=CGRectMake(0, 0, kScreenWidth,self.rowHeightOfCell*self.numOfRow);
    [self.chartView setNeedsDisplay];
}

-(TCChartView *)chartView{
    if(!_chartView)
    {
        _chartView = [[TCChartView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.rowHeightOfCell*self.numOfRow)];
        _chartView.rows = self.numOfRow;
        _chartView.lines = self.numOfLine;
        _chartView.rowHeight = self.rowHeightOfCell;
        _chartView.dataSource = self;
        _chartView.backgroundColor = [UIColor  whiteColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [_chartView addGestureRecognizer:tap];
        [self addSubview:_chartView];
    }
    return _chartView;
}

-(NSString *)contentOfEachCell:(NSIndexPath *)indexPath
{
    NSString * string = @"";
    if(self.dataSource){
        string = [self.dataSource contentOfEachCell:indexPath];
    }
    return string;
}

-(UIColor *)contentColorOfEachCell:(NSIndexPath *)indexPath
{
    UIColor * textColor = [UIColor lightGrayColor];
    if(self.dataSource)
    {
        textColor = [self.dataSource contentColorOfEachCell:indexPath];
    }
    return  textColor;
}

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath;
{
    if(self.dataSource)
    {
        return [self.dataSource indexOfRowNeedRedTriangle:indexPath];
    }
    return NO;
}

-(NSInteger)numOfRow
{
    if(self.dataSource)
    {
        _numOfRow = [self.dataSource rowsNumOfChart];
    }
    return _numOfRow;
}

-(NSInteger)numOfLine{
    if (self.dataSource) {
        _numOfLine=[self.dataSource linesNumOfChart];
    }
    return _numOfLine;
}

-(CGFloat)rowHeightOfCell
{
    if(!_rowHeightOfCell)
    {
        if(self.dataSource)
        {
            _rowHeightOfCell = [self.dataSource eachCellHeight];
        }
    }
    return _rowHeightOfCell;
}

-(void)click:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.chartView];
    int i = point.y/self.rowHeightOfCell;
    int j = (point.x-10)/((self.frame.size.width-20)/9);
    if(self.chartDelegate&&[self.chartDelegate respondsToSelector:@selector(chartDidClickAtIndexPath:)])
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:j];
        [self.chartDelegate chartDidClickAtIndexPath:indexPath];
    }
}
@end
