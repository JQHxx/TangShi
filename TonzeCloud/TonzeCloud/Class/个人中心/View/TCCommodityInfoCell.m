
//
//  CommodityCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//
#import "TCCommodityInfoCell.h"
#import "QLCoreTextManager.h"

@interface TCCommodityInfoCell ()

@end
@implementation TCCommodityInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setCommodityInfoUI];
    }
    return self;
}
#pragma mark ====== Bulild UI =======
- (void)setCommodityInfoUI{

    _goodsImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 375*kScreenWidth/375)];
    [self.contentView addSubview:_goodsImg];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, _goodsImg.bottom, kScreenWidth, 0.5)];
    len.backgroundColor = kLineColor;
    [self.contentView addSubview:len];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake( 20,len.bottom + 20, kScreenWidth- 40, 20)];
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.font = kFontWithSize(15);
    [self.contentView addSubview:_titleLab];
    

    _integralNumberLab = [[UILabel alloc]initWithFrame:CGRectMake( _titleLab.left,_titleLab.bottom + 31/2, 200, 50)];
    _integralNumberLab.textColor = UIColorFromRGB(0xFF9d38);
    _integralNumberLab.font = kFontWithSize(32);
    [self.contentView addSubview:_integralNumberLab];
    
    _commodityNumberLab = [[UILabel alloc]initWithFrame: CGRectMake( _titleLab.left, _integralNumberLab.bottom + 31/2 ,200, 20)];
    _commodityNumberLab.font = kFontWithSize(15);
    _commodityNumberLab.textColor = UIColorFromRGB(0x959595);
    [self.contentView addSubview:_commodityNumberLab];
    
    
    _freightLab = [[UILabel alloc]initWithFrame:CGRectMake( kScreenWidth - 120 ,_commodityNumberLab.top, 100, 20)];
    _freightLab.textColor = UIColorFromRGB(0x313131);
    _freightLab.font = kFontWithSize(15);
    _freightLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_freightLab];

    NSString *integralStr =@"运费: 包邮";
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
    [QLCoreTextManager setAttributedValue:attStr text:@"包邮" font:kFontWithSize(15) color:UIColorFromRGB(0xf9c92b)];
    _freightLab.attributedText = attStr;
}
- (void)setCellDataWithModel:(TCGoodsDetailModel *)model{
    
    [_goodsImg sd_setImageWithURL:[NSURL URLWithString:model.image_cover_url] placeholderImage:[UIImage imageNamed:@""]];
    
    _titleLab.text = kIsEmptyString(model.good_name) ? @"" : model.good_name;
    CGSize statusLabelSize =[model.good_name sizeWithLabelWidth:kScreenWidth - 40 font:kFontWithSize(15)];
    if (statusLabelSize.height > 15) {
        _titleLab.numberOfLines = 0;
        _titleLab.frame  =CGRectMake( 10,self.goodsImg.bottom + 15, kScreenWidth- 20, 40);
        _integralNumberLab.frame = CGRectMake( _titleLab.left,_titleLab.bottom + 5, kScreenWidth- 20, 40);
        _commodityNumberLab.frame =CGRectMake( _titleLab.left, _integralNumberLab.bottom + 8 ,200, 20);
        _freightLab.frame = CGRectMake( kScreenWidth - 115 ,_commodityNumberLab.top, 100, 20);
    }
    
    NSString *integralStr =[NSString stringWithFormat:@"%@ 积分",kIsEmptyObject(model.change_points) ? @"" :model.change_points];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
    [QLCoreTextManager setAttributedValue:attStr text:@"积分" font:kFontWithSize(15) color:UIColorFromRGB(0x313131)];
    _integralNumberLab.attributedText = attStr;
    _commodityNumberLab.text = [NSString stringWithFormat:@"剩余: %@",kIsEmptyObject(model.good_num) ? @"" : model.good_num];
}

@end
