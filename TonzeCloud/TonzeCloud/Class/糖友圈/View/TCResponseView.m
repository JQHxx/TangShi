//
//  TCResponseView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCResponseView.h"

@interface TCResponseView (){
    
    UIButton        *headImgViewBtn;
    UIButton        *nickNameBtn;
    UIButton        *theTitle;
    UILabel         *timeLabel;
}
@end
@implementation TCResponseView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        headImgViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, 7, 40, 40)];
        headImgViewBtn.layer.cornerRadius = 20;
        headImgViewBtn.clipsToBounds = YES;
        [headImgViewBtn addTarget:self action:@selector(myDynamic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:headImgViewBtn];
        
        nickNameBtn = [[UIButton alloc] initWithFrame:CGRectMake(headImgViewBtn.right+5, headImgViewBtn.top, 60, 20)];
        nickNameBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [nickNameBtn setTitleColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];
        [nickNameBtn addTarget:self action:@selector(myDynamic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nickNameBtn];
        
        theTitle = [[UIButton alloc] initWithFrame:CGRectMake(nickNameBtn.right+15, nickNameBtn.top, 40, 20)];
        theTitle.titleLabel.font = [UIFont systemFontOfSize:13];
        [theTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        theTitle.layer.cornerRadius = 3;
        [self addSubview:theTitle];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom+10, kScreenWidth/2, 20)];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        [self addSubview:timeLabel];

    }
    return self;
}
- (void)responseViewModel:(TCMyCommentsModel *)model type:(NSInteger)type{
    NSDictionary *userDict= nil;
    if (type==2) {
        userDict = model.commented_user_info;
    } else {
        userDict = model.comment_user_info;
    }
    //头部
    headImgViewBtn.frame =CGRectMake(18, 14, 30, 30);
    headImgViewBtn.layer.cornerRadius = 15;
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:[userDict objectForKey:@"head_url"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    nickNameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nickNameBtn setTitle:[userDict objectForKey:@"nick_name"] forState:UIControlStateNormal];
    CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickNameBtn.frame =  CGRectMake(headImgViewBtn.right+8,headImgViewBtn.top, size.width, 15);

    //用户类型
    NSString *label =[model.comment_user_info objectForKey:@"label"];
    CGSize labelSize = [label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
    if (!kIsEmptyString(label) && ![label isEqualToString:@"官方"]) {
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.hidden = NO;
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(label) && [label isEqualToString:@"官方"]){
        theTitle.hidden = NO;
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = kSystemColor;
    }else{
        theTitle.hidden = YES;
    }
    
    timeLabel.font = [UIFont systemFontOfSize:13];
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    timeLabel.frame =CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom+5, kScreenWidth/2, 15);
}


- (void)dynamicCommentsViewModel:(TCDynamicCommentsModel *)model{
    if (model.comment_user_id>0) {
        //头部
        headImgViewBtn.hidden=NO;
        nickNameBtn.hidden=NO;
        theTitle.hidden=NO;
        timeLabel.hidden=NO;
        
        headImgViewBtn.frame =CGRectMake(18, 14, 30, 30);
        headImgViewBtn.layer.cornerRadius = 15;
        [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:model.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
        
        [nickNameBtn setTitle:model.nick_name forState:UIControlStateNormal];
        CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
        nickNameBtn.frame =CGRectMake(headImgViewBtn.right+6,headImgViewBtn.top, size.width+5, 15);
        
        CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
        if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
            [theTitle setTitle:model.label forState:UIControlStateNormal];
            theTitle.hidden = NO;
            theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
            theTitle.backgroundColor = UIColorFromRGB(0xf9c92b);
        }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
            theTitle.hidden = NO;
            [theTitle setTitle:model.label forState:UIControlStateNormal];
            theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
            theTitle.backgroundColor = kSystemColor;
        }else{
            theTitle.hidden = YES;
        }
        
        NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
        timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.frame =CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom, kScreenWidth/2, 15);
    }else{
        headImgViewBtn.hidden=YES;
        nickNameBtn.hidden=YES;
        theTitle.hidden=YES;
        timeLabel.hidden=YES;
        
    }
}


- (void)myPraiseModel:(TCMyPraiseModel *)model{
    //头部
    headImgViewBtn.frame =CGRectMake(18, 14, 30, 30);
    headImgViewBtn.layer.cornerRadius = 15;
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:model.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
//
    [nickNameBtn setTitle:model.nick_name forState:UIControlStateNormal];
    nickNameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickNameBtn.frame =   CGRectMake(headImgViewBtn.right+8,headImgViewBtn.top, size.width, 15);
    
    CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        [theTitle setTitle:model.label forState:UIControlStateNormal];
        theTitle.hidden = NO;
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        theTitle.hidden = NO;
        [theTitle setTitle:model.label forState:UIControlStateNormal];
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = kSystemColor;
    }else{
        theTitle.hidden = YES;
    }
    
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    timeLabel.frame =CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom+5, kScreenWidth/2, 20);
}

- (void)myMaxReplyDict:(NSDictionary *)dict{
    _dict = dict;
    //头部
    [nickNameBtn setTitle:[_dict objectForKey:@"nick_name"] forState:UIControlStateNormal];
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"head_url"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    nickNameBtn.frame =  CGRectMake(headImgViewBtn.right+6,10, size.width, 15);
    
    NSString *label = [dict objectForKey:@"label"];
    CGSize labelSize = [label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
    if (!kIsEmptyString(label) && ![label isEqualToString:@"官方"]) {
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.hidden = NO;
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(label) && [label isEqualToString:@"官方"]){
        theTitle.hidden = NO;
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = kSystemColor;
    }else{
        theTitle.hidden = YES;
    }
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:[dict objectForKey:@"add_time"] format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.frame =CGRectMake(headImgViewBtn.right+6, nickNameBtn.bottom+5, kScreenWidth/2, 15);
}
- (void)setDict:(NSDictionary *)dict{
    _dict = dict;
    //头部
    [nickNameBtn setTitle:[_dict objectForKey:@"name"] forState:UIControlStateNormal];
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickNameBtn.frame =  CGRectMake(headImgViewBtn.right+8,10, size.width+10, 20);

    NSString *label = [dict objectForKey:@"label"];
    CGSize labelSize = [label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
    if (!kIsEmptyString(label) && ![label isEqualToString:@"官方"]) {
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.hidden = NO;
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(label) && [label isEqualToString:@"官方"]){
        theTitle.hidden = NO;
        [theTitle setTitle:label forState:UIControlStateNormal];
        theTitle.frame = CGRectMake(nickNameBtn.right+10, nickNameBtn.top, labelSize.width+10, 16);
        theTitle.backgroundColor = kSystemColor;
    }else{
        theTitle.hidden = YES;
    }
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:[_dict objectForKey:@"time"] format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    timeLabel.frame =CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom+5, kScreenWidth/2, 15);
}
#pragma mark -- 点击用户信息
- (void)myDynamic{
    if ([_delegate respondsToSelector:@selector(respondView)]) {
        [_delegate respondView];
    }
}

@end
