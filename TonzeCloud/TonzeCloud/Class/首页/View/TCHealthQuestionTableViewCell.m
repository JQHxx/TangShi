//
//  TCHealthQuestionTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthQuestionTableViewCell.h"

@implementation TCHealthQuestionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _optionLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, kScreenWidth-15-50, 20)];
        _optionLable.textAlignment = NSTextAlignmentLeft;
        _optionLable.font = [UIFont systemFontOfSize:15];
        _optionLable.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self.contentView addSubview:_optionLable];
        
        _seletedImg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 40, 12, 24, 24)];
        [self.contentView addSubview:_seletedImg];
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
