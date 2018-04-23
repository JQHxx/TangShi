
//
//  TCGPRSRecordsCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSRecordsCell.h"
#import "QLCoreTextManager.h"

@implementation TCGPRSRecordsCell

- (void)cellDisplayWithRecord:(TCGPRSRecordsModel *)model{
    
    NSArray *colorItems=[NSArray arrayWithObjects:[UIColor colorWithHexString:@"#ffd03e"],[UIColor colorWithHexString:@"#37deba"],[UIColor colorWithHexString:@"#fa6f6e"],nil];
    
    UIColor *color = colorItems[model.state];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ mmol/L",model.glucose]];
    [QLCoreTextManager setAttributedValue:attString artlcleText:model.glucose font:[UIFont systemFontOfSize:15] color:color];
     self.bloodSugarLevelsLab.attributedText = attString;
    
    
    NSString *timeStr = [[TCHelper sharedTCHelper]timeWithTimeIntervalString:model.measurement_time format: @"HH:mm"];
    NSString *timeSlotStr = [[TCHelper sharedTCHelper]getPeriodChNameForPeriodEn:model.time_slot];
    NSMutableAttributedString *timeAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",timeSlotStr,timeStr]];
    [QLCoreTextManager setAttributedValue:attString artlcleText:timeStr font:[UIFont systemFontOfSize:13] color:UIColorFromRGB(0x626262)];
     self.timeLab.attributedText = timeAttString;

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
