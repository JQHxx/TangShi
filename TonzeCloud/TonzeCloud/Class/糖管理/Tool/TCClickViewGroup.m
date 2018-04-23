//
//  TCClickViewGroup.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/14.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCClickViewGroup.h"
#define kBtnWidth 70

@interface TCClickViewGroup ()<UIScrollViewDelegate>{
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    CGFloat        lineHeight;
    
    NSUInteger     num;
}

@end
@implementation TCClickViewGroup

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor *)color titleColor:(UIColor *)titleColor{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
                
        viewHeight=frame.size.height;
        
        self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, viewHeight)];
        self.rootScrollView.showsHorizontalScrollIndicator=NO;
        self.rootScrollView.delegate = self;
        [self addSubview:self.rootScrollView];
        
        num=titles.count;
        if (kBtnWidth*num<kScreenWidth) {
            btnWidth=kScreenWidth/num;
            self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, viewHeight);
            lineHeight=kScreenWidth;
        }else{
            btnWidth=kBtnWidth;
            self.rootScrollView.contentSize=CGSizeMake(btnWidth*num, viewHeight);
            lineHeight=btnWidth*num;
        }
        
        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            btn.tag=100+i;
            [btn addTarget:self action:@selector(tcChangeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.rootScrollView addSubview:btn];
            
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5.0,viewHeight-3, btnWidth-10.0, 2.0)];
        line_lab.backgroundColor = color;
        [self.rootScrollView addSubview:line_lab];
        
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight-1,kScreenWidth, 1)];
        lineLab.backgroundColor=titleColor;
        [self addSubview:lineLab];
    }
    return self;
}

-(void)tcChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index*btnWidth+5.0, 38, btnWidth-10.0, 2.0);
        if (index>=2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth-10, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }
        
    }];
    
    if ([_viewDelegate respondsToSelector:@selector(TCClickViewGroupActionWithIndex:)]) {
        [_viewDelegate TCClickViewGroupActionWithIndex:index];
    }
    
}
@end
