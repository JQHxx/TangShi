//
//  DiscountView.h
//  TonzeCloud
//
//  Created by vision on 18/4/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DiscountViewDelegate <NSObject>

//显示积分使用规则
- (void)discountViewShowInteralRules;
//选择优惠券
- (void)discountViewSelectCoupon;
//设置积分抵扣
- (void)discountViewSetIntegralSelected:(BOOL)isSelected;
//选择可用积分
- (void)discountViewChooseIntegralCount:(NSInteger)count;

@end

@interface DiscountView : UIView

@property (nonatomic,assign)NSInteger integralCount;       //积分总数
@property (nonatomic,assign)BOOL hasavailableIntegral;     
@property (nonatomic ,weak )id <DiscountViewDelegate>delegate;

@end
