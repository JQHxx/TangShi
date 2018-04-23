//
//  TCFoodTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodAddModel.h"

@protocol TCFoodTableViewCellDelegate <NSObject>

@optional
-(void)foodTableViewCellDeleteFood:(TCFoodAddModel *)food;

@end

@interface TCFoodTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloryLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodWeightLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property (nonatomic,assign)NSInteger cellType;
@property (nonatomic,weak)id<TCFoodTableViewCellDelegate>cellDelegate;

-(void)cellDisplayWithFood:(TCFoodAddModel *)model searchText:(NSString *)searchText;

@end
