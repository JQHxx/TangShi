//
//  TCAddDeviceTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddDeviceTableViewCell.h"

@interface TCAddDeviceTableViewCell (){
    UIImageView       *deviceImageView;
    UILabel           *deviceNameLbl;
    UILabel           *deviceDescLbl;
}

@end

@implementation TCAddDeviceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        deviceNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth-130, 30)];
        deviceNameLbl.font=[UIFont boldSystemFontOfSize:15];
        deviceNameLbl.textColor=[UIColor blackColor];
        [self.contentView addSubview:deviceNameLbl];
        
        deviceDescLbl=[[UILabel alloc] initWithFrame:CGRectMake(15,deviceNameLbl.bottom,deviceNameLbl.width, 60)];
        deviceDescLbl.numberOfLines=0;
        deviceDescLbl.textColor=[UIColor lightGrayColor];
        deviceDescLbl.font=[UIFont systemFontOfSize:13];
        [self.contentView addSubview:deviceDescLbl];
        
        
        deviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-90, 10, 80, 80)];
        deviceImageView.image=[UIImage imageNamed:@"img_h_jtfb"];
        [self.contentView addSubview:deviceImageView];
        
        
    }
    return self;
}

-(void)setDevice:(TCAddDeviceModel *)device{
    deviceNameLbl.text=device.deviceName;
    deviceDescLbl.text=device.desc;
    
    CGFloat descHeight=[device.desc boundingRectWithSize:CGSizeMake(kScreenWidth-130, 60) withTextFont:deviceDescLbl.font].height;
    deviceDescLbl.frame=CGRectMake(15, deviceNameLbl.bottom, deviceNameLbl.width, descHeight);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
