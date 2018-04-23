//
//  TCFeedbackDetailTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFeedbackDetailTableViewCell.h"

@interface TCFeedbackDetailTableViewCell(){
    
    UILabel *timeLabel;
    UILabel *contentLabel;
    UIView  *bgView;
    UILabel *porpmtLabel;
}

@end

@implementation TCFeedbackDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, kScreenWidth-30, 20)];
        timeLabel.textColor = [UIColor colorWithHexString:@"0x939393"];
        timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:timeLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.numberOfLines = 0;
        contentLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self.contentView addSubview:contentLabel];
        
        bgView = [[UIView alloc] initWithFrame:CGRectMake(18, timeLabel.bottom+5, 4, 20)];
        bgView.backgroundColor = kbgBtnColor;
        [self.contentView addSubview:bgView];
        bgView.hidden = YES;
        
        porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.right+8, bgView.top+3, kScreenWidth/2, 15)];
        porpmtLabel.font = [UIFont systemFontOfSize:15];
        porpmtLabel.text = @"官方回复";
        porpmtLabel.textColor = kbgBtnColor;
        [self.contentView addSubview:porpmtLabel];
        porpmtLabel.hidden = YES;
    }
    return self;
}
- (void)cellFeedbackDetailDict:(NSDictionary *)dict isBack:(BOOL)isBack{
    if (isBack==YES) {
        NSString *timeStr =[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[dict objectForKey:@"feedback_time"] format:@"yyy-MM-dd HH:mm"];
        timeLabel.text = timeStr;
        contentLabel.text = [dict objectForKey:@"feedback_content"];
        CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
        contentLabel.frame = CGRectMake(18, timeLabel.bottom+5, kScreenWidth-36, size.height);
    } else {
        NSString *timeStr =[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[dict objectForKey:@"add_time"] format:@"yyy-MM-dd HH:mm"];
        timeLabel.text = timeStr;

        bgView.hidden = NO;
        porpmtLabel.hidden = NO;
        
        contentLabel.text=[dict objectForKey:@"content"];
        CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
        contentLabel.frame = CGRectMake(18, bgView.bottom+5, kScreenWidth-36, size.height);
    }
    
}
@end
