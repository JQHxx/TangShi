//
//  TCFoodCollectionViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodCollectionViewCell.h"

@implementation TCFoodCollectionViewCell
-(void)cellDisplayWithDict:(TCFoodClassModel *)classModel{
    
    NSString *url = [NSString stringWithFormat:@"%@",classModel.image_url];
    [_foodImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    _foodImage.layer.cornerRadius = _foodImage.frame.size.width/2;
    
    _classLabel.text = classModel.name;
    _classLabel.font = [UIFont systemFontOfSize:12];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
