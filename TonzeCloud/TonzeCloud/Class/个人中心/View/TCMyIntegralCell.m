
//
//  MyIntegralCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCMyIntegralCell.h"

@interface TCMyIntegralCell ()
{
    UIImageView *_iconImg;
}
@end

@implementation TCMyIntegralCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setMyIntegralCellUI];
    }
    return self;
}
#pragma mark ====== Set UI =======

- (void)setMyIntegralCellUI{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 8, 180, 20)];
    _titleLab.font = kFontWithSize(15);
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLab];

    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(_titleLab.left, _titleLab.bottom + 5, 180, 15)];
    _timeLab.textAlignment = NSTextAlignmentLeft;
    _timeLab.font = kFontWithSize(11);
    _timeLab.textColor = UIColorFromRGB(0x959595);
    [self.contentView addSubview:_timeLab];
    
    _integralNumberLab =[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 120,(CGRectGetHeight(self.frame)- 35)/2 , 100, 35)];
    _integralNumberLab.font = kFontWithSize(25);
    _integralNumberLab.textColor = UIColorFromRGB(0xf9c92b);
    _integralNumberLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_integralNumberLab];
    
    _iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth -100 ,(60 - 15)/2 , 15, 15)];
    [self.contentView addSubview:_iconImg];
}
- (void)setCellModel:(TCUserIntegralModel *)model{
    _titleLab.text = model.action_name;
    _timeLab.text = model.time;
    
    NSString *textStr = [NSString stringWithFormat:@"+%@",model.use_points];
    CGSize integralTextSize = [textStr boundingRectWithSize:CGSizeMake(200, 25) withTextFont:kFontWithSize(25)];
   
    _integralNumberLab.frame = CGRectMake(kScreenWidth - integralTextSize.width - 20, 35/2 , integralTextSize.width, 25);
    _iconImg.frame = CGRectMake(kScreenWidth - integralTextSize.width - 40 , 45/2, 15, 15);
    
    if ([model.use_type integerValue] == 1) {
        _integralNumberLab.textColor = UIColorFromRGB(0xf9c92b);
        _integralNumberLab.text = [NSString stringWithFormat:@"+%@",model.use_points];
        _iconImg.image = [UIImage imageNamed:@"yellow_integral"];
    }else{
        _integralNumberLab.text = [NSString stringWithFormat:@"-%@",model.use_points];
        _integralNumberLab.textColor = kSystemColor;
        _iconImg.image = [UIImage imageNamed:@"green_integral"];
    }
}
@end
