//
//  TCFoodAddTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodAddModel.h"

@interface TCFoodAddTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodColaryLabel;

-(void)cellDisplayWithFood:(TCFoodAddModel *)foodAddModel;

@end
