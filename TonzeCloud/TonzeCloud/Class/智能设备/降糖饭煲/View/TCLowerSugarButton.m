//
//  TCLowerSugarButton.m
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLowerSugarButton.h"

@interface TCLowerSugarButton ()

@end


@implementation TCLowerSugarButton

-(instancetype)initWithFrame:(CGRect)frame info:(NSDictionary *)info{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnWidth=frame.size.width;
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-50)/2, 5, 50, 50)];
        imgView.image=[UIImage imageNamed:info[@"image"]];
        [self addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(10, imgView.bottom, btnWidth-20, 20)];
        titleLab.text=info[@"title"];
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.textColor=[UIColor blackColor];
        [self addSubview:titleLab];
        
        UILabel *desclab=[[UILabel alloc] initWithFrame:CGRectMake(10, titleLab.bottom, btnWidth-20, 15)];
        desclab.textColor=[UIColor lightGrayColor];
        desclab.text=info[@"desc"];
        desclab.font=[UIFont systemFontOfSize:12];
        desclab.textAlignment=NSTextAlignmentCenter;
        [self addSubview:desclab];
        
    }
    return self;
}

@end
