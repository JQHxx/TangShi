//
//  TCCommentNewsCell.m
//  TonzeCloud
//
//  Created by vision on 17/10/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCommentNewsCell.h"
#import "MYCoreTextLabel.h"

@interface TCCommentNewsCell ()<MYCoreTextLabelDelegate>{
    UIButton         *headImageBtn;    //头像
    UIButton         *nickNameBtn;     //昵称
    UILabel          *callLbl;         //职称
    UILabel          *commentTimeLbl;  //评论时间
    MYCoreTextLabel  *contentLbl;      //主评论内容
    UIView           *bgView;          //被评论区域
    MYCoreTextLabel  *replyContentLbl; //评论文章内容
    UILabel          *tempContentLbl;  //
    
    UIView           *articleBgView;   //
    UIImageView      *coverImageView;  //文章封面图
    UILabel          *articleTitleLbl; //文章标题
    
    TCCommentNewsModel      *commentNewsModel;
    TCCommentUserModel      *user;                //评论者
    TCCommentUserModel      *commentedUser;       //被回复者
    TCCommentUserModel      *beforeCommentUser;   //上一条评论者
    TCCommentUserModel      *beforeCommentedUser; //上一条被回复者
}


@end

@implementation TCCommentNewsCell

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
        contentLbl.customLinkFont = [UIFont systemFontOfSize:16];         //设置关键词字体
        contentLbl.customLinkColor = kbgBtnColor;                         //设置关键字颜色
        contentLbl.customLinkBackColor = [UIColor whiteColor];            //设置关键字高亮背景色
        contentLbl.tag=100;
        [self.contentView addSubview:contentLbl];
        
        bgView=[[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor=[UIColor whiteColor];
        bgView.layer.borderWidth = 1;
        bgView.layer.borderColor = [[UIColor colorWithHexString:@"0xdcdcdc"] CGColor];
        [self.contentView addSubview:bgView];
        
        //评论文章
        replyContentLbl = [[MYCoreTextLabel alloc]initWithFrame: CGRectZero];
        replyContentLbl.lineSpacing = 1.5;
        replyContentLbl.wordSpacing = 0.5;
        replyContentLbl.textFont = [UIFont systemFontOfSize:14.f];     //设置普通内容文字大小
        replyContentLbl.textColor = [UIColor grayColor];               // 设置普通内容文字颜色
        replyContentLbl.delegate = self;
        replyContentLbl.tag=101;
        replyContentLbl.customLinkFont = [UIFont systemFontOfSize:14]; //设置关键词字体
        replyContentLbl.customLinkColor = kbgBtnColor;                 //设置关键字颜色
        replyContentLbl.customLinkBackColor = [UIColor whiteColor];    //设置关键字高亮背景色
        [bgView addSubview:replyContentLbl];
        
        tempContentLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        tempContentLbl.textColor=[UIColor grayColor];
        tempContentLbl.font=[UIFont systemFontOfSize:14];
        [bgView addSubview:tempContentLbl];
        tempContentLbl.hidden=YES;
        
        //文章显示区域
        articleBgView=[[UIView alloc] initWithFrame:CGRectZero];
        articleBgView.backgroundColor=[UIColor bgColor_Gray];
        articleBgView.userInteractionEnabled=YES;
        [self.contentView addSubview:articleBgView];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectArticleBg:)];
        [articleBgView addGestureRecognizer:tap];
        
        //文章封面图
        coverImageView=[[UIImageView alloc] initWithFrame:CGRectZero];
        [articleBgView addSubview:coverImageView];
        
        //文章标题
        articleTitleLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        articleTitleLbl.numberOfLines=2;
        articleTitleLbl.textColor=[UIColor grayColor];
        articleTitleLbl.font=[UIFont systemFontOfSize:14];
        [articleBgView addSubview:articleTitleLbl];
        
    }
    return self;
}

-(void)commentNewsCellDisplayWithModel:(TCCommentNewsModel *)model{
    commentNewsModel=model;
    
    /****评论者用户信息****/
    user=[[TCCommentUserModel alloc] init];
    [user setValues:model.comment_user_info];
    
    //头像
    [headImageBtn sd_setImageWithURL:[NSURL URLWithString:user.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    //昵称
    [nickNameBtn setTitle:user.nick_name forState:UIControlStateNormal];
    CGFloat nicklblWidith = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
    nickNameBtn.frame =  CGRectMake(headImageBtn.right+5,headImageBtn.top, nicklblWidith, 20);
    
    //职称
    if (!kIsEmptyString(user.label)) {
        callLbl.hidden=NO;
        if ([user.label isEqualToString:@"官方"]) {
            callLbl.backgroundColor = kSystemColor;
        }else{
            callLbl.backgroundColor=UIColorFromRGB(0xf9c92b);
        }
        callLbl.hidden=NO;
        callLbl.text=user.label;
        CGSize labelSize = [user.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
        callLbl.frame = CGRectMake(nickNameBtn.right+5, nickNameBtn.top, labelSize.width+10, 20);
    }else{
        callLbl.hidden = YES;
    }
    
    //评论时间
    NSString *timeStr = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"] ;
    commentTimeLbl.text = [[TCHelper sharedTCHelper] dateToRequiredString:timeStr];
    CGFloat timelblWidith = [commentTimeLbl.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]].width;
    commentTimeLbl.frame=CGRectMake(headImageBtn.right+10, nickNameBtn.bottom, timelblWidith, 20);
    
    //评价内容
    if (model.commented_user_id==0) {
        [contentLbl setText:model.content customLinks:@[] keywords:@[]];
        CGFloat contentHeight = [contentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
        contentLbl.frame = CGRectMake(50, commentTimeLbl.bottom+5, kScreenWidth-50, contentHeight);
        
        bgView.frame=CGRectZero;
        articleBgView.frame=CGRectMake(50, contentLbl.bottom, kScreenWidth-60, 60);
        
        replyContentLbl.frame=CGRectZero;
        tempContentLbl.hidden=YES;
    }else{
        //被回复用户信息
        commentedUser=[[TCCommentUserModel alloc] init];
        [commentedUser setValues:model.commented_user_info];
        
        NSString *contentStr=[NSString stringWithFormat:@"回复%@：%@",commentedUser.nick_name,model.content];
        [contentLbl setText:contentStr customLinks:@[commentedUser.nick_name] keywords:@[]];
        CGFloat contentHeight = [contentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
        contentLbl.frame = CGRectMake(50, commentTimeLbl.bottom+5, kScreenWidth-50, contentHeight);
        
        //上一条评论信息
        TCCommentNewsModel *beforeCommentModel=[[TCCommentNewsModel alloc] init];
        [beforeCommentModel setValues:model.before_comment];
        
        CGFloat replyContentHeight=0.0;
        if (beforeCommentModel.before_comment_status==1) {
            tempContentLbl.hidden=YES;
            //上一条评论者用户信息
            beforeCommentUser=[[TCCommentUserModel alloc] init];
            [beforeCommentUser setValues:beforeCommentModel.comment_user_info];
            //上一条被回复用户信息
            beforeCommentedUser=[[TCCommentUserModel alloc] init];
            [beforeCommentedUser setValues:beforeCommentModel.commented_user_info];
            
            //评论文章内容
            NSString *replyContentStr=nil;
            if (beforeCommentModel.commented_user_id==0) {
                replyContentStr=[NSString stringWithFormat:@"%@：%@",beforeCommentUser.nick_name,beforeCommentModel.content];
                [replyContentLbl setText:replyContentStr customLinks:@[beforeCommentUser.nick_name] keywords:@[]];
            }else{
                replyContentStr=[NSString stringWithFormat:@"%@回复%@：%@",beforeCommentUser.nick_name,beforeCommentedUser.nick_name,beforeCommentModel.content];
                [replyContentLbl setText:replyContentStr customLinks:@[beforeCommentUser.nick_name,beforeCommentedUser.nick_name] keywords:@[]];
            }
            replyContentHeight = [replyContentLbl sizeThatFits:CGSizeMake(kScreenWidth-55, CGFLOAT_MAX)].height;
            replyContentLbl.frame = CGRectMake(0, 5, kScreenWidth-55, replyContentHeight);
        }else{
            tempContentLbl.hidden=NO;
            replyContentHeight=30;
            tempContentLbl.text=@"该评论已被删除";
            tempContentLbl.frame = CGRectMake(15, 5, kScreenWidth-55, replyContentHeight);
        }
        
        articleBgView.frame=CGRectMake(51,contentLbl.bottom+replyContentHeight+10, kScreenWidth-62, 59);
        bgView.frame=CGRectMake(50, contentLbl.bottom, kScreenWidth-60, replyContentHeight+70);
    }
    
    coverImageView.frame=CGRectMake(10, 10, 40, 40);
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:model.article_info[@"image"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    articleTitleLbl.frame=CGRectMake(coverImageView.right+10, 5, kScreenWidth-130, 50);
    articleTitleLbl.text=model.article_info[@"title"];
}

+(CGFloat)getCommentNewsCellHeightWithModel:(TCCommentNewsModel *)model{
    CGFloat totalHeight;
    
    MYCoreTextLabel *tempContentLbl = [[MYCoreTextLabel alloc] initWithFrame: CGRectZero];
    tempContentLbl.lineSpacing = 1.5;
    tempContentLbl.wordSpacing = 0.5;
    tempContentLbl.textFont = [UIFont systemFontOfSize:16.f];
    if (model.commented_user_id==0) {
        [tempContentLbl setText:model.content customLinks:@[] keywords:@[]];
        CGFloat contentHeight = [tempContentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
        totalHeight=contentHeight;
    }else{
        TCCommentUserModel *commentedUser=[[TCCommentUserModel alloc] init];
        [commentedUser setValues:model.commented_user_info];
        
        NSString *contentStr=[NSString stringWithFormat:@"回复%@：%@",commentedUser.nick_name,model.content];
        [tempContentLbl setText:contentStr customLinks:@[commentedUser.nick_name] keywords:@[]];
        CGFloat contentHeight = [tempContentLbl sizeThatFits:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX)].height+5;
        
        //上一条评论信息
        TCCommentNewsModel *beforeCommentModel=[[TCCommentNewsModel alloc] init];
        [beforeCommentModel setValues:model.before_comment];
        
        CGFloat replyContentHeight=0.0;
        
        if (beforeCommentModel.before_comment_status==1) {
            //上一条评论者用户信息
            TCCommentUserModel *beforeCommentUser=[[TCCommentUserModel alloc] init];
            [beforeCommentUser setValues:beforeCommentModel.comment_user_info];
            //上一条被回复用户信息
            TCCommentUserModel *beforeCommentedUser=[[TCCommentUserModel alloc] init];
            [beforeCommentedUser setValues:beforeCommentModel.commented_user_info];
            
            //评论文章内容
            MYCoreTextLabel *replyContentLbl = [[MYCoreTextLabel alloc]initWithFrame: CGRectZero];
            replyContentLbl.lineSpacing = 1.5;
            replyContentLbl.wordSpacing = 0.5;
            replyContentLbl.textFont = [UIFont systemFontOfSize:14.f];     //设置普通内容文字大小
            replyContentLbl.textColor = [UIColor grayColor];               // 设置普通内容文字颜色
            NSString *replyContentStr=nil;
            if (beforeCommentModel.commented_user_id==0) {
                replyContentStr=[NSString stringWithFormat:@"%@：%@",beforeCommentUser.nick_name,beforeCommentModel.content];
                [replyContentLbl setText:replyContentStr customLinks:@[beforeCommentUser.nick_name] keywords:@[]];
            }else{
                replyContentStr=[NSString stringWithFormat:@"%@回复%@：%@",beforeCommentUser.nick_name,beforeCommentedUser.nick_name,beforeCommentModel.content];
                [replyContentLbl setText:replyContentStr customLinks:@[beforeCommentUser.nick_name,beforeCommentedUser.nick_name] keywords:@[]];
            }
            replyContentHeight = [replyContentLbl sizeThatFits:CGSizeMake(kScreenWidth-55, CGFLOAT_MAX)].height;
        }else{
            replyContentHeight = 30;
        }
        
        totalHeight=contentHeight+replyContentHeight+10;
    }
    
    return totalHeight+54+70;
}

#pragma mark -- Event Response
#pragma mark 跳转到个人信息页
-(void)goIntoUserInfo{
    NSInteger userId=[[NSUserDefaultsInfos getValueforKey:kUserID] integerValue];
    BOOL isSelf=user.user_id==userId;
    if ([_cellDelegate respondsToSelector:@selector(pushIntoPersonalVCWithIsSelf:userId:)]) {
        [_cellDelegate pushIntoPersonalVCWithIsSelf:isSelf userId:user.user_id];
    }
}

#pragma mark 跳转到文章详情
-(void)selectArticleBg:(id )sender{
    NSDictionary *articleDict=commentNewsModel.article_info;
    NSDictionary *userInfo=@{@"id":[NSNumber numberWithInteger:commentNewsModel.article_id],@"title":articleDict[@"title"],@"cover":articleDict[@"image"]};
    if ([_cellDelegate respondsToSelector:@selector(pushIntoArticelDetailsVCWithArticleInfo:)]) {
        [_cellDelegate pushIntoArticelDetailsVCWithArticleInfo:userInfo];
    }
}

#pragma mark -- Custom Delegate
#pragma mark MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
    MyLog(@"clickString:%@,linkType:%ld\n",clickString,(long)linkType);
    
    NSInteger selfUserId=[[NSUserDefaultsInfos getValueforKey:kUserID] integerValue];
    NSInteger userId;
    BOOL isSelf;
    if(tag==100){  //主评论内容
        isSelf=commentedUser.user_id==selfUserId;
        userId=commentedUser.user_id;
    }else{ //回复评论内容
        if ([beforeCommentUser.nick_name isEqualToString:clickString]) {
            userId=beforeCommentUser.user_id;
            isSelf=selfUserId==beforeCommentUser.user_id;
        }else{
            userId=beforeCommentedUser.user_id;
            isSelf=beforeCommentedUser.user_id==selfUserId;
        }
    }
    if ([_cellDelegate respondsToSelector:@selector(pushIntoPersonalVCWithIsSelf:userId:)]) {
        [_cellDelegate pushIntoPersonalVCWithIsSelf:isSelf userId:userId];
    }
}

@end
