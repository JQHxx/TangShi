//
//  ETapScrollView.m
//  WOWlife
//
//  Created by Eva on 17/2/21.
//  Copyright © 2017年 Eva. All rights reserved.
//
#define kScreenW [[UIScreen mainScreen] bounds].size.width //屏幕宽度
#define kScreenH [[UIScreen mainScreen] bounds].size.height //屏幕高度


#import "ETapScrollView.h"
#import "WLScrollView.h"

@interface ETapScrollView ()<UIScrollViewDelegate>

@end
@implementation ETapScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置代理
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = NO;
        //翻页效果
        self.pagingEnabled = YES;
        
    }
    return self;
}
- (void)setTapViewWithImage:(NSArray<NSString *>*)array isUrlImage:(BOOL)isUrlImage index:(NSInteger)index{
    
    CGFloat dx = 30;
    CGFloat itemWidth = self.bounds.size.width + dx * 2.0;
    for(NSInteger i= 0; i< array.count; i++ ) {
        WLScrollView *s = [[WLScrollView alloc] initWithFrame:CGRectMake(i==0? 0:(kScreenW + 10)* i, 0, kScreenW, kScreenH)];
        CGRect frame = self.bounds;
        frame.origin.x = itemWidth * i;
        frame.origin.y = 0.0;
        frame.size.width = itemWidth;
        s.frame = CGRectInset(frame, dx, 0);
        [self addSubview:s];
        if (isUrlImage) {
            [s.imageView sd_setImageWithURL:[NSURL URLWithString:array[i]]];
        }else {
            s.imageView.image = [UIImage imageNamed:array[i]];
        }
        s.block = ^(){
            [self clickImage];
        };
    }
    self.frame = CGRectMake(-dx, 0, itemWidth, kScreenH);
    self.contentSize = CGSizeMake(itemWidth *array.count, self.frame.size.height);
    [self setContentOffset:CGPointMake(itemWidth *index, 0) animated:NO];


}
- (void)clickImage{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (_ETapDelegate && [_ETapDelegate respondsToSelector:@selector(disMissController)]) {
        [_ETapDelegate disMissController];
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
