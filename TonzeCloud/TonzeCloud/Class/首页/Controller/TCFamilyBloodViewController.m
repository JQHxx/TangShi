//
//  TCFamilyBloodViewController.m
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFamilyBloodViewController.h"
#import "TCFamilyBloodDetailViewController.h"
#import "FamilyNewsTableViewCell.h"
#import "TCFamilyBloodModel.h"

@interface TCFamilyBloodViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger    page;
}

@property (nonatomic,strong)UITableView      *familyTableView;
@property (nonatomic,strong)NSMutableArray   *familyNewsArray;
@property (nonatomic ,strong) TCBlankView    *blankView;

@end

@implementation TCFamilyBloodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"亲友血糖";
    self.rightImageName=@"ic_n_del";
    
    page=1;
    
    [self.view addSubview:self.familyTableView];
    
    [self requestFamilyBloodNewsData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-04" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-04" type:2];
#endif
}
#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.familyNewsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"FamilyNewsTableViewCell";
    FamilyNewsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[FamilyNewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCFamilyBloodModel *model=self.familyNewsArray[indexPath.row];
    cell.model=model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [MobClick event:@"101_003004"];
    TCFamilyBloodModel *model=self.familyNewsArray[indexPath.row];
    TCFamilyBloodDetailViewController *detailVC=[[TCFamilyBloodDetailViewController alloc] init];
    detailVC.record_family_id=model.record_family_id;
    __weak typeof(self) weakSelf=self;
    detailVC.backBlock=^(){
        for (TCFamilyBloodModel *tempModel in weakSelf.familyNewsArray) {
            if (tempModel.record_family_id==model.record_family_id) {
                tempModel.is_read=[NSNumber numberWithBool:YES];
            }
        }
        [weakSelf.familyTableView reloadData];
    };
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MobClick event:@"101_003006"];
        TCFamilyBloodModel *model=self.familyNewsArray[indexPath.row];
        NSMutableArray *delNewsArray=[[NSMutableArray alloc] init];
        [delNewsArray addObject:[NSNumber numberWithInteger:model.record_family_id]];
        __weak typeof(self) weakSelf=self;
        NSString *params=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:delNewsArray];
        NSString *body=[NSString stringWithFormat:@"record_family_id=%@&is_all=2",params];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDeleteFamilyNews body:body success:^(id json) {
            [self.familyNewsArray removeObjectAtIndex:indexPath.row];
            [weakSelf.familyTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
    
}

#pragma mark -- Event Response
-(void)rightButtonAction{
    [MobClick event:@"101_003005"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认清空所有消息吗？" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf=self;
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDeleteFamilyNews body:@"is_all=1" success:^(id json) {
            [weakSelf.familyNewsArray removeAllObjects];
            weakSelf.blankView.hidden = NO;
            [weakSelf.familyTableView.mj_header endRefreshing];
            [weakSelf.familyTableView.mj_footer endRefreshing];
            [weakSelf.familyTableView reloadData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 获取最新亲友血糖消息数据
-(void)loadNewFamilyBloodData{
    page=1;
    [self requestFamilyBloodNewsData];
}

#pragma mark 获取更多亲友血糖消息数据
-(void)loadMoreFamilyBloodData{
    page++;
    [self requestFamilyBloodNewsData];
}

#pragma mark 获取亲友血糖消息数据
-(void)requestFamilyBloodNewsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)page];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFamilyBloodNewsList body:body success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCFamilyBloodModel *newsModel=[[TCFamilyBloodModel alloc] init];
                [newsModel setValues:dict];
                [tempArr addObject:newsModel];
            }
            weakSelf.familyTableView.mj_footer.hidden=tempArr.count<20;
            if (page==1) {
                weakSelf.familyNewsArray=tempArr;
            }else{
                [weakSelf.familyNewsArray addObjectsFromArray:tempArr];
            }
            weakSelf.blankView.hidden = weakSelf.familyNewsArray.count>0;
            [weakSelf.familyTableView reloadData];
            [weakSelf.familyTableView.mj_header endRefreshing];
            [weakSelf.familyTableView.mj_footer endRefreshing];
        }else{
            weakSelf.blankView.hidden = NO;
        }
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.familyTableView.mj_header endRefreshing];
        [weakSelf.familyTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Setters and Getters
#pragma mark  亲友血糖列表
-(UITableView *)familyTableView{
    if (!_familyTableView) {
        _familyTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _familyTableView.delegate=self;
        _familyTableView.dataSource=self;
        _familyTableView.backgroundColor=[UIColor bgColor_Gray];
        _familyTableView.tableFooterView=[[UIView alloc] init];
        [_familyTableView addSubview:self.blankView];
        self.blankView.hidden = YES;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFamilyBloodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _familyTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFamilyBloodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _familyTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _familyTableView;
}

#pragma mark 亲友血糖数据列表
-(NSMutableArray *)familyNewsArray{
    if (!_familyNewsArray) {
        _familyNewsArray=[[NSMutableArray alloc] init];
    }
    return _familyNewsArray;
}
#pragma mark ====== 无数据视图 =======
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0,kNavHeight+30, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
    }
    return _blankView;
}
@end
