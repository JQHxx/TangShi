//
//  ExchangeAddressCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCExchangeRecordsDetailModel.h"

@interface TCExchangeAddressCell : UITableViewCell

/// 收货人
@property (nonatomic ,strong)  UILabel *nameLab;
/// 手机号码
@property (nonatomic ,strong)  UILabel *phoneNumberLab;
/// 地址
@property (nonatomic ,strong)  UILabel *addressLab;

- (void)setExchangeAddressWithModel:(TCExchangeRecordsDetailModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;

@end
