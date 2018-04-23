//
//  TCProgramButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/12/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCProgramButton.h"

@interface TCProgramButton (){
    
    CGFloat viewH;
    UIImageView *imgView;
}
@end

@implementation TCProgramButton

- (instancetype)initWithFrame:(CGRect)frame titleColor:(NSString *)color{
    self = [super initWithFrame:frame];
    if (self) {
        viewH=frame.size.height;
        CGFloat imgH=50;
        
        _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth/2.0-imgH-30, 30)];
        _titleLab.font=[UIFont boldSystemFontOfSize:18];
        _titleLab.textColor=[UIColor colorWithHexString:color];
        [self addSubview:_titleLab];
        
        _descLab=[[UILabel alloc] initWithFrame:CGRectZero];
        _descLab.font=[UIFont systemFontOfSize:13];
        _descLab.textColor=[UIColor colorWithHexString:color];
        _descLab.numberOfLines=0;
        [self addSubview:_descLab];
        
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-imgH-15, (viewH-imgH)/2.0, imgH, imgH)];
        imgView.contentMode=UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds=YES;
        [self addSubview:imgView];
    }
    return self;
}

- (void)setImgName:(NSString *)imgName{
    _imgName = imgName;

    CGFloat descHeight=[_descLab.text boundingRectWithSize:CGSizeMake(_titleLab.width, viewH-_titleLab.bottom-10) withTextFont:_descLab.font].height;
    _descLab.frame=CGRectMake(10, _titleLab.bottom, _titleLab.width, descHeight);
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:_imgName] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    
}
@end
