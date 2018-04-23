//
//  TCFriendSearchResultViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCFriendSearchModel.h"
#import "TCMyDynamicModel.h"

@protocol TCFriendSearchResultDelegate <NSObject>

//滑动
-(void)friendSearchResultViewControllerBeginDraggingAction;
//查看更多
- (void)seletedMoreFriendResult;
//查看动态详情
- (void)lookDynamicDetailModel:(TCMyDynamicModel *)model;
//点击糖友头像
- (void)seleteSearchFriendResult:(TCFriendSearchModel *)searchModel;
//点击糖友头像
- (void)seleteMydynamicFriendResult:(TCMyDynamicModel *)searchModel;
//点击标记区域
- (void)seleteFriendResult:(NSInteger)news_id role_type:(NSInteger)role_type;
//点击话题
- (void)seleteLookTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic;
@end
@interface TCFriendSearchResultViewController : UIViewController

@property (nonatomic,weak)id<TCFriendSearchResultDelegate>friendSearchDelegate;

@property (nonatomic, copy )NSString   *keyword;

@property (nonatomic, assign)NSInteger   page;

@property (nonatomic,strong)UITableView       *tableView;

@end
