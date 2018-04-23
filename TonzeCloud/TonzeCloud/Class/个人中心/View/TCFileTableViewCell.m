//
//  TCFileTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/4/10.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCFileTableViewCell.h"

@interface TCFileTableViewCell (){

    CGFloat btnw;
    CGFloat btnh;
}
@end
@implementation TCFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        btnw = kScreenWidth;
        btnh = 48;
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, (btnh-30)/2, kScreenWidth/2-15, 30)];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_titleLabel];
        
        _contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(btnw/2-10,(btnh-15)/2,btnw/2-20, 15)];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textAlignment=NSTextAlignmentRight;
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor grayColor];
        [self addSubview:_contentLabel];

    }
    return self;
}
@end
