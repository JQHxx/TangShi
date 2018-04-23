//
//  TCMyDynamicTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyDynamicModel.h"



typedef void(^ReviewClick)();

typedef void(^DynamicContentClickBlock)();

typedef void(^PraiseClickBlock)();

@protocol TCMyDynamicDelegate <NSObject>
@required

- (void)lookAllContent:(TCMyDynamicModel *)model;     //查看全部

- (void)deleteContent:(NSInteger)expert_id role_type:(NSInteger)role_type;      //删除

- (void)myLinSeletedContent:(NSInteger)user_id role_type:(NSInteger)role_type;      //点击标记区域

- (void)myLookTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic;      //查看话题

@optional
- (void)commentsContent:(NSInteger)expert_id User_id:(NSInteger)user_id role_type_ed:(NSInteger)role_type_ed;    //查看评论

- (void)myPreiseDynamic:(TCMyDynamicModel *)model;    //点赞

- (void)myLinkUserInfo:(TCMyDynamicModel *)model;
@end
@interface TCMyDynamicTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCMyDynamicDelegate> delegate;
/// 评论回调
@property (nonatomic, copy) ReviewClick reviewClick;
///  动态内容点击回调
@property (nonatomic, copy) DynamicContentClickBlock  dynamicContentClickBlock;
/// 点赞动态
@property (nonatomic, copy) PraiseClickBlock praiseClickBlock;

- (void)cellMyDynamicModel:(TCMyDynamicModel *)model;

+ (CGFloat)getDynamicContentTextHeightWithDynamic:(TCMyDynamicModel *)model;


@end
