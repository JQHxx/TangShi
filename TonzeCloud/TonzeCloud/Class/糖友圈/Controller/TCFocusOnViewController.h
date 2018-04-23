//
//  TCFocusOnViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCFocusOnViewController : BaseViewController

@property (nonatomic ,assign)NSInteger type;//type=1为我的关注列表 ＝2为其他人的关注列表

@property (nonatomic ,assign)NSInteger user_id;

@property (nonatomic ,assign)NSInteger role_type; 


@end
