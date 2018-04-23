//
//  TCTopicListCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCTopicListModel;

@interface TCTopicListCell : UITableViewCell

/// 图标
@property (nonatomic ,strong) UIImageView *topicIcon;
/// 标题
@property (nonatomic ,strong) UILabel *topicTitleLab;
/// 摘要说明
@property (nonatomic ,strong) UILabel *instructionsLab;
/// 阅读量
@property (nonatomic ,strong) UILabel *readLab;
/// 讨论量
@property (nonatomic ,strong) UILabel *discussLab;

- (void)setTopicListWithModel:(TCTopicListModel *)model;

@end
