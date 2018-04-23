//
//  TCShopClickViewGroup.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/6.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShopViewGroupDelegate <NSObject>

-(void)ShopViewGroupActionWithIndex:(NSUInteger)index;

@end
@interface TCShopClickViewGroup : UIScrollView

@property (nonatomic ,weak) id<ShopViewGroupDelegate>ShopClickDelegate;
@property(nonatomic,assign)BOOL  isNeedReloadData;

-(instancetype)initWithShopFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor*)color;

-(void)ShopChangeViewWithButton:(UIButton *)btn;

-(void)ShopBgChangeViewWithButton:(UIButton *)btn;
@end
