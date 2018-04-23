//
//  TCCommentsDetailTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDynamicCommentsModel.h"

@protocol TCCommentsReplyDelegate <NSObject>

//回复评论
-(void)commentsDetailCellReplyCommentWithReplyModel:(TCCommentReplyModel *)replyModel parentCommentId:(NSInteger)parentCommentId;
//删除回复
-(void)commentsDeleteReply:(TCCommentReplyModel *)replyModel;
 //点击用户头像
- (void)commentsDetailCellDidClickUserPhotoWithUserId:(TCDynamicCommentsModel *)userModel;
//点赞评论
-(void)commentsDetailCellDidClickPraisedWithModel:(TCDynamicCommentsModel *)commentsModel;
//获取更多回复
-(void)commentsDetailCellGetMoreReplyWithCommentsModel:(TCDynamicCommentsModel *)model;

- (void)linkCommentsReplyContent:(NSInteger)linkContent role_type:(NSInteger)role_type;          //点击被标记区域


@end
@interface TCCommentsDetailTableViewCell : UITableViewCell

@property (nonatomic ,weak) id<TCCommentsReplyDelegate>delegate;

- (void)cellCommentsReplyModel:(TCDynamicCommentsModel *)model;

+ (CGFloat)getCommentReplyHeightForModel:(TCDynamicCommentsModel *)model;

@end
