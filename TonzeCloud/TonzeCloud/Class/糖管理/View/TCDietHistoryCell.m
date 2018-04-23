//
//  TCDietHistoryCell.m
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDietHistoryCell.h"

@implementation TCDietHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithModel:(TCFoodRecordModel *)diet{
    NSString *dietTime=[[TCHelper sharedTCHelper] getDietPeriodChNameWithPeriod:diet.time_slot];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"dietTime" ofType:@"plist"];
    NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:path];
    self.dietImageView.image=[UIImage imageNamed:dict[diet.time_slot]];
    self.dietTimeLabel.text=dietTime;
    
    NSArray *foodsArr=diet.ingredient;
    NSInteger total_energy=0;
    for (NSDictionary *dict in foodsArr) {
        total_energy+=[dict[@"ingredient_calories"] integerValue];
    }
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)total_energy]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(0, attributeStr.length-2)];
    self.caloryLabel.attributedText=attributeStr;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
