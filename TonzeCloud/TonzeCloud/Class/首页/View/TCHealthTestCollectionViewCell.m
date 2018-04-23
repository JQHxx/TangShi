//
//  TCHealthTestCollectionViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthTestCollectionViewCell.h"
@interface TCHealthTestCollectionViewCell (){

    CGFloat          width;
    UILabel         *contentLabel;
}

@end
@implementation TCHealthTestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    width = frame.size.width;
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _titleImg = [[UIImageView alloc]initWithFrame:CGRectMake((width -  80)/2, 20 ,80 ,80)];
        [self addSubview:_titleImg];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleImg.bottom + 15, width, 15)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        [self addSubview:_titleLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _titleLabel.bottom + 10,width-5, 55)];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        contentLabel.numberOfLines = 3;
        [self addSubview:contentLabel];
    }
    return self;
}
-(void)setContent:(NSString *)content{
    _content = content;
    contentLabel.text = _content;
    CGSize size = [contentLabel.text sizeWithLabelWidth:width-5 font:[UIFont systemFontOfSize:14]];
    if (size.height>52) {
        contentLabel.frame =CGRectMake(5, _titleLabel.bottom + 10,width-5, 52);
    } else {
        contentLabel.frame =CGRectMake(5, _titleLabel.bottom + 10,width-5, size.height);
    }
}
@end
