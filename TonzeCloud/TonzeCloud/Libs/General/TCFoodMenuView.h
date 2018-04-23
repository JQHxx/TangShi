//
//  TCFoodMenuView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/29.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCFoodMenuView;
@protocol TCFoodMenuViewDelegate <NSObject>

-(void)foodMenuView:(TCFoodMenuView *)menuView actionWithIndex:(NSInteger)index;

@end
@interface TCFoodMenuView : UIView
@property (nonatomic ,assign) id<TCFoodMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *foodMenusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)changeFoodViewWithButton:(UIButton *)btn;

@end
