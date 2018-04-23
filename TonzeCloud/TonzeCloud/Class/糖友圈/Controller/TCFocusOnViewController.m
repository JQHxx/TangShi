//
//  TCFocusOnViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFocusOnViewController.h"
#import "TCFocusOnModel.h"
#import "TCFocusOnTableViewCell.h"
#import "TCMyDynamicViewController.h"

@interface TCFocusOnViewController ()<UITableViewDelegate,UITableViewDataSource,TCFocusOnDelegate>{

    NSMutableArray *focusOnArray;
    TCBlankView    *blankView;

    NSInteger      focusOnPage;
}

@property (nonatomic ,strong)UITableView *focusOnTab;
@end

@implementation TCFocusOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"关注";
    focusOnArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    focusOnPage = 1;
    
    [self.view addSubview:self.focusOnTab];
    [self loadFocusOnData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-08" type:1];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-08" type:2];
}
#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return focusOnArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFocusOnTableViewCell";
    TCFocusOnTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCFocusOnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    TCFocusOnModel *mineModel =focusOnArray[indexPath.row];
    [cell cellFocusOnModel:mineModel index:self.type];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"105_003002"];
    [[TCHelper sharedTCHelper] loginClick:@"008-08-02"];
    TCFocusOnModel *mineModel =focusOnArray[indexPath.row];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = mineModel.followed_user_id;
    myDynamicVC.role_type_ed = mineModel.role_type_ed;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
#pragma mark -- TCFocusOnDelegate
#pragma mark --取消关注
- (void)returnFocusOnIndex:(NSInteger)index{
    [TCHelper sharedTCHelper].isFocusOnDynamicListReload = YES;
    [MobClick event:@"105_003001"];
    [[TCHelper sharedTCHelper] loginClick:@"008-08-01"];
    [self loadFocusOnData];
}
#pragma mark -- 获取关注数据
- (void)loadFocusOnData{
    NSString *body = nil;
    NSString *url = nil;
    if (self.user_id>0) {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type=%ld&follow_user_id=%ld&role_type_user=0",(long)focusOnPage,self.role_type,self.user_id];
        url=KLoadotherFoucsOnList;
    } else {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type=0",(long)focusOnPage];
        url=KLoadFoucsOnList;
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)) {
            NSMutableArray *focusArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCFocusOnModel *focusOnModel = [[TCFocusOnModel alloc] init];
                [focusOnModel setValues:dict];
                [focusArr addObject:focusOnModel];
            }
            if (focusOnPage==1) {
                blankView.hidden = focusArr.count>0;
                focusOnArray = focusArr;
            } else {
                [focusOnArray addObjectsFromArray:focusArr];
            }
            self.focusOnTab.mj_footer.hidden=(total -focusOnPage*20)<=0;
        }
        [self.focusOnTab.mj_header endRefreshing];
        [self.focusOnTab.mj_footer endRefreshing];
        [_focusOnTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.focusOnTab.mj_header endRefreshing];
        [self.focusOnTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- Private Methods
#pragma mark  获取最新亲友数据
-(void)loadFocusOnNewData{
    focusOnPage=1;
    [self loadFocusOnData];
}

#pragma mark  获取更多亲友数据
-(void)loadFocusOnMoreData{
    focusOnPage++;
    [self loadFocusOnData];
}
#pragma mark -- getter
- (UITableView *)focusOnTab{
    if (_focusOnTab==nil) {
        _focusOnTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _focusOnTab.delegate = self;
        _focusOnTab.dataSource = self;
        _focusOnTab.backgroundColor = [UIColor bgColor_Gray];
        _focusOnTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFocusOnNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _focusOnTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadFocusOnMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _focusOnTab.mj_footer = footer;
        footer.hidden=YES;

        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"还没有关注任何人"];
        [_focusOnTab addSubview:blankView];
        blankView.hidden=YES;
    }
    return _focusOnTab;
}


@end
