//
//  TCSuagrHistoryCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSugarModel.h"


@interface TCSuagrHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;

-(void)cellDisplayWithSugar:(TCSugarModel *)model;

@end
