//
//  TCCouponCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/4/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCMallCouponCell.h"

@interface  TCMallCouponCell()
{
    UILabel *_couponNameLab;        // 优惠券名称
    UILabel *_validityPeriodLab;    // 有效期
    UILabel *_priceLab;             // 价格
    UILabel *_priceRangeLab;        // 适用范围
    UIImageView *_selectIcon;       // 选中图标
}
@end

@implementation TCMallCouponCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor bgColor_Gray];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 100*kScreenWidth/320)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        UIImageView *iconImg = [[UIImageView alloc]init];
        iconImg.frame = CGRectMake(0, 0 ,bgView.width, 40 * kScreenWidth/320);
        iconImg.backgroundColor = kSystemColor;
        [bgView addSubview:iconImg];
        
        // 优惠券名称
        _couponNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 , iconImg.width - 10, 20)];
        _couponNameLab.textColor = UIColorHex(0xffffff);
        _couponNameLab.font = kFontWithSize(15);
        _couponNameLab.text = @"商城优惠券名称";
        [iconImg addSubview:_couponNameLab];
        
        // 适用时间
        _validityPeriodLab = [[UILabel alloc]initWithFrame:CGRectMake(_couponNameLab.left, iconImg.bottom + 10 , iconImg.width - 10, 40)];
        _validityPeriodLab.textColor = UIColorHex(0x959595);
        _validityPeriodLab.font = kFontWithSize(12);
        _validityPeriodLab.numberOfLines = 0;
        _validityPeriodLab.text = @"有效期：\n2017-08-01 00:00 ~ 2018-08-01 00:00";
        [bgView addSubview:_validityPeriodLab];
        
        _selectIcon = [[UIImageView alloc]initWithFrame:CGRectMake(iconImg.width - 30, (iconImg.height - 15)/2, 15, 15)];
        _selectIcon.image = [UIImage imageNamed:@"ic_eqment_pick_on"];
        _selectIcon.hidden = YES;
        [iconImg addSubview:_selectIcon];
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
