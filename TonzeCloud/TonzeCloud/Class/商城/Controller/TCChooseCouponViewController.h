//
//  TCChooseCouponViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/4/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef enum: NSInteger{
    MallCoupon,         // 商城优惠券
    ServiceCoupon,      // 服务优惠券
}CouponType;

@interface TCChooseCouponViewController : BaseViewController
/// 优惠券类型
@property (nonatomic, assign) CouponType cupontype;

@end
