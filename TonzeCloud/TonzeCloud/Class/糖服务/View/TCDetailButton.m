//
//  TCDetailButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDetailButton.h"

@implementation TCDetailButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        float btnw = frame.size.width;
        
        _headImage= [[UIImageView alloc] initWithFrame:CGRectMake((btnw-140)/2, 10, 140,  94)];
        [self addSubview:_headImage];
        
        _expertName = [[UILabel alloc] initWithFrame:CGRectMake(0, _headImage.bottom+8, btnw, 20)];
        _expertName.font = [UIFont systemFontOfSize:13];
        _expertName.textAlignment = NSTextAlignmentCenter;
        _expertName.textColor = [UIColor colorWithHexString:@"#626262"];
        [self addSubview:_expertName];

    }
    return self;
}
@end
