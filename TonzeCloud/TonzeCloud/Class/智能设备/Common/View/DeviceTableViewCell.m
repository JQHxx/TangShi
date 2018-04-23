//
//  DeviceTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "DeviceTableViewCell.h"


@interface DeviceTableViewCell (){
    UIImageView       *deviceImageView;
    UILabel           *deviceNameLbl;
    UIImageView       *imgView;
    UILabel           *deviceStateLbl;
    UILabel           *workTypeLbl;
}

@end

@implementation DeviceTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        deviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        deviceImageView.image=[UIImage imageNamed:@"img_h_list_jtfb"];
        [self.contentView addSubview:deviceImageView];
        
        deviceNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(deviceImageView.right+10, 10, kScreenWidth-deviceImageView.right-80, 30)];
        deviceNameLbl.font=[UIFont boldSystemFontOfSize:15];
        deviceNameLbl.textColor=[UIColor blackColor];
        [self.contentView addSubview:deviceNameLbl];
        
        imgView=[[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:imgView];
        
        deviceStateLbl=[[UILabel alloc] initWithFrame:CGRectMake(deviceImageView.right+10, 40, 120, 30)];
        deviceStateLbl.textColor=[UIColor lightGrayColor];
        deviceStateLbl.font=[UIFont systemFontOfSize:13];
        [self.contentView addSubview:deviceStateLbl];
        
        workTypeLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        workTypeLbl.textColor=kRGBColor(234, 174, 100);
        workTypeLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:workTypeLbl];
        
        
    }
    return self;
}

-(void)setDevice:(TCDeviceModel *)device{
    deviceNameLbl.text=device.deviceName;
    deviceStateLbl.text=device.isConnected?@"设备在线":@"设备离线";
    imgView.image=[UIImage imageNamed:device.isConnected?@"在线icon":@"离线icon"];
    
    NSString *stateName=device.stateDict[@"state"];
    workTypeLbl.text=stateName;
    workTypeLbl.hidden=!device.isConnected;
    
    CGFloat typeW=[workTypeLbl.text boundingRectWithSize:CGSizeMake(100, 30) withTextFont:workTypeLbl.font].width;
    workTypeLbl.frame=CGRectMake(kScreenWidth-typeW-30, 25, typeW, 30);
    
    CGFloat nameW=[device.deviceName boundingRectWithSize:CGSizeMake(kScreenWidth-deviceImageView.right-70-typeW, 30) withTextFont:deviceNameLbl.font].width;
    deviceNameLbl.frame=CGRectMake(deviceImageView.right+10, 10, nameW, 30);
    
    imgView.frame=CGRectMake(deviceNameLbl.right+5, 15, 20, 20);
}


@end
