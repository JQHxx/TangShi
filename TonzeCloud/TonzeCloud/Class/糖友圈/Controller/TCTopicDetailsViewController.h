//
//  TCTopicDetailsViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCTopicDetailsViewController : BaseViewController

/// 话题
@property (nonatomic, copy) NSString *topic;
/// 话题id
@property (nonatomic, assign) NSInteger  topicId;
/// 话题标题
@property (nonatomic, assign) BOOL  topic_delete_status;

@end
