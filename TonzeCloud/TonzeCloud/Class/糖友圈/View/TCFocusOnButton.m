//
//  TCFocusOnButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFocusOnButton.h"
@interface TCFocusOnButton (){
    UILabel       *numLabel;
}

@end
@implementation TCFocusOnButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width, 20)];
        numLabel.font = [UIFont systemFontOfSize:15];
        numLabel.textColor = [UIColor whiteColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:numLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, numLabel.bottom+5, width, 15)];
        nameLabel.text = title;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
    }
    return self;
}
-(void)setNumTitle:(NSString *)numTitle{
    _numTitle = numTitle;
    numLabel.text = _numTitle;
}
@end
