//
//  TCFoodSearchTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodSearchTableViewCell.h"
#import "QLCoreTextManager.h"

@interface TCFoodSearchTableViewCell (){
    TCFoodAddModel  *foodModel;
}
@end
@implementation TCFoodSearchTableViewCell

-(void)cellDisplayWithFood:(TCFoodAddModel *)model  searchText:(NSString *)searchText{
    foodModel=model;
    
    [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    self.foodNameLabel.text=model.name;
    self.caloryLabel.text=[NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal];
    
    if (!kIsEmptyString(searchText)) {
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.name]];
        [QLCoreTextManager setAttributedValue:attString artlcleText:searchText font:[UIFont systemFontOfSize:15] color:[UIColor redColor]];
        self.foodNameLabel.attributedText = attString;
    }
}
@end
