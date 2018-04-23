//
//  TCWeekCountView.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWeekCountView.h"

@interface TCWeekCountView (){
    UILabel *countLab;
    UILabel *colorLab;
    UILabel *stateLab;
    UILabel *percentLab;
    
}

@end

@implementation TCWeekCountView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        countLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        countLab.font=[UIFont systemFontOfSize:12];
        countLab.textAlignment=NSTextAlignmentCenter;
        [self addSubview:countLab];
        
        colorLab=[[UILabel alloc] initWithFrame:CGRectMake(countLab.center.x-31, countLab.bottom+5, 16, 16)];
        colorLab.layer.cornerRadius=8.0;
        colorLab.clipsToBounds=YES;
        [self addSubview:colorLab];
        
        stateLab=[[UILabel alloc] initWithFrame:CGRectMake(colorLab.right+5, colorLab.top, frame.size.width-20, 20)];
        stateLab.font=[UIFont systemFontOfSize:14.0f];
        stateLab.textColor=[UIColor lightGrayColor];
        [self addSubview:stateLab];
        
        percentLab=[[UILabel alloc] initWithFrame:CGRectMake(10, stateLab.bottom, frame.size.width-20, 20)];
        percentLab.textColor=[UIColor lightGrayColor];
        percentLab.textAlignment=NSTextAlignmentCenter;
        percentLab.font=[UIFont systemFontOfSize:12];
        [self addSubview:percentLab];
        
    }
    return self;
}

-(void)setWeekCount:(NSInteger)weekCount{
    _weekCount=weekCount;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld次",(long)weekCount]];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22.0f] range:NSMakeRange(0, attributeStr.length-1)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#535353"] range:NSMakeRange(0, attributeStr.length-1)];
    countLab.attributedText=attributeStr;
}

-(void)setPercentageStr:(NSString *)percentageStr{
    _percentageStr=percentageStr;
    percentLab.text=percentageStr;
}

-(void)setColor:(UIColor *)color{
    _color=color;
    colorLab.backgroundColor=color;
}

-(void)setStateString:(NSString *)stateString{
    _stateString=stateString;
    stateLab.text=stateString;
}


@end
