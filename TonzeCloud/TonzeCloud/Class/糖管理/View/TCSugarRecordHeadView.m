//
//  TCSugarRecordHeadView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarRecordHeadView.h"
#import "TCManagerRecordButton.h"
#import "TCDietRecordButton.h"
@interface TCSugarRecordHeadView (){

    TCDietRecordButton *seletedRecord;
    TCManagerRecordButton       *addRecord;
}

@end
@implementation TCSugarRecordHeadView

- (instancetype)initWithFrame:(CGRect)frame leftDict:(NSDictionary *)leftDict rightDict:(NSDictionary *)rightDict{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        seletedRecord = [[TCDietRecordButton alloc] initWithFrame:CGRectMake(0, 0, width-54, 70) dict:leftDict];
        seletedRecord.num = self.num;
        [seletedRecord addTarget:self action:@selector(seletedRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:seletedRecord];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(seletedRecord.right, 10, 1, 50)];
        lineLabel.backgroundColor = [UIColor bgColor_Gray];
        [self addSubview:lineLabel];
        
        addRecord = [[TCManagerRecordButton alloc] initWithFrame:CGRectMake(lineLabel.right, 0, 54, 70) dictManager:rightDict bgColor:[UIColor whiteColor]];
        [addRecord addTarget:self action:@selector(addRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addRecord];
    }
    return self;
}

- (void)seletedRecord{
    if ([_delegate respondsToSelector:@selector(TCSugarRecordForIndex:)]) {
        [_delegate TCSugarRecordForIndex:self.type];
    }
}

- (void)addRecord{
    if ([_delegate respondsToSelector:@selector(TCAddRecordForIndex:)]) {
        [_delegate TCAddRecordForIndex:self.type];
    }
}
- (void)setData:(NSDictionary *)data{
    _data = data;
    
    if (self.type==4) {
        NSInteger scount=[[NSUserDefaultsInfos getValueforKey:@"kTargetStepCount"] integerValue];
        NSString *currentDate=[[TCHelper sharedTCHelper] getCurrentDate];
        NSInteger targetStepCount=scount<1000?6000:scount;
        seletedRecord.timeLabel.text = currentDate;
        seletedRecord.detailLabel.text = _data[@"detail"];
        if (self.num>0) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_data[@"detail"]];
            NSRange r1 = NSMakeRange(0, self.num);
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r1];
            [seletedRecord.detailLabel setAttributedText:attributedString];
        }
        if ([data[@"detail"] integerValue]<targetStepCount) {
            addRecord.titleLab.text = @"未达标";
            addRecord.image.image = [UIImage imageNamed:@"pub_ic_wal_un"];
        }else{
            addRecord.titleLab.text = @"达标";
            addRecord.image.image = [UIImage imageNamed:@"pub_ic_right"];
        }
    } else {
        seletedRecord.timeLabel.text = _data[@"time"];
        seletedRecord.detailLabel.text =_data[@"detail"];
        if (self.bloodNum>0) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_data[@"detail"]];
            NSRange r1 = NSMakeRange(0, self.num);
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r1];
            
            NSRange r2 = NSMakeRange(self.num+1, self.bloodNum);
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r2];
            [seletedRecord.detailLabel setAttributedText:attributedString];
        }else{
            if (self.num>0) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_data[@"detail"]];
                NSRange r1 = NSMakeRange(0, self.num);
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0xf39800"] range:r1];
                [seletedRecord.detailLabel setAttributedText:attributedString];
            }
        }
    }
}
@end
