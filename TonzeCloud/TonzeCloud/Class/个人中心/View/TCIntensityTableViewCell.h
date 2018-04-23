//
//  TCIntensityTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLaborModel.h"

@interface TCIntensityTableViewCell : UITableViewCell

-(void)cellDisplayWithLabor:(TCLaborModel *)model;

+(CGFloat)getCellHeightWithLabor:(TCLaborModel *)model;


@end
