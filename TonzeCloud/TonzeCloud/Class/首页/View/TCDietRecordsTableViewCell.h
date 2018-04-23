//
//  TCDietRecordsTableViewCell.h
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDietRecordsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodsWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodEnergyLabel;


-(void)cellDisplayWithFoodDict:(NSDictionary *)foodDict;

@end
