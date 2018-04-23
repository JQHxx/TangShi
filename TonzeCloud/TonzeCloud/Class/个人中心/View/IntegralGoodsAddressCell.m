//
//  IntegralGoodsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/6.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "IntegralGoodsAddressCell.h"

@implementation IntegralGoodsAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        [self setIntegralGoodsCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setIntegralGoodsCellUI{

    _nameLab = [[UILabel alloc]initWithFrame:CGRectMake( 20, (38 - 20)/2, kScreenWidth - 180, 20)];
    _nameLab.textColor = UIColorFromRGB(0x313131);
    _nameLab.font = kFontWithSize(15);
    _nameLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLab];
    
    _phoneNumberLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 145 , _nameLab.top, 100, 20)];
    _phoneNumberLab.textAlignment = NSTextAlignmentRight;
    _phoneNumberLab.font = kFontWithSize(13);
    _phoneNumberLab.textColor = UIColorFromRGB(0x959595);
    _phoneNumberLab.text = @"您还未填写";
    [self.contentView addSubview:_phoneNumberLab];
    
    _addressInfoLab = [[UILabel alloc]initWithFrame:CGRectMake( 95, _nameLab.bottom + 5, kScreenWidth - 130, 35)];
    _addressInfoLab.font = kFontWithSize(13);
    _addressInfoLab.numberOfLines = 0;
    _addressInfoLab.textColor = UIColorFromRGB(0x959595);
    _addressInfoLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_addressInfoLab];
    

    _arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (38 - 15)/2 , 15, 15)];
    _arrowImg.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
    [self.contentView addSubview:_arrowImg];
}
@end
