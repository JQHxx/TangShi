//
//  TCMyCommentsButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyCommentsButton.h"
@interface TCMyCommentsButton (){
    
    UIImageView     *headImage;
    UILabel         *nameLabel;
    UIButton        *type;
    UILabel         *commentsLabel;
    
    CGFloat          width;
    UILabel         *blackLabel;
}
@end
@implementation TCMyCommentsButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        CGFloat height = frame.size.height;
        
        headImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
        [self addSubview:headImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+10, headImage.top, 100, 15)];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        
        type = [[UIButton alloc] initWithFrame:CGRectMake(nameLabel.right, nameLabel.top, 50, 15)];
        [type setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        type.layer.cornerRadius = 3;
        type.titleLabel.font =[UIFont systemFontOfSize:13];
        [self addSubview:type];
        
        commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, nameLabel.bottom+5, width-headImage.right-15, 40)];
        commentsLabel.font = [UIFont systemFontOfSize:14];
        commentsLabel.textColor = [UIColor grayColor];
        commentsLabel.numberOfLines = 2;
        [self addSubview:commentsLabel];
        
        blackLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (height-20)/2, width, 20)];
        blackLabel.text = @"该动态已被删除";
        blackLabel.font = [UIFont systemFontOfSize:15];
        blackLabel.textColor = [UIColor grayColor];
        blackLabel.hidden = YES;
        [self addSubview:blackLabel];
    }
    return self;
}
- (void)commentsButton:(NSDictionary *)model{
    if ([model count]==0) {
        blackLabel.hidden = NO;
        headImage.hidden = YES;
        nameLabel.hidden = YES;
        type.hidden = YES;
        commentsLabel.hidden = YES;
    }else{
        blackLabel.hidden = YES;
        headImage.hidden = NO;
        nameLabel.hidden = NO;
        type.hidden = NO;
        commentsLabel.hidden = NO;
        NSArray  *imgArray = [model objectForKey:@"image"];
        NSDictionary *user = [model objectForKey:@"user_info"];
        if (imgArray.count>0) {
        [headImage sd_setImageWithURL:[NSURL URLWithString:[imgArray[0] objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
        } else {
        [headImage sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"head_url"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
        }
        
        nameLabel.text = [user objectForKey:@"nick_name"];
        CGSize size = [nameLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
        nameLabel.frame  =CGRectMake(headImage.right+10, headImage.top, size.width, 20);
        
        NSString *label =[[model objectForKey:@"user_info"] objectForKey:@"label"];
        CGSize labelSize = [label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
        if (!kIsEmptyString(label) && ![label isEqualToString:@"官方"]) {
            [type setTitle:label forState:UIControlStateNormal];
            type.hidden = NO;
            type.frame = CGRectMake(nameLabel.right+10, nameLabel.top+2, labelSize.width+10, 15);
            type.backgroundColor = UIColorFromRGB(0xf9c92b);
        }else if (!kIsEmptyString(label) && [label isEqualToString:@"官方"]){
            type.hidden = NO;
            [type setTitle:label forState:UIControlStateNormal];
            type.frame = CGRectMake(nameLabel.right+10, nameLabel.top+2, labelSize.width+10, 15);
            type.backgroundColor = kSystemColor;
        }else{
            type.hidden = YES;
        }
        
        commentsLabel.text = [model objectForKey:@"news"];
    }
}
@end
