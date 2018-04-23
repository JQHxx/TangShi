//
//  TCServiceClickViewGroup.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceClickViewGroup.h"
#define kBtnWidth 70

@interface TCServiceClickViewGroup ()<UIScrollViewDelegate>{
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    
    NSUInteger     num;
}

@end
@implementation TCServiceClickViewGroup
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor *)color line:(BOOL)line{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        self.showsHorizontalScrollIndicator=NO;
        self.delegate=self;
        
        viewHeight=frame.size.height;
        num=titles.count;

        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectZero];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            btn.tag=100+i;
            CGSize size = [btn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
            btnWidth=size.width+60;
            btn.frame =CGRectMake(kScreenWidth/2-btnWidth*(1-i), 10, btnWidth, 20);
            [btn addTarget:self action:@selector(serviceChangeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-btnWidth+35,38, btnWidth-70.0, 2.0)];
        line_lab.backgroundColor = color;
        [self addSubview:line_lab];
        
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth, 1)];
        lineLab.backgroundColor=kLineColor;
        [self addSubview:lineLab];
        lineLab.hidden = line;
    }
    return self;
}

-(void)serviceChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kScreenWidth/2-btnWidth*(1-index)+35, 38, btnWidth-70.0, 2.0);
    }];
    
    if ([_serviceDelegate respondsToSelector:@selector(ServiceViewGroupActionWithIndex:)]) {
        [_serviceDelegate ServiceViewGroupActionWithIndex:index];
    }
    
}
-(void)serviceBgChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kScreenWidth/2-btnWidth*(1-index)+35, 38, btnWidth-70.0, 2.0);
    }];
}
@end
