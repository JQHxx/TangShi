//
//  UUBar.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBar.h"
#import "UUChartConst.h"

#define kLabelValue  0.7

@interface UUBar (){
    UILabel    *valueLabel;
}

@end

@implementation UUBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
		_chartLine = [CAShapeLayer layer];
		_chartLine.lineCap = kCALineCapSquare;
		_chartLine.fillColor = [UIColor whiteColor].CGColor;
		_chartLine.lineWidth = self.frame.size.width*kLabelValue;
		_chartLine.strokeEnd = 0.0;
        [self.layer addSublayer:_chartLine];
		self.clipsToBounds = YES;
        
        valueLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.textAlignment=NSTextAlignmentCenter;
        valueLabel.font=[UIFont systemFontOfSize:12];
        valueLabel.textColor=[UIColor blackColor];
        [self addSubview:valueLabel];
        valueLabel.hidden=YES;
    }
    return self;
}

-(void)setGradePercent:(float)gradePercent
{
    if (gradePercent==0)
    return;
    
	_gradePercent = gradePercent;
    
    valueLabel.frame=CGRectMake(0, (1-gradePercent)*self.frame.size.height-25, self.frame.size.width, 30);
    
    
	UIBezierPath *progressline = [UIBezierPath bezierPath];
    [progressline moveToPoint:CGPointMake(self.frame.size.width/2.0, self.frame.size.height+30)];
	[progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - gradePercent) * self.frame.size.height+15)];
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapSquare];
	_chartLine.path = progressline.CGPath;
    _chartLine.strokeColor = _barColor.CGColor ?: [UUColor green].CGColor;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.5;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @0.0;
    pathAnimation.toValue = @1.0;
    pathAnimation.autoreverses = NO;
    [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    _chartLine.strokeEnd = 2.0;
}

- (void)drawRect:(CGRect)rect
{
	//Draw BG
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, rect);
}


#pragma mark -- Setters and Getters
-(void)setValueStr:(NSString *)valueStr{
    _valueStr=valueStr;
    valueLabel.text=valueStr;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected=isSelected;
    
    valueLabel.hidden=!isSelected;
    
    UIBezierPath *progressline = [UIBezierPath bezierPath];
    [progressline moveToPoint:CGPointMake(self.frame.size.width/2.0, self.frame.size.height+30)];
    [progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - _gradePercent) * self.frame.size.height+15)];
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapSquare];
    _chartLine.path = progressline.CGPath;
    _chartLine.strokeColor =isSelected?[UIColor colorWithHexString:@"0xd6e395"].CGColor:[UUColor green].CGColor;
}


@end
