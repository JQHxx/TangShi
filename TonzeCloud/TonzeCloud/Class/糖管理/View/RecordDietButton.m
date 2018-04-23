//
//  RecordDietButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "RecordDietButton.h"

@implementation RecordDietButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((width-80)/2+10, (height-20)/2, 80, 20)];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = kbgBtnColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.left-20, (height-20)/2, 20, 20)];
        imgView.image = [UIImage imageNamed:@"ic_m_record_add"];
        [self addSubview:imgView];
    }
    return self;
 }
@end
