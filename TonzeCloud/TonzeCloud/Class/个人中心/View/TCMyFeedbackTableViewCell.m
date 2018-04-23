//
//  TCMyFeedbackTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyFeedbackTableViewCell.h"
@interface TCMyFeedbackTableViewCell(){
    
    UILabel *contentLabel;
    UILabel *timeLabel;
    UIView  *readView;
    UILabel *backLabel;
}
@end
@implementation TCMyFeedbackTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.numberOfLines = 2;
        contentLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self.contentView addSubview:contentLabel];
        
        readView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth-20, 23, 10, 10)];
        readView.backgroundColor = [UIColor redColor];
        readView.layer.cornerRadius = 5;
        [self.contentView addSubview:readView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 51, kScreenWidth/2, 15)];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor colorWithHexString:@"0x939393"];
        [self.contentView addSubview:timeLabel];
        
        backLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-70, 50, 50, 15)];
        backLabel.text = @"已回复";
        backLabel.textAlignment = NSTextAlignmentRight;
        backLabel.font = [UIFont systemFontOfSize:14];
        backLabel.textColor = kbgBtnColor;
        [self.contentView addSubview:backLabel];
    }
    return self;
}
- (void)myFeedbackWithModel:(TCMyFeedbackModel *)model{
    
    contentLabel.text = model.feedback_content;
    CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
    contentLabel.frame = CGRectMake(18, 10, kScreenWidth-36, size.height<20?18:36);
    
    readView.hidden = model.is_read;
    
    timeLabel.text = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.feedback_time format:@"yyyy-MM-dd HH:mm"];

    backLabel.hidden = !model.is_reply;
}

@end
