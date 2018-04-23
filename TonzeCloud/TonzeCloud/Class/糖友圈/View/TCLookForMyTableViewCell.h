//
//  TCLookForMyTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLookFoMyModel.h"


@protocol TCLookForMyDelegate <NSObject>
@required

- (void)commentsLookForMyContent:(NSInteger)expert_id User_id:(NSInteger)user_id role_type_ed:(NSInteger)role_type_ed;    //查看评论

- (void)myDynamicLookForMyContent:(TCLookFoMyModel *)model;      //个人信息

- (void)myLinkLookForMyMoreContent:(NSInteger)expert_id User_id:(NSInteger)user_id role_type_ed:(NSInteger)role_type_ed;      //点击标记之外区域

- (void)myLinkSeletedClickContent:(TCLookFoMyModel *)model;      //点击标记区域

- (void)myLinkTopic:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic;      //点击标记区域

- (void)myPraiseDynamic:(TCLookFoMyModel *)model;      //点赞

@end
@interface TCLookForMyTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCLookForMyDelegate> delegate;

- (void)cellLookForMyModel:(TCLookFoMyModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView rowLookForMyHeightForModel:(TCLookFoMyModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView toLookForMyCalculateHeight:(NSArray *)imgArray;
@end
