//
//  TCGPRSRecordsViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSRecordsViewController.h"
#import "TCGPRSRecordsCell.h"
#import "TCGPRSRecordsModel.h"

static NSString *recordsIdentifier = @"recordsIdentifier";

@interface TCGPRSRecordsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger   _pageNum;
}
///
@property (nonatomic ,strong) TCBlankView *recordBlankView;

@property (nonatomic,strong) UITableView *recordTab;
///
@property (nonatomic ,strong) NSMutableArray *singleHistoryListArray;
/// 日期标题
@property (nonatomic ,strong) NSMutableArray *dataTitleArray;
@end

@implementation TCGPRSRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"历史记录";
    _pageNum = 1;
    [self setRecordsVC];
    [self requestSingleHistoryData];
}
#pragma mark ====== 布局UI =======

- (void)setRecordsVC{
    [self.recordTab registerNib:[UINib nibWithNibName:@"TCGPRSRecordsCell" bundle:nil] forCellReuseIdentifier:recordsIdentifier];
    [self.view addSubview:self.recordTab];
}
#pragma mark ====== Request Data =======

-(void)requestSingleHistoryData{
    NSString *url = [NSString stringWithFormat:@"%@?sn=%@&page_size=20&page_num=%ld",KsingleHistory,_sn,(long)_pageNum];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
        
        if (kIsArray(resultArray) && resultArray.count > 0) {
            for (NSDictionary *dic in resultArray) {
                TCGPRSRecordsModel *reconrdModel = [TCGPRSRecordsModel new];
                [reconrdModel setValues:dic];
                [tempArr addObject:reconrdModel];
                
                NSString *dataTime = [[TCHelper sharedTCHelper]timeWithTimeIntervalString:reconrdModel.measurement_time format:@"yyyy/MM/dd"];
                [tempTimeArr addObject:dataTime];
                if (_pageNum == 1) {
                    weakSelf.dataTitleArray = tempTimeArr;
                    weakSelf.singleHistoryListArray = tempArr;
                }else{
                    [ weakSelf.singleHistoryListArray addObjectsFromArray:tempArr];
                    [weakSelf.dataTitleArray  addObjectsFromArray:tempTimeArr];
                }
                NSSet *set = [NSSet setWithArray:weakSelf.dataTitleArray]; //去重
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                weakSelf.dataTitleArray = [NSMutableArray arrayWithArray:timeArr];
            }
            weakSelf.recordTab.tableFooterView = tempTimeArr.count < 20 ? [self tableCommentFooterView] : [UIView new];
        }
        weakSelf.recordTab.mj_footer.hidden = tempTimeArr.count < 20;
        weakSelf.recordBlankView.hidden=weakSelf.dataTitleArray.count>0?YES:NO;
        [weakSelf.recordTab.mj_header endRefreshing];
        [weakSelf.recordTab.mj_footer endRefreshing];
        [weakSelf.recordTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.recordTab.mj_header endRefreshing];
        [weakSelf.recordTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 重新加载数据 =======
- (void)newBloodGlucoseRecords{
    _pageNum = 1;
    [self requestSingleHistoryData];
}
#pragma mark ====== 加载更多 =======
- (void)loadMoreBloodGlucoseRecords{
    _pageNum++;
    [self  requestSingleHistoryData];
}
#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   return  self.dataTitleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=self.dataTitleArray[section];
    for (TCGPRSRecordsModel *reconrdModel in self.singleHistoryListArray) {
        NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:reconrdModel.measurement_time format:@"yyyy/MM/dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:reconrdModel];
        }
    }
    return tempList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 59;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.dataTitleArray[section];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCGPRSRecordsCell *recordsCell = [tableView dequeueReusableCellWithIdentifier:recordsIdentifier];
    recordsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=self.dataTitleArray[indexPath.section];
    for (TCGPRSRecordsModel *reconrdModel in self.singleHistoryListArray) {
        NSString *timeKey= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:reconrdModel.measurement_time format:@"yyyy/MM/dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:reconrdModel];
        }
    }
    TCGPRSRecordsModel *reconrdModel = tempList[indexPath.row];
    [recordsCell cellDisplayWithRecord:reconrdModel];
    return recordsCell;
}
#pragma mark ====== Setter =======
- (UITableView *)recordTab{
    if (!_recordTab) {
        _recordTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _recordTab.delegate = self;
        _recordTab.dataSource = self;
        _recordTab.backgroundColor = [UIColor bgColor_Gray];
        MJRefreshNormalHeader *mjHeader  = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(newBloodGlucoseRecords)];
        mjHeader.stateLabel.text = @"下拉刷新";
        _recordTab.mj_header = mjHeader;
        
        MJRefreshAutoNormalFooter *mjFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreBloodGlucoseRecords)];
        mjFooter.automaticallyRefresh = NO;
        _recordTab.mj_footer = mjFooter;
        mjFooter.hidden = YES;
        
        [_recordTab addSubview:self.recordBlankView];
    }
    return _recordTab;
}
- (NSMutableArray *)singleHistoryListArray{
    if (!_singleHistoryListArray) {
        _singleHistoryListArray = [NSMutableArray array];
    }
    return _singleHistoryListArray;
}
- (NSMutableArray *)dataTitleArray{
    if (!_dataTitleArray) {
        _dataTitleArray = [NSMutableArray array];
    }
    return _dataTitleArray;
}
#pragma mark ======  没有更多评论 =======
- (UIView *)tableCommentFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    
    return footerView;
}
#pragma mark 无数据空白页
-(TCBlankView *)recordBlankView{
    if (_recordBlankView==nil) {
        _recordBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 40, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无历史记录"];
    }
    return _recordBlankView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
