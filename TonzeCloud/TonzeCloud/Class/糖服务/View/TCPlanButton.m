//
//  TCPlanButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPlanButton.h"

@implementation TCPlanButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat  btnw = frame.size.width;
        CGFloat  btnh = frame.size.height;
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, btnh-30, btnh-30)];
        _headImage.layer.cornerRadius = (btnh-30)/2;
        _headImage.clipsToBounds=YES;
        [self addSubview:_headImage];
        
        _expertName = [[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+10, _headImage.top, btnw/2, 30)];
        _expertName.font =  [UIFont systemFontOfSize:16];
        _expertName.textColor = [UIColor darkGrayColor];
        [self addSubview:_expertName];
        
        _workRank = [[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+10, _expertName.bottom, btnw-_headImage.right-50, 20)];
        _workRank.font =  [UIFont systemFontOfSize:14];
        _workRank.textColor = [UIColor grayColor];
        [self addSubview:_workRank];
        
        UIImageView *detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(btnw-30, (btnh-20)/2, 20, 20)];
        detailImage.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self addSubview:detailImage];
        
    }
    return self;
}
@end
