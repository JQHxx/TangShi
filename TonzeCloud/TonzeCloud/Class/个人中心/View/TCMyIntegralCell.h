//
//  MyIntegralCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCUserIntegralModel.h"

@interface TCMyIntegralCell : UITableViewCell

/// 积分选项标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 时间
@property (nonatomic ,strong) UILabel *timeLab;
/// 积分数
@property (nonatomic ,strong) UILabel *integralNumberLab;

- (void)setCellModel:(TCUserIntegralModel *)model;

@end
