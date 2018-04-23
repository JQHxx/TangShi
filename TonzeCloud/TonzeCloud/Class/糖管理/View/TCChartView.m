//
//  TCChartView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCChartView.h"

@implementation TCChartView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i<=self.lines; i++) {
        
        CGFloat  x = rect.size.width*i/self.lines;
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 0.5f);
        CGContextSetLineDash(context, 0, (CGFloat[]){3, 0}, 2);//绘制10个跳过5个
        CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
        
        if (i== 3 || i==5 || i==7) {
            CGContextMoveToPoint(context, x, self.rowHeight);
            CGContextAddLineToPoint(context,x, rect.size.height);
        } else {
            CGContextMoveToPoint(context, x, 0);
            CGContextAddLineToPoint(context,x, rect.size.height);
        }
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
    }
    for (int i = 0; i<=self.rows; i++) {
        CGFloat  y = self.rowHeight*i;
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 0.5f);
        CGContextSetLineDash(context, 0, (CGFloat[]){3, 0}, 2);//绘制10个跳过5个
        CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
        
        if (i==1) {
            CGContextMoveToPoint(context, kScreenWidth/9*2, y);
            CGContextAddLineToPoint(context,rect.size.width-kScreenWidth/9, y);
        } else {
            CGContextMoveToPoint(context, 0, y);
            CGContextAddLineToPoint(context,rect.size.width, y);
        }
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
    }
    CGFloat  eachCellWidth  =  rect.size.width/self.lines;
    for(int i = 0;i<self.lines;i++)
    {
        for (int j = 0 ; j<self.rows; j++) {
            NSString * string =@"";
            UIColor * color = [UIColor grayColor];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            if(self.dataSource&&[self.dataSource respondsToSelector:@selector(contentOfEachCell:)])
            {
                string =[self.dataSource contentOfEachCell:indexPath];
            }
            if(self.dataSource&&[self.dataSource respondsToSelector:@selector(contentColorOfEachCell:)])
            {
                color =[self.dataSource contentColorOfEachCell:indexPath];
            }
            UIFont *font = nil;
            if (i==0&&j!=1) {
                font = [UIFont fontWithName:@"Courier" size:10.f];
            } else {
                font = [UIFont fontWithName:@"Courier" size:12.f];
            }
            
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            
            
            NSDictionary *attributes = @{ NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle ,
                                          NSForegroundColorAttributeName :color,};
            
            if (j==0) {
                [string drawInRect:CGRectMake(i*eachCellWidth+kScreenWidth/18, (j+0.4)*self.rowHeight, eachCellWidth, self.rowHeight*0.6) withAttributes:attributes];

            }else if (j==1){
                if (i==0||i==1||i==8) {
                    [string drawInRect:CGRectMake(i*eachCellWidth, self.rowHeight-5, eachCellWidth, self.rowHeight*0.6) withAttributes:attributes];
                }else{
                    [string drawInRect:CGRectMake(i*eachCellWidth, (j+0.4)*self.rowHeight, eachCellWidth, self.rowHeight*0.6) withAttributes:attributes];
                }
            } else {
                [string drawInRect:CGRectMake(i*eachCellWidth, (j+0.4)*self.rowHeight, eachCellWidth, self.rowHeight*0.6) withAttributes:attributes];
            }
        }
    }
    
    for (int i=0; i<self.lines; i++) {
        for(int j = 0;j<self.rows;j++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            if(self.dataSource)
            {
                if([self.dataSource indexOfRowNeedRedTriangle:indexPath])
                {
                    CGFloat startPointX = i*eachCellWidth+2*eachCellWidth/3.0;
                    CGFloat startPointY = j*self.rowHeight;
                    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
                    
                    CGContextMoveToPoint(context, startPointX, startPointY);
                    CGContextAddLineToPoint(context,startPointX+eachCellWidth/3.0, startPointY);
                    CGContextAddLineToPoint(context,startPointX+eachCellWidth/3.0, startPointY+self.rowHeight/3.0);
                    CGContextFillPath(context);
                }
            }
        }
    }
    
}
@end
