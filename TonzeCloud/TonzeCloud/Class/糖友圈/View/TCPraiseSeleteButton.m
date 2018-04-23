//
//  TCPraiseSeleteButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPraiseSeleteButton.h"
@interface TCPraiseSeleteButton (){
    
    UILabel     *titleLabel;
    UIImageView *imgView;
    CGFloat      width;
    CGFloat      height;
}
@end

@implementation TCPraiseSeleteButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (height-16)/2, 16, 16)];
        [self addSubview:imgView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (height-20)/2, 0, 20)];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:titleLabel];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    titleLabel.text = _title;
    CGSize size = [titleLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:15]];
    titleLabel.frame = CGRectMake(20, (height-20)/2, size.width, 20);
}
- (void)setSeleted:(NSInteger)seleted{
    _seleted = seleted;
    imgView.image = [UIImage imageNamed:_seleted==1?@"choose_thumbs":@"thumbs"];
    titleLabel.textColor = _seleted==1?kbgBtnColor:[UIColor grayColor];

}
@end
