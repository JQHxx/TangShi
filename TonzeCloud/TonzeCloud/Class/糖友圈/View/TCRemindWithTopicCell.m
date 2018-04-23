//
//  TCRemindWithTopicCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRemindWithTopicCell.h"

@implementation TCRemindWithTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        self.titleLab  = [[UILabel alloc]initWithFrame:CGRectMake(20, (40 - 20)/2, 80, 20)];
        self.titleLab.font = kFontWithSize(15);
        self.titleLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView  addSubview:self.titleLab];
        
        self.topicLab =   [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - (kScreenWidth - 120), (CGRectGetHeight(self.contentView.frame) - 20)/2, kScreenWidth - 160, 20)];
        self.topicLab.font = kFontWithSize(15);
        self.topicLab.textAlignment = NSTextAlignmentRight;
        self.topicLab.textColor = UIColorFromRGB(0x959595);
        [self.contentView  addSubview:self.topicLab];
        
        // -- 箭头
        _arrowImg= [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (CGRectGetHeight(self.contentView.frame) - 15)/2 , 15, 15)];
        _arrowImg.image =[UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self.contentView addSubview:_arrowImg];
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
