//
//  UUBarChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBarChart.h"
#import "UUChartLabel.h"
#import "UUBar.h"

#define kLabelValue  0.7

@interface UUBarChart (){
    UIScrollView    *myScrollView;
    CGFloat         xLabelWidth;
    NSHashTable     *_chartLabelsForX;
    NSInteger       yValueMin;
    
    UUBar           *selBar;
    UILabel         *blankLab;
}
@end

@implementation UUBarChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:myScrollView];
        
        blankLab=[[UILabel alloc] initWithFrame:CGRectMake(30, (self.height-30)/2, kScreenWidth-60, 30)];
        blankLab.text=@"暂无数据";
        blankLab.textColor = [UIColor lightGrayColor];
        blankLab.textAlignment=NSTextAlignmentCenter;
        blankLab.font=[UIFont systemFontOfSize:15.0f];
        [self addSubview:blankLab];
        blankLab.hidden=YES;
    }
    return self;
}

#pragma mark 最大值
-(void)setYValueMax:(NSInteger)yValueMax{
    _yValueMax=yValueMax;
}

#pragma mark 差额
-(void)setYMarginValue:(NSInteger)yMarginValue{
    _yMarginValue=yMarginValue;
}

#pragma mark -- Setters and Getters
-(void)setYValues:(NSArray *)yValues{
    _yValues = yValues;
    
    yValueMin=0;
    NSNumber *maxValue = [yValues valueForKeyPath:@"@max.integerValue"];
    NSInteger mValue=[maxValue integerValue];
    if (mValue<_yValueMax) {
        _yValueMax=mValue+_yMarginValue;
    }
}

-(void)setXLabels:(NSArray *)xLabels{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }
    
    _xLabels = xLabels;
    NSInteger num;
    if (xLabels.count>=8) {
        num = 8;
    }else if (xLabels.count<=4){
        num = 4;
    }else{
        num = xLabels.count;
    }
    xLabelWidth = myScrollView.frame.size.width/num;
}

-(void)setLimitLineValues:(NSArray *)limitLineValues{
    _limitLineValues=limitLineValues;
}

#pragma mark 绘制图表
-(void)strokeChart{
    blankLab.hidden=_yValues.count>0;

    if (_yValues.count>0) {
        //x轴坐标值
        for (int i=0; i<_xLabels.count; i++) {
            UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake((i*xLabelWidth), self.frame.size.height - UULabelHeight, xLabelWidth, UULabelHeight)];
            label.text = _xLabels[i];
            [myScrollView addSubview:label];
            
            [_chartLabelsForX addObject:label];
        }
        
        float max = (([_xLabels count]-1)*xLabelWidth + chartMargin)+xLabelWidth;
        if (myScrollView.frame.size.width < max-10) {
            myScrollView.contentSize = CGSizeMake(max, self.frame.size.height);
        }
        
        //画横线
        CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
        CGFloat levelHeight = chartCavanHeight /4.0;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0,UULabelHeight+4*levelHeight)];
        [path addLineToPoint:CGPointMake(self.frame.size.width,UULabelHeight+4*levelHeight)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        [self.layer addSublayer:shapeLayer];
        
        
        //绘制柱形
        for (int i=0; i<_yValues.count; i++) {
            NSNumber *valueString = _yValues[i];
            NSInteger value = [valueString integerValue];
            float grade = (value-yValueMin) /(float) (_yValueMax-yValueMin);
            
            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake(i*xLabelWidth, UULabelHeight, xLabelWidth, chartCavanHeight)];
            bar.backgroundColor=[UIColor lightGrayColor];
            bar.barColor = [UUColor green];
            bar.gradePercent = grade;
            bar.valueStr=[NSString stringWithFormat:@"%@",valueString];
            bar.tag=i;
            [bar addTarget:self action:@selector(barDidSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
            [myScrollView addSubview:bar];
            
            if (i==_yValues.count-1) {
                selBar=bar;
                selBar.isSelected=YES;
            }
        }
        
        //绘制限制线
        if (kIsArray(_limitLineValues)) {
            for (NSInteger i=0; i<_limitLineValues.count; i++) {
                NSInteger value=[_limitLineValues[i] integerValue];
                float grade = (value-yValueMin) /(float) (_yValueMax-yValueMin);
                UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, chartCavanHeight*(1-grade), self.frame.size.width, 1)];
                [self drawDashLine:lineView lineLength:5 lineSpacing:3 lineColor:[UIColor redColor]];
                [myScrollView addSubview:lineView];
                
                UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, lineView.top-30, 50, 20)];
                lab.text=_limitLineValues[i];
                lab.textColor=[UIColor redColor];
                lab.textAlignment=NSTextAlignmentCenter;
                lab.font=[UIFont systemFontOfSize:14];
                [myScrollView addSubview:lab];
            }
        }
    }
}

#pragma mark 绘制虚线
/**
 ** lineView:       需要绘制成虚线的view
 ** lineLength:     虚线的宽度
 ** lineSpacing:    虚线的间距
 ** lineColor:      虚线的颜色
 **/
- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}


- (NSArray *)chartLabelsForX{
    return [_chartLabelsForX allObjects];
}

#pragma mark -- Event Reponse
-(void)barDidSelectedAction:(UUBar *)bar{
    selBar.isSelected=NO;
    bar.isSelected=YES;
    selBar=bar;
}


@end
