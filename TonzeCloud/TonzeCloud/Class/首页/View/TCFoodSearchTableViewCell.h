//
//  TCFoodSearchTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodAddModel.h"

@interface TCFoodSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloryLabel;

-(void)cellDisplayWithFood:(TCFoodAddModel *)model  searchText:(NSString *)searchText;
@end
