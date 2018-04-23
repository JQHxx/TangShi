//
//  TCTopicDetailDescCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTopicDetailDescCell.h"

@interface TCTopicDetailDescCell ()
{
    UIView *_discussView;
}
@end
@implementation TCTopicDetailDescCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.descLabel];
        
        _discussView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 40, kScreenWidth,40)];
        _discussView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:_discussView];
    
        _discussTotalLabe =[[UILabel alloc]initWithFrame:CGRectMake(20, 10 , kScreenWidth - 40,20)];
        _discussTotalLabe.textColor = UIColorFromRGB(0x959595);
        _discussTotalLabe.font = kFontWithSize(15);
        [_discussView addSubview:_discussTotalLabe];
    }
    return self;
}
#pragma mark ====== 赋值数据 =======
- (void)cellWithDesc:(NSString *)desc discussToutal:(NSInteger )discussToutal{
    
    [self.descLabel setText:desc customLinks:@[@""] keywords:@[@""]];
    CGSize descSize = [self.descLabel sizeThatFits:CGSizeMake(kScreenWidth- 26, [UIScreen mainScreen].bounds.size.height)];
    self.descLabel.frame = CGRectMake(13, 14 , kScreenWidth - 26,descSize.height);
    
    _discussView.frame = CGRectMake(0, _descLabel.bottom + 14, kScreenWidth, 40);
    _discussTotalLabe.text = [NSString stringWithFormat:@"讨论热度（%ld）",discussToutal];
    if (discussToutal == 0) {
        _discussTotalLabe.hidden = YES;
    }
}
- (MYCoreTextLabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[MYCoreTextLabel alloc]init];
        _descLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _descLabel.textColor = UIColorFromRGB(0x313131);   // 设置普通内容文字颜色
        _descLabel.lineSpacing = 1.5;
        _descLabel.wordSpacing = 0.5;
    }
    return _descLabel;
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
