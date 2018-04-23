//
//  TCSearchViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSearchViewController.h"
#import "TCSearchTableView.h"
#import "TCSearchResultViewController.h"
#import "TCFoodDetailViewController.h"
#import "TCRecordDietViewController.h"
#import "TCFoodAddModel.h"
#import "TCArticleModel.h"
#import "TCBasewebViewController.h"

@interface TCSearchViewController ()<UISearchBarDelegate,TCSearchTableViewDelegate,TCSearchResultViewControllerDelegate>{
    NSMutableArray                 *foodHistoryArray;
    NSMutableArray                 *articleHistoryArray;
    TCSearchResultViewController   *searchResultViewController;    //搜索结果展示
}
@property (nonatomic,strong)UISearchBar         *mySearchBar;         //搜索框
@property (nonatomic,strong)TCSearchTableView   *searchTableView;     //热门搜索和历史记录

@end

@implementation TCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn=YES;
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    foodHistoryArray=[[NSMutableArray alloc] init];
    articleHistoryArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.searchTableView];
    
    [self requestHotSearchWords];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mySearchBar becomeFirstResponder];
    [MobClick beginLogPageView:@"搜索"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mySearchBar becomeFirstResponder];
    [MobClick endLogPageView:@"搜索"];
}

#pragma mark -- CustomDelegate
#pragma mark  TCSearchTableViewDelegate
-(void)searchTableViewWillBeginDragging:(TCSearchTableView *)searchTableView{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}

#pragma amrk 选择搜索词
-(void)searchtableView:(TCSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword{
    self.mySearchBar.text=keyword;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}

#pragma mark 清除历史记录
-(void)searchTableViewDidDeleteAllHistory:(TCSearchTableView *)searchTableView{
    if (self.type==FoodSearchType) {
        [NSUserDefaultsInfos removeObjectForKey:@"foodHistory"];
        [foodHistoryArray removeAllObjects];
        self.searchTableView.historyRecordsArray=foodHistoryArray;
        
    }else if (self.type==KnowledgeSearchType){
        [NSUserDefaultsInfos removeObjectForKey:@"articleHistory"];
        [articleHistoryArray removeAllObjects];
        self.searchTableView.historyRecordsArray=articleHistoryArray;
    }
    [self.searchTableView reloadData];
}
#pragma mark -- 删除单条历史纪录
- (void)deleteHomeHistoryRecord:(NSMutableArray *)history{
    self.searchTableView.historyRecordsArray=history;
    [self.searchTableView reloadData];
}
#pragma amrk 选择搜索词
-(void)HomeSearchtableView:(TCSearchTableView *)searchTableView didSelectHomeKeyword:(NSString *)keyword{
    self.mySearchBar.text=keyword;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}
#pragma mark TCSearchResultViewControllerDelegate
#pragma mark 选择搜索结果
-(void)searchResultViewControllerDidSelectModel:(id)model withType:(SearchType)searchType{
    if (searchType==FoodSearchType) {   //食物详情
        TCFoodAddModel *food=(TCFoodAddModel *)model;
        TCFoodDetailViewController  *foodDetailVC=[[TCFoodDetailViewController alloc] init];
        foodDetailVC.food_id=food.id;
        [self.navigationController pushViewController:foodDetailVC animated:YES];
    }else if (searchType==KnowledgeSearchType){   //文章详情
        TCArticleModel *article=(TCArticleModel *)model;
        NSString *urlString = [NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)article.id];
        TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
        webVC.type=BaseWebViewTypeArticle;
        webVC.titleText=@"文章详情";
        webVC.urlStr=urlString;
        webVC.shareTitle = article.title;
        webVC.image_url = article.image_url;
        webVC.articleID = article.id;
        webVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (searchType==FoodAddSearchType){  //添加食物
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
        
    }
}

#pragma mark  滑动搜素结果界面
-(void)searchResultViewControllerBeginDraggingAction{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}

#pragma mark 确定添加
-(void)searchResultViewControllerConfirmAction{
    MyLog(@"controllers:%@",self.navigationController.viewControllers);
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCRecordDietViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            [TCHelper sharedTCHelper].isAddFood=YES;
        }
    }
}

#pragma mark -- Network Methods
#pragma mark 加载热门搜索关键词和历史搜索记录
-(void)requestHotSearchWords{
     NSInteger way=1;
     if (_type==FoodSearchType||_type==FoodAddSearchType) {
         NSArray *tempArr=[NSUserDefaultsInfos getValueforKey:@"foodHistory"];
         if (kIsArray(tempArr)) {
             foodHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
             self.searchTableView.historyRecordsArray=foodHistoryArray;
         }
         way=2;
    }else if(_type==KnowledgeSearchType){
        NSArray *tempArr=[NSUserDefaultsInfos getValueforKey:@"articleHistory"];
        if (kIsArray(tempArr)) {
            articleHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
            self.searchTableView.historyRecordsArray=articleHistoryArray;
        }
        way=1;
    }
    self.searchTableView.searchType=self.type;
    NSString *body=[NSString stringWithFormat:@"way=%ld",(long)way];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kHotKeyword body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (result.count>0) {
            NSArray *dataArray = [result valueForKey:@"keyword"];
            self.searchTableView.hotSearchWordsArray=[NSMutableArray arrayWithArray:dataArray];
            [self.searchTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        
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
        _mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, KStatusHeight, kScreenWidth, kNavHeight)];
        _mySearchBar.delegate=self;
        if (_type==FoodSearchType||_type == FoodAddSearchType) {
            _mySearchBar.placeholder=@"请输入食物名称";
        }else if (_type==KnowledgeSearchType){
            _mySearchBar.placeholder=@"请输入搜索关键词";

        }else{
            _mySearchBar.placeholder=@"请输入搜索名称";
        }
        [_mySearchBar setBackgroundImage:[UIImage imageWithColor:kSystemColor size:CGSizeMake(kScreenWidth, kNavHeight)]];
    }
    return _mySearchBar;
}

#pragma mark 热门搜索和历史记录
-(TCSearchTableView *)searchTableView{
    if (_searchTableView==nil) {
        _searchTableView=[[TCSearchTableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _searchTableView.searchDelegate=self;
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
#pragma mark 搜索框文字变化时
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length>0) {
        BOOL isSearchBool = [[TCHelper sharedTCHelper] strIsContainEmojiWithStr:searchText];
        if (isSearchBool) {
            [self.view makeToast:@"不能搜索特殊符号" duration:1.0 position:CSToastPositionCenter];
        } else {
            if (searchResultViewController==nil) {
                searchResultViewController=[[TCSearchResultViewController alloc] init];
            }
            searchResultViewController.view.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
            searchResultViewController.controllerDelegate=self;
            searchResultViewController.type=_type;
            searchResultViewController.keyword=searchText;
            [self.view addSubview:searchResultViewController.view];
            
        }
    }
}

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
            searchResultViewController=[[TCSearchResultViewController alloc] init];
        }
        searchResultViewController.view.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
        searchResultViewController.controllerDelegate=self;
        searchResultViewController.type=_type;
        searchResultViewController.keyword=searchText;
        [self.view addSubview:searchResultViewController.view];
        
        if (self.type==FoodSearchType||self.type==FoodAddSearchType) {
            if (![foodHistoryArray containsObject:searchText]) {
                [foodHistoryArray addObject:searchText];
                [NSUserDefaultsInfos putKey:@"foodHistory" andValue:foodHistoryArray];
            }

            [MobClick event:@"401_001002" attributes:@{@"food":searchText}];

        }else if (self.type==KnowledgeSearchType){
            if (![articleHistoryArray containsObject:searchText]) {
                [articleHistoryArray addObject:searchText];
                [NSUserDefaultsInfos putKey:@"articleHistory" andValue:articleHistoryArray];
            }
            
            [MobClick event:@"401_001001" attributes:@{@"keyword":searchText}];
        }
    }
    }
}

#pragma mark 点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
