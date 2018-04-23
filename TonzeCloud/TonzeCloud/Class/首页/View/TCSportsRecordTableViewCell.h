//
//  TCSportsRecordTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSportRecordModel.h"

@interface TCSportsRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sportsImageView;
@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

-(void)cellDisplayWithModel:(TCSportRecordModel *)sportModel;



@end
