//
//  TCRemindWhoSeeViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^RemindUsersBlock)(NSString *userName, NSInteger userId,NSInteger role_type_ed);

@interface TCRemindWhoSeeViewController : BaseViewController

/// 
@property (nonatomic, copy) RemindUsersBlock remindUsersBlock ;

@end
