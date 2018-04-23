//
//  TCMineButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMineButton.h"

@implementation TCMineButton

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnw = kScreenWidth;
        CGFloat btnh = 48;
        _titleName=[[UILabel alloc] initWithFrame:CGRectMake(15, (btnh-30)/2, kScreenWidth/2-15, 30)];
        _titleName.textColor = [UIColor colorWithHexString:@"0x313131"];
        _titleName.font = [UIFont systemFontOfSize:15];
        _titleName.text = dict[@"title"];
        [self addSubview:_titleName];
        
        _contentLab=[[UILabel alloc] initWithFrame:CGRectMake(btnw/2-10,(btnh-30)/2,btnw/2-20, 30)];
        _contentLab.text=dict[@"content"];
        _contentLab.font = [UIFont systemFontOfSize:13];
        _contentLab.textAlignment=NSTextAlignmentRight;
        _contentLab.textColor = [UIColor grayColor];
        [self addSubview:_contentLab];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(_contentLab.right, (btnh-20)/2, 20, 20)];
        imgView.image = [UIImage imageNamed:dict[@"image"]];
        [self addSubview:imgView];
        
        _phoneLab=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2,(btnh-30)/2,kScreenWidth/2-30, 30)];
        _phoneLab.text=dict[@"phone"];
        _phoneLab.font = [UIFont systemFontOfSize:13];
        _phoneLab.textAlignment=NSTextAlignmentRight;
        _phoneLab.textColor = [UIColor grayColor];
        [self addSubview:_phoneLab];

        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, btnh-1,btnw-5 , 1)];
        line.backgroundColor = kbgView;
        [self addSubview:line];
    }
    return self;
}
@end
