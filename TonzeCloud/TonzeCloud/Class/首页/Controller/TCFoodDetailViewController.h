//
//  TCFoodDetailViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^LeftActionBlock)();

@interface TCFoodDetailViewController : BaseViewController

@property (nonatomic,assign)NSInteger food_id;
/// 返回按钮返回事件
@property (nonatomic, copy) LeftActionBlock  leftActionBlock;

@end
