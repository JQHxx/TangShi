//
//  TCWeekRecordView.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWeekRecordView.h"
#import "TCPieView.h"
#import "TCWeekCountView.h"

@interface TCWeekRecordView (){
    
}

@end

@implementation TCWeekRecordView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        _titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(5, 90, 90, 25)];
        _titleLbl.textAlignment=NSTextAlignmentCenter;
        _titleLbl.font=[UIFont systemFontOfSize:13];
        _titleLbl.textColor=[UIColor grayColor];
        [self addSubview:_titleLbl];
    }
    return self;
}

-(void)setWeekRecordsDict:(NSDictionary *)weekRecordsDict{
    _weekRecordsDict=weekRecordsDict;
    
    NSInteger highCount=[weekRecordsDict[@"high"] integerValue];
    NSInteger normalCount=[weekRecordsDict[@"normal"] integerValue];
    NSInteger lowCount=[weekRecordsDict[@"low"] integerValue];
    if (highCount==0&&normalCount==0&&lowCount==0) {
        NSArray *dataItems=[NSArray arrayWithObjects:[NSString stringWithFormat:@"1"],nil];
        NSArray *colorItems=[NSArray arrayWithObjects:[UIColor bgColor_Gray],nil];
        TCPieView *pieView=[[TCPieView alloc] initWithFrame:CGRectMake(10, 10, 80, 80) dataItems:dataItems colorItems:colorItems];
        [self addSubview:pieView];
        [pieView stroke];   //动画绘制
    }
    //绘制饼图
    NSArray *dataItems=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)highCount],
                                                 [NSString stringWithFormat:@"%ld",(long)normalCount],
                                                 [NSString stringWithFormat:@"%ld",(long)lowCount],nil];
    NSArray *colorItems=[NSArray arrayWithObjects:[UIColor colorWithHexString:@"#fa6f6e"],
                                                  [UIColor colorWithHexString:@"#37deba"],
                                                  [UIColor colorWithHexString:@"#ffd03e"],nil];
    TCPieView *pieView=[[TCPieView alloc] initWithFrame:CGRectMake(10, 10, 80, 80) dataItems:dataItems colorItems:colorItems];
    [self addSubview:pieView];
    [pieView stroke];   //动画绘制
    
    //次数和百分比
    NSArray *textsArr=@[@"偏高",@"正常",@"偏低"];
    NSInteger totalCount=highCount+normalCount+lowCount;
    
    CGFloat countViewWidth=(kScreenWidth-pieView.right-20-15)/3;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[TCWeekCountView class]]) {
            [view removeFromSuperview];
        }
    }
    
    
    for (NSInteger i=0; i<dataItems.count; i++) {
        TCWeekCountView *weekCountView=[[TCWeekCountView alloc] initWithFrame:CGRectMake(pieView.right+20+i*(countViewWidth+5), 10, countViewWidth, 110)];
        NSInteger count=[dataItems[i] integerValue];
        weekCountView.weekCount=count;
        weekCountView.color=colorItems[i];
        weekCountView.percentageStr=totalCount>0?[NSString stringWithFormat:@"%.1f%%",((float)count/(float)totalCount)*100]:@"0.0%";
        weekCountView.stateString=textsArr[i];
        [self addSubview:weekCountView];
    }
    
}





@end
