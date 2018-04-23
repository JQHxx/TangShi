//
//  ExchangeRecordsDetailCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCExchangeRecordsGoodsModel.h"

@interface TCExchangeRecordsDetailCell : UITableViewCell
/// 商品图片
@property (nonatomic ,strong) UIImageView *commodityImg;
/// 标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 积分数
@property (nonatomic ,strong) UILabel *integralLab;

- (void)setExchangeRecordsDetailWithModel:(TCExchangeRecordsGoodsModel *)model;

@end
