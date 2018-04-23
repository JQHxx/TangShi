//
//  TCDynamicDetailViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CommentsSuccessBlock)(BOOL isDeleteComments);

typedef void(^LikeSuccessBlock)(NSInteger likeCount,NSInteger like_status);

@interface TCDynamicDetailViewController : BaseViewController

@property (nonatomic ,assign)NSInteger news_id;    //动态id

@property (nonatomic ,assign)NSInteger commented_user_id;  //被评论者id

@property (nonatomic ,assign)NSInteger role_type_ed;    //消息用户id

@property (nonatomic ,assign)NSInteger news_comment_id;  //评论id
// 评论，控制键盘 （“ 1”）
@property (nonatomic ,assign)NSInteger keyboradType;
/// 评论成功回调
@property (nonatomic, copy) CommentsSuccessBlock  commentsSuccessBlock;
/// 点赞成功回调
@property (nonatomic, copy) LikeSuccessBlock likeSuccessBlock;


@end
