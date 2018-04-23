
//
//  TCGlucoseMeterHelpCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGlucoseMeterHelpCell.h"

@interface TCGlucoseMeterHelpCell()
{
    CGFloat _imgHight;// 图片高度
}
@end

@implementation TCGlucoseMeterHelpCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
        [self.contentView addSubview:_img];
    }
    return self;
}
- (void)setImgHight:(CGFloat)imgHight{
    _img.frame = CGRectMake(0, 0, kScreenWidth, imgHight);
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
