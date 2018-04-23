//
//  TCGlyHistoryTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGlyHistoryTableViewCell.h"

@implementation TCGlyHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)cellGlycosylateHsitoryModel:(TCGlycosylateModel *)model{

    _headImg.image = [UIImage imageNamed:@"ic_record_img_xuehong"];
    _contentLabel.text = [NSString stringWithFormat:@"%.1f％",model.measure_value];
    _timeLabel.text = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measure_time format:@"HH:mm"];
}

@end
