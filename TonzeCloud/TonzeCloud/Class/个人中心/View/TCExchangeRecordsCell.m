
//
//  ExchangeRecordsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeRecordsCell.h"
#import "QLCoreTextManager.h"

@implementation TCExchangeRecordsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setExchangeRecordsCell];
    }
    return self;
}
#pragma mark -- Set UI
- (void)setExchangeRecordsCell{
    _commodityImg = [[UIImageView alloc]initWithFrame:CGRectMake(12, (90 - 75)/2 , 75 , 75 )];
    [self.contentView addSubview:_commodityImg];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(_commodityImg.right + 10, _commodityImg.top, kScreenWidth - _commodityImg.right - 22, 40)];
    _titleLab.font = kFontWithSize(13);
    _titleLab.numberOfLines = 0;
    _titleLab.textColor = UIColorFromRGB(0x313131);
    [self.contentView addSubview:_titleLab];
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(_commodityImg.right + 10, _commodityImg.bottom - 20 , 200, 20)];
    _timeLab.textAlignment = NSTextAlignmentLeft;
    _timeLab.font = kFontWithSize(12);
    _timeLab.textColor = UIColorFromRGB(0x959595);
    [self.contentView addSubview:_timeLab];
    
    _integralNumberLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 200, 90 - 30, 200 - 12, 15)];
    _integralNumberLab.font = kFontWithSize(15);
    _integralNumberLab.textColor = UIColorFromRGB(0xf9c92b);
    _integralNumberLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_integralNumberLab];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, 90 - 0.5, kScreenWidth, 0.5)];
    len.backgroundColor = kLineColor;
    [self.contentView addSubview:len];
}

#pragma mark ====== set Data =======

- (void)setExchangeRecordsCellWithModle:(TCExchangeRecordsGoodsModel *)model{
    [_commodityImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@""]];
    _titleLab.text = model.good_name;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ 积分",model.change_points]];
    [QLCoreTextManager setAttributedValue:attStr text:@"积分" font:kFontWithSize(12) color:UIColorFromRGB(0xf9c92b)];
    _integralNumberLab.attributedText = attStr;
}
- (void)setTimeStr:(NSString *)timeStr{
    _timeLab.text = timeStr;
}

@end
