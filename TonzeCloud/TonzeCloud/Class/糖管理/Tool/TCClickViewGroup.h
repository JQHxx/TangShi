//
//  TCClickViewGroup.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/14.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCClickViewGroupDelegate <NSObject>

-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index;

@end
@interface TCClickViewGroup : UIView

@property (nonatomic ,weak) id<TCClickViewGroupDelegate>viewDelegate;
@property(nonatomic,assign)BOOL  isNeedReloadData;

@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor*)color titleColor:(UIColor *)titleColor;

-(void)tcChangeViewWithButton:(UIButton *)btn;
@end
