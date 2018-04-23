//
//  ShippingAddressVC.h
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "TCConsigneeInfoModel.h"

typedef void(^ShippingInfoBlock)(NSString *addressStr,NSString *phoneNumberStr,NSString *nameStr);

@interface TCShippingAddressViewController : BaseViewController

/// 收货信息相关
@property (nonatomic, copy) ShippingInfoBlock  addressInfo;
/// 收货信息
@property (nonatomic ,strong) TCConsigneeInfoModel *consigneeInfoModel;

@end
