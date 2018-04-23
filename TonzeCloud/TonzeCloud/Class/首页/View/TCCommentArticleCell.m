//
//  TCCommentArticleCell.m
//  TonzeCloud
//
//  Created by vision on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCommentArticleCell.h"
#import "MYCoreTextLabel.h"
#import "TCReplyButton.h"

@interface TCCommentArticleCell ()<MYCoreTextLabelDelegate,linkReplyDelegate>{
    UIButton         *headImageBtn;    //头像
    UIButton         *nickNameBtn;     //昵称
    UILabel          *callLbl;         //职称
    UILabel          *commentTimeLbl;  //评论时间
    MYCoreTextLabel  *contentLbl;      //主评论内容
    UIView           *replyView;
    UIButton         *moreReplyButton;
    
    
    TCCommentArticleModel      *commentArticleModel;
}


@end

@implementation TCCommentArticleCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        headImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 40, 40)];
        headImageBtn.layer.cornerRadius = 20;
        headImageBtn.clipsToBounds = YES;
        [headImageBtn addTarget:self action:@selector(goIntoUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:headImageBtn];
        
        //昵称
        nickNameBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        nickNameBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [nickNameBtn setTitleColor:[UIColor colorWithHexString:@"0x313131"] forState:UIControlStateNormal];
        [nickNameBtn addTarget:self action:@selector(goIntoUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nickNameBtn];
        
        //职称
        callLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        callLbl.font = [UIFont systemFontOfSize:13];
        callLbl.textColor=[UIColor whiteColor];
        callLbl.layer.cornerRadius = 3;
        callLbl.backgroundColor=UIColorFromRGB(0xf9c92b);
        callLbl.textAlignment=NSTextAlignmentCenter;
        callLbl.clipsToBounds=YES;
        [self.contentView addSubview:callLbl];
        
        //评论时间
        commentTimeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        commentTimeLbl.font = [UIFont systemFontOfSize:12];
        commentTimeLbl.textColor = [UIColor colorWithHexString:@"0x959595"];
        [self.contentView addSubview:commentTimeLbl];
        
        //主评论内容
        contentLbl = [[MYCoreTextLabel alloc] initWithFrame: CGRectZero];
        contentLbl.lineSpacing = 1.5;
        contentLbl.wordSpacing = 0.5;
        contentLbl.textFont = [UIFont systemFontOfSize:16.f];              //设置普通内容文字大小
        contentLbl.textColor = [UIColor colorWithHexString:@"0x313131"];   // 设置普通内容文字颜色
        contentLbl.delegate = self;
        contentLbl.tag=100;
        [self.contentView addSubview:contentLbl];
        
        replyView=[[UIView alloc] initWithFrame:CGRectZero];
        replyView.backgroundColor = [UIColor colorWithHexString:@"0xf7f7f7"];
        [self.contentView addSubview:replyView];
        replyView.hidden=YES;
        
        //更多回复
        moreReplyButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [moreReplyButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        moreReplyButton.titleLabel.font = kFontWithSize(15);
        [moreReplyButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [moreReplyButton addTarget:self action:@selector(getMoreCommentReply:) forControlEvents:UIControlEventTouchUpInside];
        [replyView addSubview:moreReplyButton];
        
        
    }
    return self;
}

-(void)commentArticleCellDisplayWithModel:(TCCommentArticleModel *)model{
    commentArticleModel=model;
    
    /****评论者用户信息****/
    //头像
    [headImageBtn sd_setImageWithURL:[NSURL URLWithString:model.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    //昵称
    [nickNameBtn setTitle:model.nick_name forState:UIControlStateNormal];
    CGFloat nicklblWidith = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
    nickNameBtn.frame =  CGRectMake(headImageBtn.right+5,headImageBtn.top, nicklblWidith, 20);
    
    //职称
    if (!kIsEmptyString(model.label)) {
        callLbl.hidden=NO;
        if ([model.label isEqualToString:@"官方"]) {
            callLbl.backgroundColor = kSystemColor;
        }else{
            callLbl.backgroundColor=UIColorFromRGB(0xf9c92b);
        }
        callLbl.hidden=NO;
        callLbl.text=model.label;
        CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
        callLbl.frame = CGRectMake(nickNameBtn.right+5, nickNameBtn.top, labelSize.width+10, 20);
    }else{
        callLbl.hidden = YES;
    }
    
    //评论时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    commentTimeLbl.text = [[TCHelper sharedTCHelper] dateToRequiredString:timeStr];
    CGFloat timelblWidith = [commentTimeLbl.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
    commentTimeLbl.frame=CGRectMake(headImageBtn.right+10, nickNameBtn.bottom, timelblWidith, 20);
    
    [contentLbl setText:model.content customLinks:@[] keywords:@[]];
    CGFloat contentHeight = [contentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
    contentLbl.frame = CGRectMake(50, commentTimeLbl.bottom+5, kScreenWidth-50, contentHeight);
    
    //评价内容
    if (model.reply_num>0) {
        replyView.hidden=NO;
    
        NSArray *replyArr=model.reply;
        
        for (UIView *view in replyView.subviews) {   //删除子视图
            if ([view isKindOfClass:[TCReplyButton class]]) {
                [view removeFromSuperview];
            }
        }
        
        CGFloat height = 0.0;
        NSInteger replyCount = 0;
        if (!model.islookAllComment) {
             replyCount =replyArr.count>2?2:replyArr.count;
        }else{
             replyCount = replyArr.count;
        }
        for (int i=0; i<replyCount; i++) {
            TCReplyButton *replyBtn = [[TCReplyButton alloc] initWithFrame:CGRectMake(5, height,kScreenWidth-67, 0)];
            [replyBtn viewReplyDict:replyArr[i]];
            replyBtn.tag = i;
            replyBtn.delegate=self;
            [replyBtn addTarget:self action:@selector(replyCommentsArcticleAction:) forControlEvents:UIControlEventTouchUpInside];
            float replyHeight = [TCReplyButton rowReplyForObject:[replyArr[i] objectForKey:@"content"]];
            replyBtn.frame =CGRectMake(10, height, replyBtn.width-20, replyHeight+40);
            height = height+replyHeight+40;
            [replyView addSubview:replyBtn];
        }
        
        CGFloat btnH=0.0;
        if (model.reply_num>2 && !model.islookAllComment) {
            btnH=20;
            moreReplyButton.hidden=NO;
            NSString *moreText=[NSString stringWithFormat:@"%ld条回复",(long)model.reply_num];
            [moreReplyButton setTitle:moreText forState:UIControlStateNormal];
            
            CGFloat moreBtnWidth = [moreText sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
            moreReplyButton.frame =CGRectMake(10, height+5, moreBtnWidth+20, 20);
            [moreReplyButton  layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
        }else{
            btnH=0.0;
            moreReplyButton.hidden=YES;
            moreReplyButton.frame =CGRectZero;
        }
        replyView.frame = CGRectMake(57, contentLbl.bottom, kScreenWidth-67, height+btnH+10);
        
    }else{
        replyView.hidden=YES;
        replyView.frame = CGRectZero;
    }
}
+(CGFloat)getCommentArticleCellHeightWithModel:(TCCommentArticleModel *)model{
    
    MYCoreTextLabel *tempContentLbl = [[MYCoreTextLabel alloc] initWithFrame: CGRectZero];
    tempContentLbl.lineSpacing = 1.5;
    tempContentLbl.wordSpacing = 0.5;
    tempContentLbl.textFont = [UIFont systemFontOfSize:16.f];
    
    [tempContentLbl setText:model.content customLinks:@[] keywords:@[]];
    CGFloat contentHeight = [tempContentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
    
    CGFloat replyTotalHeight=0.0;
    if (model.reply_num>0) {
        
        CGFloat replyHeight=0.0;
        NSInteger replyCount= 0;
        if (!model.islookAllComment) {
            replyCount=model.reply.count>2?2:model.reply.count;
        }else{
            replyCount=model.reply.count;
        }
        for (int i=0; i<replyCount; i++) {
            CGFloat tempHeight = [TCReplyButton rowReplyForObject:[model.reply[i] objectForKey:@"content"]];
            replyHeight +=tempHeight+40;
        }
        //更多回复高度
        CGFloat moreReplyHeight=model.reply_num>2?45:20;
        replyTotalHeight=replyHeight+moreReplyHeight;
    }
    
    return contentHeight+54+replyTotalHeight;
}
#pragma mark -- Event Response
#pragma mark 更多回复
-(void)getMoreCommentReply:(UIButton *)sender{
    if ([_cellDelegate respondsToSelector:@selector(didClickcLookAllCommentCell:)]) {
        [_cellDelegate didClickcLookAllCommentCell:self];
    }
}
#pragma mark 选择回复内容
-(void)replyCommentsArcticleAction:(TCReplyButton *)button{
    NSDictionary *replyDict=commentArticleModel.reply[button.tag];
    TCArticleReplyModel *replyModel=[[TCArticleReplyModel alloc] init];
    [replyModel setValues:replyDict];
    if ([_cellDelegate respondsToSelector:@selector(commentArticleCellReplyCommentActionWithReply:isSelf:parentCommentId:)]) {
        [_cellDelegate commentArticleCellReplyCommentActionWithReply:replyModel isSelf:[replyModel.is_self boolValue] parentCommentId:commentArticleModel.article_comment_id];
    }
}
#pragma mark 跳转到个人信息页
-(void)goIntoUserInfo{
    if ([_cellDelegate respondsToSelector:@selector(commentArticleCellPushIntoPersanlInfoVCWithUserId:isSelf:)]) {
        [_cellDelegate commentArticleCellPushIntoPersanlInfoVCWithUserId:commentArticleModel.comment_user_id isSelf:[commentArticleModel.is_self boolValue]];
    }
}
#pragma mark -- Custom Delegate
#pragma mark MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    MyLog(@"clickString:%@,linkType:%ld\n",clickString,(long)linkType);
   
}
#pragma mark linkReplyDelegate
#pragma mark 点击回复内容里被标记的区域
- (void)linkReply:(NSString *)linkContent{
    MyLog(@"linkContent:%@",linkContent);
    NSArray *linkArr = commentArticleModel.reply;
    NSInteger user_id = 0;
    NSInteger userID=[[NSUserDefaultsInfos getValueforKey:kUserID] integerValue];
    for (NSDictionary *dict in linkArr) {
        if ([[dict objectForKey:@"comment_nick"] isEqualToString:linkContent]) {
            user_id = [[dict objectForKey:@"comment_user_id"] integerValue];
        }
        if ([[dict objectForKey:@"commented_nick"] isEqualToString:linkContent]) {
            user_id = [[dict objectForKey:@"commented_user_id"] integerValue];
        }
    }
    BOOL isSelf=user_id==userID;
    if ([_cellDelegate respondsToSelector:@selector(commentArticleCellPushIntoPersanlInfoVCWithUserId:isSelf:)]) {
        [_cellDelegate commentArticleCellPushIntoPersanlInfoVCWithUserId:user_id isSelf:isSelf];
    }
}
@end
