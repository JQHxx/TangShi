//
//  TCHomeCenterView.m
//  TonzeCloud
//
//  Created by vision on 17/10/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHomeCenterView.h"
#import "TCProgramButton.h"

@interface TCHomeCenterView (){

    CGFloat height;
    
    TCProgramButton *imgPlanButton;
    TCProgramButton *consultPlanButton;
    
    NSDictionary  *homeCenterDict;
}
@end

@implementation TCHomeCenterView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        height = frame.size.height;
        
        //图文方案
        imgPlanButton = [[TCProgramButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2.0-1, frame.size.height) titleColor:@"#ffc742"];
        imgPlanButton.tag = 102;
        [imgPlanButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imgPlanButton];
        //营养方案
        consultPlanButton = [[TCProgramButton alloc] initWithFrame:CGRectMake(kScreenWidth/2.0+1, 0, kScreenWidth/2.0-1, frame.size.height) titleColor:@"#44a9ff"];
        consultPlanButton.tag = 103;
        [consultPlanButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:consultPlanButton];

        //竖线
        UILabel *horLine=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0,0, 1, height)];
        horLine.backgroundColor=[UIColor colorWithHexString:@"#e5e5e5"];
        [self addSubview:horLine];
        
        
    }
    return self;
}
- (void)homeCenterData:(NSArray *)homeCenterArr{
    NSDictionary *imgServiceDict = nil;
    NSDictionary *planServiceDict = nil;
    if (kIsArray(homeCenterArr)&&homeCenterArr.count>0) {
        for (NSDictionary *dict in homeCenterArr) {
            if ([[dict objectForKey:@"type"] integerValue]==1) {
                homeCenterDict = dict;
            } else if([[dict objectForKey:@"type"] integerValue]==2){
                imgServiceDict = dict;
            }else{
                planServiceDict = dict;
            }
        }
    }

    imgPlanButton.titleLab.text =  [imgServiceDict objectForKey:@"main_title"];
    imgPlanButton.descLab.text =  [imgServiceDict objectForKey:@"subheading_title"];
    imgPlanButton.imgName = [imgServiceDict objectForKey:@"image_url"];
    
    consultPlanButton.titleLab.text =  [planServiceDict objectForKey:@"main_title"];
    consultPlanButton.descLab.text =  [planServiceDict objectForKey:@"subheading_title"];
    consultPlanButton.imgName = [planServiceDict objectForKey:@"image_url"];

}
-(void)homeButtonAction:(UIButton *)btn{

    
    if ([_delegate respondsToSelector:@selector(homeCenterViewDidClickWithTag:)]) {
        [_delegate homeCenterViewDidClickWithTag:btn.tag];
    }
}

@end
