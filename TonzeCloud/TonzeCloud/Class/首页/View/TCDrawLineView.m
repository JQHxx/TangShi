//
//  TCDrawLineView.m
//  TonzeCloud
//
//  Created by vision on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDrawLineView.h"

@implementation TCDrawLineView


- (void)drawRect:(CGRect)rect {
    // 获取上下文,进行绘制
    CGContextRef ContextRef = UIGraphicsGetCurrentContext();
    // 线的颜色 横线
    CGContextSetStrokeColorWithColor(ContextRef, [UIColor bgColor_Gray].CGColor);
    
    for (int i =0 ; i<9; i++) {
        CGContextMoveToPoint(ContextRef, 0,40+(i+1)*(self.height-40)/9);
        CGContextAddLineToPoint(ContextRef,self.width,40+(i+1)*(self.height-40)/9);
        CGContextStrokePath(ContextRef);
    }
    
    // 设置线的宽度 竖线
    for (int i= 0; i< 3; i++) {
        CGContextMoveToPoint(ContextRef, i*self.width/2, self.height);
        CGContextAddLineToPoint(ContextRef, i*self.width/2,0);
        CGContextStrokePath(ContextRef);
    }
}


@end
