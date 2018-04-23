//
//  MyIntegralDetailCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCMyIntegralDetailCell.h"

@implementation TCMyIntegralDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
        _titleLab.font = kFontWithSize(13);
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.textColor = UIColorFromRGB(0x959595);
        [self.contentView addSubview:_titleLab];
        
        _detailLab =[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 200, _titleLab.top, 180, 20)];
        _detailLab.font = kFontWithSize(13);
        _detailLab.textAlignment = NSTextAlignmentRight;
        _detailLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView addSubview:_detailLab];
    }
    return self;
}


@end
