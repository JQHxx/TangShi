//
//  TCDietRecordButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDietRecordButton.h"

@implementation TCDietRecordButton

- (instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 30, 30)];
        imgView.image = [UIImage imageNamed:dict[@"image"]];
        [self addSubview:imgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+15, 8, width-imgView.right, 20)];
        titleLabel.text = dict[@"title"];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:titleLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+15, titleLabel.bottom, width-imgView.right, 20)];
        _detailLabel.text = dict[@"detail"];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self addSubview:_detailLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+15, _detailLabel.bottom, width-imgView.right, 15)];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        [self addSubview:_timeLabel];
    }
    return self;
}

@end
