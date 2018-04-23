//
//  TCMyDynamicViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#define kImgViewHeight 223

@interface TCMyDynamicViewController : BaseViewController

/// 用户id    ( 主页动态 本人主页动态不需要传user_id ,他人主页动态需要传递 user_id)
@property (nonatomic ,assign)NSInteger news_id;
/// 用户角色
@property (nonatomic, assign)NSInteger  role_type_ed;

@property (nonatomic, assign)BOOL       isMyDynamic;  //是否我的动态


@end
