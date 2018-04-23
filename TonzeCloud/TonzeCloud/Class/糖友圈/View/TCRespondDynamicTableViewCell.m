//
//  TCRespondDynamicTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRespondDynamicTableViewCell.h"
#import "TCMyCommentsButton.h"
#import "MYCoreTextLabel.h"
#import "TCResponseView.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCRespondDynamicTableViewCell ()<MYCoreTextLabelDelegate,TCRespondViewDelegate>{
    
    TCResponseView  *respondView;
    UILabel         *replyContent;
    UILabel         *replyLab;
    UIView          *bgView;
    UIView            *lenView;

    TCMyCommentsButton  *commentsBtn;
    NSMutableArray      *seletedArr;
    TCMyCommentsModel   *myCommentsModel;
}
@property (nonatomic, strong) MYCoreTextLabel *contentLabel;
@property (nonatomic, strong) MYCoreTextLabel *replyLabel;

@end
@implementation TCRespondDynamicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        seletedArr = [[NSMutableArray alloc] init];
        
        respondView = [[TCResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        respondView.delegate = self;
        [self.contentView addSubview:respondView];
        
        [self.contentView addSubview:self.contentLabel];
        
        bgView = [[UIView alloc] initWithFrame:CGRectMake(_contentLabel.left, _contentLabel.bottom+5, _contentLabel.width, 60)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderWidth = 1;
        bgView.layer.borderColor = [[UIColor colorWithHexString:@"0xdcdcdc"] CGColor];
        [self.contentView addSubview:bgView];
        
        [bgView addSubview:self.replyLabel];
        
        replyLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,bgView.width-10, 20)];
        replyLab.textColor = [UIColor grayColor];
        replyLab.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:replyLab];
        
        commentsBtn = [[TCMyCommentsButton alloc] initWithFrame:CGRectMake(0, self.contentLabel.bottom+5, self.contentLabel.width, 70)];
        [commentsBtn addTarget:self action:@selector(dynamicDetailButton) forControlEvents:UIControlEventTouchUpInside];
        commentsBtn.backgroundColor = [UIColor bgColor_Gray];
        [bgView addSubview:commentsBtn];
        
        lenView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.bottom+10, kScreenWidth, 0)];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
    }
    return self;
}
- (void)cellRespondModel:(TCMyCommentsModel *)model{
    myCommentsModel = model;
    //头部
    [respondView responseViewModel:model type:1];
    
    //赋值
    NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:model.content];
    [self.contentLabel setText:[NSString stringWithFormat:@"回复%@：%@",[model.commented_user_info objectForKey:@"nick_name"],contentStr] customLinks:@[[model.commented_user_info objectForKey:@"nick_name"]] keywords:@[]];
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-60, [UIScreen mainScreen].bounds.size.height)];
    self.contentLabel.frame = CGRectMake(50, 54, kScreenWidth-60, size.height);
    
    //赋值
    NSDictionary *before_comment = model.before_comment;
    if (kIsDictionary(before_comment)) {
        NSString *content=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[before_comment objectForKey:@"content"]];
        NSInteger before_comment_status = [[before_comment objectForKey:@"before_comment_status"] integerValue];
        if (before_comment_status==1) {
            replyLab.hidden = YES;
            _replyLabel.hidden = NO;
            if ([[before_comment objectForKey:@"parent_id"] integerValue]==0) {
                [self.replyLabel setText:[NSString stringWithFormat:@"%@",content] customLinks:@[] keywords:@[@"关键字"]];
                
                NSDictionary *dict = @{@"name":[model.commented_user_info objectForKey:@"nick_name"],@"news":[model.commented_user_info objectForKey:@"user_id"]};
                [seletedArr addObject:dict];
            } else {
                [self.replyLabel setText:[NSString stringWithFormat:@" %@回复 %@：%@",[[before_comment objectForKey:@"comment_user_info"] objectForKey:@"nick_name"],[[before_comment objectForKey:@"commented_user_info"] objectForKey:@"nick_name"],content] customLinks:@[[[before_comment objectForKey:@"comment_user_info"] objectForKey:@"nick_name"],[[before_comment objectForKey:@"commented_user_info"] objectForKey:@"nick_name"]] keywords:@[]];
                
                NSDictionary *dict = @{@"name":[model.commented_user_info objectForKey:@"nick_name"],@"news":[model.commented_user_info objectForKey:@"user_id"]};
                [seletedArr addObject:dict];
                
                NSDictionary *dict1 = @{@"name":[[before_comment objectForKey:@"comment_user_info"] objectForKey:@"nick_name"],@"news":[[before_comment objectForKey:@"comment_user_info"] objectForKey:@"user_id"]};
                [seletedArr addObject:dict1];
                
                NSDictionary *dict2 = @{@"name":[[before_comment objectForKey:@"commented_user_info"] objectForKey:@"nick_name"],@"news":[[before_comment objectForKey:@"commented_user_info"] objectForKey:@"user_id"]};
                [seletedArr addObject:dict2];
                
            }

        }else if (before_comment_status==0){
            replyLab.hidden = NO;
            _replyLabel.hidden = YES;
            replyLab.text = @"该回复／评论已被审核";
        }else{
            replyLab.hidden = NO;
            _replyLabel.hidden = YES;
            replyLab.text = @"该回复／评论已被删除";
        }
    }
   
    size = [self.replyLabel sizeThatFits:CGSizeMake(bgView.width-10, [UIScreen mainScreen].bounds.size.height)];
    bgView.frame =CGRectMake(_contentLabel.left, _contentLabel.bottom+5, _contentLabel.width, size.height+80);
    self.replyLabel.frame = CGRectMake(5,5, bgView.width-10, size.height);
    
    commentsBtn.frame =CGRectMake(0,self.replyLabel.bottom+5, self.contentLabel.width, 70);
    [commentsBtn commentsButton:model.news_info];
    
    lenView.frame = CGRectMake(0, bgView.bottom+10, kScreenWidth, 10);
}
#pragma mark -- 返回文本高度
+ (CGFloat)tableView:(UITableView *)tableView rowrespondHeightForObject:(id)object{
    
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(50, 68, kScreenWidth-60, 0)];
    //设置普通文本的属性
    [contentLabel setText:object customLinks:@[] keywords:@[]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];
    CGSize size = [contentLabel sizeThatFits:CGSizeMake( kScreenWidth-60, [UIScreen mainScreen].bounds.size.height)];
    return size.height+10;
}
#pragma mark -- 返回评论源高度
+ (CGFloat)tableView:(UITableView *)tableView rowDetailHeightForObject:(id)object array:(NSArray *)arr{
    
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(68, 70, kScreenWidth-73-20, 0)];
    contentLabel.lineSpacing = 1.5;
    contentLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    [contentLabel setText:object customLinks:arr keywords:@[]];
    //设置普通文本的属性
    contentLabel.textFont = [UIFont systemFontOfSize:14.f];   //设置普通内容文字大小
    contentLabel.textColor = [UIColor grayColor];   // 设置普通内容文字颜色
    //设置关键字的属性
    contentLabel.customLinkFont = [UIFont systemFontOfSize:14];
    contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    CGSize size = [contentLabel sizeThatFits:CGSizeMake( kScreenWidth-70, [UIScreen mainScreen].bounds.size.height)];
    return size.height+10;
}

#pragma mark -- 查看动态详情
- (void)dynamicDetailButton{
    if ([_delegate respondsToSelector:@selector(respondDynamicDetailContentModel:)]) {
        [_delegate respondDynamicDetailContentModel:myCommentsModel];
    }
}
#pragma mark -- getter
- (MYCoreTextLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(50, 58+10, kScreenWidth-60, 0)];
        _contentLabel.tag = 100;
        //设置普通文本的属性
        _contentLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _contentLabel.textColor = [UIColor blackColor];   // 设置普通内容文字颜色
        _contentLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置关键字的属性
        _contentLabel.customLinkFont = [UIFont systemFontOfSize:16];
        _contentLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _contentLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    }
    return _contentLabel;
}

- (MYCoreTextLabel *)replyLabel
{
    if (!_replyLabel) {
        _replyLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(5, 10,bgView.width-10, 20)];
        _replyLabel.lineSpacing = 1.5;
        _replyLabel.wordSpacing = 0.5;
        _replyLabel.tag = 101;
        //设置普通文本的属性
        _replyLabel.textFont = [UIFont systemFontOfSize:14.f];   //设置普通内容文字大小
        _replyLabel.textColor = [UIColor grayColor];   // 设置普通内容文字颜色
        _replyLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置关键字的属性
        _replyLabel.customLinkFont = [UIFont systemFontOfSize:14];
        _replyLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _replyLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    }
    return _replyLabel;
}
#pragma mark -- TCRespondViewDelegate
#pragma mark -- 点击用户信息
- (void)respondView{
    if ([_delegate respondsToSelector:@selector(respondDynamicContentModel:)]) {
        [_delegate respondDynamicContentModel:myCommentsModel];
    }
}
#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);

    if (tag==100) {
        if ([_delegate respondsToSelector:@selector(didDespondUserContent:role_type:)]) {
            [_delegate didDespondUserContent:[[myCommentsModel.commented_user_info objectForKey:@"user_id"] integerValue] role_type:myCommentsModel.role_type_ed];
        }
    } else {
        NSInteger newsID = 0;
        NSInteger role_type = 0;
        NSDictionary *comment_user_info = [myCommentsModel.before_comment objectForKey:@"comment_user_info"];
        NSDictionary *commented_user_info = [myCommentsModel.before_comment objectForKey:@"commented_user_info"];
        
        if ([[comment_user_info objectForKey:@"nick_name"] isEqualToString:clickString]) {
            newsID = [[comment_user_info objectForKey:@"user_id"] integerValue];
            role_type=[[myCommentsModel.before_comment objectForKey:@"role_type"] integerValue];
        }
        if ([[commented_user_info objectForKey:@"nick_name"] isEqualToString:clickString]) {
            newsID = [[commented_user_info objectForKey:@"user_id"] integerValue];
            role_type=[[myCommentsModel.before_comment objectForKey:@"role_type_ed"] integerValue];
        }
        if ([_delegate respondsToSelector:@selector(didDespondUserContent:role_type:)]) {
            [_delegate didDespondUserContent:newsID role_type:role_type];
        }
    }
 
}
- (void)linkMoretag:(NSInteger)tag{

        if ([_delegate respondsToSelector:@selector(linkMoreModel:)]) {
            [_delegate linkMoreModel:myCommentsModel];
        }
}
@end
