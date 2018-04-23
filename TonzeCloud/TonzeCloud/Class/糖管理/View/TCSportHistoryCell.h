//
//  TCSportHistoryCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSportRecordModel.h"

@interface TCSportHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sportImageView;
@property (weak, nonatomic) IBOutlet UILabel *sportTypelabel;
@property (weak, nonatomic) IBOutlet UILabel *sportTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportCaloryLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

-(void)cellDisplayWithModel:(TCSportRecordModel *)sport;


@end
