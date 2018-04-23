//
//  TCFriendSearchTableView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSearchViewController.h"

@class TCFriendSearchTableView;

@protocol TCSearchTableViewDelegate <NSObject>

//开始滑动
-(void)friendSearchTableViewWillBeginDragging:(TCFriendSearchTableView *)searchTableView;
//选择热门词或搜索历史
-(void)friendSearchtableView:(TCFriendSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword;
//清除搜索历史
-(void)friendSearchTableViewDidDeleteAllHistory:(TCFriendSearchTableView *)searchTableView;
//清除单条搜索历史
-(void)deleteHistoryRecord:(NSMutableArray *)history;
//点击热门搜索
- (void)seleteHotSearch:(TCFriendSearchTableView *)searchTableView didSelectTitle:(NSString *)title;
@end
@interface TCFriendSearchTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,weak)id<TCSearchTableViewDelegate>friendSearchDelegate;

@property (nonatomic,strong)NSMutableArray  *historyRecordsArray;

@property (nonatomic,strong)NSMutableArray  *hotSearchWordsArray;
@end
