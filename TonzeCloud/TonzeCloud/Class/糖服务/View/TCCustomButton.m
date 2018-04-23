//
//  TCCustomButton.m
//  TonzeCloud
//
//  Created by vision on 17/2/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCustomButton.h"

@implementation TCCustomButton

-(instancetype)initWithFrame:(CGRect)frame info:(NSDictionary *)infoDict{
    self=[super initWithFrame:frame];
    if (self) {
        
        CGFloat wid=frame.size.width;
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((wid-48)/2, 21, 48, 48)];
        imgView.image=[UIImage imageNamed:infoDict[@"icon"]];
        [self addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+12, wid-40, 20)];
        titleLab.text=infoDict[@"title"];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.textColor = [UIColor darkGrayColor];
        titleLab.font=[UIFont boldSystemFontOfSize:15.0f];
        [self addSubview:titleLab];
        
        UILabel *subtitleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, titleLab.bottom+5, wid-40, 35)];
        subtitleLab.text=infoDict[@"subtitle"];
        subtitleLab.textAlignment=NSTextAlignmentCenter;
        subtitleLab.numberOfLines=0;
        subtitleLab.textColor = [UIColor grayColor];
        subtitleLab.font=[UIFont systemFontOfSize:13.0f];
        [self addSubview:subtitleLab];
        
    }
    return self;
}

@end
