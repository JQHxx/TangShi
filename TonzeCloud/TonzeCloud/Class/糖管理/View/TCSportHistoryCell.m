//
//  TCSportHistoryCell.m
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSportHistoryCell.h"

@implementation TCSportHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithModel:(TCSportRecordModel *)sport{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"sports" ofType:@"plist"];
    NSArray *sportsArr=[[NSArray alloc] initWithContentsOfFile:path];
    
    NSString *imgName=nil;
    for (NSDictionary *dict in sportsArr) {
        NSString *sportsName=dict[@"name"];
        if ([sport.motion_type isEqualToString:sportsName]) {
            imgName=dict[@"image"];
            break;
        }
    }
    if (!kIsEmptyString(imgName)) {
        self.sportImageView.image=[UIImage imageNamed:imgName];
    }
    self.sportTypelabel.text=sport.motion_type;
    
    NSString *valueStr=[NSString stringWithFormat:@"%ld分钟",(long)[sport.motion_time integerValue]];
    self.startTimeLabel.hidden=NO;
    
    NSString *startTime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:sport.motion_bigin_time format:@"HH:mm"];
    self.startTimeLabel.text=kIsEmptyString(startTime)?@"":startTime;
    
    self.sportCaloryLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)[sport.calorie integerValue]];
    self.sportTimeLabel.text=valueStr;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
