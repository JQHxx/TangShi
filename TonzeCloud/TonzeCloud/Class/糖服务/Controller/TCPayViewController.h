//
//  TCPayViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCServiceDetailModel.h"

@interface TCPayViewController : BaseViewController

@property (nonatomic,assign)NSInteger planType;   //1.图文咨询；2.医疗方案
@property (nonatomic,assign)NSInteger expertId;   //专家id
@property (nonatomic, assign )double  payAmount; //支付金额
@property (nonatomic, assign )double  payPriceAmount; //优惠金额

@property (nonatomic,assign)NSInteger planId;     //方案id （医疗方案用）

@end
