//
//  TCArticleLibraryViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCArticleLibraryViewController.h"
#import "TCFoodMenuView.h"
#import "TCArticleTableView.h"
#import "TCArticleModel.h"
#import "TCSearchViewController.h"
#import "TCBasewebViewController.h"

@interface TCArticleLibraryViewController ()<TCFoodMenuViewDelegate,TCArticleTableViewDelegate>{

    NSMutableArray *titleArray;
    NSMutableArray *idArray;
    TCBlankView    *blankView;
    NSInteger       selectIndex;
    NSInteger       articlePage;    //文章记录页数
    NSMutableArray  *articleArray;
}
@property (nonatomic,strong)TCFoodMenuView         *catMenuView;
@property (nonatomic,strong)TCArticleTableView     *articleTableView;
@end
@implementation TCArticleLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"糖百科";
    self.rightImageName = @"ic_top_search";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    titleArray = [[NSMutableArray alloc] init];
    idArray =  [[NSMutableArray alloc] init];
    articleArray = [[NSMutableArray alloc] init];
    articlePage = 1;
    self.catMenuView.delegate = self;
    
    [self.view addSubview:self.catMenuView];
    [self.view addSubview:self.articleTableView];
    
    if (idArray.count>0) {
        [self requestArticleList:selectIndex];
    }else{
        [self requestMenuCategoryInfo];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.articleIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-10-03" type:1];
#endif
    }else if (self.articleIndex==1){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-11-03" type:1];
#endif
        
    }else if (self.articleIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-09-03" type:1];
#endif
        
    }else if (self.articleIndex==3){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-12-03" type:1];
#endif
        
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.articleIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-10-03" type:2];
#endif
        
    }else if (self.articleIndex==1){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-11-03" type:2];
#endif
        
    }else if (self.articleIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-09-03" type:2];
#endif
        
    }else if (self.articleIndex==3){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-12-03" type:2];
#endif
        
    }
    
}
#pragma mark --Delegate
#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(TCFoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    [MobClick event:@"101_002017"];
    
    articlePage=1;
    selectIndex = index;
    [self requestArticleList:selectIndex];
}
#pragma mark  TCArticleTableViewDelegate
-(void)articleTableViewDidSelectedCellWithArticle:(TCArticleModel *)article{
    [MobClick event:@"101_002018"];
    
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.type=BaseWebViewTypeArticle;
    webVC.titleText=@"糖士-糖百科";
    webVC.shareTitle = article.title;
    webVC.image_url = article.image_url;
    webVC.articleID = article.id;
    webVC.articleIndex = _articleIndex;
    webVC.isTaskListLogin = _isTaskListLogin;
    webVC.urlStr=[NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)article.id];
    webVC.hidesBottomBarWhenPushed=YES;
    kSelfWeak;
    webVC.backBlock=^(){
        NSInteger read_number = 0;
        for (TCArticleModel *model in articleArray) {
            if (model.id==article.id) {
                model.reading_number+=1;
                read_number=model.reading_number;
            }
        }
        [weakSelf.articleTableView reloadData];
        if (weakSelf.articleBackBlock) {
             weakSelf.articleBackBlock(article.id,read_number);
        }
    };
    [self.navigationController pushViewController:webVC animated:YES];
}


#pragma mark -- Event Response
-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex>titleArray.count-1) {
            selectIndex=titleArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectIndex--;
        if (selectIndex<0) {
            selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in _catMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_catMenuView changeFoodViewWithButton:btn];
}
#pragma mark -- 加载最新数据
- (void)loadNewArticleData{
    [MobClick event:@"101_002019"];
    articlePage =1;
    if (idArray.count>0) {
        [self requestArticleList:selectIndex];
    } else {
        [self requestMenuCategoryInfo];
    }
}
#pragma mark -- 加载更多数据
- (void)loadMoreArticleData{
    [MobClick event:@"101_002020"];

    articlePage++;
    [self requestArticleList:selectIndex];
}
#pragma mark -- Event Response
#pragma mark 导航栏右侧按钮事件（搜索）
-(void)rightButtonAction{
    TCSearchViewController *searchViewController=[[TCSearchViewController alloc] init];
    searchViewController.type=KnowledgeSearchType;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
#pragma mark -- Network Methods
#pragma mark 获取分类菜单
-(void)requestMenuCategoryInfo{
    __weak typeof(self) weakSelf=self;
    NSString *urlstr = [NSString stringWithFormat:@"AccessToken=0"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCategory body:urlstr success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        [titleArray addObject:@"推荐"];
        [idArray addObject:@"0"];
        if (dataArray.count>0) {
            for (int i=0; i<dataArray.count; i++) {
                NSDictionary *dict=dataArray[i];
                [titleArray addObject:dict[@"name"]];
                [idArray addObject:[NSString stringWithFormat:@"%@",dict[@"id"]]];
            }
            weakSelf.catMenuView.foodMenusArray=[NSMutableArray arrayWithArray:titleArray];
            weakSelf.catMenuView.backgroundColor=[UIColor whiteColor];
        
            [weakSelf changeMenuForRequestArticleData];

        } else {
            weakSelf.catMenuView.hidden = YES;
        }
        [weakSelf.articleTableView.mj_header endRefreshing];

    } failure:^(NSString *errorStr) {
        [weakSelf.articleTableView.mj_header endRefreshing];
    }];
}
#pragma mark 切换菜单获取文章
-(void)changeMenuForRequestArticleData{
    if (selectIndex==1) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-10-03"];
#endif
    }else if (selectIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-11-03"];
#endif

    }else if (selectIndex==3){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-09-03"];
#endif

    }else if (selectIndex==4){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-12-03"];
#endif

    }
    selectIndex=[idArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)self.cateID]];
    UIButton *btn;
    for (UIView  *view in _catMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.catMenuView changeFoodViewWithButton:btn];
}
#pragma mark 获取文章列表信息
-(void)requestArticleList:(NSInteger)index{
    __weak typeof(self) weakSelf=self;
    NSString *string = [NSString stringWithFormat:@"%@",idArray[index]];
    NSString *urlString = nil;
    if (index==0) {
            urlString =[NSString stringWithFormat:@"page_num=%ld&page_size=20&is_recommended=1",(long)articlePage];
    } else {
            urlString =[NSString stringWithFormat:@"page_num=%ld&page_size=20&classification_id=%@",(long)articlePage,string];
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleList body:urlString success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        if (kIsArray(dataArray) && dataArray.count > 0) {
            NSInteger  totalCount = [[[json objectForKey:@"pager"] objectForKey:@"total"] integerValue];
            blankView.hidden = YES;
            for (int i=0; i<dataArray.count; i++) {
                TCArticleModel *articleModel=[[TCArticleModel alloc] init];
                [articleModel setValues:dataArray[i]];
                [tempArr addObject:articleModel];
            }
            weakSelf.articleTableView.mj_footer.hidden=(totalCount -articlePage*20)<=0;
            weakSelf.articleTableView.tableFooterView = (totalCount -articlePage*20)<=0 ? [weakSelf tableVieFooterView] : [UIView new];
            if (articlePage==1) {
                blankView.hidden=tempArr.count>0;
                articleArray=tempArr;
            }else{
                [articleArray addObjectsFromArray:tempArr];
            }
            weakSelf.articleTableView.articlesArray = articleArray;
            [weakSelf.articleTableView reloadData];
        }else{
            [articleArray removeAllObjects];
            weakSelf.articleTableView.articlesArray = articleArray;
            weakSelf.articleTableView.tableFooterView = [UIView new];
            weakSelf.articleTableView.mj_footer.hidden = YES;
            [weakSelf.articleTableView reloadData];
            blankView.hidden = NO;
        }
        [weakSelf.articleTableView.mj_header endRefreshing];
        [weakSelf.articleTableView.mj_footer endRefreshing];
    
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [weakSelf.articleTableView.mj_header endRefreshing];
        [weakSelf.articleTableView.mj_footer endRefreshing];
    }];
}
#pragma mark ======  没有更多动态 =======
- (UIView *)tableVieFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    return footerView;
}
#pragma mark -- getters and setters
#pragma mark 分类菜单
-(TCFoodMenuView *)catMenuView{
    if (_catMenuView==nil) {
        _catMenuView=[[TCFoodMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 49)];
    }
    return _catMenuView;
}
#pragma mark 文章列表
-(TCArticleTableView *)articleTableView{
    if (_articleTableView==nil) {
        _articleTableView=[[TCArticleTableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, kRootViewHeight - 49) style:UITableViewStylePlain];
        _articleTableView.type=1;
        _articleTableView.articleDetagate = self;
        _articleTableView.scrollEnabled=YES;
        _articleTableView.backgroundColor=[UIColor bgColor_Gray];

        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewArticleData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _articleTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreArticleData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _articleTableView.mj_footer = footer;
        footer.hidden=YES;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_articleTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_articleTableView addGestureRecognizer:swipGestureRight];
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无文章数据"];
        [_articleTableView addSubview:blankView];
        blankView.hidden=YES;
    }
    return _articleTableView;
}
@end
