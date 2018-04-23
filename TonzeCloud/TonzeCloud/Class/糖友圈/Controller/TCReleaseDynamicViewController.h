//
//  TCReleaseDynamicViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCReleaseDynamicViewController : BaseViewController

/// 话题 id
@property (nonatomic, assign) NSInteger  topicId;
/// 话题标题
@property (nonatomic, copy) NSString *topicTiele;
/// 是否可以选择话题
@property (nonatomic, assign) BOOL  isCanChooseTopic;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@end
