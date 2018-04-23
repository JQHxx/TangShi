//
//  TCDietHistoryCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodRecordModel.h"

@interface TCDietHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dietImageView;
@property (weak, nonatomic) IBOutlet UILabel *dietTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloryLabel;

-(void)cellDisplayWithModel:(TCFoodRecordModel *)diet;

@end
