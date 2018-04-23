//
//  TCHomeShopView.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/5.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCHomeShopViewDelegate <NSObject>

-(void)homeShopViewDidClickWithTag:(NSInteger)tag Shop_id:(NSInteger)shop_id;

@end
@interface TCHomeShopView : UIView

@property(nonatomic,weak)id<TCHomeShopViewDelegate>delegate;

- (void)homeShopData:(NSDictionary *)homeCenterDict;

@end
