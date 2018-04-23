//
//  TCExamteHistoryCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCExaminationModel.h"

@interface TCExamteHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)cellExamteHsitoryModel:(TCExaminationModel *)model;
@end
