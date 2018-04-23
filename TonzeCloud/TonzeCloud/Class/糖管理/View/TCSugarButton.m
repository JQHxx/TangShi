//
//  TCSugarButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarButton.h"

@interface TCSugarButton (){
    
    UILabel *titleLabel;
    UIImageView *imgView;
    CGFloat width;
    CGFloat height;
}
@end

@implementation TCSugarButton

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image color:(NSString *)color title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((width-80)/2, (height-25)/2, 70, 25)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor colorWithHexString:color];
        [self addSubview:titleLabel];
        CGSize size =[titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        titleLabel.frame = CGRectMake((width-size.width)/2, (height-25)/2, size.width, 25);
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.right+5, (height-15)/2, 15, 15)];
        imgView.image = [UIImage imageNamed:image];
        [self addSubview:imgView];
    }
    return self;
}
- (void)setTitle:(NSString *)title{
    _title = title;
    titleLabel.text = _title;
    CGSize size =[titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    titleLabel.frame = CGRectMake((width-size.width)/2, (height-25)/2, size.width, 25);
    imgView.frame =CGRectMake(titleLabel.right, (height-20)/2, 20, 20);
}
@end
