//
//  TCColumnDetailViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/1/24.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCColumnDetailViewController.h"
#import "TCArticleTableViewCell.h"
#import "TCArticleModel.h"
#import "TCBasewebViewController.h"

@interface TCColumnDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSInteger    page;
    UIImageView *columnImg;
    NSString    *columnImgUrl;
}

@property (nonatomic ,strong)NSMutableArray *columnArray;

@property (nonatomic ,strong)UITableView *columnTab;
@end

@implementation TCColumnDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.titleStr;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    page =1;
    
    [self.view addSubview:self.columnTab];
    [self loadCloumnDetailData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"004-20" type:1];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"004-20" type:2];
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.columnArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCArticleTableViewCell";
    TCArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCArticleModel *article=self.columnArray[indexPath.row];
    [cell cellDisplayWithModel:article searchText:@""];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"101_002030"];
    [[TCHelper sharedTCHelper] loginClick:@"004-24-01"];

    TCArticleModel *article=self.columnArray[indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)article.id];
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.type=BaseWebViewTypeArticle;
    webVC.titleText=@"糖士-糖百科";
    webVC.shareTitle = article.title;
    webVC.image_url = article.l_url;
    webVC.urlStr=urlString;
    webVC.articleID = article.id;
    webVC.backBlock=^(){
        for (TCArticleModel *model in self.columnArray) {
            if (model.id==article.id) {
                model.reading_num+=1;
            }
        }
        [self.columnTab reloadData];
    };
    [self.navigationController pushViewController:webVC animated:YES];


}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 100;
}
#pragma mark -- Event Response
- (void)loadCloumnDetailData{
    NSString *body = [NSString stringWithFormat:@"column_id=%ld&page_size=20&page_num=%ld",self.column_id,page];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kColumnDtailList body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        
        NSInteger total = [[json objectForKey:@"total"] integerValue];
        self.columnTab.mj_footer.hidden=(total-page*20)<=0;
        if (kIsDictionary(result)) {
           columnImgUrl = [result objectForKey:@"column_url"];
            
            NSArray *articleArr = [result objectForKey:@"article"];
            NSMutableArray *article = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in articleArr) {
                TCArticleModel *model = [[TCArticleModel alloc] init];
                [model setValues:dict];
                [article addObject:model];
            }
            if (page==1) {
                self.columnArray = article;
            } else {
                [self.columnArray addObject:article];
            }
        }
        [self.columnTab.mj_header endRefreshing];
        [self.columnTab.mj_footer endRefreshing];
        self.columnTab.tableHeaderView = [self tableviewHeadView];
        [self.columnTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.columnTab.mj_header endRefreshing];
        [self.columnTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];

}
#pragma mark -- Private Methods
#pragma mark -- tableviewhead
- (UIView *)tableviewHeadView{

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/250*130)];

    columnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/250*130)];
    [columnImg sd_setImageWithURL:[NSURL URLWithString:columnImgUrl] placeholderImage:[UIImage imageNamed:@""]];
    [headView addSubview:columnImg];
    
    return headView;
}
#pragma mark 下拉刷新
-(void)loadNewColumnListData{
    page=1;
    [self loadCloumnDetailData];
}

#pragma mark 上拉加载更多
-(void)loadMoreColumnListData{
    page++;
    [self loadCloumnDetailData];
}
#pragma mark -- setter or getter
- (UITableView *)columnTab{
    if (!_columnTab) {
        _columnTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kNewNavHeight) style:UITableViewStylePlain];
        _columnTab.backgroundColor = [UIColor bgColor_Gray];
        _columnTab.delegate = self;
        _columnTab.dataSource = self;
        _columnTab.tableFooterView = [[UIView alloc] init];
        _columnTab.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewColumnListData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _columnTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreColumnListData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _columnTab.mj_footer = footer;
        footer.hidden=YES;
    }
    return _columnTab;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
