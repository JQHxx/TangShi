//
//  TCShopClickViewGroup.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/6.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCShopClickViewGroup.h"

#define kBtnWidth 50

@interface TCShopClickViewGroup ()<UIScrollViewDelegate>{
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    
    NSUInteger     num;
}

@end
@implementation TCShopClickViewGroup
-(instancetype)initWithShopFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor *)color{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=kSystemColor;
        self.showsHorizontalScrollIndicator=NO;
        self.delegate=self;
        
        viewHeight=frame.size.height;
        num=titles.count;
        
        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectZero];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            btn.tag=100+i;
            btn.frame =CGRectMake(kBtnWidth*i, 10, kBtnWidth, 20);
            [btn addTarget:self action:@selector(ShopChangeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5,38, kBtnWidth-10, 2.0)];
        line_lab.backgroundColor = color;
        [self addSubview:line_lab];
        
    }
    return self;
}

-(void)ShopChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kBtnWidth*index+5, 38, kBtnWidth-10, 2.0);
    }];
    
    if ([_ShopClickDelegate respondsToSelector:@selector(ShopViewGroupActionWithIndex:)]) {
        [_ShopClickDelegate ShopViewGroupActionWithIndex:index];
    }
    
}
-(void)ShopBgChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kBtnWidth*index+5, 38, kBtnWidth-10, 2.0);
    }];
}
@end
