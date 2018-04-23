
//
//  TCChooseTopicCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCChooseTopicCell.h"

@implementation TCChooseTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
      
        self.topicTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, (44 - 20)/2, 200, 20)];
        self.topicTitleLab.font = kFontWithSize(15);
        self.topicTitleLab.textColor = UIColorFromRGB(0x05d380);
        self.topicTitleLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.topicTitleLab];
        
        self.checkImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 38, (40 - 19)/2, 19, 19)];
        self.checkImg.image = [UIImage imageNamed:@"not_choice"];
        [self.contentView addSubview:self.checkImg];
    }
    return self;
}
- (void)cellwithModel:(TCTopicListModel *)model selectTopicStr:(NSString *)selectTopicStr{
    
    self.topicTitleLab.text = [NSString stringWithFormat:@"%@",model.title];
    if ([selectTopicStr isEqualToString:model.title]) {
        self.checkImg.image =[UIImage imageNamed:@"choice"];
        self.topicTitleLab.textColor = UIColorFromRGB(0x05d380);
    }else{
        self.checkImg.image =[UIImage imageNamed:@"not_choice"];
        self.topicTitleLab.textColor = UIColorFromRGB(0x313131);
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
