//
//  TCMyPraiseTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyPraiseTableViewCell.h"
#import "TCResponseView.h"
#import "TCMyCommentsButton.h"
#import "MYCoreTextLabel.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCMyPraiseTableViewCell ()<TCRespondViewDelegate,MYCoreTextLabelDelegate>{
    
    TCResponseView      *myRespondView;
    TCMyCommentsButton  *commentsBtn;
    UIView              *bgView;
    UILabel             *titleLabel;
    UIView              *lenView;

    TCMyPraiseModel     *myPriaiseModel;
}
@property (nonatomic, strong) MYCoreTextLabel *commentsLabel;

@end
@implementation TCMyPraiseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myRespondView = [[TCResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 58)];
        myRespondView.delegate = self;
        [self.contentView addSubview:myRespondView];
        
        UIImageView *praiseImg = [[UIImageView alloc] initWithFrame:CGRectMake(50, myRespondView.bottom+2, 18, 17)];
        praiseImg.image = [UIImage imageNamed:@"choose_thumbs"];
        [self addSubview:praiseImg];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(praiseImg.right, praiseImg.top, kScreenWidth/2, 20)];
        titleLabel.text = @"我赞了这条动态";
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:titleLabel];
        
        bgView  = [[UIView alloc] initWithFrame:CGRectMake(50, titleLabel.bottom+10, kScreenWidth-60, 0)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderWidth = 1;
        bgView.layer.borderColor = [[UIColor colorWithHexString:@"0xdcdcdc"] CGColor];
        [self.contentView addSubview:bgView];
        
        [bgView addSubview:self.commentsLabel];
        
        commentsBtn = [[TCMyCommentsButton alloc] initWithFrame:CGRectMake(praiseImg.left, praiseImg.bottom+5, kScreenWidth-60, 70)];
        [commentsBtn addTarget:self action:@selector(dynamicDetailButton) forControlEvents:UIControlEventTouchUpInside];
        commentsBtn.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:commentsBtn];
        
        lenView = [[UIView alloc] initWithFrame:CGRectMake(0, commentsBtn.bottom+15, kScreenWidth, 0)];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
    }
    return self;
}

- (void)cellMyPraiseModel:(TCMyPraiseModel *)model type:(NSInteger)type{
    myPriaiseModel = model;
    
    [myRespondView myPraiseModel:model];
    [commentsBtn commentsButton:model.news_info];
    bgView.hidden = model.type==1?NO:YES;
    if (model.type==1) {
        titleLabel.text = type==1?@"我赞了这条评论":@"ta赞了你的评论";
        NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[model.comment_info objectForKey:@"content"]];
        NSString *replyStr = [NSString stringWithFormat:@"%@：%@",[[model.comment_info objectForKey:@"comment_user_info"] objectForKey:@"nick_name"],contentStr];
        [self.commentsLabel setText:replyStr customLinks:@[[[model.comment_info objectForKey:@"comment_user_info"] objectForKey:@"nick_name"]] keywords:@[]];
        CGSize size = [self.commentsLabel sizeThatFits:CGSizeMake(kScreenWidth-70, [UIScreen mainScreen].bounds.size.height)];
        bgView.frame = CGRectMake(50, titleLabel.bottom+10, kScreenWidth-60, size.height+10);
        self.commentsLabel.frame = CGRectMake(5, 5, kScreenWidth-60-10, size.height);
        commentsBtn.frame = CGRectMake(bgView.left, bgView.bottom, kScreenWidth-60, 70);
    }else{
        titleLabel.text = type==1?@"我赞了这条动态":@"ta赞了你的动态";
        commentsBtn.frame = CGRectMake(bgView.left, titleLabel.bottom+10, kScreenWidth-60, 70);
    }
    
    lenView.frame = CGRectMake(0, commentsBtn.bottom+15, kScreenWidth, 10);
}

+ (CGFloat)tableView:(UITableView *)tableView rowPraiseForObject:(id)object{
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(55, 70, kScreenWidth-70, 0)];
    contentLabel.lineSpacing = 1.5;
    contentLabel.wordSpacing = 0.5;
    //设置关键字的属性
    contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
    contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色

    //设置普通文本的属性
    [contentLabel setText:object customLinks:@[] keywords:@[]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];
    CGSize size = [contentLabel sizeThatFits:CGSizeMake( kScreenWidth-70, [UIScreen mainScreen].bounds.size.height)];
    return size.height+10;

}
#pragma mark -- getter
- (UIView *)commentsLabel{
    if (_commentsLabel==nil) {
        _commentsLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(5, 0,bgView.width-10, 20)];
        _commentsLabel.lineSpacing = 1.5;
        _commentsLabel.wordSpacing = 0.5;
        //设置普通文本的属性
        _commentsLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _commentsLabel.textColor = [UIColor blackColor];   // 设置普通内容文字颜色
        _commentsLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        //设置关键字的属性
        _commentsLabel.customLinkFont = [UIFont systemFontOfSize:16];
        _commentsLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _commentsLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色

    }
    return _commentsLabel;
}
#pragma mark --MYCoreTextLabelDelegate
- (void)linkMoretag:(NSInteger)tag{
    if ([_delegate respondsToSelector:@selector(myPraiseLinkMoreText:)]) {
        [_delegate myPraiseLinkMoreText:myPriaiseModel];
    }
}
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([_delegate respondsToSelector:@selector(myPraiseLinkSeleted:role_type:)]) {
        [_delegate myPraiseLinkSeleted:[[myPriaiseModel.comment_info objectForKey:@"comment_user_id"] integerValue] role_type:[[myPriaiseModel.comment_info objectForKey:@"role_type"] integerValue]];
    }
}
#pragma mark --TCRespondViewDelegate
- (void)respondView{
    if ([_delegate respondsToSelector:@selector(myPraiseUserInfoContent:role_type:)]) {
        [_delegate myPraiseUserInfoContent:myPriaiseModel.user_id role_type:myPriaiseModel.role_type];
    }
}
- (void)dynamicDetailButton{
    if ([_delegate respondsToSelector:@selector(myPraiseContent:)]) {
        [_delegate myPraiseContent:myPriaiseModel];
    }
}
@end
