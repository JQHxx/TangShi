//
//  TCBeFocusOnViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBeFocusOnViewController.h"
#import "TCFocusOnModel.h"
#import "TCFocusOnTableViewCell.h"
#import "TCMyDynamicViewController.h"
#import "TCReleaseDynamicViewController.h"

@interface TCBeFocusOnViewController ()<UITableViewDelegate,UITableViewDataSource,TCFocusOnDelegate>{
    
    NSMutableArray *beFocusOnArray;
    UILabel        *headLabel;
    UILabel        *centerLabel;
    UIButton       *releaseButton;
    NSInteger       beFocusOnPage;
}

@property (nonatomic ,strong)UITableView *beFocusOnTab;
@end

@implementation TCBeFocusOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"被关注";
    beFocusOnArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    beFocusOnPage = 1;
    
    [self.view addSubview:self.beFocusOnTab];
    [self loadFocusOnData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-09" type:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-09" type:2];
}
#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return beFocusOnArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFocusOnTableViewCell";
    TCFocusOnTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCFocusOnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    TCFocusOnModel *mineModel =beFocusOnArray[indexPath.row];
    [cell cellBeFocusOnModel:mineModel index:self.type];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"105_003004"];
    [[TCHelper sharedTCHelper] loginClick:@"008-09-02"];
    TCFocusOnModel *mineModel =beFocusOnArray[indexPath.row];
    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
    myDynamicVC.news_id = mineModel.follow_user_id;
    myDynamicVC.role_type_ed = mineModel.role_type;
    [self.navigationController pushViewController:myDynamicVC animated:YES];
}
#pragma mark -- TCFocusOnDelegate
#pragma mark -- 加关注
- (void)returnFocusOnIndex:(NSInteger)index{
    [TCHelper sharedTCHelper].isFocusOnDynamicListReload = YES;
    [[TCHelper sharedTCHelper] loginClick:@"008-09-01"];
    [MobClick event:@"105_003003"];
    [self loadFocusOnData];
}
#pragma mark -- 获取被关注数据
- (void)loadFocusOnData{
    NSString *body = nil;
    NSString *url = nil;
    if (self.user_id>0) {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type_ed=%ld&followed_user_id=%ld&role_type_user=0",beFocusOnPage,self.role_type,self.user_id];
        url=KLoadotherBeFoucsOnList;
    } else {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type_ed=0",beFocusOnPage];
        url=KLoadBeFoucsOnList;
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)) {
            NSMutableArray *beFocusArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCFocusOnModel *focusOnModel = [[TCFocusOnModel alloc] init];
                [focusOnModel setValues:dict];
                [beFocusArr addObject:focusOnModel];
            }
            self.beFocusOnTab.mj_footer.hidden=beFocusArr.count<20;
            if (beFocusOnPage==1) {
                headLabel.hidden = beFocusArr.count>0;
                centerLabel.hidden =beFocusArr.count>0;
                releaseButton.hidden = beFocusArr.count>0;
                beFocusOnArray = beFocusArr;
            } else {
                [beFocusOnArray addObjectsFromArray:beFocusArr];
            }
            self.beFocusOnTab.mj_footer.hidden=(total -beFocusOnPage*20)<=0;
        }
        [self.beFocusOnTab.mj_header endRefreshing];
        [self.beFocusOnTab.mj_footer endRefreshing];
        [self.beFocusOnTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.beFocusOnTab.mj_header endRefreshing];
        [self.beFocusOnTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark  获取最新亲友数据
-(void)loadBeFocusOnNewData{
    beFocusOnPage=1;
    [self loadFocusOnData];
}

#pragma mark  获取更多亲友数据
-(void)loadBeFocusOnMoreData{
    beFocusOnPage++;
    [self loadFocusOnData];
}
#pragma 发布动态
- (void)nextReleaseButton{
    
    TCReleaseDynamicViewController *releaseVC = [[TCReleaseDynamicViewController alloc] init];
    releaseVC.isCanChooseTopic = YES;
    [self.navigationController pushViewController:releaseVC animated:YES];
}
#pragma mark -- getter
- (UITableView *)beFocusOnTab{
    if (_beFocusOnTab==nil) {
        _beFocusOnTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _beFocusOnTab.delegate = self;
        _beFocusOnTab.dataSource = self;
        _beFocusOnTab.backgroundColor = [UIColor bgColor_Gray];
        _beFocusOnTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadBeFocusOnNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _beFocusOnTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadBeFocusOnMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _beFocusOnTab.mj_footer = footer;
        footer.hidden=YES;
        
        headLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, kScreenWidth-20, 20)];
        headLabel.textAlignment = NSTextAlignmentCenter;
        headLabel.text = @"还没有人关注你";
        headLabel.textColor = [UIColor grayColor];
        headLabel.font = [UIFont systemFontOfSize:15];
        [_beFocusOnTab addSubview:headLabel];
        headLabel.hidden = YES;
        
        centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, headLabel.bottom+100, kScreenWidth-20, 20)];
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.text = @"分享控糖生活让更多人留意你吧";
        centerLabel.textColor = [UIColor grayColor];
        centerLabel.font = [UIFont systemFontOfSize:15];
        [_beFocusOnTab addSubview:centerLabel];
        centerLabel.hidden = YES;
        
        releaseButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, centerLabel.bottom+10, 200, 40)];
        [releaseButton setTitle:@"发布动态" forState:UIControlStateNormal];
        [releaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        releaseButton.titleLabel.font=[UIFont systemFontOfSize:15];
        releaseButton.layer.cornerRadius = 20;
        releaseButton.backgroundColor = kbgBtnColor;
        [releaseButton addTarget:self action:@selector(nextReleaseButton) forControlEvents:UIControlEventTouchUpInside];
        [_beFocusOnTab addSubview:releaseButton];
        releaseButton.hidden = YES;
    }
    return _beFocusOnTab;
}

@end
