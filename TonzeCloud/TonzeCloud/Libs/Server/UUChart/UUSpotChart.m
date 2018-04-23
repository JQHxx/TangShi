//
//  UUSpotChart.m
//  TonzeCloud
//
//  Created by vision on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "UUSpotChart.h"
#import "UUChartLabel.h"

@interface UUSpotChart (){
    CGFloat       xLabelWidth;
    NSHashTable   *_chartLabelsForX;
    double        yValueMax;
    double        yValueMin;
    
    NSArray      *periodArr;
    UILabel      *blankLab;
}

@end

@implementation UUSpotChart

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
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

-(void)strokeChart{
    
    blankLab.hidden=_yValues.count>0;
    
    if (_yValues.count>0) {
        //显示X轴文字
        CGFloat num = 0;
        if (_xLabels.count>=20) {
            num=20;
        }else if (_xLabels.count<=1){
            num=1;
        }else{
            num = _xLabels.count;
        }
        xLabelWidth = (self.frame.size.width - UUYLabelwidth-10)/(float)(num-1);
        for (int i=0; i<_xLabels.count; i++) {
            NSString *labelText = _xLabels[i];
            UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(i * xLabelWidth+10, self.frame.size.height - UULabelHeight, xLabelWidth, UULabelHeight)];
            label.text = labelText;
            [self addSubview:label];
            [_chartLabelsForX addObject:label];
        }
        
        //画竖线
        for (int i=0; i<_xLabels.count; i++) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(UUYLabelwidth+i*xLabelWidth,UULabelHeight)];
            [path addLineToPoint:CGPointMake(UUYLabelwidth+i*xLabelWidth,self.frame.size.height-2*UULabelHeight)];
            [path closePath];
            shapeLayer.path = path.CGPath;
            shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
            shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 1;
            [self.layer addSublayer:shapeLayer];
        }
        
        //显示y轴文字
        float level = (yValueMax-yValueMin) /4;
        CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
        CGFloat levelHeight = chartCavanHeight /4;
        for (int i=0; i<5; i++) {
            UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
            label.text = [NSString stringWithFormat:@"%ld",(long)(level * i+yValueMin)];
            [self addSubview:label];
        }
        
        for (int i=0; i<5; i++) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(UUYLabelwidth,UULabelHeight+i*levelHeight)];
            [path addLineToPoint:CGPointMake(self.frame.size.width-10,UULabelHeight+i*levelHeight)];
            [path closePath];
            shapeLayer.path = path.CGPath;
            shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
            shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 1;
            [self.layer addSublayer:shapeLayer];
        }
        
        //绘制数值点
        CGFloat xPosition = UUYLabelwidth ;
        for (NSInteger i=0; i<periodArr.count; i++) {
            NSString *key=periodArr[i];
            NSArray *list=[_yValues valueForKey:key];
            for (NSDictionary *dict in list) {
                //血糖值
                NSNumber *valueNum=[dict valueForKey:@"glucose"];
                double value=[valueNum doubleValue];
                float grade =(value-yValueMin) / ((float)yValueMax-yValueMin);
                //点的位置
                CGPoint point = CGPointMake(xPosition+i*xLabelWidth, chartCavanHeight - grade * chartCavanHeight+UULabelHeight);
                //点的颜色
                NSString *timeSlot=[dict valueForKey:@"time_slot"];
                NSString *periodCh=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:timeSlot];
                NSDictionary *limitDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:periodCh];
                double minValue=[[limitDict valueForKey:@"min"] doubleValue];
                double maxValue=[[limitDict valueForKey:@"max"] doubleValue];
                UIColor *color;
                if (value<minValue) {
                    color=[UIColor colorWithHexString:@"#ffd03e"];
                }else if (value>minValue&&value<maxValue){
                    color=[UIColor colorWithHexString:@"#37deba"];
                }else{
                    color=[UIColor colorWithHexString:@"#fa6f6e"];
                }
                if (value>0.01) {
                    [self addPoint:point index:i value:value color:color];
                }
            }
        }
    }
    
}

#pragma mark -- Setters and Getters
#pragma mark 数值点（竖坐标）
-(void)setYValues:(NSDictionary *)yValues{
    _yValues=yValues;
    
    yValueMin=0.0;
    yValueMax=35.0;
    
    periodArr=[TCHelper sharedTCHelper].sugarPeriodEnArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSInteger i=0; i<periodArr.count; i++) {
        NSString *key=periodArr[i];
        NSArray *list=[yValues valueForKey:key];
        for (NSDictionary *dict in list) {
            NSNumber *valueNum=[dict valueForKey:@"glucose"];
            [tempArr addObject:valueNum];
        }
    }
    
    
    NSNumber *maxValue=[tempArr valueForKeyPath:@"@max.floatValue"];
    double mValue=[maxValue doubleValue];
    if (mValue<yValueMax) {
        yValueMax=((NSInteger)mValue/4+1)*4;
    }
}

#pragma mark 横坐标数组
-(void)setXLabels:(NSArray *)xLabels{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }
    _xLabels=xLabels;
}

- (NSArray *)chartLabelsForX{
    return [_chartLabelsForX allObjects];
}

#pragma mark -- Event Response
-(void)showPointValueAction:(UIButton *)sender{
    
}

#pragma mark -- private Methods
#pragma mark 绘制点
- (void)addPoint:(CGPoint)point index:(NSInteger)index  value:(CGFloat)value color:(UIColor*)color{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 8, 8)];
    btn.center = point;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 4;
    btn.backgroundColor = color;
    [btn addTarget:self action:@selector(showPointValueAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
     UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x-UUTagLabelwidth/2.0, point.y-UULabelHeight*2, UUTagLabelwidth, UULabelHeight)];
     label.font = [UIFont systemFontOfSize:10];
     label.textAlignment = NSTextAlignmentCenter;
     label.textColor = btn.backgroundColor;
     label.text = [NSString stringWithFormat:@"%.1f",value];
     [self addSubview:label];
    
}

@end
