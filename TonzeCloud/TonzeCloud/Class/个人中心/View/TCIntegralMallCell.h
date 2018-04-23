//
//  IntegralMallCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGoodsListModel.h"

@interface TCIntegralMallCell : UICollectionViewCell

/// 商品图片
@property (nonatomic ,strong) UIImageView *commodityImg;
/// 商品标题
@property (nonatomic ,strong) UILabel *productTitleLab;
/// 积分
@property (nonatomic ,strong) UILabel *IntegralLab;

- (void)cellWithGoodsListModel:(TCGoodsListModel *)model;

@end
