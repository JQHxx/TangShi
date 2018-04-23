//
//  TCRemindWithTopicCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCRemindWithTopicCell : UITableViewCell

/// 图标
@property (nonatomic ,strong) UIImageView *iconImg;
/// 标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 话题
@property (nonatomic ,strong) UILabel *topicLab;
/// 箭头
@property (nonatomic ,strong) UIImageView *arrowImg;

@end
