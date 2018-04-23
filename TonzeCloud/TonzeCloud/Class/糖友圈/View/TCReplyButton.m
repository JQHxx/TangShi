//
//  TCReplyButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCReplyButton.h"
#import "MYCoreTextLabel.h"
#import "EaseConvertToCommonEmoticonsHelper.h"


@interface TCReplyButton ()<MYCoreTextLabelDelegate>{
    
    UILabel                   *timeLabel;
    UILabel                   *contentLabel;
}
@property (nonatomic, strong) MYCoreTextLabel *picContainerView;

@end
@implementation TCReplyButton
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.picContainerView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _picContainerView.bottom, kScreenWidth/2, 20)];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor grayColor];
        [self addSubview:timeLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, timeLabel.bottom,kScreenWidth-87, 0)];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        contentLabel.numberOfLines = 0;
        [self addSubview:contentLabel];
    }
    return self;
}


- (void)viewReplyDict:(NSDictionary *)dict{
    NSString *replyStr = [NSString stringWithFormat:@"%@ 回复 %@",[dict objectForKey:@"comment_nick"],[dict objectForKey:@"commented_nick"]];
    [self.picContainerView setText:replyStr customLinks:@[[dict objectForKey:@"comment_nick"],[dict objectForKey:@"commented_nick"]] keywords:@[@"关键字"]];
    CGSize size = [self.picContainerView sizeThatFits:CGSizeMake(kScreenWidth-87, [UIScreen mainScreen].bounds.size.height)];
    self.picContainerView.frame = CGRectMake(0, 10,size.width, size.height);
    
     NSString *timeStr =[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[dict objectForKey:@"add_time"] format:@"MM-dd HH:mm"];
    timeLabel.text = [[TCHelper sharedTCHelper]dateToRequiredString:timeStr];
    timeLabel.frame =CGRectMake(5, _picContainerView.bottom, kScreenWidth/2, 20);
    
    contentLabel.text = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[dict objectForKey:@"content"]];
    size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-87 font:[UIFont systemFontOfSize:15]];
    contentLabel.frame = CGRectMake(5, timeLabel.bottom, kScreenWidth-87, size.height);
}

+ (CGFloat)rowReplyForObject:(id)object{
    CGSize size = [object sizeWithLabelWidth:kScreenWidth-87 font:[UIFont systemFontOfSize:15]];
    return size.height+10;
}

#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([_delegate respondsToSelector:@selector(linkReply:)]) {
        [_delegate linkReply:clickString];
    }
    
}
#pragma mark -- getter
- (UIView *)picContainerView{
    if (_picContainerView==nil) {
        _picContainerView = [[MYCoreTextLabel alloc]initWithFrame: CGRectMake(5, 5,kScreenWidth-87, 20)];
        
        //设置普通文本的属性
        _picContainerView.textFont = [UIFont systemFontOfSize:15.f];   //设置普通内容文字大小
        _picContainerView.textColor = [UIColor blackColor];   // 设置普通内容文字颜色
        _picContainerView.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        
        //设置指定文本的属性
        _picContainerView.customLinkFont = [UIFont systemFontOfSize:15.f];
        _picContainerView.customLinkColor = kbgBtnColor;
        _picContainerView.customLinkBackColor = [UIColor whiteColor];
    }
    return _picContainerView;
}

@end
