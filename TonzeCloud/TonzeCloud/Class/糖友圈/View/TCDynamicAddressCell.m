//
//  TCDynamicAddressCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDynamicAddressCell.h"

@implementation TCDynamicAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, (40 - 15) /2, 11, 14)];
        [self.contentView addSubview:self.iconImg];
        
        self.titleLab  = [[UILabel alloc]initWithFrame:CGRectMake(_iconImg.right + 6, (40 - 20)/2, 100, 20)];
        self.titleLab.font = kFontWithSize(15);
        self.titleLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView  addSubview:self.titleLab];
        
        // -- 箭头
        UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (CGRectGetHeight(self.contentView.frame) - 15)/2 , 15, 15)];
        arrowImg.image =[UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self.contentView addSubview:arrowImg];
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
