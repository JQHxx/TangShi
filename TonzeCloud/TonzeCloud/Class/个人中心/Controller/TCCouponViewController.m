//
//  TCCouponViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/4/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCCouponViewController.h"
#import "TCBasewebViewController.h"
#import "TCMallCouponCell.h"
#import "TCServiceCouponCell.h"
#import "TCMenuView.h"

@interface TCCouponViewController ()<UITableViewDelegate,UITableViewDataSource,TCMenuViewDelegate>
{
    NSInteger   _page;
    BOOL        _isSelectMallCoupon;    // 默认选中商城优惠券
}
@property(nonatomic ,strong) UITableView *couponTabView;
/// 优惠券数据
@property (nonatomic ,strong) NSMutableArray *couponListArray;
/// 空视图
@property (nonatomic ,strong) TCBlankView *blankView;
/// 菜单栏
@property (nonatomic ,strong) TCMenuView *menuView;
/// 分段选择菜单
@property (nonatomic ,strong) UISegmentedControl *segmentedControl;

@end
@implementation TCCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = @"我的优惠卷";
    self.rigthTitleName = @"优惠券说明";
    
    _page = 1;
    _isSelectMallCoupon = YES;
    [self initCouponUI];
//    [self requestCouponList];
}
#pragma mark ====== Build UI =======

- (void)initCouponUI{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.couponTabView];
}
#pragma mark ====== Requset  Data =======
- (void)requestCouponList{
    
    NSString *body = [NSString stringWithFormat:@""];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kWebUrl body:body success:^(id json) {
        
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --- 上拉下拉加载数据 ----
- (void)loadNewCouponListData{
    _page = 1;
    [self.couponListArray removeAllObjects];
//    [self loadNewCouponListData];
    [self.couponTabView.mj_header endRefreshing];
}
- (void)loadMoreCouponListData{
    _page ++;
//    [self loadNewCouponListData];
    [self.couponTabView.mj_footer endRefreshing];
}
#pragma mark ====== Event Response =======

- (void)rightButtonAction{
    TCBasewebViewController *webVC = [[TCBasewebViewController alloc]init];
    webVC.titleText = @"优惠券说明";
    webVC.urlStr = @"";
    
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -------  优惠券状态筛选 ----------

- (void)segmentAction:(UISegmentedControl *)sender{
    
    
}
#pragma mark ====== TCMenuViewDelegate =======

- (void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index{
    _isSelectMallCoupon = !_isSelectMallCoupon;
    [self.couponTabView reloadData];
}
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 10;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
#pragma mark ====== UITableViewDelegate =======

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100 *kScreenWidth/320;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    return sectionHeaderView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footerHeaderView.backgroundColor = [UIColor bgColor_Gray];
    return footerHeaderView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *mallCouponCellIdentifier = @"couponCellIdentifier";
    static NSString *serviceCouponCellIdentifier = @"serviceCouponCellIdentifier";
    if (_isSelectMallCoupon) {
        TCMallCouponCell *mallCouponCell = [tableView dequeueReusableCellWithIdentifier:mallCouponCellIdentifier];
        if (!mallCouponCell) {
            mallCouponCell = [[TCMallCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mallCouponCellIdentifier];
        }
        return mallCouponCell;
    }else{
        TCServiceCouponCell *serviceCouponCell = [tableView dequeueReusableCellWithIdentifier:serviceCouponCellIdentifier];
        if (!serviceCouponCell) {
            serviceCouponCell = [[TCServiceCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serviceCouponCellIdentifier];
        }
        return serviceCouponCell;
    }
}
#pragma mark ====== Getter =======

- (UITableView *)couponTabView{
    if (!_couponTabView) {
        _couponTabView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.segmentedControl.bottom + 15, kScreenWidth, kRootViewHeight - 84 - 25) style:UITableViewStyleGrouped];
        _couponTabView.delegate = self;
        _couponTabView.dataSource = self;
        _couponTabView.backgroundColor = [UIColor bgColor_Gray];
        _couponTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_couponTabView addSubview:self.blankView];
        
        MJRefreshNormalHeader *mjHerder = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCouponListData)];
        mjHerder.automaticallyChangeAlpha = YES;
        _couponTabView.mj_header = mjHerder;
        
        MJRefreshAutoFooter *mjFooter = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCouponListData)];
        mjFooter.automaticallyRefresh = NO;
        _couponTabView.mj_footer = mjFooter;
        mjFooter.hidden = YES;
    }
    return  _couponTabView;
}
- (TCMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[TCMenuView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 44)];
        _menuView.delegate = self;
        _menuView.menusArray = [NSMutableArray arrayWithObjects:@"商城优惠券",@"服务优惠券", nil];
    }
    return _menuView;
}
- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"可用", @"已使用",@"已过期"]];
        _segmentedControl.frame = CGRectMake(10, self.menuView.bottom + 10, kScreenWidth - 20, 40);
        _segmentedControl.tintColor = kSystemColor;
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _segmentedControl;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"无相关的优惠券"];
        _blankView.hidden=YES;
    }
    return _blankView;
}
- (NSMutableArray *)couponListArray{
    if (!_couponListArray) {
        _couponListArray = [NSMutableArray array];
    }
    return _couponListArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
