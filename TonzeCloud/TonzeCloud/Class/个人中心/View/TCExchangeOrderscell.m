//
//  ExchangeOrderscell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeOrderscell.h"

@implementation TCExchangeOrderscell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setExchangeOrderscellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setExchangeOrderscellUI{
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(12,8, 80, 15)];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.font = kFontWithSize(13);
    [self.contentView addSubview:_titleLab];

    _contentLab = [[UILabel alloc]initWithFrame:CGRectMake(_titleLab.right, _titleLab.top, 180, 15)];
    _contentLab.textColor = UIColorFromRGB(0x313131);
    _contentLab.font = kFontWithSize(13);
    _contentLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_contentLab];
}
@end
