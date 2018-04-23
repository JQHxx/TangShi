//
//  DeviceCloudMenuTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCookListModel.h"

@interface DeviceCloudMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cloudMenuImg;
@property (weak, nonatomic) IBOutlet UILabel     *cloudMenuName;
@property (weak, nonatomic) IBOutlet UILabel     *cloudMenuDetail;
@property (weak, nonatomic) IBOutlet UILabel *colarieLabel;

-(void)cellDisplayWithModel:(TCCookListModel *)model;

@end
