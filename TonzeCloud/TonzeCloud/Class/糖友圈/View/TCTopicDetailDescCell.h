//
//  TCTopicDetailDescCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYCoreTextLabel.h"

@interface TCTopicDetailDescCell : UITableViewCell
/// 摘要
@property (nonatomic ,strong) MYCoreTextLabel *descLabel;
/// 讨论量
@property (nonatomic ,strong) UILabel *discussTotalLabe;

- (void)cellWithDesc:(NSString *)desc discussToutal:(NSInteger )discussToutal;


@end
