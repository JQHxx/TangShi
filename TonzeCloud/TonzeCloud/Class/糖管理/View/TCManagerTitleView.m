//
//  TCManagerTitleView.m
//  TonzeCloud
//
//  Created by vision on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCManagerTitleView.h"

@implementation TCManagerTitleView

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self=[super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth, 30)];
        titleLabel.text=title;
        titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [self addSubview:titleLabel];
        
        UIButton *historyBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-120, 5, 120, 30)];
        historyBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [historyBtn setTitle:@"历史记录" forState:UIControlStateNormal];
        [historyBtn setImage:[UIImage imageNamed:@"ic_pub_arrow_y"] forState:UIControlStateNormal];
        historyBtn.imageEdgeInsets=UIEdgeInsetsMake(0, 80, 0, 0);
        historyBtn.titleEdgeInsets=UIEdgeInsetsMake(0, -30, 0, 0);
        [historyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [historyBtn addTarget:self action:@selector(getMoreHistory) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:historyBtn];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height-1, kScreenWidth-20, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
    }
    return self;
}

-(void)getMoreHistory{
    if ([_delegate respondsToSelector:@selector(managerTitleViewGotHistoryData:)]) {
        [_delegate managerTitleViewGotHistoryData:self];
    }
}

@end
