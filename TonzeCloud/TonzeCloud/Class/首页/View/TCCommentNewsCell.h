//
//  TCCommentNewsCell.h
//  TonzeCloud
//
//  Created by vision on 17/10/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCommentNewsModel.h"

@protocol TCCommentNewsCellDelegate <NSObject>

//跳转的用户的个人主页
-(void)pushIntoPersonalVCWithIsSelf:(BOOL)isSelf userId:(NSInteger)user_id;
//跳转到文章详情
-(void)pushIntoArticelDetailsVCWithArticleInfo:(NSDictionary *)info;

@end

@interface TCCommentNewsCell : UITableViewCell

@property (nonatomic,weak)id<TCCommentNewsCellDelegate>cellDelegate;

-(void)commentNewsCellDisplayWithModel:(TCCommentNewsModel *)model;

+(CGFloat)getCommentNewsCellHeightWithModel:(TCCommentNewsModel *)model;

@end
