//
//  TCFoodClassTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodClassTableViewCell.h"

@implementation TCFoodClassTableViewCell
-(void)cellDisplayWithDict:(TCFoodModel *)classModel type:(NSInteger)type{
    
    NSString *imgUrl = classModel.image_url;
    [_foodClassImg sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    _foodName.text = classModel.name;
    
    if (type==0) {
        _foodValue.text = [NSString stringWithFormat:@"%ld千卡/100克",(long)classModel.energykcal];
    }else{
       _foodValue.text = [NSString stringWithFormat:@"%.1fGI/100克",[classModel.gi floatValue]];
    }
    
    _foodValue.textColor = [UIColor grayColor];
    NSInteger titleLength = _foodValue.text.length;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_foodValue.text];
    NSRange r1 = NSMakeRange(0, titleLength-7);
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r1];
    [_foodValue setAttributedText:attributedString];

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
