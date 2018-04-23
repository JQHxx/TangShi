//
//  ExchangeRecordsDetailCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeRecordsDetailCell.h"
#import "QLCoreTextManager.h"

@implementation TCExchangeRecordsDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setExchangeRecordsDetailCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setExchangeRecordsDetailCellUI{

    _commodityImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 75, 75)];
    [self.contentView addSubview:_commodityImg];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(_commodityImg.right + 10, _commodityImg.top, kScreenWidth - _commodityImg.right - 30, 40)];
    _titleLab.font = kFontWithSize(14);
    _titleLab.numberOfLines = 0;
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor = UIColorFromRGB(0x313131);
    [self.contentView addSubview:_titleLab];

    _integralLab = [[UILabel alloc]initWithFrame: CGRectMake(kScreenWidth - 200, 90 - 30, 200 - 20, 15)];
    _integralLab.font = kFontWithSize(15);
    _integralLab.textColor = UIColorFromRGB(0xf9c92b);
    _integralLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_integralLab];
}
#pragma mark ====== Set Data =======

- (void)setExchangeRecordsDetailWithModel:(TCExchangeRecordsGoodsModel *)model
{
    [_commodityImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@""]];
    
    _titleLab.text = model.good_name;
    
    NSString *integralStr =[NSString stringWithFormat:@"%@ 积分",model.change_points];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
    [QLCoreTextManager setAttributedValue:attStr text:@"积分" font:kFontWithSize(12) color:UIColorFromRGB(0xf9c92b)];
    self.integralLab.attributedText = attStr;
}
@end
