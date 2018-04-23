//
//  TCWeChatTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/3/27.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWeChatTableViewCell.h"
#import "UIImage+Extend.h"

#define LEFT_WITH   (kScreenWidth>750?55:52.5)
#define RIGHT_WITH  (kScreenWidth>750?89:73)

@interface TCWeChatTableViewCell (){
    UILabel       *timeLabel;
    UIImageView   *headImageView;
    UIImageView   *bgImageView;
    UILabel       *contentLabel;
}

@end

@implementation TCWeChatTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor=[UIColor bgColor_Gray];
        
        timeLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.font=[UIFont systemFontOfSize:10.0f];
        timeLabel.textColor=[UIColor whiteColor];
        timeLabel.textAlignment=NSTextAlignmentCenter;
        timeLabel.backgroundColor=[UIColor lightGrayColor];
        timeLabel.layer.cornerRadius=4;
        timeLabel.clipsToBounds=YES;
        [self.contentView addSubview:timeLabel];
        
        headImageView=[[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:headImageView];
        
        bgImageView =[[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        
        contentLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        contentLabel.font=[UIFont systemFontOfSize:16];
        contentLabel.textColor=[UIColor blackColor];
        [self.contentView addSubview:contentLabel];
        
    }
    return self;
}

-(void)wechatCellDisplayWithMessage:(TCMessageModel *)message{
    CGFloat topMargin=10;
    if (message.showMessageTime) {
        topMargin=40;
        timeLabel.hidden=NO;
        timeLabel.text=kIsEmptyString(message.messageTime)?@"":message.messageTime;
        CGSize contentSize=[message.messageTime boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) withTextFont:[UIFont systemFontOfSize:10.0]];
        timeLabel.frame=CGRectMake((kScreenWidth-contentSize.width)/2, 10, contentSize.width+10, 20);
        
    }else{
        topMargin=10;
        timeLabel.hidden=YES;
    }
    
    CGFloat maxWith=kScreenWidth-LEFT_WITH-RIGHT_WITH;
    CGSize contentSize=[message.messageText boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:16]];
    if (message.messageSenderType==MessageSenderTypeUser) {
        headImageView.frame=CGRectMake(kScreenWidth-50, topMargin, 40, 40);
        NSString *imgUrl = [NSUserDefaultsInfos getValueforKey:@"headimage"];
        [headImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_IM_head_user"]];
        
        bgImageView.frame=CGRectMake(kScreenWidth-(contentSize.width+20)-LEFT_WITH, topMargin, contentSize.width+20, contentSize.height+20);
        bgImageView.image=[[UIImage imageNamed:@"wechatback2"] stretchableImageWithLeftCapWidth:8 topCapHeight:24];
        
        contentLabel.frame=CGRectMake(bgImageView.left+12, topMargin+10, contentSize.width, contentSize.height);
        contentLabel.text=message.messageText;
    }else{   //机器人客服
        headImageView.frame=CGRectMake(10, topMargin, 40, 40);
        headImageView.image=[UIImage imageNamed:@"ic_IM_head_kefu"];
        
        bgImageView.frame=CGRectMake(LEFT_WITH, topMargin, contentSize.width+20, contentSize.height+20);
        bgImageView.image=[[UIImage imageNamed:@"wechatback1"] stretchableImageWithLeftCapWidth:8 topCapHeight:24];
        
        contentLabel.frame=CGRectMake(LEFT_WITH+12, topMargin+10, contentSize.width, contentSize.height);
        contentLabel.text=message.messageText;
    }
}

+(CGFloat)wechatCellRowHeightWithMessage:(TCMessageModel *)message{
    CGFloat topMargin=message.showMessageTime?40:10;
    CGFloat maxWith=kScreenWidth-LEFT_WITH-RIGHT_WITH;
    CGSize contentSize=[message.messageText boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:16]];
    
    return contentSize.height+topMargin+30;
}

@end
