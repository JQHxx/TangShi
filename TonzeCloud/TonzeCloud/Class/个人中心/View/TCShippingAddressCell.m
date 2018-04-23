

//
//  ShippingAddressCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCShippingAddressCell.h"

@interface TCShippingAddressCell ()<UITextFieldDelegate>

@end
@implementation TCShippingAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setShippingAddressCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======

- (void)setShippingAddressCellUI{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake( 20, (48- 15)/2, 80, 15)];
    _titleLab.font = kFontWithSize(15);
    _titleLab.textColor = UIColorFromRGB(0x313131);
    _titleLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLab];
    
    _contentTF =[[UITextField alloc]initWithFrame:CGRectMake(100, (48- 20)/2, kScreenWidth - _titleLab.right - 35, 20)];
    _contentTF.textAlignment =NSTextAlignmentLeft;
    _contentTF.borderStyle = UITextBorderStyleNone;
    _contentTF.backgroundColor = [UIColor whiteColor];
    _contentTF.textColor = UIColorFromRGB(0x313131);
    _contentTF.font = kFontWithSize(15);
    _contentTF.adjustsFontSizeToFitWidth = YES;
    _contentTF.clearButtonMode = YES;
    _contentTF.inputAccessoryView = [[UIView alloc] init];
    [_contentTF addTarget:self action:@selector(textfieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_contentTF];
    
    _arrowImg =[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (44 - 15)/2 , 15, 15)];
    _arrowImg.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
    [self.contentView addSubview:_arrowImg];
                
    _arrowImg.hidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.contentTF becomeFirstResponder];
}

#pragma mark - private method
- (void)textfieldTextDidChange:(UITextField *)textField
{
//    self.block(self.contentTF.text);
}

@end
