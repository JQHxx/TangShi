//
//  TCChooseTopicCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCTopicListModel.h"

@interface TCChooseTopicCell : UITableViewCell

/// 话题标题
@property (nonatomic ,strong) UILabel *topicTitleLab;
/// 勾选图标
@property (nonatomic ,strong) UIImageView *checkImg;

/*
 *  selectTopicStr  用户选中话题标题
 */
- (void)cellwithModel:(TCTopicListModel *)model selectTopicStr:(NSString *)selectTopicStr;

@end
