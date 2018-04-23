//
//  TCTopicViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTopicListViewController.h"
#import "TCDropmenuView.h"
#import "TCTopicListCell.h"
#import "TCTopicDetailsViewController.h"
#import "TCTopicListModel.h"

@interface TCTopicListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *_topicSelectionBtn;
    TCDropmenuView *_dropmenuView;
    NSInteger _pageNum;
    NSInteger _type;
}
@property (nonatomic,strong) UITableView *topicListTab;
/// 话题数据
@property (nonatomic ,strong) NSMutableArray *topicListArray;
/// 导航栏
@property (nonatomic ,strong) UIView *navBarView;
/// 无数据视图
@property (nonatomic ,strong) TCBlankView *blankView;

@end

@implementation TCTopicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenNavBar = YES;
    
    _pageNum = 1;
    _type = 1;
    [self setTopicListVC];
    [self loadTopicListData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"话题列表"];
    [[TCHelper sharedTCHelper] loginAction:@"008-05" type:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"话题列表"];
    [[TCHelper sharedTCHelper] loginAction:@"008-05" type:2];
}

#pragma mark ====== 布局 UI =======
- (void)setTopicListVC{
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.topicListTab];
    
    _dropmenuView = [[TCDropmenuView alloc]initWithFrame:CGRectMake(kScreenWidth - 100, CGRectGetMaxY(_topicSelectionBtn.frame), 90, 0)];
    _dropmenuView.offsetXOfArrow = 20;
    [_dropmenuView addItems:@[@"按热度",@"按时间"]];
    
    kSelfWeak;
    [_dropmenuView selectedAtIndexHandle:^(NSUInteger index, NSString *itemName) {
        
        [_topicSelectionBtn setTitle:itemName forState:UIControlStateNormal];
        if (index == 0) {
            [MobClick event:@"105_002023"];
            [[TCHelper sharedTCHelper] loginClick:@"008-05-05"];
            _type = 1;
            [_topicSelectionBtn setImage:[UIImage imageNamed:@"fire"] forState:UIControlStateNormal];
        }else{
            [[TCHelper sharedTCHelper] loginClick:@"008-05-06"];
            [MobClick event:@"105_002024"];
            _type = 2;
            [_topicSelectionBtn setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        }
        _pageNum = 1;
        [weakSelf.topicListArray removeAllObjects];
        [weakSelf loadTopicListData];
    }];
}
#pragma mark ====== 加载数据 =======

- (void)loadTopicListData{
    
    NSString *url = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld&type=%ld",KTopicLists,_pageNum,_type];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        NSInteger totalNum = [[json objectForKey:@"total"] integerValue];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            weakSelf.topicListTab.mj_footer.hidden = (totalNum -_pageNum*20)<= 0;
            for (NSDictionary *dic in resultArray) {
                TCTopicListModel *topicListModel = [TCTopicListModel new];
                topicListModel.title = [dic objectForKey:@"title"];
                topicListModel.desc = [dic objectForKey:@"desc"];
                topicListModel.topic_id = [[dic objectForKey:@"topic_id"] integerValue];
                topicListModel.default_image = [dic objectForKey:@"default_image"];
                topicListModel.read_num = [[dic objectForKey:@"read_num"] integerValue];
                topicListModel.comment_num = [[dic objectForKey:@"comment_num"] integerValue];
                [weakSelf.topicListArray addObject:topicListModel];
            }
        }else{
            weakSelf.blankView.hidden = NO;
            [weakSelf.topicListArray removeAllObjects];
        }
        [weakSelf.topicListTab reloadData];
        [weakSelf.topicListTab.mj_header endRefreshing];
        [weakSelf.topicListTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.topicListTab.mj_header endRefreshing];
        [weakSelf.topicListTab.mj_footer endRefreshing];
        weakSelf.topicListTab.mj_footer.hidden = YES;
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 刷新话题 =======
- (void)newTopicData{
    [self.topicListArray removeAllObjects];
    _pageNum = 1;
    [self loadTopicListData];
}
#pragma mark ====== 更多话题 =======
- (void)moreTopicData{
    _pageNum++;
    [self loadTopicListData];
}
#pragma mark ====== 返回按钮 =======

- (void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ====== 话题筛选 =======
- (void)selectionClick{
    
    [_dropmenuView show];
}
#pragma mark ====== UITableViewDataSource,UITableViewDelegate =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _topicListArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellidentifier  = @"identifier";
    TCTopicListCell *topicListCell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (!topicListCell) {
        topicListCell = [[TCTopicListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    [topicListCell setTopicListWithModel:_topicListArray[indexPath.row]];
    return topicListCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"105_002025"];
    [[TCHelper sharedTCHelper] loginClick:@"008-05-07"];
    TCTopicListModel *topicListModel = _topicListArray[indexPath.row];
    TCTopicDetailsViewController *topicDetailsVC = [TCTopicDetailsViewController new];
    topicDetailsVC.topic = topicListModel.title;
    topicDetailsVC.topicId = topicListModel.topic_id;
    [self.navigationController pushViewController:topicDetailsVC animated:YES];
}
#pragma mark ====== Getter =======

- (UITableView *)topicListTab{
    if (!_topicListTab) {
        _topicListTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight - kNewNavHeight) style:UITableViewStylePlain];
        _topicListTab.delegate = self;
        _topicListTab.dataSource = self;
        _topicListTab.backgroundColor = [UIColor bgColor_Gray];
        _topicListTab.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _topicListTab.separatorInset=UIEdgeInsetsMake(0,20,0, 0);
        _topicListTab.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(newTopicData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _topicListTab.mj_header = header;
        
        MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreTopicData)];
        footer.automaticallyRefresh = NO;
        footer.hidden=YES;
        _topicListTab.mj_footer = footer;
        
        [_topicListTab addSubview:self.blankView];
    }
    return _topicListTab;
}
- (UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth ,kNewNavHeight)];
        _navBarView.backgroundColor = kSystemColor;
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, 44)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text=@"话题列表";
        [_navBarView addSubview:titleLabel];
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, KStatusHeight+2, 40, 40)];
        [backBtn setImage:[UIImage drawImageWithName:@"back.png"size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:backBtn];
        
        _topicSelectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _topicSelectionBtn.frame = CGRectMake(kScreenWidth-85,KStatusHeight +2, 80, 40);
        [_topicSelectionBtn setTitle:@"按热度" forState:UIControlStateNormal];
        [_topicSelectionBtn setImage:[UIImage imageNamed:@"fire"] forState:UIControlStateNormal];
        [_topicSelectionBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_topicSelectionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _topicSelectionBtn.titleLabel.font = kFontWithSize(15);
        [_topicSelectionBtn addTarget:self action:@selector(selectionClick) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:_topicSelectionBtn];
    }
    return _navBarView;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, 40, kScreenWidth, 200) img:@"un_dynamic" text:@"暂无话题"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
- (NSMutableArray *)topicListArray{
    if (!_topicListArray) {
        _topicListArray = [NSMutableArray array];
    }
    return _topicListArray;
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
