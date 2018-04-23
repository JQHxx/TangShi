//
//  TCFunctionButton.m
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFunctionButton.h"

@implementation TCFunctionButton

-(instancetype)initWithFrame:(CGRect)frame info:(NSDictionary *)info{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnWidth=frame.size.width;
        CGFloat btnHeight=frame.size.height;
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-(btnHeight-60))/2, 20, btnHeight-60, btnHeight-60)];
        imgView.image=[UIImage imageNamed:info[@"image"]];
        [self addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(10, imgView.bottom, btnWidth-20, 30)];
        titleLab.text=info[@"name"];
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.textColor=[UIColor blackColor];
        [self addSubview:titleLab];
        
    }
    return self;
}


@end
