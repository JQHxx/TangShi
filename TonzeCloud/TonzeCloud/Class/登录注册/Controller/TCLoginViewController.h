//
//  TCLoginViewController.h
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^LoginSuccessBlock)();

@interface TCLoginViewController : BaseViewController

@property (nonatomic,assign)BOOL isGuidanceIn;
/// 登录成功回调
@property (nonatomic, copy) LoginSuccessBlock loginSuccess;

@end
