
//
//  TCPraiseButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPraiseButton.h"
@interface TCPraiseButton (){
    
    UILabel     *titleLabel;
    UIImageView *imgView;
    CGFloat      width;
    CGFloat      height;
}
@end
@implementation TCPraiseButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = kScreenWidth/2;
        height = frame.size.height;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-30, (height-17)/2, 18, 17)];
        [self addSubview:imgView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2-5, (height-20)/2 + 2, width/2, 20)];
        titleLabel.textColor = UIColorFromRGB(0x313131);
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:titleLabel];
    }
    return self;
}
- (void)setTitle:(NSString *)title{
    _title = title;
    titleLabel.text = _title;
    CGSize size = [titleLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:15]];

    imgView.frame =CGRectMake((width-size.width - 16)/2 , (height - 16)/2, 16, 16);
    titleLabel.frame = CGRectMake(imgView.right + 5, (height-20)/2, size.width, 20);
}

- (void)setSeleted:(NSInteger)seleted{
    _seleted = seleted;
    if (_seleted==2) {
        imgView.image = [UIImage imageNamed:@"comment"];
    }else{
        imgView.image = [UIImage imageNamed:_seleted==1?@"choose_thumbs":@"thumbs"];
        titleLabel.textColor = _seleted == 1 ? kSystemColor  : UIColorFromRGB(0x313131);
    }
}
@end
