//
//  ExchangeRecordsVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeRecordsViewController.h"
#import "TCExchangeRecordsCell.h"
#import "TCExchangeRecordDetailViewController.h"
#import "TCExchangeRecordsListModel.h"
#import "TCExchangeRecordsGoodsModel.h"

@interface TCExchangeRecordsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageNum;
}
@property (nonatomic, strong) UITableView *tableView;
///
@property (nonatomic ,strong) NSMutableArray *datasource;
/// 商品数据
@property (nonatomic ,strong) NSMutableArray *goodsArray;
/// 无数据视图
@property (nonatomic ,strong)  TCBlankView *blankView;

@end

@implementation TCExchangeRecordsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"兑换记录";
    _pageNum = 1;
    [self setExchangeRecordsUI];
    [self requestExchangeRecordsData];
}
#pragma mark ====== 返回按钮 =======
- (void)leftButtonAction{
    if (_isExchangeSuccessLogin) {
        UIViewController *viewCtl = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:viewCtl animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- Bulid UI

- (void)setExchangeRecordsUI{
    [self.view addSubview:self.tableView];
}
#pragma mark -- Request Data

- (void)requestExchangeRecordsData{
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",_pageNum];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kExchangeRecordsList body:body success:^(id json) {
        NSDictionary *paramDic = [json objectForKey:@"pager"];
        if (kIsDictionary(paramDic)) {
            NSInteger totalNumber = [[paramDic objectForKey:@"total"] integerValue];
            _tableView.mj_footer.hidden = (totalNumber > _pageNum *20)<=0;
        }
        NSArray *resultArray = [json objectForKey:@"result"];
        if (kIsArray(resultArray)  && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in resultArray) {
                TCExchangeRecordsListModel *exchangeRecordsListModel = [TCExchangeRecordsListModel new];
                [exchangeRecordsListModel setValues:dic];
                [weakSelf.datasource addObject:exchangeRecordsListModel];
                TCExchangeRecordsGoodsModel *goodsModel = [TCExchangeRecordsGoodsModel new];
                [goodsModel setValues:exchangeRecordsListModel.goods];
                [weakSelf.goodsArray addObject:goodsModel];
            }
        }else{
            [weakSelf.datasource removeAllObjects];
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)loadNewGoodsData{
    _pageNum = 1;
    [self.datasource removeAllObjects];
    [self.goodsArray removeAllObjects];
    [self requestExchangeRecordsData];
}
- (void)loadMoreGoodsData{
    _pageNum++;
    [self requestExchangeRecordsData];
}
#pragma mark ====== UITableViewDelegate  =======
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier  = @"Identifier";
    TCExchangeRecordsCell *exchangeRecordsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!exchangeRecordsCell) {
        exchangeRecordsCell = [[TCExchangeRecordsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    exchangeRecordsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [exchangeRecordsCell setExchangeRecordsCellWithModle:_goodsArray[indexPath.row]];
    TCExchangeRecordsListModel *exchangeRecordsListModel = _datasource[indexPath.row];
    NSString *timeStr = exchangeRecordsListModel.add_time;
    exchangeRecordsCell.timeStr = timeStr;
    return exchangeRecordsCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCExchangeRecordDetailViewController *exchangeRecordsDetailVC = [TCExchangeRecordDetailViewController new];
    TCExchangeRecordsListModel *exchangeRecordsListModel =_datasource[indexPath.row];
    exchangeRecordsDetailVC.order_id =[exchangeRecordsListModel.order_id integerValue];
    if ([exchangeRecordsListModel.delivery_status integerValue] == 0) {
        exchangeRecordsDetailVC.shipType = NotShipped;
    }else{
        exchangeRecordsDetailVC.shipType = Shipped;
    }
    [self.navigationController pushViewController:exchangeRecordsDetailVC animated:YES];
}

#pragma mark ====== Getter =======
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewGoodsData)];
        header.automaticallyChangeAlpha= YES;
        _tableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreGoodsData)];
        footer.automaticallyRefresh = NO;
        _tableView.mj_footer = footer;
        footer.hidden=YES;
        
        [_tableView addSubview:self.blankView];
    }
    return _tableView;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0,0 , kScreenWidth, 200) img:@"img_tips_no" text:@"暂无记录"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
- (NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}
- (NSMutableArray *)goodsArray{
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
