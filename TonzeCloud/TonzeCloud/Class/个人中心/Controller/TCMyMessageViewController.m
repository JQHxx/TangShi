//
//  TCMyMessageViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyMessageViewController.h"
#import "TCMyMessageTableViewCell.h"
#import "TCMyMessageModel.h"

@interface TCMyMessageViewController ()<UITableViewDelegate,UITableViewDataSource,TCMyMessageDelegate>{

    NSMutableArray *myMessageArr;
    NSInteger       messagePage;
}
@property (nonatomic,strong)UITableView  *myMessageTab;
@property (nonatomic,strong)TCBlankView  *blankView;
@end

@implementation TCMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"消息";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    myMessageArr = [[NSMutableArray alloc] init];
    messagePage = 1;
    
    [self.view addSubview:self.myMessageTab];
    [self.myMessageTab addSubview:self.blankView];
    self.blankView.hidden=YES;
    
    [self loadMyMessageData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"亲友消息"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"亲友消息"];
}

#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return myMessageArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCMyMessageTableViewCell";
    TCMyMessageTableViewCell  *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[TCMyMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    TCMyMessageModel *myMessageModel = myMessageArr[indexPath.row];
    [cell cellMyMessageModel:myMessageModel];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 68;
}
#pragma mark -- TCMyMessageDelegate
- (void)MyMessageIndex:(NSInteger)Index apply_family_id:(NSInteger)family_id{
    if (Index==100) {
#if !DEBUG
        [MobClick event:@"104_003004"];
#endif

    }else{
#if !DEBUG
        [MobClick event:@"104_003003"];
#endif

    }
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"apply_family_id=%ld&state=%d",family_id,Index==100?1:2];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFAgreeAddFriend body:body success:^(id json) {
        [TCHelper sharedTCHelper].isFriendResquest = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];

}

#pragma mark -- Private Methods
#pragma mark  获取最新亲友数据
-(void)loadMyMessageNewData{
    messagePage=1;
    [self loadMyMessageData];
}

#pragma mark  获取更多亲友数据
-(void)loadMyMessageMoreData{
    messagePage++;
    [self loadMyMessageData];
}

#pragma mark -- 获取消息数据
- (void)loadMyMessageData{
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",messagePage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFMyMessage body:body success:^(id json) {
        NSArray *dataArr = [json objectForKey:@"result"];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        if (kIsArray(dataArr)) {
            for (NSDictionary *dict in dataArr) {
                TCMyMessageModel *myMessageModel = [[TCMyMessageModel alloc] init];
                [myMessageModel setValues:dict];
                [dataArray addObject:myMessageModel];
            }
            weakSelf.myMessageTab.mj_footer.hidden=dataArray.count<20;
            if (messagePage==1) {
                myMessageArr = dataArray;
                weakSelf.blankView.hidden=dataArray.count>0;
            } else {
                [myMessageArr addObject:dataArray];
            }
        }
        [weakSelf.myMessageTab.mj_header endRefreshing];
        [weakSelf.myMessageTab.mj_footer endRefreshing];
        [weakSelf.myMessageTab reloadData];

    } failure:^(NSString *errorStr) {
        [weakSelf.myMessageTab.mj_header endRefreshing];
        [weakSelf.myMessageTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- setter or getter
- (UITableView *)myMessageTab{
    if (_myMessageTab==nil) {
        _myMessageTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myMessageTab.backgroundColor = [UIColor bgColor_Gray];
        _myMessageTab.delegate = self;
        _myMessageTab.dataSource = self;
        _myMessageTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMyMessageNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myMessageTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMyMessageMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myMessageTab.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myMessageTab;
}

-(TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kRootViewHeight) img:@"ic_m_member_data" text:@"暂无消息"];
    }
    return _blankView;
}


@end
