//
//  TCDynamicTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyDynamicModel.h"
@protocol TCDynamicDetailDelegate <NSObject>
@required
- (void)myDynamicDelete:(TCMyDynamicModel *)model;      //删除动态

- (void)myDynamicDetailComment:(TCMyDynamicModel *)model;      //发表评论

- (void)myDynamicDetailContent:(TCMyDynamicModel *)userModel;      //个人信息

- (void)myLinkDetailSeleted:(NSInteger)expert_id role_type:(NSInteger)role_type;      //点击其他区域

- (void)myDynamicDetailPraise:(TCMyDynamicModel *)model type:(NSInteger)type;      //点赞

- (void)myDynamicTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic;      //动态详情

@end
@interface TCDynamicTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCDynamicDetailDelegate> delegate;

- (void)cellDynamicDetailModel:(TCMyDynamicModel *)model;

+ (CGFloat)getCellContentHeightWithModel:(TCMyDynamicModel *)model;


@end
