//
//  TCPayButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPayButton.h"

@implementation TCPayButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {        
        _headImage= [[UIImageView alloc] initWithFrame:CGRectMake(12, 10,48-20,  48-20)];
        _headImage.layer.cornerRadius = 14;
        [self addSubview:_headImage];
        
        _expertName = [[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+19, _headImage.top+5, kScreenWidth/2, 20)];
        _expertName.font = [UIFont systemFontOfSize:15];
        _expertName.textAlignment = NSTextAlignmentLeft;
        _expertName.textColor = [UIColor darkGrayColor];
        [self addSubview:_expertName];
        
        _Image = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-20-15, 14, 20, 20)];
        _Image.layer.cornerRadius = 10;
        [self addSubview:_Image];
    }
    return self;

    
}
@end
