//
//  TodayMissionCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/8.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCIntegralTaskListModel.h"

@interface TCTodayMissionCell : UITableViewCell
/// 标题图标
@property (nonatomic ,strong) UIImageView *taskImg;
/// 标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 积分
@property (nonatomic ,strong) UILabel *integraInfoLab;
/// 任务状态
@property (nonatomic ,strong) UILabel *taskTypeLabe;

- (void)setTodayMissionWithModel:(TCIntegralTaskListModel *)model;

@end
