//
//  MyIntegralVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCMyScoresViewController.h"
#import "TCMyIntegralCell.h"
#import "TCIntegralDetailViewController.h"
#import "QLCoreTextManager.h"
#import "TCUserIntegralModel.h"

@interface TCMyScoresViewController ()<UITableViewDelegate ,UITableViewDataSource>
{
    NSInteger _pageNumber;
}
@property (nonatomic ,strong) UITableView *myIntegralTableView;
/// 用户积分
@property (nonatomic ,strong) UILabel *integralNumberLab;
///
@property (nonatomic ,strong) NSMutableArray *integraldataArray;
/// 提示页面
@property (nonatomic ,strong) TCBlankView *blankView;

@end
@implementation TCMyScoresViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle= @"我的积分";
    
    _pageNumber = 1;
    [self setIntegralUI];
    [self requestIntegralData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"007-01-01" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"007-01-01" type:2];
#endif
}
#pragma mark ====== Bulid UI  =======

- (void)setIntegralUI{
    [self.view addSubview:self.myIntegralTableView];
}   
- (UIView *)tableHealView{
    UIView *tableHealView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
    tableHealView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0,55/2, kScreenWidth, 15)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"糖士积分";
    titleLab.font = kFontWithSize(13);
    titleLab.textColor = UIColorFromRGB(0x313131);
    [tableHealView addSubview:titleLab];
    
    /// 用户积分
    NSString*integralStr = [NSString stringWithFormat:@"%ld",(long)_userIntegral];
    CGSize integralNumSize = [integralStr boundingRectWithSize:CGSizeMake(kScreenWidth, 60) withTextFont:kFontWithSize(60)];
    
    _integralNumberLab = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth - integralNumSize.width)/2 , titleLab.bottom + 10, kScreenWidth, 60)];
    _integralNumberLab.textAlignment = NSTextAlignmentLeft;
    _integralNumberLab.textColor = UIColorFromRGB(0xf9c92b);
    _integralNumberLab.font = kFontWithSize(60);
    _integralNumberLab.text = [NSString stringWithFormat:@"%ld",(long)_userIntegral];
    [tableHealView addSubview:_integralNumberLab];
    

    UIImageView *integralIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_integralNumberLab.left - 45 , _integralNumberLab.top + 12 , 38, 38)];
    integralIcon.image = [UIImage imageNamed:@"money_ic@2x"];
    [tableHealView addSubview:integralIcon];
    
    UIImageView *integralIconImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 274/2)/2, _integralNumberLab.bottom + 11/2,274/2 , 52/2)];
    integralIconImg.image = [UIImage imageNamed:@"integral_shadow_bg"];
    [tableHealView addSubview:integralIconImg];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, tableHealView.height - 0.5, kScreenWidth, 0.5)];
    len.backgroundColor = kLineColor;
    [tableHealView addSubview:len];
    
    return tableHealView;
}
#pragma mark ======  Request Data =======

- (void)requestIntegralData{
    // App版本信息
    NSString *version = [NSString getAppVersion];
    NSString *url = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld&app_version=%@",KIntegralList,(long)_pageNumber,version];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        // 用户积分
        NSInteger totalNumber = [[json objectForKey:@"total"] integerValue];
        weakSelf.myIntegralTableView.mj_footer.hidden=(totalNumber-_pageNumber *20)<=0;
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in resultArray) {
                TCUserIntegralModel *userIntegralModel = [TCUserIntegralModel new];
                [userIntegralModel setValues:dic];
                [weakSelf.integraldataArray  addObject:userIntegralModel];
            }
        }else{
            [weakSelf.integraldataArray removeAllObjects];
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.myIntegralTableView.mj_header endRefreshing];
        [weakSelf.myIntegralTableView.mj_footer endRefreshing];
        [weakSelf.myIntegralTableView reloadData];

    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.myIntegralTableView.mj_header endRefreshing];
        [weakSelf.myIntegralTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)loadNewRecordData{
    _pageNumber = 1;
    [_integraldataArray removeAllObjects];
    [self requestIntegralData];
}
- (void)loadMoreRecordData{
    _pageNumber++;
    [self requestIntegralData];
}
#pragma mark ====== UITableViewDelegate ,UITableViewDataSource =======

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _integraldataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *integralIdentifier  = @"integralIdentifier";
    TCMyIntegralCell *integralCell = [tableView dequeueReusableCellWithIdentifier:integralIdentifier];
    if (!integralCell) {
        integralCell = [[TCMyIntegralCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:integralIdentifier];
        integralCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [integralCell setCellModel:_integraldataArray[indexPath.row]];
    return integralCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"007-01-01"];
#endif
    TCIntegralDetailViewController *IntegralDetailVC = [TCIntegralDetailViewController new];
    TCUserIntegralModel *model =_integraldataArray[indexPath.row];
    IntegralDetailVC.userIntegralmodel = model;
    [self.navigationController pushViewController:IntegralDetailVC animated:YES];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark ====== Getter =======
- (UITableView *)myIntegralTableView{
    if (!_myIntegralTableView) {
        _myIntegralTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myIntegralTableView.delegate = self;
        _myIntegralTableView.dataSource = self;
        _myIntegralTableView.backgroundColor =  [UIColor bgColor_Gray];
        _myIntegralTableView.tableHeaderView = [self tableHealView];
        _myIntegralTableView.tableFooterView = [UIView new];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myIntegralTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myIntegralTableView.mj_footer = footer;
        footer.hidden=YES;
        
        [_myIntegralTableView addSubview:self.blankView];
    }
    return _myIntegralTableView;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0,180, kScreenWidth, kScreenHeight - 200) img:@"img_tips_no" text:@"暂无数据"];
        _blankView.hidden = YES;
    }
    return _blankView;
}

- (NSMutableArray *)integraldataArray{
    if (!_integraldataArray) {
        _integraldataArray = [NSMutableArray array];
    }
    return _integraldataArray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
