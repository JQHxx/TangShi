//
//  TCSlideView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSlideView;

@protocol TCSlideViewDelegate <NSObject>

-(void)menuView:(TCSlideView *)menuView actionWithIndex:(NSInteger)index;

@end

@interface TCSlideView : UIView

@property (nonatomic ,weak) id<TCSlideViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *menusArray;

@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)changeViewWithButton:(UIButton *)btn;

@end
