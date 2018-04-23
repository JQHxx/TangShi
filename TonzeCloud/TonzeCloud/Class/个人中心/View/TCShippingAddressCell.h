//
//  ShippingAddressCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShippingAddressCell : UITableViewCell

/**
 *  block 参数为textField.text
 */
@property (copy, nonatomic) void(^block)(NSString *);
/// 标题
@property (nonatomic ,strong) UILabel *titleLab;
/// 内容文本框
@property (nonatomic ,strong) UITextField *contentTF;
/// 箭头
@property (nonatomic ,strong) UIImageView *arrowImg;

@end
