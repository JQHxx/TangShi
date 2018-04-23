//
//  TCFoodDetailTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodModel.h"
@interface TCFoodDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *GILabel;         //gi指数
 @property (weak, nonatomic) IBOutlet UILabel *parameterLabel;  //成分
@property (weak, nonatomic) IBOutlet UIImageView *foodImg;

@property (weak, nonatomic) IBOutlet UILabel *foodName;

@property (weak, nonatomic) IBOutlet UILabel *foodEnergy;
-(void)cellDisplayWithDict:(TCFoodModel *)classModel;

@end
