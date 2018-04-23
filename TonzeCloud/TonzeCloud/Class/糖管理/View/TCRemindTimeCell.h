//
//  TCRemindTimeCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCRemindTimeCell : UITableViewCell

/// 标题
@property (nonatomic ,strong) UILabel  *titleLab;
/// 勾选图标
@property (nonatomic ,strong) UIImageView *checkImg;

- (void)cellDisplayWithDict:(NSDictionary *)dict;

@end
