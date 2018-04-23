//
//  TCMineExpertController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMineExpertController.h"
#import "TCMineExpertCell.h"
#import "TCMineExpertModel.h"
#import "TCExpertDetailController.h"

@interface TCMineExpertController ()<UITableViewDelegate,UITableViewDataSource,TCMineExpertDelegate>{

    UITableView        *_mineExpertTab;
    NSMutableArray     *toolArray;
    NSMutableArray    *serviceArray;  //我的专家
    TCBlankView    *blankView;
    NSInteger       foodPage;    //我的专家页数
}
@end
@implementation TCMineExpertController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的专家";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    [self initMineExportView];
    [self requestMyExpertData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isCancleCare==YES) {
        [self requestMyExpertData];
        [TCHelper sharedTCHelper].isCancleCare = NO;
    }
}
#pragma mark --TCMineExpertDelegate
- (void)returnIndex:(NSInteger)index{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"是否取消关注" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancleAttention:index];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return toolArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCMineExpertCell";
    TCMineExpertCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[TCMineExpertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    TCMineExpertModel *ExpertModel = toolArray[indexPath.row];
    [cell cellDisplayWithDict:ExpertModel Index:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    TCExpertDetailController *expertDetailVC = [[TCExpertDetailController alloc] init];
    TCMineExpertModel *ExpertModel = toolArray[indexPath.row];
    expertDetailVC.expert_id = ExpertModel.expert_id;
    [self.navigationController pushViewController:expertDetailVC animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  80;
}
#pragma mark -- Event response
#pragma mark -- 取消关注
- (void)cancleAttention:(NSInteger)index{
    
    NSString *urlString = [NSString stringWithFormat:@"focus=2&expert_id=%ld&user_id=10",(long)index];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kCancleCare body:urlString success:^(id json) {
        [self requestMyExpertData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        
    }];
    
}
#pragma mark -- Event Methods
#pragma mark -- 加载专家列表
- (void)requestMyExpertData{
    NSString *urlString = [NSString stringWithFormat:@"%@?page_size=20&page_num=1",kMineExpert];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        if (dataArray.count) {
            toolArray = [[NSMutableArray alloc] init];
            for (int i=0; i<dataArray.count; i++) {
                TCMineExpertModel *ExpertModel = [[TCMineExpertModel alloc] init];
                [ExpertModel setValues:dataArray[i]];
                [toolArray addObject:ExpertModel];
            }
            
            if (foodPage==1) {
                serviceArray = [[NSMutableArray alloc] init];
                serviceArray = toolArray;
                blankView.hidden=toolArray.count>0;
            }else{
                [serviceArray addObjectsFromArray:toolArray];
            }
            [_mineExpertTab reloadData];
            [_mineExpertTab.mj_header endRefreshing];
            [_mineExpertTab.mj_footer endRefreshing];
        }
        else{
            toolArray = [[NSMutableArray alloc] init];
            _mineExpertTab.mj_footer.hidden=YES;
            [_mineExpertTab reloadData];
            blankView.hidden=toolArray.count>0;
        }
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 加载最新数据
-(void)loadNewMineExpertData{
    foodPage =1;
    [self requestMyExpertData];
}
#pragma mark -- 加载更多数据
-(void)loadMoreMineExpertData{
    foodPage++;
    [self requestMyExpertData];
}
#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initMineExportView{

    _mineExpertTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, kScreenWidth, kScreenHeight-65)];
    _mineExpertTab.backgroundColor = [UIColor clearColor];
    _mineExpertTab.delegate = self;
    _mineExpertTab.dataSource = self;
    _mineExpertTab.showsVerticalScrollIndicator=NO;
    _mineExpertTab.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:_mineExpertTab];
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMineExpertData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    _mineExpertTab.mj_header=header;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMineExpertData)];
    footer.automaticallyRefresh = NO;// 禁止自动加载
    _mineExpertTab.mj_footer = footer;
    footer.hidden=YES;

    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无专家数据"];
    [self.view addSubview:blankView];
    blankView.hidden=YES;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
