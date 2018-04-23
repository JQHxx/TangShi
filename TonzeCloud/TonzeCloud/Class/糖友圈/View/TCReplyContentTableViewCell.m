//
//  TCReplyContentTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCReplyContentTableViewCell.h"
#import "MYCoreTextLabel.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCReplyContentTableViewCell ()<MYCoreTextLabelDelegate>{

    UILabel                   *timeLabel;
    UILabel                   *contentLabel;
    TCMaxDynamicModel         *maxModel;
}
@property (nonatomic, strong) MYCoreTextLabel *picContainerView;

@end

@implementation TCReplyContentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.picContainerView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, _picContainerView.bottom, kScreenWidth/2, 20)];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, timeLabel.bottom, kScreenWidth-30, 0)];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
    }
    return self;
}
- (void)cellReplyContentModel:(TCMaxDynamicModel *)model{
    maxModel = model;
    
    NSString *replyStr = [NSString stringWithFormat:@"%@ 回复 %@",model.comment_nick,model.commented_nick];
    [self.picContainerView setText:replyStr customLinks:@[model.comment_nick,model.commented_nick] keywords:@[]];
    CGSize size = [self.picContainerView sizeThatFits:CGSizeMake(kScreenWidth/2, [UIScreen mainScreen].bounds.size.height)];
    self.picContainerView.frame = CGRectMake(13, 10, kScreenWidth-20, size.height);
    
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    
    contentLabel.text =[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:model.content];
    size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-30 font:[UIFont systemFontOfSize:15]];
    contentLabel.frame = CGRectMake(18, timeLabel.bottom, kScreenWidth-30, size.height);
}

+ (CGFloat)tableView:(UITableView *)tableView rowReplyContentForObject:(id)object{
    NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:object];
    CGSize size = [contentStr sizeWithLabelWidth:kScreenWidth-30 font:[UIFont systemFontOfSize:15]];
    return size.height+10;
}

#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    NSInteger newsID = 0;
    NSInteger role_type = 0;
    if ([maxModel.comment_nick isEqualToString:clickString]) {
        newsID = maxModel.comment_user_id;
        role_type = maxModel.role_type;
    }else if ([maxModel.commented_nick isEqualToString:clickString]){
        newsID = maxModel.commented_user_id;
        role_type = maxModel.role_type_ed;
    }
    
    if ([_delegate respondsToSelector:@selector(linkReplyContent:role_type:)]) {
        [_delegate linkReplyContent:newsID role_type:role_type];
    }

}

#pragma mark -- getter
- (UIView *)picContainerView{
    if (_picContainerView==nil) {
        _picContainerView = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(10, 10,kScreenWidth/2, 20)];
        
        //设置普通文本的属性
        _picContainerView.textFont = [UIFont systemFontOfSize:15.f];   //设置普通内容文字大小
        _picContainerView.textColor = [UIColor blackColor];   // 设置普通内容文字颜色
        _picContainerView.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置关键字的属性
        _picContainerView.customLinkFont = [UIFont systemFontOfSize:15];
        _picContainerView.customLinkColor = kbgBtnColor;  //设置关键字颜色
        _picContainerView.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    }
    return _picContainerView;
}
@end
