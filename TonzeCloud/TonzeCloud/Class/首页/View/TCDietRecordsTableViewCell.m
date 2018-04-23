//
//  TCDietRecordsTableViewCell.m
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDietRecordsTableViewCell.h"

@implementation TCDietRecordsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



-(void)cellDisplayWithFoodDict:(NSDictionary *)foodDict{
    [self.foodsImageView sd_setImageWithURL:[NSURL URLWithString:foodDict[@"image_url"]] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    self.foodNameLabel.text=foodDict[@"ingredient_name"];
    
    NSInteger weight=[foodDict[@"ingredient_weight"] integerValue];
    self.foodsWeightLabel.text=[NSString stringWithFormat:@"%ld克",(long)weight];
    
    NSInteger calories=[foodDict[@"ingredient_calories"] integerValue];
    self.foodEnergyLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)calories];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
