//
//  TCMyFeedbackViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyFeedbackViewController.h"
#import "TCMyFeedbackModel.h"
#import "TCMyFeedbackTableViewCell.h"
#import "TCFeedbackDetailViewController.h"

@interface TCMyFeedbackViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray *myFeedBackArray;
    TCBlankView    *blankView;
    NSInteger       feedBackPage;
}
@property (nonatomic ,strong)UITableView *myFeedbackTab;
@end

@implementation TCMyFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的反馈";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    myFeedBackArray = [[NSMutableArray alloc] init];
    feedBackPage = 1;
    
    [self.view addSubview:self.myFeedbackTab];
    [self loadMyFeedbackData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadMyFeedbackData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10-02-02" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10-02-02" type:2];
#endif
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return myFeedBackArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TCMyFeedbackTableViewCell";
    TCMyFeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[TCMyFeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCMyFeedbackModel *model = myFeedBackArray[indexPath.row];
    [cell myFeedbackWithModel:model];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCMyFeedbackModel *model = myFeedBackArray[indexPath.row];
    TCFeedbackDetailViewController *feedbackDetailVC = [[TCFeedbackDetailViewController alloc] init];
    feedbackDetailVC.id = model.id;
    [self.navigationController pushViewController:feedbackDetailVC animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 76;
}
#pragma mark -- 获取反馈数据
- (void)loadMyFeedbackData{
    
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type=0",feedBackPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KFeedbackLists body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSDictionary *pager =[json objectForKey:@"pager"];
        NSInteger total = 0;
        if (kIsDictionary(pager)) {
            total = [[pager objectForKey:@"total"] integerValue];
        }

        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *feedBackArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMyFeedbackModel *model = [[TCMyFeedbackModel alloc] init];
                [model setValues:dict];
                [feedBackArr addObject:model];
            }
            if (feedBackPage==1) {
                myFeedBackArray = feedBackArr;
            } else {
                [myFeedBackArray addObjectsFromArray:feedBackArr];
            }
            blankView.hidden=myFeedBackArray.count>0;
            _myFeedbackTab.mj_footer.hidden=(total -feedBackPage*20)<=0;
        }else{
            blankView.hidden=NO;
            _myFeedbackTab.mj_footer.hidden=YES;

        }
        [_myFeedbackTab reloadData];
        [_myFeedbackTab.mj_header endRefreshing];
        [_myFeedbackTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [_myFeedbackTab.mj_header endRefreshing];
        [_myFeedbackTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取最新反馈数据
- (void)loadFeedBackNewData{
    feedBackPage = 1;
    [self loadMyFeedbackData];
}
#pragma mark -- 获取更多反馈数据
- (void)loadFeedBackMoreData{
    feedBackPage++;
    [self loadMyFeedbackData];
}
#pragma mark -- setter or getter
- (UITableView *)myFeedbackTab{
    if (_myFeedbackTab==nil) {
        _myFeedbackTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myFeedbackTab.backgroundColor = [UIColor bgColor_Gray];
        _myFeedbackTab.delegate = self;
        _myFeedbackTab.dataSource = self;
        _myFeedbackTab.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFeedBackNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myFeedbackTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadFeedBackMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myFeedbackTab.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无反馈信息"];
        [_myFeedbackTab addSubview:blankView];
        blankView.hidden=YES;
    }
    return _myFeedbackTab;
}
@end
