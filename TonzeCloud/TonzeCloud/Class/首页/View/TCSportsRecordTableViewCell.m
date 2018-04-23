//
//  TCSportsRecordTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSportsRecordTableViewCell.h"

@implementation TCSportsRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithModel:(TCSportRecordModel *)sportModel{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"sports" ofType:@"plist"];
    NSArray *sportsArr=[[NSArray alloc] initWithContentsOfFile:path];
    
    NSString *imgName=nil;
    for (NSDictionary *dict in sportsArr) {
        NSString *sportsName=dict[@"name"];
        if ([sportModel.motion_type isEqualToString:sportsName]) {
            imgName=dict[@"image"];
            break;
        }
    }
    if (!kIsEmptyString(imgName)) {
       self.sportsImageView.image=[UIImage imageNamed:imgName];
    }
    self.sportNameLabel.text=sportModel.motion_type;
    self.sportTimeLabel.text=[NSString stringWithFormat:@"%ld分钟",(long)[sportModel.motion_time integerValue]];
    self.startTimeLabel.text=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:sportModel.motion_bigin_time format:@"HH:mm"];
    self.caloriesLabel.text=[NSString stringWithFormat:@"%@千卡",sportModel.calorie];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
