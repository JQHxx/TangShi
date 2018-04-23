
//
//  TCMyCommentsTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyCommentsTableViewCell.h"
#import "TCMyCommentsButton.h"
#import "TCResponseView.h"
#import "MYCoreTextLabel.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCMyCommentsTableViewCell ()<TCRespondViewDelegate,MYCoreTextLabelDelegate>{
    
    TCResponseView  *respondView;

    TCMyCommentsButton  *commentsBtn;
    TCMyCommentsModel   *myCommentsModel;
    UIView              *lenView;

}
@property (nonatomic, strong) MYCoreTextLabel *contentLabel;
@end
@implementation TCMyCommentsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //个人信息
        respondView = [[TCResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 54)];
        respondView.delegate = self;
        [self.contentView addSubview:respondView];
        
        //内容
        [self.contentView addSubview:self.contentLabel];
        
        //动态信息
        commentsBtn = [[TCMyCommentsButton alloc] initWithFrame:CGRectMake(_contentLabel.left, _contentLabel.bottom+5, _contentLabel.width, 70)];
        [commentsBtn addTarget:self action:@selector(dynamicDetailButton) forControlEvents:UIControlEventTouchUpInside];
        commentsBtn.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:commentsBtn];
        
        lenView = [[UIView alloc] initWithFrame:CGRectMake(0, commentsBtn.bottom+10, kScreenWidth, 0)];
        lenView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:lenView];
    }
    return self;
}
- (void)cellMyCommentsModel:(TCMyCommentsModel *)model{
    myCommentsModel = model;
    //头部
    [respondView responseViewModel:model type:1];
    
    //赋值
    NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:model.content];
    NSMutableArray *atTempArray = [[NSMutableArray alloc] init];
    NSArray *atArray=[model.news_info valueForKey:@"at_json"];
    if (kIsArray(atArray)) {
        for (NSDictionary *dict in atArray) {
            [atTempArray addObject:[dict objectForKey:@"nick_name"]];
        }
    }
    [self.contentLabel setText:contentStr customLinks:atTempArray keywords:@[@""]];
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-60, [UIScreen mainScreen].bounds.size.height)];
    self.contentLabel.frame = CGRectMake(50, 54, kScreenWidth-60, size.height);

    
    commentsBtn.frame =CGRectMake(_contentLabel.left, _contentLabel.bottom+5, _contentLabel.width, 70);
    [commentsBtn commentsButton:model.news_info];
    
    lenView.frame = CGRectMake(0, commentsBtn.bottom+10, kScreenWidth, 10);
}
#pragma mark -- 返回文本高度
+ (CGFloat)tableView:(UITableView *)tableView rowCommentsHeightForObject:(id)object{
    NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:object];
    MYCoreTextLabel *contentLabel =[[MYCoreTextLabel alloc]initWithFrame: CGRectMake(65, 70, kScreenWidth-66, 0)];
    contentLabel.lineSpacing = 1.5;
    contentLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    [contentLabel setText:contentStr customLinks:@[] keywords:@[@"关键字"]];
    contentLabel.textFont = [UIFont systemFontOfSize:16.f];

    CGSize size = [contentLabel sizeThatFits:CGSizeMake( kScreenWidth-66, [UIScreen mainScreen].bounds.size.height)];
    return size.height+10;
}

#pragma mark -- 查看动态详情
- (void)dynamicDetailButton{
    if ([_delegate respondsToSelector:@selector(mydynamicDetailModel:)]) {
        [_delegate mydynamicDetailModel:myCommentsModel];
    }
}
#pragma mark -- getter
- (MYCoreTextLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(56, 58, kScreenWidth-66, 0)];
        _contentLabel.lineSpacing = 1.5;
        _contentLabel.wordSpacing = 0.5;
        //设置普通文本的属性
        _contentLabel.textFont = [UIFont systemFontOfSize:16.f];   //设置普通内容文字大小
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x313131"];   // 设置普通内容文字颜色
        _contentLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等

    }
    return _contentLabel;
}
#pragma mark -- TCRespondViewDelegate
#pragma mark -- 点击用户信息
- (void)respondView{
    if ([_delegate respondsToSelector:@selector(myCommentsContentModel:)]) {
        [_delegate myCommentsContentModel:myCommentsModel];
    }
}
#pragma mark --MYCoreTextLabelDelegate
#pragma mark -- 点击标记区域
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
       NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([_delegate respondsToSelector:@selector(myLinkSeleted:)]) {
        [_delegate myLinkSeleted:myCommentsModel];
    }
}
#pragma msrk -- 点击更多区域
- (void)linkMoretag:(NSInteger)tag{
    if ([_delegate respondsToSelector:@selector(myLinkMoreModel:)]) {
        [_delegate myLinkMoreModel:myCommentsModel];
    }
}
@end
