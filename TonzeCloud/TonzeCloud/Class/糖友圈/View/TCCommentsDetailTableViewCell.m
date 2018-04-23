//
//  TCCommentsDetailTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCommentsDetailTableViewCell.h"
#import "TCResponseView.h"
#import "TCReplyButton.h"
#import "TCSugarButton.h"
#import "EaseEmoji.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "TCPraiseSeleteButton.h"

@interface TCCommentsDetailTableViewCell ()<TCRespondViewDelegate,linkReplyDelegate>{
    TCResponseView          *myRespondView;
    TCPraiseSeleteButton    *praiseButton;
    UILabel                 *contentLabel;
    UIView                  *replyView;
    UIButton                *maxDynamicButton; //查看更多回复
    
    TCDynamicCommentsModel  *commentsModel;
}

@end
@implementation TCCommentsDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myRespondView = [[TCResponseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 52)];
        myRespondView.delegate = self;
        [self.contentView addSubview:myRespondView];
        
        praiseButton=[[TCPraiseSeleteButton alloc] initWithFrame:CGRectZero];
        [praiseButton addTarget:self action:@selector(praiseSelectd:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:praiseButton];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
        
        replyView=[[UIView alloc] initWithFrame:CGRectZero];
        replyView.backgroundColor = [UIColor colorWithHexString:@"0xf7f7f7"];
        [self.contentView addSubview:replyView];
        replyView.hidden=YES;
        
        //更多回复
        maxDynamicButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [maxDynamicButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        maxDynamicButton.titleLabel.font = kFontWithSize(15);
        [maxDynamicButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [maxDynamicButton addTarget:self action:@selector(getMoreReply:) forControlEvents:UIControlEventTouchUpInside];
        [replyView addSubview:maxDynamicButton];
    }
    return self;
}

- (void)cellCommentsReplyModel:(TCDynamicCommentsModel *)model{
    commentsModel = model;
    
    //用户信息
    [myRespondView dynamicCommentsViewModel:model];
    
    //点赞
    if (model.comment_user_id>0) {
        praiseButton.hidden=NO;
        praiseButton.title =model.like_count>0?[NSString stringWithFormat:@"%ld",(long)model.like_count]:@"赞";
        praiseButton.seleted = model.like_status;
        CGFloat btnWidth= [praiseButton.title sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]].width;
        praiseButton.frame =CGRectMake(kScreenWidth-btnWidth-35, 17, btnWidth+20, 50);
    }else{
        praiseButton.hidden=YES;
    }
    
    
    //文字内容
    contentLabel.text=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:model.content];
    CGFloat contentHeight = [contentLabel.text sizeWithLabelWidth:kScreenWidth-67 font:[UIFont systemFontOfSize:15]].height;
    contentLabel.frame =CGRectMake(57, myRespondView.bottom, kScreenWidth-67, contentHeight);
    
    NSArray *replyArr = model.reply;
    if (replyArr.count>0) {
        replyView.hidden=NO;
        
        for (UIView *view in replyView.subviews) {   //删除子视图
            if ([view isKindOfClass:[TCReplyButton class]]) {
                [view removeFromSuperview];
            }
        }
        
        CGFloat height = 0.0;
        NSInteger replyCount=replyArr.count>2?2:replyArr.count;
        for (int i=0; i<replyCount; i++) {
            TCReplyButton *replyBtn = [[TCReplyButton alloc] initWithFrame:CGRectMake(5, height,kScreenWidth-67, 0)];
            [replyBtn viewReplyDict:replyArr[i]];
            replyBtn.tag = i;
            replyBtn.delegate=self;
            
            [replyBtn addTarget:self action:@selector(replyCommentsDynamicAction:) forControlEvents:UIControlEventTouchUpInside];
            float replyHeight = [TCReplyButton rowReplyForObject:[replyArr[i] objectForKey:@"content"]];
            replyBtn.frame =CGRectMake(10, height, replyBtn.width-20, replyHeight+40);
            height = height+replyHeight+40;
            [replyView addSubview:replyBtn];
        }
        
        CGFloat btnH=0.0;
        if (model.reply_num>2) {
            btnH=20;
            maxDynamicButton.hidden=NO;
            NSString *moreText=[NSString stringWithFormat:@"%ld条回复",(long)model.reply_num];
            [maxDynamicButton setTitle:moreText forState:UIControlStateNormal];
            
            CGFloat moreBtnWidth = [moreText sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
            maxDynamicButton.frame =CGRectMake(10, height+5, moreBtnWidth+20, 20);
            [maxDynamicButton  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
        }else{
            btnH=0.0;
            maxDynamicButton.hidden=YES;
            maxDynamicButton.frame =CGRectZero;
        }
        replyView.frame = CGRectMake(57, contentLabel.bottom+10, kScreenWidth-67, height+btnH+10);
    }else{
        maxDynamicButton.hidden=YES;
        replyView.hidden=YES;
        replyView.frame = CGRectMake(57, contentLabel.bottom, kScreenWidth-67, 0);
    }
}

+ (CGFloat)getCommentReplyHeightForModel:(TCDynamicCommentsModel *)model{
    //评论内容高度
    NSString *commentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:model.content];
    CGFloat contentHeight = [commentStr sizeWithLabelWidth:kScreenWidth-67 font:[UIFont systemFontOfSize:15]].height;
    
    //回复区域高度
    CGFloat replyTotalHeight=0.0;
    if (model.reply.count>0) {
        CGFloat replyHeight=0.0;
        NSInteger replyCount=model.reply.count>2?2:model.reply.count;
        for (int i=0; i<replyCount; i++) {
            CGFloat tempHeight = [TCReplyButton rowReplyForObject:[model.reply[i] objectForKey:@"content"]];
            replyHeight +=tempHeight+40;
        }
        //更多回复高度
        CGFloat moreReplyHeight=model.reply_num>2?45:20;
    
        replyTotalHeight=replyHeight+moreReplyHeight;
    }
    return 54+contentHeight+replyTotalHeight+10;
}


#pragma mark   回复评论或删除评论
- (void)replyCommentsDynamicAction:(UIButton *)button{
    NSDictionary *dict = commentsModel.reply[button.tag];
    TCCommentReplyModel *model=[[TCCommentReplyModel alloc] init];
    [model setValues:dict];
    if (!model.is_self) {
        if ([_delegate respondsToSelector:@selector(commentsDetailCellReplyCommentWithReplyModel:parentCommentId:)]) {
            [_delegate commentsDetailCellReplyCommentWithReplyModel:model parentCommentId:commentsModel.news_comment_id];
        }
    }else{
        if ([_delegate respondsToSelector:@selector(commentsDeleteReply:)]) {
            [_delegate commentsDeleteReply:model];
        }
    }
}

#pragma mark -- Event response
#pragma mark 点赞
- (void)praiseSelectd:(TCPraiseSeleteButton *)sender{
    if ([_delegate respondsToSelector:@selector(commentsDetailCellDidClickPraisedWithModel:)]) {
        [_delegate commentsDetailCellDidClickPraisedWithModel:commentsModel];
    }
}

#pragma mark  --TCRespondViewDelegate
#pragma mark 获取用户信息
- (void)respondView{
    if ([_delegate respondsToSelector:@selector(commentsDetailCellDidClickUserPhotoWithUserId:)]) {
        [_delegate commentsDetailCellDidClickUserPhotoWithUserId:commentsModel];
    }
}

#pragma mark -- linkReplyDelegate
- (void)linkReply:(NSString *)linkContent{
    NSArray *linkArr = commentsModel.reply;
    NSInteger newsid = 0;
    NSInteger role_type = 0;
    for (NSDictionary *dict in linkArr) {
        if ([[dict objectForKey:@"comment_nick"] isEqualToString:linkContent]) {
            newsid = [[dict objectForKey:@"comment_user_id"] integerValue];
            role_type = [[dict objectForKey:@"role_type"] integerValue];
        }
        if ([[dict objectForKey:@"commented_nick"] isEqualToString:linkContent]) {
            newsid = [[dict objectForKey:@"commented_user_id"] integerValue];
            role_type = [[dict objectForKey:@"role_type_ed"] integerValue];
        }
    }
    if ([_delegate respondsToSelector:@selector(linkCommentsReplyContent:role_type:)]) {
        [_delegate linkCommentsReplyContent:newsid role_type:role_type];
    }

}
#pragma mark -- 更多回复
- (void)getMoreReply:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(commentsDetailCellGetMoreReplyWithCommentsModel:)]) {
        [_delegate commentsDetailCellGetMoreReplyWithCommentsModel:commentsModel];
    }
    
}
@end
