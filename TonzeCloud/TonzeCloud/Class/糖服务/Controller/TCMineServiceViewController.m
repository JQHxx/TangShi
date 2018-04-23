//
//  TCMineServiceViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMineServiceViewController.h"
#import "TCServiceEvaluateViewController.h"
#import "TCMineServiceCell.h"
#import "TCMineServiceModel.h"
#import "TCServicingViewController.h"
#import "TCClickViewGroup.h"
#import "TCServiceDetailViewController.h"

@interface TCMineServiceViewController()<UITableViewDataSource,UITableViewDelegate,TCClickViewGroupDelegate,TCMineServiceDelegate>{
    NSMutableArray    *myServiceArray;     //我的服务
    TCBlankView       *blankView;
    NSInteger          servicePage;      //服务页数
    NSInteger         selectIndex;
}

@property (nonatomic,strong)TCClickViewGroup    *myServiceMenu;
@property (nonatomic,strong)UITableView         *myServiceTableView;

@end

@implementation TCMineServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的服务";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    myServiceArray = [[NSMutableArray alloc] init];
    
    servicePage=1;
    selectIndex=1;
    
    [self initServiceView];
    [self requestMyServiceData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TCHelper sharedTCHelper].isReloadMyService) {
        [self requestMyServiceData];
        [TCHelper sharedTCHelper].isReloadMyService=NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-05" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-05" type:2];
#endif
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return myServiceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCMineServiceCell";
    TCMineServiceCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[TCMineServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.serviceDelegate = self;
    TCMineServiceModel *mineModel =myServiceArray[indexPath.row];
    [cell cellDisplayWithDict:mineModel index:indexPath.row];
    
    [cell.evaluateServiceBtn addTarget:self action:@selector(evaluateMyServiceActionForSender:) forControlEvents:UIControlEventTouchUpInside];
    cell.evaluateServiceBtn.tag=indexPath.row;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isPersonIn) {
        [MobClick event:@"104_002024"];
    }else{
        [MobClick event:@"103_002004"];
    }

    if (selectIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"006-01-01"];
#endif
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"006-01-02"];
#endif
    }
    TCMineServiceModel *mineModel =myServiceArray[indexPath.row];
    TCServicingViewController *servicingVC=[[TCServicingViewController alloc] init];
    servicingVC.serviceModel=mineModel;
    [TCHelper sharedTCHelper].expert_id=mineModel.expert_id;
    [self.navigationController pushViewController:servicingVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 168;
}

#pragma mark ClickViewGroupDelegate
-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index{
    if (self.isPersonIn) {
        [MobClick event:@"104_002021"];
    }else{
        [MobClick event:@"103_002001"];
    }

    selectIndex=index+1;
    [self requestMyServiceData];
}

#pragma mark --TCMineServiceDelegate
- (void)chatDeledalegate:(NSInteger)experd_id{
    if (self.isPersonIn) {
        [MobClick event:@"104_002022"];
    }else{
        [MobClick event:@"103_002002"];
    }

    TCMineServiceModel *mineModel =myServiceArray[experd_id];
    TCServiceDetailViewController *serviceDetailVC=[[TCServiceDetailViewController alloc] init];
    serviceDetailVC.myService=mineModel;
    [self.navigationController pushViewController:serviceDetailVC animated:YES];

}
#pragma mark -- event Response
-(void)evaluateMyServiceActionForSender:(UIButton *)sender{
    NSInteger index=sender.tag;
    TCMineServiceModel *myService =myServiceArray[index];
    
    if (self.isPersonIn) {
        [MobClick event:@"104_002023"];
    }else{
        [MobClick event:@"103_002003"];
    }

    TCServiceEvaluateViewController *evaluateVC=[[TCServiceEvaluateViewController alloc] init];
    evaluateVC.order_id=myService.order_id;
    [self.navigationController pushViewController:evaluateVC animated:YES];
    
}

#pragma mark -- Private Methods
#pragma mark -- 请求服务列表
- (void)requestMyServiceData{
    __weak typeof(self) weakSelf=self;
    NSString *urlString = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld&service_status=%ld",kMineService,(long)servicePage,(long)selectIndex];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSArray  *dataArray = [json objectForKey:@"result"];
        if (kIsArray(dataArray)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (int i=0; i<dataArray.count; i++) {
                TCMineServiceModel *mineModel = [[TCMineServiceModel alloc] init];
                [mineModel setValues:dataArray[i]];
                [tempArr addObject:mineModel];
            }
            weakSelf.myServiceTableView.mj_footer.hidden=tempArr.count<20;
            if (servicePage==1) {
                myServiceArray = tempArr;
                blankView.hidden=tempArr.count>0;
            }else{
                [myServiceArray addObjectsFromArray:tempArr];
            }
            [weakSelf.myServiceTableView reloadData];
           
        }
        [weakSelf.myServiceTableView.mj_header endRefreshing];
        [weakSelf.myServiceTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.myServiceTableView.mj_header endRefreshing];
        [weakSelf.myServiceTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 加载最新数据
-(void)loadNewMineServiceData{
    servicePage =1;
    [self requestMyServiceData];
}

#pragma mark -- 加载更多数据
-(void)loadMoreMineServiceData{
    servicePage++;
    [self requestMyServiceData];
}

#pragma mark -- 初始化界面
- (void)initServiceView{
    [self.view addSubview:self.myServiceMenu];
    [self.view addSubview:self.myServiceTableView];
    
    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
    [self.view addSubview:blankView];
    blankView.hidden=YES;

}

#pragma mark -- Getters and Setters
#pragma mark  菜单栏
-(TCClickViewGroup *)myServiceMenu{
    if (!_myServiceMenu) {
        _myServiceMenu=[[TCClickViewGroup alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 40) titles:@[@"服务中",@"已结束"] color:kSystemColor titleColor:kLineColor];
        _myServiceMenu.viewDelegate=self;
    }
    return _myServiceMenu;
}

-(UITableView *)myServiceTableView{
    if (!_myServiceTableView) {
        _myServiceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.myServiceMenu.bottom, kScreenWidth, kScreenHeight-kNewNavHeight-41)];
        _myServiceTableView.backgroundColor = [UIColor clearColor];
        _myServiceTableView.delegate = self;
        _myServiceTableView.dataSource = self;
        _myServiceTableView.showsVerticalScrollIndicator=NO;
        _myServiceTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_myServiceTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMineServiceData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myServiceTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMineServiceData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myServiceTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myServiceTableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
