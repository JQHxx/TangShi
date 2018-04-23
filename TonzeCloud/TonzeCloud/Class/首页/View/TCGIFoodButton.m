//
//  TCGIFoodButton.m
//  TonzeCloud
//
//  Created by vision on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGIFoodButton.h"



@implementation TCGIFoodButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIImageView  *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 60, 60)];
        imgView.image=[UIImage imageNamed:@"ic_food_GI"];
        [self addSubview:imgView];
        
        UILabel  *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right +10, 10, 150, 30)];
        titleLab.text=@"GI食物";
        titleLab.textColor=[UIColor blackColor];
        titleLab.font=[UIFont systemFontOfSize:16];
        [self addSubview:titleLab];
        
        UILabel   *detailLab=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, titleLab.bottom, 200, 30)];
        detailLab.textColor=[UIColor lightGrayColor];
        detailLab.text=@"更适合糖尿病人吃的食物";
        detailLab.font=[UIFont systemFontOfSize:14];
        [self addSubview:detailLab];
        
        UIImageView *arrowImgView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-25, (80-15)/2, 10, 15)];
        arrowImgView.image=[UIImage imageNamed:@"right_arrow"];
        [self addSubview:arrowImgView];
        
    }
    return self;
}

@end
