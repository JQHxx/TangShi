//
//  TCBlankView.m
//  TonzeCloud
//
//  Created by vision on 17/3/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBlankView.h"

@interface TCBlankView ()
{
    UILabel *_tipLab;
}
@end

@implementation TCBlankView

-(instancetype)initWithFrame:(CGRect)frame img:(NSString *)imgName text:(NSString *)text{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2,20, 120, 120)];
        imgView.image=[UIImage imageNamed:imgName];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:imgView];
        
        CGSize statusLabelSize =[text sizeWithLabelWidth:kScreenWidth-120 font:[UIFont systemFontOfSize:14]];
        _tipLab=[[UILabel alloc] initWithFrame:CGRectMake(60, imgView.bottom, kScreenWidth-120, statusLabelSize.height+5)];
        _tipLab.textAlignment=NSTextAlignmentCenter;
        _tipLab.text=text;
        _tipLab.numberOfLines = 0;
        _tipLab.font=[UIFont systemFontOfSize:14.0f];
        _tipLab.textColor=[UIColor lightGrayColor];
        [self addSubview:_tipLab];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Searchimg:(NSString *)imgName text:(NSString *)text{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2,40, 60, 60)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+10, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=text;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame unOrderImg:(NSString *)imgName tipText:(NSString *)tipText  chooseText:(NSString *)chooseText{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth- 236/2)/2,40, 236/2, 124/2)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+ 20, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text= tipText;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
        
        UILabel *chooseLab=[[UILabel alloc] initWithFrame:CGRectMake(20, lab.bottom+ 10, kScreenWidth-40, 20)];
        chooseLab.textAlignment=NSTextAlignmentCenter;
        chooseLab.text= chooseText;
        chooseLab.font=[UIFont systemFontOfSize:14.0f];
        chooseLab.textColor=[UIColor lightGrayColor];
        [self addSubview:chooseLab];
    }
    return self;
}
#pragma mark ====== Setter =======

- (void)setTipStr:(NSString *)tipStr{
    _tipLab.text = tipStr;
}

@end
