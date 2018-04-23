//
//  TCCommentArticleCell.h
//  TonzeCloud
//
//  Created by vision on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCommentArticleModel.h"

@protocol TCCommentArticleCellDelegate <NSObject>

//跳转到个人主页
-(void)commentArticleCellPushIntoPersanlInfoVCWithUserId:(NSInteger)user_id isSelf:(BOOL)is_self;
//触发回复或删除
-(void)commentArticleCellReplyCommentActionWithReply:(TCArticleReplyModel *)replyModel isSelf:(BOOL)is_self parentCommentId:(NSInteger)parentCommentId;
//  查看全部
- (void)didClickcLookAllCommentCell:(UITableViewCell *)cell;

@end


@interface TCCommentArticleCell : UITableViewCell

@property (nonatomic,weak)id<TCCommentArticleCellDelegate>cellDelegate;

-(void)commentArticleCellDisplayWithModel:(TCCommentArticleModel *)model;

+(CGFloat)getCommentArticleCellHeightWithModel:(TCCommentArticleModel *)model;

@end
