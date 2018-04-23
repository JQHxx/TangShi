//
//  TCChooseCouponViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/4/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCChooseCouponViewController.h"
#import "TCBasewebViewController.h"
#import "TCServiceCouponCell.h"
#import "TCMallCouponCell.h"
#import "TCMenuView.h"

@interface TCChooseCouponViewController ()<UITableViewDataSource,UITableViewDelegate,TCMenuViewDelegate>
{
    NSInteger   _page;
    BOOL        _isSelectUnUseCoupon;
    BOOL        _isShowSelectIcon;  // 是否显示可勾选图标
}
@property (nonatomic, strong) UITableView  *chooseCouponTab;
/// 优惠卷数据
@property (nonatomic ,strong) NSMutableArray *couponDataSourse;
/// 优惠券可用性菜单栏
@property (nonatomic ,strong) TCMenuView *menuView;
/// 选中优惠券图片（默认状态）
@property (nonatomic ,strong) UIImageView *selectCouponImg;
/// 空视图
@property (nonatomic ,strong) TCBlankView *blankView;

@end

@implementation TCChooseCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"选择优惠券";
    self.rigthTitleName = @"优惠券说明";
    
    _page = 1;
    _isSelectUnUseCoupon = YES;
    _isShowSelectIcon = YES;
    [self initChooseCouponUI];
//    [self requestCouponData];
}
#pragma mark ====== Bulid UI =======

- (void)initChooseCouponUI{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.chooseCouponTab];
}
#pragma mark -----  默认选中优惠券视图  ----
- (UIView *)tableHeaderView{
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    CALayer *topLine = [[CALayer alloc]init];
    topLine.frame = CGRectMake(0,0, kScreenWidth, 10);
    topLine.backgroundColor = [UIColor bgColor_Gray].CGColor;
    [tableHeaderView.layer addSublayer:topLine];
    
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(10,10, 200, 44)];
    tipLab.text = @"不使用优惠券";
    tipLab.textColor = UIColorHex(0x626262);
    tipLab.font = kBoldFontWithSize(15);
    [tableHeaderView addSubview:tipLab];
    
    _selectCouponImg = [[UIImageView alloc]init];
    _selectCouponImg.frame = CGRectMake(kScreenWidth - 30, 10 + (44 - 15)/2, 15, 15);
    _selectCouponImg.image = [UIImage imageNamed:@"ic_eqment_pick_on"];//ic_eqment_pick_un
    [tableHeaderView addSubview:_selectCouponImg];
    
    UIButton *unChooseCouponBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unChooseCouponBtn.frame = CGRectMake(0, 0, kScreenWidth, tableHeaderView.height);
    unChooseCouponBtn.backgroundColor = [UIColor clearColor];
    [unChooseCouponBtn addTarget:self action:@selector(unChooseCouponBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:unChooseCouponBtn];
    // 间隔线
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, 64 - 10, kScreenWidth, 10);
    line.backgroundColor = [UIColor bgColor_Gray].CGColor;
    [tableHeaderView.layer addSublayer:line];
    
    return tableHeaderView;
}
#pragma mark ====== Requset Data =======
- (void)requestCouponData{

    NSString *body = [NSString stringWithFormat:@""];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kNewsWebUrl body:body success:^(id json) {
        
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ----- 刷新数据 -----
- (void)loadNewCouponListData
{
    _page = 1;
    [self.couponDataSourse removeAllObjects];
    [self requestCouponData];
}
#pragma mark ----- 加载更多数据 -----
- (void)loadMoreCouponListData{
    _page++;
    [self requestCouponData];
}
#pragma mark ====== Event  Response =======

- (void)rightButtonAction{
    TCBasewebViewController *webVC = [[TCBasewebViewController alloc]init];
    webVC.titleText = @"优惠券说明";
    webVC.urlStr = @"";
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark ====== 不使用优惠券点击 =======
- (void)unChooseCouponBtnAction{
    _isSelectUnUseCoupon = !_isSelectUnUseCoupon;
    _selectCouponImg.image = _isSelectUnUseCoupon ? [UIImage imageNamed:@"ic_eqment_pick_un"] : [UIImage imageNamed:@"ic_eqment_pick_on"];
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
    return 100 * kScreenWidth/320;
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
    
    static NSString *serviceCouponCellIdentifier = @"ServiceCouponCellIdentifier";
    static NSString  *mallCouponCellIdentifier = @"mallCouponCellIdentifier";
    if (_cupontype == ServiceCoupon) {
        TCServiceCouponCell *chooseCouponCell = [tableView dequeueReusableCellWithIdentifier:serviceCouponCellIdentifier];
        if (!chooseCouponCell) {
            chooseCouponCell = [[TCServiceCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serviceCouponCellIdentifier];
        }
        chooseCouponCell.isShowSelectIcon = _isShowSelectIcon;
        return chooseCouponCell;
    }else{
        TCMallCouponCell *mallCouponCell = [tableView dequeueReusableCellWithIdentifier:mallCouponCellIdentifier];
        if (!mallCouponCell) {
            mallCouponCell = [[TCMallCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mallCouponCellIdentifier];
        }
        mallCouponCell.isShowSelectIcon = _isShowSelectIcon;
        return mallCouponCell;
    }
}
#pragma mark ====== TCMenuViewDelegate =======

- (void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index{
    if (index == 0) {
        _isShowSelectIcon = YES;
    }else{
        _isShowSelectIcon = NO;
    }
    [self.chooseCouponTab setContentOffset:CGPointMake(0,0) animated:YES];
    [self.chooseCouponTab reloadData];
}
#pragma mark ====== Getter =======

- (UITableView *)chooseCouponTab{
    if (!_chooseCouponTab) {
        _chooseCouponTab = [[UITableView alloc]initWithFrame:CGRectMake(0, self.menuView.bottom, kScreenWidth, kRootViewHeight - 44) style:UITableViewStyleGrouped];
        _chooseCouponTab.delegate = self;
        _chooseCouponTab.dataSource = self;
        _chooseCouponTab.backgroundColor = [UIColor bgColor_Gray];
        _chooseCouponTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chooseCouponTab.tableHeaderView = [self tableHeaderView];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCouponListData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _chooseCouponTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCouponListData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _chooseCouponTab.mj_footer = footer;
        footer.hidden=YES;
        
        [_chooseCouponTab addSubview:self.blankView];
    }
    return _chooseCouponTab;
}
- (TCMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[TCMenuView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 44)];
        _menuView.delegate = self;
        _menuView.menusArray = [NSMutableArray arrayWithObjects:@"可用优惠券",@"不可用优惠券", nil];
    }
    return _menuView;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"无相关的优惠券"];
        _blankView.hidden=YES;
    }
    return _blankView;
}
- (NSMutableArray *)couponDataSourse{
    if (!_couponDataSourse) {
        _couponDataSourse = [NSMutableArray array];
    }
    return _couponDataSourse;
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
