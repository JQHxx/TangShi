//
//  TCToolButton.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCToolButton.h"

@implementation TCToolButton

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict bgColor:(UIColor *)color{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnW=frame.size.width;

        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((btnW-60)/2, 0, 60, 60)];
        imgView.backgroundColor=color;
        imgView.image=[UIImage imageNamed:dict[@"image"]];
        [self addSubview:imgView];
        
        _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(5,imgView.bottom+5, btnW-10, 20)];
        _titleLab.text=dict[@"title"];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.font=[UIFont systemFontOfSize:14];
        _titleLab.textColor=[UIColor colorWithHexString:@"#313131"];
        [self addSubview:_titleLab];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat btnW=frame.size.width;
        
        _headImage=[[UIImageView alloc] initWithFrame:CGRectMake((btnW-60)/2, 15, 60, 60)];
        _headImage.layer.cornerRadius = 30;
        _headImage.clipsToBounds=YES;
        [self addSubview:_headImage];
        
        _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(5,_headImage.bottom+5, btnW-10, 20)];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.font=[UIFont systemFontOfSize:14];
        _titleLab.textColor=[UIColor colorWithHexString:@"#313131"];
        [self addSubview:_titleLab];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.3;
        [_headImage addSubview:_bgView];
        _bgView.hidden = YES;
    }
    return self;
}
-(instancetype)initWithFriendRankListFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat btnW=frame.size.width;
        
        _headImage=[[UIImageView alloc] initWithFrame:CGRectMake((btnW-45)/2, 12, 45, 45)];
        _headImage.layer.cornerRadius = 45/2;
        _headImage.clipsToBounds=YES;
        [self addSubview:_headImage];
        
        _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(5,_headImage.bottom+6, btnW-10, 20)];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.font=[UIFont systemFontOfSize:14];
        _titleLab.textColor=[UIColor colorWithHexString:@"#313131"];
        [self addSubview:_titleLab];
        
    }
    return self;
}
@end
