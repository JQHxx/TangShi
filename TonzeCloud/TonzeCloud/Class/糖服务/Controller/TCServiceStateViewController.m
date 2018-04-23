//
//  TCServiceStateViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceStateViewController.h"
#import "TCServiceStateCell.h"

@interface TCServiceStateViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  *currentServicesArray;
    NSMutableArray  *historyServicesArray;
    NSInteger       page;
}

@property (nonatomic,strong)UITableView   *stateTableView;

@end

@implementation TCServiceStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    page=1;
    currentServicesArray=[[NSMutableArray alloc] init];
    historyServicesArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.stateTableView];
    
    [self requestMyServiceStateInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"服务情况"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"服务情况"];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?currentServicesArray.count:historyServicesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCServiceStateCell";
    TCServiceStateCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCServiceStateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCMineServiceModel *service=indexPath.section==0?currentServicesArray[indexPath.row]:historyServicesArray[indexPath.row];
    cell.myService=service;
    
    [cell.evaluateBtn addTarget:self action:@selector(evaluateMyServiceForButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.evaluateBtn.tag=indexPath.section*100+indexPath.row;
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCMineServiceModel *service=indexPath.section==0?currentServicesArray[indexPath.row]:historyServicesArray[indexPath.row];
    if ([_controllerDelegate respondsToSelector:@selector(serviceStateVCDidSelectedCellWithModel:)]) {
        [_controllerDelegate serviceStateVCDidSelectedCellWithModel:service];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *headStr=@"";
    if (section==0) {
        headStr=currentServicesArray.count>0?@"当前服务":@"";
    }else{
        headStr=historyServicesArray.count>0?@"服务历史":@"";
    }
    return headStr;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat headHeight=5;
    if (section==0) {
        headHeight=currentServicesArray.count>0?30:5;
    }else{
        headHeight=historyServicesArray.count>0?30:5;
    }
    return headHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

#pragma mark -- Event Response
-(void)evaluateMyServiceForButton:(UIButton *)sender{
    NSInteger section=sender.tag/100;
    NSInteger row=sender.tag%100;
    
    MyLog(@"选择第%ld组，第%ld行",section,row);
    TCMineServiceModel *service=section==0?currentServicesArray[row]:historyServicesArray[row];
    if ([_controllerDelegate respondsToSelector:@selector(serviceStateVCPushToEvaluateWithModel:)]) {
        [_controllerDelegate serviceStateVCPushToEvaluateWithModel:service];
    }
}

#pragma mark -- Private Methods
-(void)loadNewMyServiceData{
    page=1;
    [self requestMyServiceStateInfo];
}

-(void)loadMoreMyServiceData{
    page++;
    [self requestMyServiceStateInfo];
}

#pragma mark 获取服务情况
-(void)requestMyServiceStateInfo{
    __weak typeof(self) weakSelf=self;
    NSInteger expertID=[TCHelper sharedTCHelper].expert_id;
    NSString *urlString = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld&expert_id=%ld",kMineService,(long)page,(long)expertID];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSArray  *dataArray = [json objectForKey:@"result"];
        NSMutableArray *currentTempArray = [[NSMutableArray alloc] init];
        NSMutableArray *historyTempArray = [[NSMutableArray alloc] init];
        if (kIsArray(dataArray)) {
            for (int i=0; i<dataArray.count; i++) {
                TCMineServiceModel *mineModel = [[TCMineServiceModel alloc] init];
                NSDictionary *dict=[dataArray objectAtIndex:i];
                [mineModel setValues:dict];
                if (mineModel.service_status==1) {
                    [currentTempArray addObject:mineModel];
                }else{
                    [historyTempArray addObject:mineModel];
                }
            }
            if (page==1) {
                currentServicesArray=currentTempArray;
                historyServicesArray=historyTempArray;
            }else{
                [currentServicesArray addObjectsFromArray:currentTempArray];
                [historyServicesArray addObjectsFromArray:historyTempArray];
            }
            weakSelf.stateTableView.mj_footer.hidden=(currentTempArray.count+historyTempArray.count)<20;
            [weakSelf.stateTableView reloadData];
        }
        [weakSelf.stateTableView.mj_header endRefreshing];
        [weakSelf.stateTableView.mj_footer endRefreshing];
    }failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Getters
#pragma mark 服务情况
-(UITableView *)stateTableView{
    if (!_stateTableView) {
        _stateTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight-40) style:UITableViewStyleGrouped];
        _stateTableView.delegate=self;
        _stateTableView.dataSource=self;
        _stateTableView.backgroundColor=[UIColor bgColor_Gray];
        _stateTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMyServiceData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _stateTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMyServiceData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _stateTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _stateTableView;
}


@end
