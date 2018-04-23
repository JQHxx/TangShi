//
//  TCSearchTableView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSearchViewController.h"

@class TCSearchTableView;

@protocol TCSearchTableViewDelegate <NSObject>

//开始滑动
-(void)searchTableViewWillBeginDragging:(TCSearchTableView *)searchTableView;
//选择搜索历史
-(void)HomeSearchtableView:(TCSearchTableView *)searchTableView didSelectHomeKeyword:(NSString *)keyword;
//选择热门词
-(void)searchtableView:(TCSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword;
//清除搜索历史
-(void)searchTableViewDidDeleteAllHistory:(TCSearchTableView *)searchTableView;
//清除单条搜索历史
-(void)deleteHomeHistoryRecord:(NSMutableArray *)history;
@end

@interface TCSearchTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,weak)id<TCSearchTableViewDelegate>searchDelegate;

@property (nonatomic,strong)NSMutableArray  *hotSearchWordsArray;
@property (nonatomic,strong)NSMutableArray  *historyRecordsArray;

@property (nonatomic,assign)SearchType searchType;

@end
