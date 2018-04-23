//
//  EaseMessageQuestionnarieCell.m
//  TangShiService
//
//  Created by vision on 17/12/13.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "EaseMessageQuestionnarieCell.h"
#import "EaseBubbleView+Questionnarie.h"

static const CGFloat kCellHeight =120.0f;

@implementation EaseMessageQuestionnarieCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.hasRead.hidden =YES;
        self.selectionStyle =UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(BOOL)isCustomBubbleView:(id)model{
    return YES;
}

-(void)setCustomModel:(id<IMessageModel>)model{
    UIImage *image = model.image;
    if (!image) {
        [self.bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:[UIImage imageNamed:model.failImageName]];
    } else {
        _bubbleView.imageView.image = image;
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

-(void)setCustomBubbleView:(id<IMessageModel>)model{
    [_bubbleView setupQuestionnarieBubbleView];
    _bubbleView.imageView.image=[UIImage imageNamed:@"imageDownloadFail"];
}

-(void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model{
   _bubbleView.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat bubbleViewHeight = 80;// 气泡背景图高度
    CGFloat nameLabelHeight = 15;// 昵称label的高度
    if (model.isSender) {
        _bubbleView.frame =
        CGRectMake([UIScreen mainScreen].bounds.size.width - 273.5, nameLabelHeight, 213, bubbleViewHeight);
    }else{
        _bubbleView.frame = CGRectMake(55, nameLabelHeight, 213, bubbleViewHeight);
    }
    
    [_bubbleView updateQuestionnarieMargin:bubbleMargin];
    
    
    // 这里强制调用内部私有方法
//    [_bubbleView _setupQuestionnarieBubbleMarginConstraints];
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model{
    return kCellHeight;
}

- (void)setModel:(id<IMessageModel>)model{
    [super setModel:model];
 
    NSDictionary *ext = [[NSDictionary alloc] initWithDictionary:model.message.ext];
    if ([ext[@"msg_type"] isEqualToString:@"question"]) {
        NSDictionary *msgtypeDic =[[NSDictionary alloc] initWithDictionary:ext[@"msg_info"]];
        if (kIsDictionary(msgtypeDic)) {
            _bubbleView.questionNameLabel.text =msgtypeDic[@"name"];
            NSString *imageUrl = [NSString stringWithFormat:@"%@",msgtypeDic[@"image_url"]];
            if (imageUrl.length > 0) {
                [_bubbleView.questionIconView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"msg_ic_examen"]];
            }else{
                _bubbleView.questionIconView.image = [UIImage imageNamed:@"msg_ic_examen"];
            }
        }
    }else if ([ext[@"msg_type"] isEqualToString:@"userInfo"]){
        _bubbleView.questionNameLabel.text =@"基本信息";
        _bubbleView.questionIconView.image = [UIImage imageNamed:@"msg_ic_user"];
    }else if ([ext[@"msg_type"] isEqualToString:@"bloodRecord"]){
        _bubbleView.questionNameLabel.text =@"糖档案";
        _bubbleView.questionIconView.image = [UIImage imageNamed:@"msg_ic_files"];
    }else if ([ext[@"msg_type"] isEqualToString:@"checkForm"]){
        _bubbleView.questionNameLabel.text =@"检查单";
        _bubbleView.questionIconView.image = [UIImage imageNamed:@"msg_ic_check"];
    }else if ([ext[@"msg_type"] isEqualToString:@"comment"]){
        _bubbleView.questionNameLabel.text =@"评论";
        _bubbleView.questionIconView.image = [UIImage imageNamed:@"msg_ic_evaluation"];
    }
    _hasRead.hidden = YES;//名片消息不显示已读
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

@end
