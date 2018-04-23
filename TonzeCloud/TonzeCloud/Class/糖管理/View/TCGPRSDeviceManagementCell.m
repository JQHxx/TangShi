//
//  TCGPRSDeviceManagementCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSDeviceManagementCell.h"

@implementation TCGPRSDeviceManagementCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(18, (44 - 20)/2, 150, 20)];
        _titleLab.font = kFontWithSize(15);
        _titleLab.textColor = UIColorFromRGB(0x343434);
        [self.contentView addSubview:_titleLab];
       
        _deviceNameLab =[[UILabel alloc]initWithFrame:CGRectMake(150, _titleLab.top, kScreenWidth - 188, 20)];
        _deviceNameLab.textColor = UIColorFromRGB(0x626262);
        _deviceNameLab.font = kFontWithSize(15);
        _deviceNameLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_deviceNameLab];
        
        _contentLab = [[UILabel alloc]initWithFrame:CGRectMake(150, _titleLab.top, kScreenWidth - 168, 20)];
        _contentLab.textColor = UIColorFromRGB(0x626262);
        _contentLab.font = kFontWithSize(13);
        _contentLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_contentLab];
        
        _arrowIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 28, (44 - 16)/2, 10, 16)];
        _arrowIcon.image = [UIImage imageNamed:@"right_arrow"];
        [self.contentView addSubview:_arrowIcon];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
