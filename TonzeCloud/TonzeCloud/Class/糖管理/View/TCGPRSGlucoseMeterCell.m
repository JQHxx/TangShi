
//
//  TCGPRSGlucoseMeterCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSGlucoseMeterCell.h"

@interface TCGPRSGlucoseMeterCell()
{
    UILabel *_deviceNameLab;        /// 设备名称
    UILabel *_bloodSugarLevelsLab;  /// 血糖值
    UILabel *_highSideNumLab;        /// 偏高
    UILabel *_lowSideNumLab;         /// 偏低
    UILabel *_normalNumLab;          /// 正常
    UILabel *_testTimeLab;           /// 测试时间
    UILabel *_testRecordsNumLab;     /// 测试次数
    UILabel *_testDataLab;           /// 测试日期
    UIImageView *_timeIcon;          //  时间图标
}
@end

@implementation TCGPRSGlucoseMeterCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *greenVerticalLines = [[UILabel alloc]initWithFrame:CGRectMake(18, (48 - 20)/2 - 3, 5, 20)];
        greenVerticalLines.backgroundColor = kSystemColor;
        [self.contentView addSubview:greenVerticalLines];
        
        _deviceNameLab = [[UILabel alloc]initWithFrame:CGRectMake(greenVerticalLines.right + 5, (40 - 20)/2, kScreenWidth - 50, 20)];
        _deviceNameLab.font = kFontWithSize(15);
        _deviceNameLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView addSubview:_deviceNameLab];
        
        UIButton *managementTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        managementTextBtn.frame = CGRectMake(kScreenWidth - 75, 0, 60, 48);
        [managementTextBtn setTitle:@"管理" forState:UIControlStateNormal];
        [managementTextBtn setTitleColor:UIColorFromRGB(0x959595) forState:UIControlStateNormal];
        managementTextBtn.titleLabel.font = kFontWithSize(15);
        [managementTextBtn setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
        [managementTextBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:10];
        [self.contentView addSubview:managementTextBtn];
        
        UIButton *managementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        managementBtn.frame = CGRectMake(0, 0, kScreenWidth, 48);
        [managementBtn addTarget:self action:@selector(managementBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:managementBtn];
        
        UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(18, 48, kScreenWidth - 36, 0.5)];
        lens.backgroundColor = UIColorFromRGB(0xe5e5e5);
        [self.contentView addSubview:lens];
        
        UILabel *recentlyTestLab = [[UILabel alloc]initWithFrame:CGRectMake(10, lens.bottom + 15, kScreenWidth - 20, 15)];
        recentlyTestLab.textAlignment = NSTextAlignmentCenter;
        recentlyTestLab.font = kFontWithSize(15);
        recentlyTestLab.text = @"最近一次血糖";
        recentlyTestLab.textColor = UIColorFromRGB(0x626262);
        [self.contentView addSubview:recentlyTestLab];
        
        _testDataLab = [[UILabel alloc]initWithFrame:CGRectMake(10, recentlyTestLab.bottom + 5, kScreenWidth - 20, 13)];
        _testDataLab.textAlignment = NSTextAlignmentCenter;
        _testDataLab.font = kFontWithSize(13);
        _testDataLab.textColor = UIColorFromRGB(0x626262);
        [self.contentView addSubview:_testDataLab];
        
        _bloodSugarLevelsLab = [[UILabel alloc]initWithFrame:CGRectMake(30, _testDataLab.bottom + 10 , kScreenWidth - 60, 30)];
        _bloodSugarLevelsLab.textAlignment = NSTextAlignmentCenter;
        _bloodSugarLevelsLab.font = kFontWithSize(24);
        _bloodSugarLevelsLab.textColor = UIColorFromRGB(0x313131);
        [self.contentView addSubview:_bloodSugarLevelsLab];
        
        UILabel *unitLab = [[UILabel alloc]initWithFrame:CGRectMake(30, _bloodSugarLevelsLab.bottom, kScreenWidth - 60, 10)];
        unitLab.text = @"mmol/L";
        unitLab.textAlignment = NSTextAlignmentCenter;
        unitLab.font = kFontWithSize(13);
        unitLab.textColor = UIColorFromRGB(0x939393);
        [self.contentView addSubview:unitLab];
        
        _timeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 20,unitLab.bottom + 5, 14, 14)];
        _timeIcon.image = [UIImage imageNamed:@"xty02_ic_time"];
        [self.contentView addSubview:_timeIcon];
        
        _testTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2 + 40, unitLab.bottom + 5, 200, 15)];
        _testTimeLab.textAlignment = NSTextAlignmentCenter;
        _testTimeLab.font = kFontWithSize(13);
        _testTimeLab.textColor = UIColorFromRGB(0x62626);
        [self.contentView addSubview:_testTimeLab];
        
   
        UILabel *horizontalLine = [[UILabel alloc]initWithFrame:CGRectMake(18, _testTimeLab.bottom + 15, kScreenWidth - 36, 0.5)];
        horizontalLine.backgroundColor = UIColorFromRGB(0xe5e5e5);
        [self.contentView addSubview:horizontalLine];
        
        _testRecordsNumLab = [[UILabel alloc]initWithFrame:CGRectMake(10,horizontalLine.bottom + 15, kScreenWidth - 20, 20)];
        _testRecordsNumLab.textColor = UIColorFromRGB(0x626262);
        _testRecordsNumLab.font = kFontWithSize(15);
        _testRecordsNumLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_testRecordsNumLab];

        UIImageView *hightImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/4 - 15, _testRecordsNumLab.bottom + 10, 30, 30)];
        hightImg.image = [UIImage imageNamed:@"xty02_ic_color_01"];
        [self.contentView addSubview:hightImg];
        
        UIImageView *normalImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 15, hightImg.top ,hightImg.width , hightImg.height)];
        normalImg.image = [UIImage imageNamed:@"xty02_ic_color_02"];
        [self.contentView addSubview:normalImg];
        
        UIImageView *lowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/4 * 3 - 15, hightImg.top, hightImg.width , hightImg.height)];
        lowImg.image = [UIImage imageNamed:@"xty02_ic_color_03"];
        [self.contentView addSubview:lowImg];
        
        _highSideNumLab = [[UILabel alloc]initWithFrame:CGRectMake(0, hightImg.bottom + 5 , kScreenWidth/2, 20)];
        _highSideNumLab.textAlignment = NSTextAlignmentCenter;
        _highSideNumLab.font = kFontWithSize(13);
        _highSideNumLab.textColor = UIColorFromRGB(0x626262);
        [self.contentView addSubview:_highSideNumLab];
        
        _normalNumLab = [[UILabel alloc]initWithFrame:CGRectMake(50, _highSideNumLab.top, kScreenWidth  - 100, 20)];
        _normalNumLab.textAlignment = NSTextAlignmentCenter;
        _normalNumLab.font = kFontWithSize(13);
        _normalNumLab.textColor = UIColorFromRGB(0x626262);
        [self.contentView addSubview:_normalNumLab];
        
        _lowSideNumLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2, _highSideNumLab.top, kScreenWidth/2, 20)];
        _lowSideNumLab.textColor = UIColorFromRGB(0x626262);
        _lowSideNumLab.textAlignment = NSTextAlignmentCenter;
        _lowSideNumLab.font = kFontWithSize(13);
        [self.contentView addSubview:_lowSideNumLab];
        
        UIButton  *checkRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkRecordBtn.frame = CGRectMake((kScreenWidth - 135)/2, _normalNumLab.bottom + 20, 135, 34);
        [checkRecordBtn  setTitle:@"查看记录" forState:UIControlStateNormal];
        [checkRecordBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        checkRecordBtn.titleLabel.font = kFontWithSize(15);
        checkRecordBtn.layer.cornerRadius = 18;
        checkRecordBtn.layer.borderWidth = 1;
        checkRecordBtn.layer.borderColor = UIColorFromRGB(0x666666).CGColor;
        [checkRecordBtn addTarget:self action:@selector(checkRecordBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:checkRecordBtn];
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, 365 - 10, kScreenWidth, 10)];
        len.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:len];
    }
    return self;
}
#pragma mark ====== Setter =======
- (void)setDeviceListModel:(TCGPRSDeviceListModel *)deviceListModel{
    _deviceListModel = deviceListModel;
    
    _deviceNameLab.text = _deviceListModel.device_name;
    
    if (kIsDictionary(_deviceListModel.sugar_data)) {
        _testRecordsNumLab.text = [NSString stringWithFormat:@"共%ld条记录",(long)[[_deviceListModel.sugar_data objectForKey:@"total"] integerValue]];
        _highSideNumLab.text = [NSString stringWithFormat:@"偏高%ld次",(long)[[_deviceListModel.sugar_data objectForKey:@"high_num"] integerValue]];
        _normalNumLab.text = [NSString stringWithFormat:@"正常%ld次",(long)[[_deviceListModel.sugar_data objectForKey:@"normal_num"] integerValue]];
        _lowSideNumLab.text = [NSString stringWithFormat:@"偏低%ld次",(long)[[_deviceListModel.sugar_data objectForKey:@"low_num"] integerValue]];
    }else{
        _testRecordsNumLab.text = @"共0条记录";
        _highSideNumLab.text =@"偏高0次";
        _normalNumLab.text = @"正常0次";
        _lowSideNumLab.text = @"偏低0次";
    }
    
    NSString *time_slot = [_deviceListModel.latest objectForKey:@"time_slot"];
    if (!kIsEmptyString(time_slot)) {
        _bloodSugarLevelsLab.text =[NSString stringWithFormat:@"%@",[_deviceListModel.latest objectForKey:@"glucose"]] ;
        NSArray *colorItems=[NSArray arrayWithObjects:[UIColor colorWithHexString:@"#ffd03e"],[UIColor colorWithHexString:@"#37deba"],[UIColor colorWithHexString:@"#fa6f6e"],nil];
        /// 血糖值状态 0 偏低 1正常 2偏高
        NSInteger state = [[_deviceListModel.latest objectForKey:@"state"] integerValue];
        UIColor *color = colorItems[state];
        _bloodSugarLevelsLab.textColor = color;
        
        NSString *momentStr = [[TCHelper sharedTCHelper]getPeriodChNameForPeriodEn: [_deviceListModel.latest objectForKey:@"time_slot"]];
        NSString *time = [[TCHelper sharedTCHelper]timeWithTimeIntervalString:[_deviceListModel.latest objectForKey:@"measurement_time"] format:@"HH:mm"];
        NSString *timeStr = [NSString stringWithFormat:@"%@%@",momentStr,time];
        CGSize timeSize = [timeStr boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontWithSize(13)];
        
        _timeIcon.frame = CGRectMake(kScreenWidth/2 - (timeSize.width + 14 + 5)/2,_bloodSugarLevelsLab.bottom + 15, 14, 14);
        _testTimeLab.frame = CGRectMake(_timeIcon.right + 5, _timeIcon.top, timeSize.width, timeSize.height);
        
        _testTimeLab.text = timeStr;
        _timeIcon.hidden = NO;
        
        _testDataLab.text =[[TCHelper sharedTCHelper]timeWithTimeIntervalString:[_deviceListModel.latest objectForKey:@"measurement_time"] format:@"yyyy-MM-dd"];
    }else{
        _timeIcon.hidden = YES;
        _bloodSugarLevelsLab.text = @"--";
        _testDataLab.text = @"";
        _testTimeLab.text = @"";
    }
}
#pragma mark ====== 管理设备 =======
- (void)managementBtnAction{
    if ([self.delegate respondsToSelector:@selector(didmanagementOfEquipment:)]) {
        [self.delegate didmanagementOfEquipment:self];
    }
}
#pragma mark ====== 查看历史记录 =======
- (void)checkRecordBtnAction{
    if ([self.delegate respondsToSelector:@selector(didcheckTheRecord:)]) {
        [self.delegate didcheckTheRecord:self];
    }
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
