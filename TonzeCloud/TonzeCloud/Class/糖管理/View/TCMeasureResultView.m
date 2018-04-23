//
//  TCMeasureResultView.m
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMeasureResultView.h"
#import "TCLimitView.h"

#define kMinValue  1.1
#define kMaxValue  33.3

@interface TCMeasureResultView (){
    UIImageView     *locImageView;
    TCLimitView     *limitView;
    UILabel         *lowLabel;
    UILabel         *highLabel;
    
    double min;
    double max;
    
    
}

@end

@implementation TCMeasureResultView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        locImageView=[[UIImageView alloc] initWithFrame:CGRectZero];
        locImageView.image=[UIImage imageNamed:@"img_seekbar_buoy"];
        [self addSubview:locImageView];
        
        limitView=[[TCLimitView alloc] initWithFrame:CGRectMake(20, 15, self.width-40, 20)];
        [self addSubview:limitView];
        
        lowLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        lowLabel.textColor=[UIColor lightGrayColor];
        lowLabel.font=[UIFont systemFontOfSize:14];
        lowLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:lowLabel];
        
        highLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        highLabel.textColor=[UIColor lightGrayColor];
        highLabel.font=[UIFont systemFontOfSize:14];
        highLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:highLabel];
        
    }
    return self;
}


-(void)setPeriodString:(NSString *)periodString{
    _periodString=periodString;
    
    limitView.periodStr=periodString;
    
    NSDictionary *dict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:periodString];
    min=[[dict valueForKey:@"min"] doubleValue];
    max=[[dict valueForKey:@"max"] doubleValue];
    
    lowLabel.frame=CGRectMake(self.width*(min-kMinValue)/(kMaxValue-kMinValue)-5, limitView.bottom, 40, 20);
    lowLabel.text=[NSString stringWithFormat:@"%.1f",min];
    
    highLabel.frame=CGRectMake(self.width*(max-kMinValue)/(kMaxValue-kMinValue)-5, limitView.bottom, 40, 20);
    highLabel.text=[NSString stringWithFormat:@"%.1f",max];
}

-(void)setSugarValue:(double)sugarValue{
    _sugarValue=sugarValue;
    if (sugarValue>kMinValue) {
        locImageView.frame=CGRectMake(10+self.width*(sugarValue-kMinValue)/(kMaxValue-kMinValue), 0, 10, 20);
    }
}

@end
