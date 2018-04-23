//
//  TCMaxDynamicViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCDynamicCommentsModel.h"
#import "TCMyCommentsModel.h"

@interface TCMaxDynamicViewController : BaseViewController

@property (nonatomic ,assign)NSInteger news_id;

@property (nonatomic ,assign)NSInteger newscomment_id;

@property (nonatomic ,assign)NSInteger relpy_num;
@end
