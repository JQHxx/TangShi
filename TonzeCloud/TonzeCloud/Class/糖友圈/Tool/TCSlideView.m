//
//  TCSlideView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSlideView.h"
#define kBtnWidth 80

@interface TCSlideView(){
    UILabel   *line_lab;
    UIButton  *selectBtn;
    CGFloat   btnWidth;
    CGFloat   viewHeight;
    NSUInteger num;
    CGSize btnTextSize;
}@end

@implementation TCSlideView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        viewHeight=frame.size.height;
        
        self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, viewHeight)];
        self.rootScrollView.showsHorizontalScrollIndicator=NO;
        [self addSubview:self.rootScrollView];
        num=0;
    }
    return self;
}

-(void)setMenusArray:(NSMutableArray *)menusArray{
    _menusArray=menusArray;
    
    num=menusArray.count;
    if (kBtnWidth*num<kScreenWidth) {
        btnWidth=kScreenWidth/num;
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, viewHeight);
    }else{
        btnWidth=kBtnWidth;
        self.rootScrollView.contentSize=CGSizeMake(btnWidth*num, viewHeight);
    }
    
    for (int i=0; i<num; i++) {
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
        [btn setTitle:menusArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x424242) forState:UIControlStateNormal];
        [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
        btn.titleLabel.font = kFontWithSize(15);
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    NSString *textWidth = @"推荐";
    btnTextSize = [textWidth boundingRectWithSize:CGSizeMake(100, 100) withTextFont:kFontWithSize(15)];
    
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake((btnWidth - 45)/2,viewHeight- 3, 45 , 2)];
    line_lab.backgroundColor = kSystemColor;
    [self.rootScrollView addSubview:line_lab];
    
    UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight- 1,kScreenWidth , 1)];
    line.backgroundColor= [UIColor bgColor_Gray];
    [self addSubview:line];
}

-(void)changeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index * btnWidth +  (btnWidth - 45)/2,viewHeight- 3, 45, 2);
        if (index>2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==num-2){
            CGFloat scrollw=self.menusArray.count*btnWidth;
            if (scrollw>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollw-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    
    if ([_delegate respondsToSelector:@selector(menuView:actionWithIndex:)]) {
        [_delegate menuView:self actionWithIndex:index];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
