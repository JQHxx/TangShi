
//
//  TCEditAndAddRemindCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCEditAndAddRemindCell.h"

@implementation TCEditAndAddRemindCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setEditAndAddRemindCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setEditAndAddRemindCellUI{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(18,(38 - 20)/2, 100, 20)];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.font = kFontWithSize(15);
    [self.contentView addSubview:_titleLab];
   
    _contentLab = [[UILabel alloc]initWithFrame:CGRectMake( 120, (38 - 20)/2, kScreenWidth - 155, 20)];
    _contentLab.textAlignment = NSTextAlignmentRight;
    _contentLab.textColor = UIColorFromRGB(0x959595);
    _contentLab.font = kFontWithSize(13);
    [self.contentView addSubview:_contentLab];
    
    _arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 30, (38 - 15)/2, 15, 15)];
    _arrowImg.image = [UIImage imageNamed:@"箭头_列表"];
    [self.contentView addSubview:_arrowImg];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
