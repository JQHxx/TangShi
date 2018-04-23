//
//  TCMenuView.h
//  TonzeCloud
//
//  Created by vision on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCMenuView;
@protocol TCMenuViewDelegate <NSObject>

-(void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index;

@end

@interface TCMenuView : UIView

@property (nonatomic ,assign) id<TCMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *menusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)changeViewWithButton:(UIButton *)btn;



@end
