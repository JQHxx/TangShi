//
//  CustomButton.m
//  TonzeCloud
//
//  Created by vision on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "CustomButton.h"

@interface CustomButton (){

    UIImageView *iconImageView;
    UILabel     *titleLabel;
}
@end

@implementation CustomButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnW=frame.size.width;
        
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake((btnW-45)/2,10, 45,45)];
        [self addSubview:iconImageView];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, iconImageView.bottom+7, btnW, 25)];
        titleLabel.font=[UIFont systemFontOfSize:13];
        titleLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
    }
    return self;
}

- (void)setTitleStr:(NSString *)titleStr{
    NSArray *imgArr = @[@"ic_h_test",@"ic_h_food",@"ic_h_day",@"ic_h_baike"];
    _titleStr = titleStr;
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:self.iconImage] placeholderImage:[UIImage imageNamed:imgArr[self.tag]]];
    titleLabel.text = _titleStr;
}

@end
