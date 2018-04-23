
//
//  IntegralMallCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCIntegralMallCell.h"
#import "QLCoreTextManager.h"

@interface TCIntegralMallCell ()

@property (nonatomic ,strong) UIButton *statusBtn;
@end
@implementation TCIntegralMallCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setIntegralViewCell];
    }
    return self;
}
#pragma mark ==== set UI ====

- (void)setIntegralViewCell{
    
    _commodityImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 175 * kScreenWidth/375)];
    [self addSubview:_commodityImg];
    
    _productTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, _commodityImg.bottom + 8, _commodityImg.width - 40, 15)];
    _productTitleLab.textAlignment = NSTextAlignmentLeft;
    _productTitleLab.font = kFontWithSize(12);
    _productTitleLab.textColor = UIColorFromRGB(0x313131);
    [self addSubview:_productTitleLab];
    
    _IntegralLab = [[UILabel alloc]initWithFrame:CGRectMake(_productTitleLab.left, _productTitleLab.bottom + 5, _commodityImg.width  - 20, 15)];
    _IntegralLab.textColor = UIColorFromRGB(0xf9c92b);
    _IntegralLab.font = kFontWithSize(12);
    [self addSubview:_IntegralLab];
    
    _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _statusBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 67, CGRectGetHeight(self.frame) - 25 , 47, 17);
    [_statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _statusBtn.titleLabel.font = kFontWithSize(10);
    _statusBtn.backgroundColor = UIColorFromRGB(0xBFBFBF);
    [self addSubview:_statusBtn];
    _statusBtn.layer.cornerRadius = 8;
    _statusBtn.hidden = YES;
}
- (void)cellWithGoodsListModel:(TCGoodsListModel *)model{
    [_commodityImg sd_setImageWithURL:[NSURL URLWithString:model.image_cover_url] placeholderImage:[UIImage imageNamed:@"goods_background"]];
    _productTitleLab.text = model.good_name;
    
    NSString  *integralStr = [NSString stringWithFormat:@"%@ 积分",model.change_points];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
    [QLCoreTextManager setAttributedValue:attStr text:@"积分" font:kFontWithSize(12) color:UIColorFromRGB(0x313131)];
    _IntegralLab.attributedText = attStr;

    if ([model.status integerValue] == 2) {
        _statusBtn.hidden = NO;
        [_statusBtn setTitle:@"已兑完" forState:UIControlStateNormal];
    }else if ([model.status integerValue] == 3){
        _statusBtn.hidden = NO;
        [_statusBtn setTitle:@"已结束" forState:UIControlStateNormal];
    }else{
        _statusBtn.hidden = YES;
    }
}

@end
