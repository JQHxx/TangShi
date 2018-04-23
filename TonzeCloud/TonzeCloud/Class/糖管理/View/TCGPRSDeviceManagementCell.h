//
//  TCGPRSDeviceManagementCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCGPRSDeviceManagementCell : UITableViewCell
///
@property (nonatomic ,strong) UILabel *titleLab;
///
@property (nonatomic ,strong) UILabel *contentLab;
/// 设备名称
@property (nonatomic ,strong) UILabel *deviceNameLab;
///
@property (nonatomic ,strong) UIImageView *arrowIcon;

@end
