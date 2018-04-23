//
//  TCExpertDetailController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCConsultModel.h"

typedef void(^LeftActionBlock)();
@interface TCExpertDetailController : BaseViewController

@property (nonatomic,assign)BOOL      isHomeIn;
@property (nonatomic,assign)NSInteger expert_id;
///  返回按钮回调
@property (nonatomic, copy) LeftActionBlock leftActionBlock;
//是否需要登录
@property (nonatomic, assign)BOOL     isNeedLogin;


@end
