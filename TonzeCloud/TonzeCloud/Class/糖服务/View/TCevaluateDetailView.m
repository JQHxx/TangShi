//
//  TCevaluateDetailView.m
//  TonzeCloud
//
//  Created by vision on 17/6/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCevaluateDetailView.h"

@interface TCevaluateDetailView (){
    
    UILabel         *evalueteTimeLabel;
    UIImageView     *oneScoreImageView;
    UIImageView     *twoScoreImageView;
    UIImageView     *threeScoreImageView;
    
    NSMutableArray  *oneScoreArray;
    NSMutableArray  *twoScoreArray;
    NSMutableArray  *threeScoreArray;
}

@end

@implementation TCevaluateDetailView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        NSArray *labs=[[NSArray alloc] initWithObjects:@"服务态度",@"回复速度",@"解决态度", nil];
        for (NSInteger i=0; i<labs.count; i++) {
            UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 5+30*i, 80.0, 30.0)];
            lab.text=labs[i];
            lab.textColor=[UIColor colorWithHexString:@"#333333"];
            lab.font=[UIFont systemFontOfSize:15];
            [self addSubview:lab];
        }
        
        oneScoreArray=[[NSMutableArray alloc] init];
        twoScoreArray=[[NSMutableArray alloc] init];
        threeScoreArray=[[NSMutableArray alloc] init];
        
        for (NSInteger i=0; i<5; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [oneScoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
        for (NSInteger i=0; i<5; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [twoScoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
        for (NSInteger i=0; i<5; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [threeScoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
    }
    return self;
}

-(void)setMyService:(TCMineServiceModel *)myService{
    _myService=myService;
    
    CGSize scoreSize = CGSizeMake(20, 20);
    //
    NSInteger attitudeScoreNum = myService.attitude_score;
    for (int i = 0; i<oneScoreArray.count; i++) {
        UIImageView *scoreImage = oneScoreArray[i];
        scoreImage.hidden=NO;
        [scoreImage setFrame:CGRectMake(90+scoreSize.width*i,10, scoreSize.width, scoreSize.height)];
        if (i>attitudeScoreNum-1) {
            scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
        }
    }
    
    NSInteger speedScoreNum = myService.speed_score;
    for (int i = 0; i<twoScoreArray.count; i++) {
        UIImageView *scoreImage = twoScoreArray[i];
        scoreImage.hidden=NO;
        [scoreImage setFrame:CGRectMake(90+scoreSize.width*i,40, scoreSize.width, scoreSize.height)];
        if (i>speedScoreNum-1) {
            scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
        }
    }
    
    NSInteger satifiedNum = myService.satisfied_score;
    for (int i = 0; i<threeScoreArray.count; i++) {
        UIImageView *scoreImage = threeScoreArray[i];
        scoreImage.hidden=NO;
        [scoreImage setFrame:CGRectMake(90+scoreSize.width*i,70, scoreSize.width, scoreSize.height)];
        if (i>satifiedNum-1) {
            scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
        }
    }
    
}



@end
