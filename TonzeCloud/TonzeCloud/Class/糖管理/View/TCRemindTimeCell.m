//
//  TCRemindTimeCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRemindTimeCell.h"

@implementation TCRemindTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setRemindTimeCell];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setRemindTimeCell{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(18, (44 - 20)/2 , 150, 20)];
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.font = kFontWithSize(15);
    [self.contentView addSubview:_titleLab];
    
    _checkImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 50, (44 - 20)/2, 20, 20)];
    _checkImg.image = [UIImage imageNamed:@"ic_pub_arrow"];
    _checkImg.hidden = YES;
    [self.contentView addSubview:_checkImg];
}
- (void)cellDisplayWithDict:(NSDictionary *)dict{
    
    _titleLab.text = [NSString stringWithFormat:@"每%@",[dict objectForKey:@"title"]];
    if ([[dict objectForKey:@"checkImg"]isEqualToString:@"1"]) {
        _checkImg.hidden = NO;
    }else{
        _checkImg.hidden = YES;
    }
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
