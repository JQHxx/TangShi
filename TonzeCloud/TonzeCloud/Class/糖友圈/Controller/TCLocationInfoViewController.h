//
//  TCLocationInfoViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^AddressBlock)(NSString *proStr,NSString *cityStr);

@interface TCLocationInfoViewController : BaseViewController

/// 所选地址
@property (nonatomic, copy) NSString *address;
///
@property (nonatomic, copy)  AddressBlock adressBlock;

@end
