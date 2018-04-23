//
//  TCUserDynamicButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCUserDynamicButton.h"
@interface TCUserDynamicButton (){

    UIImageView  *backImage;
    UILabel      *nameLabel;
}

@end

@implementation TCUserDynamicButton

- (instancetype)initWithFrame:(CGRect)frame img:(NSString *)image{
    self = [super initWithFrame:frame];
    if (self) {
        float width = frame.size.width;
        float height = frame.size.height;
        
        backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        backImage.image = [UIImage imageNamed:image];
        [self addSubview:backImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, width-25, 15)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    nameLabel.text = _title;
}
@end
