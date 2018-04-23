
//
//  TCChooseTopicViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCChooseTopicViewController.h"
#import "TCChooseTopicCell.h"
#import "TCTopicListModel.h"

@interface TCChooseTopicViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageNum;
}
@property (nonatomic, strong) UITableView *chooseTopicTab;
///
@property (nonatomic ,strong) NSMutableArray *topicArray;
/// 无数据视图
@property (nonatomic ,strong) TCBlankView *blankView;
@end

@implementation TCChooseTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"选择话题";
    
    _pageNum = 1;
    [self setChooseTopicVC];
    [self loadChooseTopicData];
}
#pragma mark ====== 布局UI =======

- (void)setChooseTopicVC{
    [self.view addSubview:self.chooseTopicTab];
}
#pragma mark ====== 刷新话题 =======
- (void)newTopicData{
    [self.topicArray removeAllObjects];
    _pageNum = 1;
    [self loadChooseTopicData];
}

#pragma mark ====== 更多话题 =======
- (void)moreTopicData{
    _pageNum++;
    [self loadChooseTopicData];
}
#pragma mark ====== 加载数据 =======

- (void)loadChooseTopicData{
    NSString *url = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld&is_limit=1&role_type=0",KTopicLists,(long)_pageNum];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        NSInteger totalNum = [[json objectForKey:@"total"] integerValue];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            weakSelf.chooseTopicTab.mj_footer.hidden = (totalNum -_pageNum*20)<= 0;
            for (NSDictionary *dic in resultArray) {
                TCTopicListModel *topicListModel = [TCTopicListModel new];
                [topicListModel setValues:dic];
                [weakSelf.topicArray addObject:topicListModel];
            }
        }else{
            weakSelf.blankView.hidden = NO;
            [weakSelf.topicArray removeAllObjects];
        }
        [weakSelf.chooseTopicTab reloadData];
        [weakSelf.chooseTopicTab.mj_header endRefreshing];
        [weakSelf.chooseTopicTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.chooseTopicTab.mj_header endRefreshing];
        [weakSelf.chooseTopicTab.mj_footer endRefreshing];
        weakSelf.chooseTopicTab.mj_footer.hidden = YES;
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _topicArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifiel  = @"cellIdentifier";

    TCChooseTopicCell *chooseTopCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiel];
    if (!chooseTopCell) {
        chooseTopCell = [[TCChooseTopicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiel];
    }
    [chooseTopCell cellwithModel:_topicArray[indexPath.row]selectTopicStr:_topicStr];
    return chooseTopCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TCTopicListModel *topicListModel = self.topicArray[indexPath.row];
    if (self.topicTitleBlock) {
        self.topicTitleBlock(topicListModel.title,topicListModel.topic_id);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ====== Getter =======

- (UITableView *)chooseTopicTab{
    if (!_chooseTopicTab) {
        _chooseTopicTab = [[UITableView alloc]initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _chooseTopicTab.delegate = self;
        _chooseTopicTab.dataSource = self;
        _chooseTopicTab.backgroundColor = [UIColor bgColor_Gray];
        _chooseTopicTab.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _chooseTopicTab.separatorInset=UIEdgeInsetsMake(0,0, 0, 0);           //top left bottom right 左右边距相同
        _chooseTopicTab.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(newTopicData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _chooseTopicTab.mj_header = header;
        
        MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreTopicData)];
        footer.automaticallyRefresh = NO;
        footer.hidden=YES;
        _chooseTopicTab.mj_footer = footer;
        
        [_chooseTopicTab addSubview:self.blankView];
    }
    return _chooseTopicTab;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, 40, kScreenWidth, 200) img:@"un_dynamic" text:@"暂无话题"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
// 话题数据
- (NSMutableArray *)topicArray{
    if (!_topicArray) {
        _topicArray = [NSMutableArray array];
    }
    return _topicArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
