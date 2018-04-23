//
//  TCHistoryMenuView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCHistoryMenuView;
@protocol TCHistoryMenuViewDelegate <NSObject>

-(void)foodHistoryMenuView:(TCHistoryMenuView *)menuView actionWithIndex:(NSInteger)index;

@end
@interface TCHistoryMenuView : UIView
@property (nonatomic ,assign) id<TCHistoryMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *foodMenusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;


-(void)changeHistoryViewWithButton:(UIButton *)btn;
@end
