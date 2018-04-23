//
//  TCMyFriendTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyFriendTableViewCell.h"
#import "TCWeekRecordView.h"
#import "TCSugarModel.h"

@interface TCMyFriendTableViewCell (){
    
    UIImageView      *headImg;
    UILabel          *nickName;
    UIImageView      *sexImg;
    UILabel          *timeLabel;
    UIImageView      *imgView;
}
@property (nonatomic,strong)TCWeekRecordView *weekRecordView;
@end
@implementation TCMyFriendTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
        headImg.layer.cornerRadius = 24;
        headImg.clipsToBounds=YES;
        [self addSubview:headImg];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, headImg.top, kScreenWidth-headImg.right, 20)];
        nickName.font = [UIFont systemFontOfSize:15];
        [self addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, nickName.top, 20, 20)];
        sexImg.layer.cornerRadius =10;
        [self addSubview:sexImg];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, nickName.bottom+5, kScreenWidth-headImg.right, 20)];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font =[UIFont systemFontOfSize:13];
        [self addSubview:timeLabel];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.right, timeLabel.top+5, 10, 10)];
        imgView.layer.cornerRadius =5;
        imgView.backgroundColor = [UIColor redColor];
        [self addSubview:imgView];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 0.5)];
        lineLabel.backgroundColor = kLineColor;
        [self addSubview:lineLabel];
        
        [self addSubview:self.weekRecordView];
        self.weekRecordView.weekRecordsDict=[[NSDictionary alloc] init];
        self.weekRecordView.titleLbl.text = @"最近一周血糖";
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _weekRecordView.bottom+5, kScreenWidth, 20)];
        bgView.backgroundColor = [UIColor bgColor_Gray];
        [self addSubview:bgView];
        
    }
    return self;
}
- (void)cellMyFriendData:(TCMyFriendModel *)model{
    [headImg sd_setImageWithURL:[NSURL URLWithString:[model.family_info objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text =model.call.length>0?model.call:[model.family_info objectForKey:@"nick_name"];
    CGSize  sexSize = [nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickName.frame = CGRectMake(headImg.right+10, headImg.top, sexSize.width, 20);
    
    sexImg.frame = CGRectMake(nickName.right, nickName.top-5, 30 , 30);
    NSInteger sex=[[model.family_info objectForKey:@"sex"] integerValue];
    if (sex<3&&sex>0) {
        sexImg.image =[UIImage imageNamed: [[model.family_info objectForKey:@"sex"] integerValue]==1?@"ic_m_male":@"ic_m_famale"];
    }
    
    NSString *last_time = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:[model.family_info objectForKey:@"last_time"] format:@"yyyy-MM-dd HH:mm"];
    timeLabel.text =[last_time isEqualToString:@"1970-01-01 08:00"]?@"":[NSString stringWithFormat:@"最后更新：%@",last_time];
    CGSize size =  [timeLabel.text sizeWithLabelWidth:200 font:[UIFont systemFontOfSize:13]];
    timeLabel.frame = CGRectMake(headImg.right+10, nickName.bottom+5, size.width+10, 20);
    
    imgView.frame = CGRectMake(timeLabel.right, timeLabel.top+5, 10, 10);
    imgView.hidden = model.is_read==0?NO:YES;
    
    
    NSDictionary *result=model.blood_glucose_info;
    if (result.count>0) {
        NSArray *timeArr=[result allKeys];
        
        NSInteger highCount=0;
        NSInteger normalCount=0;
        NSInteger lowCount=0;
        NSString *startTime = [[TCHelper sharedTCHelper] getLastWeekDateWithDays:6];
        NSString *endTime = [[TCHelper sharedTCHelper] getCurrentDate];
        NSMutableArray *dateTempArr=[[TCHelper sharedTCHelper] getDateFromStartDate:startTime toEndDate:endTime format:@"yyyy-MM-dd"];
        for (NSInteger i=0; i<dateTempArr.count; i++) {
            //日期转换（M/d->yyyy-MM-dd）
            NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dateTempArr[i] format:@"yyyy-MM-dd"];
            NSString *atime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"yyyy-MM-dd"];
          NSArray *periodEnArray=[TCHelper sharedTCHelper].sugarPeriodEnArr;

            for (NSInteger j=0; j<periodEnArray.count; j++) {
                double value=0.0;
                NSString *periodEnStr=periodEnArray[j];
                for (NSString *timeStr in timeArr) {
                    if ([atime isEqualToString:timeStr]) {
                        NSArray *periodArr=[TCHelper sharedTCHelper].sugarPeriodArr;
                        NSString *period=periodArr[j];
                        NSDictionary *limitDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:period];
                        double maxValue=[limitDict[@"max"] doubleValue];
                        double minValue=[limitDict[@"min"] doubleValue];
                        
                        NSArray *list=[result valueForKey:timeStr];     //获取对应日期的血糖记录
                        for (NSDictionary *dict in list) {
                            TCSugarModel *sugar=[[TCSugarModel alloc] init];
                            [sugar setValues:dict];
                            NSString *dataTime = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:sugar.measurement_time format:@"yyyy-MM-dd HH:mm"];
                            NSString *hour = [dataTime substringWithRange:NSMakeRange(11, 2)];
                            NSString *min = [dataTime substringWithRange:NSMakeRange(14, 2)];
                            NSString *periodCh=[[TCHelper sharedTCHelper] getInPeriodOfHour:[hour integerValue] minute:[min integerValue]];
                            if ([[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodCh] isEqualToString:periodEnStr]) {   //计算相应时间段的血糖值
                                value=[sugar.glucose doubleValue];
                                
                                if (value>0.01) {
                                    if (value<minValue) {
                                        lowCount++;
                                    }else if (value>maxValue) {
                                        highCount++;
                                    }else{
                                        normalCount++;
                                    }
                                }
                            }
                        }
                    }
                }
        }
        
        //血糖分析表
        self.weekRecordView.titleLbl.text = @"最近一周血糖";
        self.weekRecordView.weekRecordsDict=@{@"high":[NSNumber numberWithInteger:highCount],
                                              @"normal":[NSNumber numberWithInteger:normalCount],
                                              @"low":[NSNumber numberWithInteger:lowCount]};
        }
    }
}
#pragma mark 血糖数据统计
-(TCWeekRecordView *)weekRecordView{
    if (_weekRecordView==nil) {
        _weekRecordView=[[TCWeekRecordView alloc] initWithFrame:CGRectMake(0, 60.5, kScreenWidth, 120)];
    }
    return _weekRecordView;
}
@end
