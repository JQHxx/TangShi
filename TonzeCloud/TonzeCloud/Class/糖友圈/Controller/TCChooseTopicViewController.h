//
//  TCChooseTopicViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^TopicTitleBlock)(NSString *tiptitleStr,NSInteger topicId);

@interface TCChooseTopicViewController : BaseViewController

/// 选择的话题回调
@property (nonatomic, copy) TopicTitleBlock topicTitleBlock;
///
@property (nonatomic, copy) NSString  *topicStr;// 话题字符串 ;


@end
