//
//  TCNewFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCNewFriendViewController.h"
#import "TCNewFriendModel.h"
#import "TCFocusOnTableViewCell.h"
#import "TCSetUpViewController.h"
#import "TCMyDynamicViewController.h"

@interface TCNewFriendViewController ()<UITableViewDelegate,UITableViewDataSource,TCFocusOnDelegate>{
    
    NSMutableArray *newFriendArray;
    TCBlankView    *blankView;
    NSInteger       newFriendPage;
}

@property (nonatomic ,strong)UITableView *newFriendTab;
@end
@implementation TCNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"新朋友";
    self.rigthTitleName = @"设置";
    newFriendArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    newFriendPage = 1;
    
    [self.view addSubview:self.newFriendTab];
    [self loadNewFriendData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-10" type:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-10" type:2];
}
#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return newFriendArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFocusOnTableViewCell";
    TCFocusOnTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCFocusOnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    TCNewFriendModel *mineModel =newFriendArray[indexPath.row];
    [cell cellNewFriendModel:mineModel];
    if (indexPath.row==newFriendArray.count-1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, MAXFLOAT)];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"105_003006"];
    [[TCHelper sharedTCHelper] loginClick:@"008-10-02"];
    TCNewFriendModel *mineModel =newFriendArray[indexPath.row];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = mineModel.follow_user_id;
    myDynamicVC.role_type_ed =mineModel.role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
#pragma mark -- TCFocusOnDelegate
#pragma mark -- 加关注
- (void)returnFocusOnIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:@"008-10-01"];
    [MobClick event:@"105_003005"];
    [self loadNewFriendData];
}
#pragma mark -- Event response
#pragma mark -- 设置
- (void)rightButtonAction{
    [[TCHelper sharedTCHelper] loginClick:@"008-10-03"];
    [MobClick event:@"105_003007"];
    TCSetUpViewController *setUpVC = [[TCSetUpViewController alloc] init];
    setUpVC.type = 1;
    [self.navigationController pushViewController:setUpVC animated:YES];
}
#pragma mark -- 获取新朋友数据
- (void)loadNewFriendData{
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type_ed=0",newFriendPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KLoadNewFriendList body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)) {
            NSMutableArray *beFocusArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCNewFriendModel *focusOnModel = [[TCNewFriendModel alloc] init];
                [focusOnModel setValues:dict];
                [beFocusArr addObject:focusOnModel];
            }
            if (newFriendPage==1) {
                blankView.hidden = beFocusArr.count>0;
                newFriendArray = beFocusArr;
            } else {
                [newFriendArray addObjectsFromArray:beFocusArr];
            }
            self.newFriendTab.mj_footer.hidden=(total -newFriendPage*20)<=0;
        }
        [self.newFriendTab.mj_header endRefreshing];
        [self.newFriendTab.mj_footer endRefreshing];
        [self.newFriendTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.newFriendTab.mj_header endRefreshing];
        [self.newFriendTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];

}
#pragma mark  获取最新亲友数据
-(void)loadNewFriendNewData{
    newFriendPage=1;
    [self loadNewFriendData];
}

#pragma mark  获取更多亲友数据
-(void)loadNewFriendMoreData{
    newFriendPage++;
    [self loadNewFriendData];
}
#pragma mark -- getter
- (UITableView *)newFriendTab{
    if (_newFriendTab==nil) {
        _newFriendTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _newFriendTab.delegate = self;
        _newFriendTab.dataSource = self;
        _newFriendTab.backgroundColor = [UIColor bgColor_Gray];
        _newFriendTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFriendNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _newFriendTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNewFriendMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _newFriendTab.mj_footer = footer;
        footer.hidden=YES;

        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无新朋友"];
        [_newFriendTab addSubview:blankView];
        blankView.hidden=YES;
    }
    return _newFriendTab;
}
@end
