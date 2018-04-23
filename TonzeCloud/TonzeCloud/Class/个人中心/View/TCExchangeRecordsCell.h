//
//  ExchangeRecordsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCExchangeRecordsGoodsModel.h"

@interface TCExchangeRecordsCell : UITableViewCell

/// 时间
@property (nonatomic ,strong) UILabel *timeLab;
/// 商品图片
@property (nonatomic ,strong) UIImageView *commodityImg;
/// 商品标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 积分数
@property (nonatomic ,strong) UILabel *integralNumberLab;
/// 时间
@property (nonatomic, copy) NSString *timeStr;

- (void)setExchangeRecordsCellWithModle:(TCExchangeRecordsGoodsModel *)model;

@end
