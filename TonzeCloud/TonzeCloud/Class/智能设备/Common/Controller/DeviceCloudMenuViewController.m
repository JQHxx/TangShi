//
//  DeviceCloudMenuViewController.m
//  Product
//
//  Created by Feng on 16/3/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceCloudMenuViewController.h"
#import "AppDelegate.h"
#import "TCMainDeviceHelper.h"
#import "DeviceCloudMenuTableViewCell.h"
#import "CloudMenuDetailViewController.h"
#import "TCCookListModel.h"

@interface DeviceCloudMenuViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  *menuArray;
    NSInteger       page;
}

@property(nonatomic,strong)UITableView *deviceCloudMenuTab;
@property(nonatomic,strong)TCBlankView * blankView;

@end

@implementation DeviceCloudMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.baseTitle=self.titleText;
    
    page=1;
    menuArray = [[NSMutableArray alloc] init];

    [self.view addSubview:self.deviceCloudMenuTab];
    [self.deviceCloudMenuTab addSubview:self.blankView];
    self.blankView.hidden=YES;

    [self requestCloudMenu];
}

#pragma mark --UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DeviceCloudMenuTableViewCell";
    DeviceCloudMenuTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DeviceCloudMenuTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCCookListModel *model = menuArray[indexPath.row];
    [cell cellDisplayWithModel:model];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCCookListModel *deviceCloudModel = menuArray[indexPath.row];
    CloudMenuDetailViewController *cloudMenuDetailVC = [[CloudMenuDetailViewController alloc] init];
    cloudMenuDetailVC.model = self.model;
    cloudMenuDetailVC.isLowerSugarCook=[self.titleText isEqualToString:@"更换偏好"];
    cloudMenuDetailVC.menuid  = deviceCloudModel.cook_id;
    cloudMenuDetailVC.imageUrl=deviceCloudModel.image_id_cover;
    [self.navigationController pushViewController:cloudMenuDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


#pragma mark -- Private Methods
#pragma mark 加载更多
- (void)loadMoreCloudMenuData{
    page++;
    [self requestCloudMenu];
}

#pragma mark 加载最新
- (void)loadNewCloudMenuData{
    page = 1;
    [self requestCloudMenu];
}

#pragma mark -- 获取云菜谱列表
- (void)requestCloudMenu{
    NSString *body  = nil;
    if([self.titleText isEqualToString:@"更换偏好"]) {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&type=1&equipment=11&tag=5",(long)page];
    }else{
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&type=1&equipment=11",(long)page];
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kCloudMenuList body:body success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        NSMutableArray *dataArr = [NSMutableArray array];
        if (kIsArray(resultArr)) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic  in resultArr) {
                TCCookListModel *menuListModel = [[TCCookListModel alloc] init];
                [menuListModel setValues:dic];
                [dataArr addObject:menuListModel];
            }
            self.deviceCloudMenuTab.mj_footer.hidden=dataArr.count<20;
            
            if (page==1) {
                menuArray=dataArr;
            }else{
                [menuArray addObjectsFromArray:dataArr];
            }
        }
        [weakSelf.deviceCloudMenuTab.mj_header endRefreshing];
        [weakSelf.deviceCloudMenuTab.mj_footer endRefreshing];
        [weakSelf.deviceCloudMenuTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.deviceCloudMenuTab.mj_header endRefreshing];
        [weakSelf.deviceCloudMenuTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Getters
#pragma mark  菜谱列表
- (UITableView *)deviceCloudMenuTab{
    if (_deviceCloudMenuTab==nil) {
        _deviceCloudMenuTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _deviceCloudMenuTab.backgroundColor = [UIColor bgColor_Gray];
        _deviceCloudMenuTab.delegate = self;
        _deviceCloudMenuTab.dataSource = self;
        _deviceCloudMenuTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCloudMenuData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _deviceCloudMenuTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCloudMenuData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _deviceCloudMenuTab.mj_footer = footer;
        footer.hidden = YES;

    }
    return _deviceCloudMenuTab;
}

#pragma mark  暂无数据页面
-(TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:self.deviceCloudMenuTab.bounds img:@"img_pub_none" text:@"暂无云菜谱"];
    }
    return _blankView;
}


@end
