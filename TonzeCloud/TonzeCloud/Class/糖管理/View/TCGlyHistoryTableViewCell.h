//
//  TCGlyHistoryTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGlycosylateModel.h"

@interface TCGlyHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)cellGlycosylateHsitoryModel:(TCGlycosylateModel *)model;

@end
