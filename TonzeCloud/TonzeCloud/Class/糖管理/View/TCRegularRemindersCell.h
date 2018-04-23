//
//  TCRegularRemindersCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCRegularRemindersModel.h"


typedef void(^SwitchTypeBlock)(BOOL isOpen);

@interface TCRegularRemindersCell : UITableViewCell

/// 定时时间
@property (nonatomic ,strong) UILabel *timeLab;
/// 类型 &&  星期
@property (nonatomic ,strong) UILabel *weekLab;
/// 提醒开关
@property (nonatomic ,strong) UISwitch *switchBtn;
/// 提醒开关回调
@property (nonatomic, copy) SwitchTypeBlock switchTypeBlock;

- (void)loadRegularRemindersCellData:(TCRegularRemindersModel *)model;


@end
