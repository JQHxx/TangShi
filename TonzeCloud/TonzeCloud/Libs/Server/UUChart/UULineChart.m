//
//  UULineChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UULineChart.h"
#import "UUChartConst.h"
#import "UUChartLabel.h"

@interface UULineChart ()<UIScrollViewDelegate>{
    CGFloat       xLabelWidth;
    NSHashTable   *_chartLabelsForX;
    double        yValueMax;
    double        yValueMin;
    
    UIScrollView  *myScrollView;
}

@end

@implementation UULineChart 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        myScrollView.showsHorizontalScrollIndicator=NO;
        myScrollView.delegate=self;
        [self addSubview:myScrollView];
        

        
    }
    return self;
}

-(void)setYLabels:(NSArray *)yLabels{
    _yLabels = yLabels;
    
    yValueMax=[[yLabels lastObject] doubleValue];
    yValueMin=[[yLabels firstObject] doubleValue];
    
    //竖坐标数值显示
    NSInteger num=_yLabels.count;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight /(float)(num-1);
    
    for (int i=0; i<_yLabels.count; i++) {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
        double value=[_yLabels[i] doubleValue];
        label.text =[NSString stringWithFormat:@"%.1f",value];
        [self addSubview:label];
    }
    
    //画横线
    for (int i=0; i<_yLabels.count; i++) {
        UIColor *color;
        if (i==_yLabels.count-1) {
            color=[UIColor blackColor];
        }else{
            color=[UIColor lightGrayColor];
        }
        [self drawHorizontalLineWithIndex:i levelHeight:levelHeight color:color];
    }
}

-(void)setYValues:(NSArray *)yValues{
    _yValues = yValues;
}

- (void)setXLabels:(NSArray *)xLabels{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }
    
    _xLabels = [[xLabels reverseObjectEnumerator] allObjects];
    
    xLabelWidth = (self.frame.size.width - UUYLabelwidth-15)/(float)(8-1);
    
    float max = ([_xLabels count]-1)*xLabelWidth+UUYLabelwidth+15;
    myScrollView.contentSize = CGSizeMake(max+20, myScrollView.frame.size.height);
    
    for (int i=0; i<_xLabels.count; i++) {
        NSString *labelText = _xLabels[i];
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(i * xLabelWidth+10, myScrollView.frame.size.height - UULabelHeight, xLabelWidth, UULabelHeight)];
        label.text = labelText;
        [myScrollView addSubview:label];
        
        [_chartLabelsForX addObject:label];
    }
    
    //画竖线
    for (int i=0; i<_xLabels.count; i++) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(UUYLabelwidth+i*xLabelWidth,UULabelHeight-5)];
        [path addLineToPoint:CGPointMake(UUYLabelwidth+i*xLabelWidth,self.frame.size.height-2*UULabelHeight)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        if (i==0) {
            shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
            [self.layer addSublayer:shapeLayer];
        }else{
            shapeLayer.strokeColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor];
            [myScrollView.layer addSublayer:shapeLayer];
        }
    }
}


#pragma mark 限制线
-(void)setLimitLineValues:(NSArray *)limitLineValues{
    _limitLineValues=limitLineValues;
}

#pragma mark 绘制图表
- (void)strokeChart{
    //绘制限制线
    for (NSInteger i=0; i<_limitLineValues.count; i++) {
        double value=[_limitLineValues[i] doubleValue];
        CGFloat yPosition=[self getYPositionWithValue:value];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(UUYLabelwidth,yPosition)];
        [path addLineToPoint:CGPointMake(myScrollView.frame.size.width-10,yPosition)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        [self.layer addSublayer:shapeLayer];
    }
    
    
    //绘制数值
    for (int i=0; i<_yValues.count; i++) {
        NSArray *childAry = [[_yValues[i] reverseObjectEnumerator] allObjects];
        if (childAry.count==0) {
            return;
        }
        
        //筛选出已有数值
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSInteger j=0; j<childAry.count; j++){
            double num = [childAry[j] doubleValue];
            if (num>0.0) {
                [tempArr addObject:[NSNumber numberWithDouble:num]];
            }
        }
        
        if (tempArr.count>0) {
            //获取最大最小位置
            double max=[tempArr[0] doubleValue];
            double min=[tempArr[0] doubleValue];
            for (NSInteger i=0; i<tempArr.count; i++) {
                double value=[tempArr[i] doubleValue];
                if (max<=value) {
                    max=value;
                }
                if (min>=value) {
                    min=value;
                }
            }
            NSInteger maxInt=[childAry indexOfObject:[NSNumber numberWithDouble:max]];
            NSInteger minInt=[childAry indexOfObject:[NSNumber numberWithDouble:min]];
            
            
            //划线
            CAShapeLayer *_chartLine = [CAShapeLayer layer];
            _chartLine.lineCap = kCALineCapRound;
            _chartLine.lineJoin = kCALineJoinBevel;
            _chartLine.fillColor   = [[UIColor whiteColor] CGColor];
            _chartLine.lineWidth   = 2.0;
            _chartLine.strokeEnd   = 0.0;
            [myScrollView.layer addSublayer:_chartLine];
            
            //第一个点
            
            NSInteger firstIndex=0;
            for (NSInteger j=0; j<childAry.count; j++) {
                double firstValue = [[childAry objectAtIndex:j] doubleValue];
                if (firstValue>0.01) {
                    firstIndex=j;
                    break;
                }
            }
            
            double firstValue = [[childAry objectAtIndex:firstIndex] doubleValue];
            CGFloat xPosition = UUYLabelwidth+firstIndex*xLabelWidth;
            CGFloat yPosition=[self getYPositionWithValue:firstValue];
            BOOL isShowMaxAndMinPoint = YES;
            isShowMaxAndMinPoint = (maxInt==firstIndex || minInt==firstIndex)?NO:YES;
            [self addPoint:CGPointMake(xPosition, yPosition)
                    isShow:isShowMaxAndMinPoint
                     value:firstValue];
            
            UIBezierPath *progressline = [UIBezierPath bezierPath];
            [progressline moveToPoint:CGPointMake(xPosition, yPosition)];
            [progressline setLineWidth:2.0];
            [progressline setLineCapStyle:kCGLineCapRound];
            [progressline setLineJoinStyle:kCGLineJoinRound];
            
            
            NSInteger index = 0;
            for (NSNumber * valueString in childAry) {
                if ([valueString doubleValue]>0.01) {
                    CGFloat yPos=[self getYPositionWithValue:[valueString doubleValue]];
                    if (firstIndex==0) {
                        if (index!=0) {
                            CGPoint point = CGPointMake(xPosition+index*xLabelWidth, yPos);
                            [progressline addLineToPoint:point];
                            BOOL isShowMaxAndMinPoint = YES;
                            isShowMaxAndMinPoint = (maxInt==index || minInt==index)?NO:YES;
                            [progressline moveToPoint:point];
                            [self addPoint:point
                                    isShow:isShowMaxAndMinPoint
                                     value:[valueString doubleValue]];
                        }
                    }else{
                        if (index >= firstIndex) {
                            CGPoint point = CGPointMake(xPosition+(index-firstIndex)*xLabelWidth, yPos);
                            [progressline addLineToPoint:point];
                            BOOL isShowMaxAndMinPoint = YES;
                            isShowMaxAndMinPoint = (maxInt==index || minInt==index)?NO:YES;
                            [progressline moveToPoint:point];
                            [self addPoint:point
                                    isShow:isShowMaxAndMinPoint
                                     value:[valueString doubleValue]];
                        }
                    }
                }
                index += 1;
            }
            
            _chartLine.path = progressline.CGPath;
            _chartLine.strokeColor = [UUColor green].CGColor;
            
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = childAry.count*0.4;
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            pathAnimation.autoreverses = NO;
            [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
            
            _chartLine.strokeEnd = 1.0;
        }
        
    }
}

- (void)addPoint:(CGPoint)point isShow:(BOOL)isHollow value:(double)value
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 8, 8)];
    view.center = point;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    view.backgroundColor =[UUColor green];
    
    if (isHollow) {
        view.backgroundColor = [UIColor greenColor];
    }else{
        view.backgroundColor = [UUColor redColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x-UUTagLabelwidth/2.0, point.y-UULabelHeight*2, UUTagLabelwidth, UULabelHeight)];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = view.backgroundColor;
        label.text = [NSString stringWithFormat:@"%.1f",value];
        [myScrollView addSubview:label];
    }
    [myScrollView addSubview:view];
}

#pragma mark 划横线
-(void)drawHorizontalLineWithIndex:(NSInteger)index levelHeight:(CGFloat)levelHeight color:(UIColor *)color{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(UUYLabelwidth,UULabelHeight+index*levelHeight)];
    [path addLineToPoint:CGPointMake(self.frame.size.width-10,UULabelHeight+index*levelHeight)];
    [path closePath];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [color colorWithAlphaComponent:0.5].CGColor;
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = 1;
    [self.layer addSublayer:shapeLayer];
}

#pragma mark 获取数值y坐标
-(CGFloat)getYPositionWithValue:(double)value{
    CGFloat chartCavanHeight = myScrollView.frame.size.height - UULabelHeight*3;
    CGFloat levelH=chartCavanHeight/(float)(_yLabels.count-1);
    float grade=0.0;
    CGFloat yPosition;
    if (value<3.5) {
        grade=((float)value-yValueMin)/3.5;
        yPosition=levelH*(_yLabels.count-2)+UULabelHeight+(1-grade)*levelH;
    }else if (value>=3.5&&value<5.0){
        grade=((float)value-3.5)/(5.0-3.5);
        yPosition=levelH*(_yLabels.count-3)+UULabelHeight+(1-grade)*levelH;
    }else if (value>=5.0&&value<11.0){
        grade=((float)value-5.0)/(11.0-5.0);
        yPosition=levelH*(_yLabels.count-9)+UULabelHeight+(1-grade)*levelH*6;
    }else if(value>=11.0&&value<15.0){
        grade=((float)value-11.0)/(15.0-11.0);
        yPosition=levelH*(_yLabels.count-10)+UULabelHeight+(1-grade)*levelH;
    }else{
        grade=((float)value-15.0)/(35.0-15.0);
        yPosition=UULabelHeight+(1-grade)*levelH;
    }
    return yPosition;
}

- (NSArray *)chartLabelsForX
{
    return [_chartLabelsForX allObjects];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x<1.0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kScrollNotification object:nil];
    }
}




@end
