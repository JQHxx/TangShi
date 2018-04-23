//
//  TCBloodHistoryCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBloodHistoryCell.h"

@implementation TCBloodHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)cellBloodHsitoryModel:(TCBloodModel *)model{
    _headImg.image = [UIImage imageNamed:model.way==1?@"ic_record_img_xueya":@"ic_record_img_xueya"];
    _contentLabel.text = [NSString stringWithFormat:@"%ld/%ldmmHg",model.systolic_pressure,model.diastolic_pressure];
    _timeLabel.text = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"HH:mm"];
}

@end
