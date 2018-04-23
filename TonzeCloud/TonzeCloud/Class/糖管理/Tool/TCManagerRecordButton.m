//
//  TCManagerRecordButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/26.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCManagerRecordButton.h"

@implementation TCManagerRecordButton

-(instancetype)initWithFrame:(CGRect)frame dictManager:(NSDictionary *)dict bgColor:(UIColor *)color{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnW=frame.size.width;
        CGFloat btnH=frame.size.height;

        _image=[[UIImageView alloc] initWithFrame:CGRectMake(16, (btnH-48)/2, 22, 22)];
        _image.backgroundColor=color;
        _image.image=[UIImage imageNamed:dict[@"image"]];
        [self addSubview:_image];
        
        _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(5,_image.bottom+6, btnW-10, 20)];
        _titleLab.text=dict[@"title"];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.font=[UIFont systemFontOfSize:13];
        _titleLab.textColor=[UIColor colorWithHexString:@"0x626262"];
        [self addSubview:_titleLab];
    }
    return self;
}
@end
