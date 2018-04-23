//
//  DeviceCloudMenuTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DeviceCloudMenuTableViewCell.h"

@implementation DeviceCloudMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithModel:(TCCookListModel *)model{
    self.cloudMenuImg.contentMode=UIViewContentModeScaleToFill;
    [self.cloudMenuImg sd_setImageWithURL:[NSURL URLWithString:model.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    self.cloudMenuName.text = model.name;
    self.cloudMenuName.textColor = [UIColor colorWithHexString:@"0x313131"];
    self.cloudMenuDetail.text = model.abstract;
    self.cloudMenuDetail.textColor = [UIColor colorWithHexString:@"0x7d7d7d"];
    self.colarieLabel.text=[NSString stringWithFormat:@"%ldkcal",(long)model.energykcal];
    self.colarieLabel.textColor= [UIColor colorWithHexString:@"0x7d7d7d"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
