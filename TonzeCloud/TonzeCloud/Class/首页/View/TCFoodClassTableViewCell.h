//
//  TCFoodClassTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodModel.h"

@interface TCFoodClassTableViewCell : UITableViewCell


-(void)cellDisplayWithDict:(TCFoodModel *)classModel type:(NSInteger)type;


@property (weak, nonatomic) IBOutlet UIImageView *foodClassImg;
@property (weak, nonatomic) IBOutlet UILabel *foodName;
@property (weak, nonatomic) IBOutlet UILabel *foodValue;

@end
