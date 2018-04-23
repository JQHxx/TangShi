//
//  TCFriendSearchViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFriendSearchViewController.h"
#import "TCFriendSearchTableView.h"
#import "TCFriendSearchResultViewController.h"
#import "TCMoreSearchFriendViewController.h"
#import "TCMyDynamicViewController.h"
#import "TCFastLoginViewController.h"
#import "TCDynamicDetailViewController.h"
#import "TCTopicDetailsViewController.h"
#import "TCBlankView.h"

@interface TCFriendSearchViewController ()<UISearchBarDelegate,TCFriendSearchResultDelegate,TCSearchTableViewDelegate>{
    NSMutableArray                 *friendHistoryArray;
    
    TCFriendSearchResultViewController   *searchResultViewController;    //搜索结果展示
}

@property (nonatomic,strong)UISearchBar         *mySearchBar;         //搜索框
@property (nonatomic,strong)TCFriendSearchTableView   *searchTableView;     //历史记录
@property (nonatomic, assign) BOOL     isLogin;        // 是否登入

@end
@implementation TCFriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn=YES;
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    friendHistoryArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.searchTableView];
    
    [self requestHotSearchWords];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isLogin =[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];

    if ([TCHelper sharedTCHelper].isSearchKeyboard==YES) {
        [self.mySearchBar becomeFirstResponder];
        [TCHelper sharedTCHelper].isSearchKeyboard = NO;
    }
}

#pragma mark -- CustomDelegate
#pragma mark  TCSearchTableViewDelegate
-(void)friendSearchTableViewWillBeginDragging:(TCFriendSearchTableView *)searchTableView{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}

#pragma amrk 选择搜索词
-(void)friendSearchtableView:(TCFriendSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword{
    self.mySearchBar.text=keyword;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}

#pragma mark 清除历史记录
-(void)friendSearchTableViewDidDeleteAllHistory:(TCFriendSearchTableView *)searchTableView{
    [NSUserDefaultsInfos removeObjectForKey:@"sugarFriendHistory"];
    [friendHistoryArray removeAllObjects];
    self.searchTableView.historyRecordsArray=friendHistoryArray;
    [self.searchTableView reloadData];
}
#pragma mark -- 删除单条历史纪录
- (void)deleteHistoryRecord:(NSMutableArray *)history{
    self.searchTableView.historyRecordsArray=history;
    [self.searchTableView reloadData];
}
#pragma mark -- 点击热门搜索
- (void)seleteHotSearch:(TCFriendSearchTableView *)searchTableView didSelectTitle:(NSString *)title{
    self.mySearchBar.text=title;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}
#pragma mark TCSearchResultViewControllerDelegate
#pragma mark  滑动搜素结果界面
-(void)friendSearchResultViewControllerBeginDraggingAction{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}
#pragma mark -- 查看更多
- (void)seletedMoreFriendResult{
    TCMoreSearchFriendViewController *moreSearchFriendVC = [[TCMoreSearchFriendViewController alloc] init];
    moreSearchFriendVC.keywords = searchResultViewController.keyword;
    [self.navigationController pushViewController:moreSearchFriendVC animated:YES];
}
#pragma mark -- 选择搜索糖友
- (void)seleteSearchFriendResult:(TCFriendSearchModel *)searchModel{
    if (_isLogin) {
        TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
        myDynamicVC.news_id = searchModel.user_id;
        myDynamicVC.role_type_ed =searchModel.role_type;
        [self.navigationController pushViewController:myDynamicVC animated:YES];
    } else {
        [self fastLoginAction];
    }
}
#pragma mark -- 查看动态详情
- (void)lookDynamicDetailModel:(TCMyDynamicModel *)model{
    if (_isLogin) {
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
        dynamicDetailVC.commented_user_id = model.user_id;
        dynamicDetailVC.news_id = model.news_id;
        dynamicDetailVC.role_type_ed =  model.role_type;
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    } else {
        [self fastLoginAction];
    }
}
#pragma mark -- 点击标记区域
- (void)seleteFriendResult:(NSInteger)news_id role_type:(NSInteger)role_type{
    if (_isLogin) {
        TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
        myDynamicVC.news_id = news_id;
        myDynamicVC.role_type_ed =role_type;
        [self.navigationController pushViewController:myDynamicVC animated:YES];
    } else {
        [self fastLoginAction];
    }
}
#pragma mark -- 点击话题区域
- (void)seleteLookTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
    if (_isLogin) {
        TCTopicDetailsViewController *topicDetailVC = [[TCTopicDetailsViewController alloc] init];
        topicDetailVC.topicId = topic_id;
        topicDetailVC.topic_delete_status = topic_delete_status;
        topicDetailVC.topic = topic;
        [self.navigationController pushViewController:topicDetailVC animated:YES];
    } else {
       [self fastLoginAction];
    }
}
#pragma mark -- 点击用户头像
- (void)seleteMydynamicFriendResult:(TCMyDynamicModel *)searchModel{
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = searchModel.user_id;
    myDynamicVC.role_type_ed =searchModel.role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}

#pragma mark -- Network Methods
#pragma mark 加载历史搜索记录
-(void)requestHotSearchWords{
    NSArray *tempArr=[NSUserDefaultsInfos getValueforKey:@"sugarFriendHistory"];
    if (kIsArray(tempArr)) {
        friendHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
        self.searchTableView.historyRecordsArray=friendHistoryArray;
    }else{
        self.searchTableView.historyRecordsArray=friendHistoryArray;
    }
    
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:KFriendHotKeyWords success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        if (result.count>0&&kIsDictionary(result)) {
            NSArray *arr = [result objectForKey:@"keyword"];
            dataArr = [NSMutableArray arrayWithArray:arr];
        }
        self.searchTableView.hotSearchWordsArray =dataArr;
        [self.searchTableView reloadData];

    } failure:^(NSString *errorStr) {
        [self.searchTableView reloadData];
    }];
    
}

#pragma mark -- Private Methods
#pragma mark 设置取消按钮
-(void)setSearchBarCancelButton{
    for (id cc in [self.mySearchBar.subviews[0] subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)cc;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.enabled=YES;
        }
    }
}

#pragma mark -- Getters and Setters
#pragma mark 搜索框
-(UISearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, KStatusHeight +( kNavHeight - 28)/2, kScreenWidth, 28)];
        _mySearchBar.delegate=self;
        _mySearchBar.placeholder=@"昵称/动态内容";
        [_mySearchBar setBackgroundImage:[UIImage imageWithColor:kSystemColor size:CGSizeMake(kScreenWidth, kNavHeight)]];
    }
    return _mySearchBar;
}

#pragma mark 历史记录
-(TCFriendSearchTableView *)searchTableView{
    if (_searchTableView==nil) {
        _searchTableView=[[TCFriendSearchTableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _searchTableView.friendSearchDelegate=self;
        _searchTableView.scrollsToTop = NO;
    }
    return _searchTableView;
}

#pragma mark -- UISearchBarDelegate
#pragma mark 搜索框编辑开始
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.mySearchBar setShowsCancelButton:YES animated:YES];
    [self setSearchBarCancelButton];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{  if ([searchBar isFirstResponder]) {
    
    if ([[[searchBar textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[searchBar textInputMode] primaryLanguage]) {
        return NO;
    }
    
    //判断键盘是不是九宫格键盘
    if ([[TCHelper sharedTCHelper] isNineKeyBoard:text] ){
        return YES;
    }else{
        if ([[TCHelper sharedTCHelper] hasEmoji:text] || [[TCHelper sharedTCHelper] strIsContainEmojiWithStr:text]){
            return NO;
        }
    }
}
    return YES;
    
}
#pragma mark 点击搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    BOOL isSearchBool = [[TCHelper sharedTCHelper] strIsContainEmojiWithStr:searchBar.text];
    if (isSearchBool) {
        [self.view makeToast:@"不能搜索特殊符号" duration:1.0 position:CSToastPositionCenter];
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
    } else {
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
        
        NSString *searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        searchBar.text=searchText;
        if (kIsEmptyString(searchText)) {
            searchBar.text=@"";
            [self showAlertWithTitle:@"" Message:@"请输入关键词"];
        }else{
            if (searchResultViewController==nil) {
                searchResultViewController=[[TCFriendSearchResultViewController alloc] init];
            }
            searchResultViewController.tableView.scrollsToTop = YES;
            searchResultViewController.view.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
            searchResultViewController.friendSearchDelegate=self;
            searchResultViewController.page = 1;
            searchResultViewController.keyword=searchText;
            [self.view addSubview:searchResultViewController.view];
            
            if (![friendHistoryArray containsObject:searchText]) {
                [friendHistoryArray insertObject:searchText atIndex:0];
            }else{
                NSMutableArray *history = [[NSMutableArray alloc] init];
                for (int i=0; i<friendHistoryArray.count; i++) {
                    if ([friendHistoryArray[i] isEqualToString:searchText]) {
                        [history insertObject:friendHistoryArray[i] atIndex:0];
                    }else{
                        [history addObject:friendHistoryArray[i]];
                    }
                }
                friendHistoryArray = history;
            }
            [NSUserDefaultsInfos putKey:@"sugarFriendHistory" andValue:friendHistoryArray];
        }
    }
}

#pragma mark 点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
@end
