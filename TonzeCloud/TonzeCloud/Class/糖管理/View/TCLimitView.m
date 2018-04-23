//
//  TCLimitView.m
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLimitView.h"

#define kMinValue  1.1
#define kMaxValue  33.3
@implementation TCLimitView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSDictionary *dict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:_periodStr];
    double min=[[dict valueForKey:@"min"] doubleValue];
    double max=[[dict valueForKey:@"max"] doubleValue];
    
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //直线宽度
    CGContextSetLineWidth(context,self.height*2);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, 252.0/255.0, 152.0/255.0, 39.0/255.0, 1.0);
    CGContextMoveToPoint(context,0, 0);
    //下一点
    CGContextAddLineToPoint(context,self.width*(min-kMinValue)/(kMaxValue-kMinValue),0);
    //绘制完成
    CGContextStrokePath(context);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, 31.0/255.0, 202.0/255.0, 62.0/255.0, 1.0);
    CGContextMoveToPoint(context, self.width*(min-kMinValue)/(kMaxValue-kMinValue), 0);
    //下一点
    CGContextAddLineToPoint(context,self.width*(max-kMinValue)/(kMaxValue-kMinValue),0);
    //绘制完成
    CGContextStrokePath(context);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, 252.0/255.0, 13.0/255.0, 27.0/255.0, 1.0);
    CGContextMoveToPoint(context, self.width*(max-kMinValue)/(kMaxValue-kMinValue), 0);
    //下一点
    CGContextAddLineToPoint(context,self.width,0);
    //绘制完成
    CGContextStrokePath(context);
    
    
}


-(void)setPeriodStr:(NSString *)periodStr{
    _periodStr=periodStr;
    [self setNeedsDisplay];
}

@end
