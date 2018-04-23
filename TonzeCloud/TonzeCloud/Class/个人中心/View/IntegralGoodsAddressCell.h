//
//  IntegralGoodsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/6.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralGoodsAddressCell : UITableViewCell

/// 收货信息
@property (nonatomic ,strong) UILabel *nameLab;
/// 手机号
@property (nonatomic ,strong) UILabel *phoneNumberLab;
/// 地址信息
@property (nonatomic ,strong) UILabel *addressInfoLab;
/// 箭头
@property (nonatomic ,strong) UIImageView *arrowImg;

@end
