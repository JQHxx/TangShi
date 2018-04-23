//
//  TCManagerView.m
//  TonzeCloud
//
//  Created by vision on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCManagerView.h"
#import "TCToolButton.h"

@interface TCManagerView (){
    UILabel     *periodLabel;
    UILabel     *noneRecordLabel;
}

@end

@implementation TCManagerView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIView  *sugarView=[[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-125)/2, 20 , 125, 125)];
        sugarView.layer.cornerRadius=125/2;
        sugarView.userInteractionEnabled=YES;
        sugarView.backgroundColor=[UIColor whiteColor];
        [self addSubview:sugarView];
        
        UIImageView *sugarImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
        sugarImg.image = [UIImage imageNamed:@"h_circle_bg"];
        [sugarView addSubview:sugarImg];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSugarValueForTap)];
        [sugarView addGestureRecognizer:tap];
        
        periodLabel=[[UILabel alloc] initWithFrame:CGRectMake((125-60)/2, 20, 60, 20)];
        periodLabel.text=@"";
        periodLabel.textAlignment=NSTextAlignmentCenter;
        periodLabel.font=[UIFont systemFontOfSize:12.0f];
        periodLabel.textColor=[UIColor whiteColor];
        [sugarView addSubview:periodLabel];
        
        
        UIImageView *addImg = [[UIImageView alloc] initWithFrame:CGRectMake((125-26)/2, 45, 26, 26)];
        addImg.image = [UIImage imageNamed:@"ic_h_add"];
        [sugarView addSubview:addImg];
        
        UILabel *sugarValueLabel=[[UILabel alloc] initWithFrame:CGRectMake((125-60)/2, 75, 60, 20)];
        sugarValueLabel.text=@"mmol/L" ;
        sugarValueLabel.textAlignment=NSTextAlignmentCenter;
        sugarValueLabel.font=[UIFont systemFontOfSize:12.0f];
        sugarValueLabel.textColor=[UIColor whiteColor];
        [sugarView addSubview:sugarValueLabel];
        
        NSArray *sugarArr=@[@{@"title":@"血糖数据",@"image":@"ic_h_data"},@{@"title":@"血糖设备",@"image":@"ic_h_equ"}];
        for (NSInteger i=0; i<sugarArr.count; i++) {
            NSDictionary *dict=sugarArr[i];
            CGRect btnFrame;
            if (i==0) {
                btnFrame=CGRectMake(10, 60, 100, 90);
            }else{
                btnFrame=CGRectMake(kScreenWidth-110,60, 100,90);
            }
            TCToolButton *btn=[[TCToolButton alloc] initWithFrame:btnFrame dict:dict bgColor:[UIColor clearColor]];
            btn.tag=i;
            [btn addTarget:self action:@selector(clickActionForToolBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
    return self;
}

#pragma mark -- Event Response
#pragma mark toolButton Actions
-(void)clickActionForToolBtn:(TCToolButton *)button{
    NSInteger btnTag=button.tag;
    if ([_delegate respondsToSelector:@selector(managerViewDidClickToolButtonForIndex:)]) {
        [_delegate managerViewDidClickToolButtonForIndex:btnTag];
    }
}

#pragma mark 添加血糖值
-(void)addSugarValueForTap{
    if ([_delegate respondsToSelector:@selector(managerViewAddSugarViewAction)]) {
        [_delegate managerViewAddSugarViewAction];
    }
}

#pragma mark -- Setters
#pragma mark 时间段
-(void)setPeriodString:(NSString *)periodString{
    _periodString=periodString;
    periodLabel.text=kIsEmptyString(periodString)?@"":periodString;
}

@end
