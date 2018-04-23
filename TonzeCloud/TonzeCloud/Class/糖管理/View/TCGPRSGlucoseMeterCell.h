//
//  TCGPRSGlucoseMeterCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGPRSDeviceListModel.h"

@protocol  TCGlucoseMeterCellDelegate<NSObject>
// 管理设备
- (void)didmanagementOfEquipment:(UITableViewCell *)cell;
// 历史记录
- (void)didcheckTheRecord:(UITableViewCell *)cell;

@end

@interface TCGPRSGlucoseMeterCell : UITableViewCell
///
@property (nonatomic, weak) id<TCGlucoseMeterCellDelegate>  delegate;
/// 数据模型
@property (nonatomic ,strong) TCGPRSDeviceListModel *deviceListModel;

@end
