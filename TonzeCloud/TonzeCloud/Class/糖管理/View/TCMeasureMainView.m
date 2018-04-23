//
//  TCMeasureMainView.m
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMeasureMainView.h"
#import "TimePickerView.h"

@interface TCMeasureMainView ()<UIActionSheetDelegate>

@end

@implementation TCMeasureMainView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *circleImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-130)/2, 10, 130, 100)];
        circleImageView.image=[UIImage imageNamed:@"ic_xty_num"];
        [self addSubview:circleImageView];
        
        _sugarValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, (130-30)/2-5, 110, 30)];
        _sugarValueLabel.textColor=kRGBColor(254, 212, 92);
        _sugarValueLabel.font=[UIFont boldSystemFontOfSize:24];
        _sugarValueLabel.textAlignment=NSTextAlignmentCenter;
        [circleImageView addSubview:_sugarValueLabel];
        
        UILabel  *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, _sugarValueLabel.bottom+5, 130-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.font=[UIFont systemFontOfSize:14];
        lab.textColor=[UIColor blackColor];
        lab.text=@"mmol/L";
        [circleImageView addSubview:lab];
        
    }
    return self;
}

#pragma mark -- Setters

#pragma mark 血糖值
-(void)setSugarValueStr:(NSString *)sugarValueStr{
    _sugarValueStr=sugarValueStr;
    _sugarValueLabel.text=sugarValueStr;
}


@end
