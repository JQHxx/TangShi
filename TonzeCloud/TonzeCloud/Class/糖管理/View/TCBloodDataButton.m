//
//  TCBloodDataButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBloodDataButton.h"

@implementation TCBloodDataButton

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{

    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        CGFloat wid=frame.size.width;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((wid-150)/2, 10, 20, 20)];
        imgView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
        [self addSubview:imgView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+5, 10, 120, 20)];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_timeLabel];
    }
    return self;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
