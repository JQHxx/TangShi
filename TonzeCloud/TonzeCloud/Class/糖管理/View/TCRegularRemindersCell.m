//
//  TCRegularRemindersCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRegularRemindersCell.h"

@implementation TCRegularRemindersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        [self setRegularRemindersCell];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setRegularRemindersCell{
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(18, 5, 150, 20)];
    _timeLab.textColor = UIColorFromRGB(0x313131);
    _timeLab.textAlignment = NSTextAlignmentLeft;
    _timeLab.font = kFontWithSize(18);
    [self.contentView addSubview:_timeLab];

    _weekLab = [[UILabel alloc]initWithFrame:CGRectMake(18, _timeLab.bottom + 5, kScreenWidth - 120, 20)];
    _weekLab.textColor = UIColorFromRGB(0x959595);
    _weekLab.textAlignment = NSTextAlignmentLeft;
    _weekLab.font = kFontWithSize(13);
    [self.contentView addSubview:_weekLab];

    _switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth - 70, (60 - 30)/2, 40, 30)];
    [_switchBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switchBtn];
}
#pragma mark ====== Action =======

- (void)switchClick{
    if (self.switchTypeBlock) {
        self.switchTypeBlock(YES);
    }
}
#pragma mark ====== Set Data =======

- (void)loadRegularRemindersCellData:(TCRegularRemindersModel *)model{
    NSString *hourStr;
    NSString *minuteStr;
    if (model.hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%ld",(long)model.hour];
    }else{
        hourStr = [NSString stringWithFormat:@"%ld",(long)model.hour];
    }
    
    if( model.minute < 10){
        minuteStr = [NSString stringWithFormat:@"0%ld",(long)model.minute];
    }else{

        minuteStr = [NSString stringWithFormat:@"%ld",(long)model.minute];
    }
    _timeLab.text = [NSString stringWithFormat:@"%@:%@",hourStr,minuteStr];
    if (kIsEmptyString([self timeShowWitnRepeatimeStr:model.repeat_type])) {
        _weekLab.text = [NSString stringWithFormat:@"%@",model.reminder_type];
    }else{
        _weekLab.text = [NSString stringWithFormat:@"%@,  %@",model.reminder_type,[self timeShowWitnRepeatimeStr:model.repeat_type]];
    }
    if (model.status == 1) {
        [_switchBtn setOn:YES];
    }else{
        [_switchBtn setOn:NO];
    }
}
#pragma mark ====== 时间处理 =======
- (NSString *)timeShowWitnRepeatimeStr:(NSString *)timeStr{
    NSString *weakDayStr;
    if ([timeStr isEqualToString:@"周一 周二 周三 周四 周五"]) {
        weakDayStr = @"工作日";
    }else if ([timeStr isEqualToString:@"周一 周二 周三 周四 周五 周六 周日"]){
        weakDayStr = @"每天";
    }else if ([timeStr isEqualToString:@"从不"]){
        weakDayStr = @"";
    }else{
        weakDayStr = timeStr;
    }
    return weakDayStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
