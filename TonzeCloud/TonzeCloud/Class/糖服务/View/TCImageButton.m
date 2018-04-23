//
//  TCImageButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/4/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCImageButton.h"

@implementation TCImageButton

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{
    self=[super initWithFrame:frame];
    if (self) {
        float btnw = frame.size.width;
        float btnh = frame.size.height;

        _titleName=[[UILabel alloc] initWithFrame:CGRectMake(15, (btnh-20)/2, kScreenWidth-30, 20)];
        _titleName.textColor = [UIColor grayColor];
        _titleName.font = [UIFont systemFontOfSize:14];
        _titleName.text = dict[@"title"];
        [self addSubview:_titleName];
        
        _contentLab=[[UILabel alloc] initWithFrame:CGRectMake(btnw-100,(btnh-30)/2,80, 20)];
        _contentLab.text=dict[@"content"];
        _contentLab.font = [UIFont systemFontOfSize:13];
        _contentLab.textAlignment=NSTextAlignmentRight;
        _contentLab.textColor = [UIColor grayColor];
        [self addSubview:_contentLab];
    }
    return self;
}
@end
