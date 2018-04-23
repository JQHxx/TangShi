//
//  TCColumnButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/1/24.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCColumnButton.h"

@interface TCColumnButton (){

    UIImageView *imgView;
    UILabel     *textLabel;
    UILabel     *detailLabel;
    
    CGFloat     width;
    CGFloat     height;
}
@end

@implementation TCColumnButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [self addSubview:imgView];
        
        UILabel *bgView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"0x011d12"];
        bgView.alpha = 0.6;
        [self addSubview:bgView];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:kScreenWidth>=375?21:20];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.numberOfLines = 2;
        [self addSubview:textLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.font = [UIFont systemFontOfSize:kScreenWidth>=375?17:16];
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.numberOfLines = 2;
        [self addSubview:detailLabel];
        
    }
    return self;
}
- (void)columnBtnDict:(NSDictionary *)dict{
    

    [imgView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"l_url"]] placeholderImage:[UIImage imageNamed:@""]];
    textLabel.text = [NSString stringWithFormat:@"＃ %@",[dict objectForKey:@"name"]];
    CGSize textSize = [textLabel.text sizeWithLabelWidth:width-10 font:[UIFont systemFontOfSize:kScreenWidth>=375?21:20]];
    CGFloat textHeight = textSize.height>26?0:10;
    
    textLabel.frame = CGRectMake(5, textSize.height>52?height/2-52-textHeight:height/2-textSize.height-textHeight, width-10, textSize.height>52?52:textSize.height);
    
    detailLabel.text = [dict objectForKey:@"subtitle"];
    CGSize detailSize = [detailLabel.text sizeWithLabelWidth:width-10 font:[UIFont systemFontOfSize:kScreenWidth>=375?17:16]];
    detailLabel.frame = CGRectMake(5,height/2+10, width-10, detailSize.height>42?42:detailSize.height);
}

@end
