//
//  SystemNewsViewController.m
//  TangShiService
//
//  Created by vision on 17/7/10.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "SystemNewsViewController.h"
#import "TCBasewebViewController.h"
#import "NewsTableViewCell.h"
#import "TCSystemNewsModel.h"

@interface SystemNewsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger       newsPage;
    NSMutableArray  *newsArray;
}
/// 无数据页面
@property (nonatomic ,strong) TCBlankView *blankView;

@property (nonatomic,strong)UITableView *newsTableView;

@end

@implementation SystemNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"系统消息";
    self.rightImageName=@"ic_n_del";
    
    newsPage=1;
    newsArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.newsTableView];
    
    [self loadSystemNewsData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-03" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-03" type:2];
#endif
}
#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return newsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenfier=@"NewsTableView";
    NewsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdenfier];
    if (cell==nil) {
        cell=[[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenfier];
    }
    TCSystemNewsModel *model=newsArray[indexPath.row];
    cell.model=model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCSystemNewsModel *model=newsArray[indexPath.row];
    return [NewsTableViewCell getCellHeightWithNews:model];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [MobClick event:@"101_003001"];
    
    TCSystemNewsModel *model=newsArray[indexPath.row];
    
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.isSystemNewsIn=YES;
    if (model.type==1) {
        webVC.type=BaseWebViewTypeNewsArticle;
        webVC.titleText=@"糖士-糖百科";
        webVC.shareTitle = model.title;
        webVC.image_url = model.image_url;
        webVC.message_id=model.message_id;
        webVC.message_user_id=model.message_user_id;
        webVC.articleID = model.message_id;
    }else{
        webVC.type=BaseWebViewTypeSystemNews;
        webVC.titleText=@"系统消息详情";
        NSString *urlString = [NSString stringWithFormat:@"%@?message_id=%ld&message_user_id=%ld",kNewsWebUrl,(long)model.message_id,(long)model.message_user_id];
        webVC.urlStr=urlString;
    }
    
    __weak typeof(self) weakSelf=self;
    webVC.backBlock=^(){
        for (TCSystemNewsModel *tempNews in newsArray) {
            if (tempNews.message_id==model.message_id) {
                tempNews.is_read=[NSNumber numberWithBool:YES];
            }
            [weakSelf.newsTableView reloadData];
        }
    };
    [self.navigationController pushViewController:webVC animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MobClick event:@"101_003003"];
        TCSystemNewsModel *model=newsArray[indexPath.row];
        NSMutableArray *delNewsArray=[[NSMutableArray alloc] init];
        [delNewsArray addObject:[NSNumber numberWithInteger:model.message_user_id]];
        __weak typeof(self) weakSelf=self;
        NSString *params=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:delNewsArray];
        NSString *body=[NSString stringWithFormat:@"message_user_id=%@&is_all=2",params];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDeleteSystemNews body:body success:^(id json) {
            [newsArray removeObjectAtIndex:indexPath.row];
            [weakSelf.newsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

#pragma mark -- Event response
-(void)rightButtonAction{
    [MobClick event:@"101_003002"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认清空所有消息吗？" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf=self;
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDeleteSystemNews body:@"is_all=1" success:^(id json) {
            [newsArray removeAllObjects];
            weakSelf.blankView.hidden = NO;
            weakSelf.newsTableView.mj_footer.hidden=YES;
            [weakSelf.newsTableView reloadData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Private Methods
#pragma mark 加载最新系统消息
-(void)loadNewSystemNewsData{
    newsPage=1;
    [self loadSystemNewsData];
}

#pragma mark 加载更多系统消息
-(void)loadMoreSystemNewsData{
    newsPage++;
    [self loadSystemNewsData];
}

#pragma mark 加载系统消息列表
-(void)loadSystemNewsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)newsPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSystemNewsList body:body success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCSystemNewsModel *newsModel=[[TCSystemNewsModel alloc] init];
                [newsModel setValues:dict];
                [tempArr addObject:newsModel];
            }
            weakSelf.newsTableView.mj_footer.hidden=tempArr.count<20;
            if (newsPage==1) {
                newsArray=tempArr;
                weakSelf.blankView.hidden = tempArr.count>0;
            }else{
                [newsArray addObjectsFromArray:tempArr];
            }
        }else{
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.newsTableView.mj_header endRefreshing];
        [weakSelf.newsTableView.mj_footer endRefreshing];
        [weakSelf.newsTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.newsTableView.mj_header endRefreshing];
        [weakSelf.newsTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Setters and Getters
-(UITableView *)newsTableView{
    if (!_newsTableView) {
        _newsTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _newsTableView.dataSource=self;
        _newsTableView.delegate=self;
        _newsTableView.tableFooterView=[[UIView alloc] init];
        _newsTableView.showsVerticalScrollIndicator=NO;
        _newsTableView.backgroundColor=[UIColor bgColor_Gray];
        [_newsTableView addSubview:self.blankView];
        self.blankView.hidden = YES;
    
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSystemNewsData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _newsTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSystemNewsData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _newsTableView.mj_footer = footer;
        footer.hidden=YES;
        
    }
    return _newsTableView;
}
#pragma mark ====== 无数据视图 =======
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0,kNavHeight+30, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
    }
    return _blankView;
}
@end
