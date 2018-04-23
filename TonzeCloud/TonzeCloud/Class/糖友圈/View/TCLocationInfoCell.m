//
//  TCLocationInfoCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLocationInfoCell.h"

@implementation TCLocationInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, (CGRectGetHeight(self.contentView.frame) - 20)/2, 150, 20)];
        self.titleLab.font = kFontWithSize(14);
        self.titleLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView addSubview:self.titleLab];
        
        self.iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 44, (CGRectGetHeight(self.contentView.frame) - 24)/2, 24, 24)];
        [self.contentView addSubview:self.iconImg];
        
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
