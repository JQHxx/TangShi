//
//  TCEvaluateListViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCEvaluateListViewController.h"
#import "TCEvaluateTableViewCell.h"
#import "TCEvaluateModel.h"

@interface TCEvaluateListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray   *evaluateArray;
    NSInteger         page;
}
@property (nonatomic,strong)UITableView *evaluaTableView;

@end

@implementation TCEvaluateListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"全部评价";
    
    page =1;
    evaluateArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.evaluaTableView];
    
    [self requestEvaluateListData];
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return evaluateArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCEvaluateTableViewCell";
    TCEvaluateTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCEvaluateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCEvaluateModel *model=evaluateArray[indexPath.row];
    cell.evaluateModel=model;
    
    return cell;
}

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCEvaluateModel *model=evaluateArray[indexPath.row];
    return [TCEvaluateTableViewCell getEvaluateCellHeightWithModel:model];
}

#pragma mark -- Private Methods
-(void)requestEvaluateListData{
    NSString *body = [NSString stringWithFormat:@"%@?expert_id=%ld&page_size=20&page_num=%ld",kAllEvaluate,self.expert_id,page];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:body success:^(id json) {
        
        NSDictionary *pager=[json objectForKey:@"pager"];
        NSInteger totalValues = 0;
        if (kIsDictionary(pager)) {
            totalValues=[[pager valueForKey:@"total"] integerValue];
        }
        self.evaluaTableView.mj_footer.hidden=(totalValues-page*20)<=0;
        
        NSArray *result = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        if (result.count>0) {
            for (NSDictionary *dict in result) {
                TCEvaluateModel *model=[[TCEvaluateModel alloc] init];
                [model setValues:dict];
                [tempArr addObject:model];
            }
            evaluateArray=tempArr;
            [self.evaluaTableView reloadData];
            [self.evaluaTableView.mj_header endRefreshing];
            [self.evaluaTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [self.evaluaTableView.mj_header endRefreshing];
        [self.evaluaTableView.mj_footer endRefreshing];

    }];
}
#pragma mark -- 加载最新
- (void)loadNewEvaluate{
    page =1;
    [self requestEvaluateListData];
}
#pragma mark -- 加载更多
- (void)loadMoreEvaluate{
    page++;
    [self requestEvaluateListData];

}
#pragma mark -- Getters
#pragma mark 评价列表
-(UITableView *)evaluaTableView{
    if (!_evaluaTableView) {
        _evaluaTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _evaluaTableView.delegate=self;
        _evaluaTableView.dataSource=self;
        _evaluaTableView.tableFooterView=[[UIView alloc] init];
        _evaluaTableView.backgroundColor=[UIColor bgColor_Gray];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewEvaluate)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _evaluaTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreEvaluate)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _evaluaTableView.mj_footer = footer;
        footer.hidden=YES;

    }
    return _evaluaTableView;
}
@end
