//
//  TCTopicThatCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyDynamicModel.h"

typedef enum : NSUInteger {
    TopicCellTypeHome,          //首页
    TopicCellTypeTopicDetail,   //话题详情
} TopicCellType;

@protocol TCTopicCellDelegate <NSObject>

//  点击标记区域
- (void)didClickTagLinkSeletedContent:(NSString *)string  clickStrId:(NSInteger)clickStrId  role_type:(NSInteger)role_type topic_delete_status:(BOOL)topic_delete_status  topic:(NSString *)topic;
//  点赞
- (void)didClickLikeButtonInCell:(UITableViewCell *)cell;
//  评论
- (void)didClickcCommentButtonInCell:(UITableViewCell *)cell;
//  动态内容
- (void)didClickcDynamicContentInCell:(UITableViewCell *)cell;
//  查看全部
- (void)didClickcLookAllContentInCell:(UITableViewCell *)cell;
//  删除动态
- (void)didClickcDeleteDynamicInCell:(UITableViewCell *)cell;
//  个人信息
- (void)didClickcPersonalInfoInCell:(UITableViewCell *)cell;

@end

@interface TCTopicThatCell : UITableViewCell

@property (nonatomic, assign)TopicCellType cellType;

@property (nonatomic,weak) id <TCTopicCellDelegate> topicCellDelegate;
/// 模型
@property (nonatomic ,strong) TCMyDynamicModel *myDynamicModel;
#pragma mark -- 返回文本高度
+ (CGFloat)getDynamicContentTextHeightWithDynamic:(TCMyDynamicModel *)model;

@end
