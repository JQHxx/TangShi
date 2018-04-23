//
//  TCArcSlider.m
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCArcSlider.h"

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

@interface TCArcSlider (){
    
    CGFloat      radius;
    CGFloat      lineWidth;
    CGFloat      angle;
}

@end

@implementation TCArcSlider

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        angle=180;
        lineWidth=5.0;
        radius=frame.size.width/2-lineWidth*2-lineWidth/2;
    }
    return self;
}

-(void)setIsHomeIn:(BOOL)isHomeIn{
    _isHomeIn=isHomeIn;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    
//  1.绘制灰色的背景
    CGContextAddArc(context, self.width/2, self.height-10, radius, -M_PI, M_PI, 0);
    [[UIColor lightGrayColor] setStroke];
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextDrawPath(context, kCGPathStroke);
    
//  2.绘制进度
    CGContextAddArc(context, self.width/2,self.height-10,radius,-M_PI,-ToRad(angle), 0);
    if (angle>self.minValueAngle) {
        [kRGBColor(254, 213, 98) setStroke];
    }else if (angle<self.minValueAngle&&angle>self.maxValueAngle){
        [kRGBColor(70, 222, 188) setStroke];
    }else{
        [kRGBColor(247, 118, 119) setStroke];
    }
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    
    [self drawLineAction];
    
//    //3.绘制拖动小块
    CGPoint handleCenter =  [self pointFromAngle:angle];
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    CGContextSetLineWidth(context, 1.0);
    [kLineColor setStroke];
    CGContextAddArc(context,handleCenter.x,handleCenter.y,lineWidth*2,0,2*M_PI,0);//添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark 更新滑动手柄的位置
-(void)movehandle:(CGPoint)lastPoint{
    //获得中心点
    CGPoint centerPoint = CGPointMake(self.width/2,self.height-10);
    //计算中心点到任意点的角度
    angle =AngleFromNorth(centerPoint,lastPoint,NO);
    if ([self.slideDelegate respondsToSelector:@selector(arcSliderSetSugarValueWithAngle:)]) {
        [self.slideDelegate arcSliderSetSugarValueWithAngle:angle];
    }
    //重新绘制
    [self setNeedsDisplay];
}

#pragma mark 计算中心点到任意点的角度
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    
    
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result =-ToDeg(radians);
    if (result<-100&&result>-180) {
        result=-180;
    }else if (result<0&&result>-100) {
        result=0;
    }
    return (double)fabs(result);
}


#pragma mark 根据角度得到圆环上的坐标
-(CGPoint)pointFromAngle:(CGFloat)aAngle{
    //中心点
    CGPoint centerPoint = CGPointMake(self.width/2,self.height-10);
    //根据角度得到圆环上的坐标
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-aAngle)));
    result.x = round(centerPoint.x + radius * cos(ToRad(-aAngle)));
    return result;
}


#pragma mark 开始跟踪触摸事件
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    MyLog(@"beginTrackingWithTouch,event:%@",self.isHomeIn?@"101_002008":@"102_002008");
#if !DEBUG
    if (self.isHomeIn) {
        [MobClick event:@"101_002008"];
    }else{
        [MobClick event:@"102_002008"];
    }
    
#endif
    
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

#pragma mark 持续跟踪触摸事件
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    //获取触摸点
    CGPoint lastPoint = [touch locationInView:self];
    //使用触摸点来移动小块
    [self movehandle:lastPoint];
    //发送值改变事件
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)moveArcSliderWithAngle:(CGFloat)newAngle{
    angle=newAngle;
    [self setNeedsDisplay];
}

#pragma mark -- Private Methods 
#pragma mark 绘制线条
-(void)drawLineAction{
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //指定直线样式
    CGContextSetLineCap(context,kCGLineCapSquare);
    //直线宽度
    CGContextSetLineWidth(context,lineWidth);
    //设置颜色
    if (angle>self.minValueAngle) {
        [kRGBColor(254, 213, 98) setStroke];
    }else if (angle<self.minValueAngle&&angle>self.maxValueAngle){
        [kRGBColor(70, 222, 188) setStroke];
    }else{
        [kRGBColor(247, 118, 119) setStroke];
    }
    //开始绘制
    CGContextBeginPath(context);
    //画笔移动到点(31,170)
    CGContextMoveToPoint(context,2*lineWidth+lineWidth/2,self.height);
    //下一点
    CGContextAddLineToPoint(context,2*lineWidth+lineWidth/2,self.height-10);
    //绘制完成
    CGContextStrokePath(context);
}

#pragma mark --Setters and Getters
-(void)setMinValueAngle:(CGFloat)minValueAngle{
    _minValueAngle=minValueAngle;
}

-(void)setMaxValueAngle:(CGFloat)maxValueAngle{
    _maxValueAngle=maxValueAngle;
}


-(void)setInitAngle:(CGFloat)initAngle{
    _initAngle=initAngle;
    angle=initAngle;
}

@end
