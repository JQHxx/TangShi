//
//  TCCouponCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/4/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCServiceCouponCell.h"

@interface TCServiceCouponCell()
{
    UILabel *_couponNameLab;        // 优惠券名称
    UILabel *_validityPeriodLab;    // 有效期
    UILabel *_applianceLab;         // 适用
    UILabel *_priceLab;             // 价格
    UILabel *_priceRangeLab;        // 适用范围
    UIImageView *_selectIcon;       // 选中图标
}
@end

@implementation TCServiceCouponCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor bgColor_Gray];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 100 *kScreenWidth/320)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        UIImageView *iconImg = [[UIImageView alloc]init];
        iconImg.frame = CGRectMake(0, 0 , bgView.height, bgView.height);
        iconImg.backgroundColor = kSystemColor;
        [bgView addSubview:iconImg];
        
        // 价值
        _priceLab = [[UILabel alloc]initWithFrame:CGRectMake(0, (iconImg.height - 50)/2, iconImg.width, 30)];
        _priceLab.textAlignment = NSTextAlignmentCenter;
        _priceLab.textColor = UIColorHex(0xffffff);
        _priceLab.font = kFontWithSize(20);
        _priceLab.text = @"¥100";
        [iconImg addSubview:_priceLab];
        
        // 适用价格范围
        _priceRangeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _priceLab.bottom , iconImg.width, 20)];
        _priceRangeLab.textAlignment = NSTextAlignmentCenter;
        _priceRangeLab.textColor = UIColorHex(0xffffff);
        _priceRangeLab.font = kFontWithSize(12);
        _priceRangeLab.text = @"满200元可用";
        [iconImg addSubview:_priceRangeLab];
        
        // 优惠券名称
        _couponNameLab = [[UILabel alloc]initWithFrame:CGRectMake(iconImg.right + 5, 5 , kScreenWidth - iconImg.right - 10, 40)];
        _couponNameLab.textColor = UIColorHex(0x626262);
        _couponNameLab.font = kFontWithSize(15);
        _couponNameLab.numberOfLines = 0;
        _couponNameLab.text = @"优惠券名称（适配换行)";
        [bgView addSubview:_couponNameLab];
        
        // 适用
        _applianceLab = [[UILabel alloc]initWithFrame:CGRectMake(_couponNameLab.left, _couponNameLab.bottom + 5 , kScreenWidth - iconImg.right - 40, 20)];
        _applianceLab.textColor = UIColorHex(0x626262);
        _applianceLab.font = kFontWithSize(12);
        _applianceLab.text = @"适用：全部服务-专家姓名";
        [bgView addSubview:_applianceLab];
        
        // 适用时间
        _validityPeriodLab = [[UILabel alloc]initWithFrame:CGRectMake(_couponNameLab.left, _applianceLab.bottom + 5, kScreenWidth - iconImg.right - 40, 20)];
        _validityPeriodLab.textColor = UIColorHex(0x959595);
        _validityPeriodLab.font = kFontWithSize(12);
        _validityPeriodLab.text = @"2017-08-01~2018-08-01";
        [bgView addSubview:_validityPeriodLab];
        
        _selectIcon = [[UIImageView alloc]initWithFrame:CGRectMake(bgView.width - 30, (bgView.height - 15)/2, 15, 15)];
        _selectIcon.image = [UIImage imageNamed:@"ic_eqment_pick_un"];
        _selectIcon.hidden = YES;
        [bgView addSubview:_selectIcon];
    }
    return self;
}
#pragma mark ====== Setter =======

- (void)setIsShowSelectIcon:(BOOL)isShowSelectIcon{
    if (isShowSelectIcon) {
        _selectIcon.hidden = NO;
    }else{
        _selectIcon.hidden = YES;
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
