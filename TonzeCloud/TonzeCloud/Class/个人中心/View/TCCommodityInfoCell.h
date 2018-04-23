//
//  CommodityCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGoodsDetailModel.h"

@interface TCCommodityInfoCell : UITableViewCell

///
@property (nonatomic ,strong) UIImageView *goodsImg;
/// 标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 积分数
@property (nonatomic ,strong) UILabel *integralNumberLab;
/// 商品数量
@property (nonatomic ,strong) UILabel *commodityNumberLab;
/// 运费
@property (nonatomic ,strong) UILabel *freightLab;

-(void)setCellDataWithModel:(TCGoodsDetailModel *)model;

@end
