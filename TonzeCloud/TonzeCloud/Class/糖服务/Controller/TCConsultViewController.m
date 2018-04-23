//
//  TCConsultViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCConsultViewController.h"
#import "TCMenuView.h"
#import "TCConsultTableViewCell.h"
#import "TCExpertDetailController.h"
#import "TCMineExpertController.h"
#import "TCConsultModel.h"
#import "TCFastLoginViewController.h"

@interface TCConsultViewController ()<TCMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView         *_consultTab;
    TCMenuView          *menuView;
    NSArray             *imgArray;
    NSMutableArray      *idArray;
    NSMutableArray      *consultArray;  //专家
    TCBlankView         *blankView;
    NSInteger           selectIndex;
    NSInteger           page;      //专家页数

}
@end
@implementation TCConsultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"专家咨询";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    page=1;
    idArray   = [[NSMutableArray alloc] init];
    consultArray = [[NSMutableArray alloc] init];
    
    [self initConsultView];
    [self requestExpertClass];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-03" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-03" type:2];
#endif
}
#pragma mark --Delegate
#pragma mark  TCMenuViewDelegate
-(void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index{
    selectIndex = index;
    page=1;
    [self requestConsultData:index];
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return consultArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCConsultTableViewCell";
    TCConsultTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[TCConsultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCConsultModel *consultModel = consultArray[indexPath.row];
    [cell cellConsultWithDict:consultModel];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"103_002007"];
    TCConsultModel *consultModel = consultArray[indexPath.row];
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"006-03-05:%ld",consultModel.id]];

    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        TCExpertDetailController *exportVC =[[TCExpertDetailController alloc] init];
        exportVC.expert_id = consultModel.id;
        [self.navigationController pushViewController:exportVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
#pragma mark -- Event Response
-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex+1> menuView.menusArray.count) {
            selectIndex= menuView.menusArray.count;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectIndex--;
        if (selectIndex<0) {
            selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [menuView changeViewWithButton:btn];
}
#pragma mark --获取专家分类列表
- (void)requestExpertClass{
    NSString *urlString = [NSString stringWithFormat:@"%@?page_size=20&page_num=1",kServiceExpertClass];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        if (kIsArray(dataArray)&&dataArray.count>0) {
            NSMutableArray *nameArray = [[NSMutableArray alloc] init];
            for (int i=0; i<dataArray.count; i++) {
                [idArray addObject:[dataArray[i] objectForKey:@"id"]];
                [nameArray addObject:[dataArray[i] objectForKey:@"name"]];
            }
            if (nameArray.count > 1) {
               menuView.menusArray =nameArray;
            }else{
                menuView.hidden = YES;
                _consultTab.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
            }
            [weakSelf requestConsultData:0];
        }
    } failure:^(NSString *errorStr) {
        blankView.hidden = NO;
        [_consultTab.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 获取专家咨询列表
- (void)requestConsultData:(NSInteger)index{
    NSString *urlString = [NSString stringWithFormat:@"%@?page_num=%ld&page_size=20&id=%@",kServiceExpertConsult,(long)page,idArray[index]];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSArray *dataArray   = [json objectForKey:@"result"];
        if (kIsArray(dataArray)&&dataArray.count>0) {
            NSMutableArray  *tempArray = [[NSMutableArray alloc] init];
            for (int i=0; i<dataArray.count; i++) {
                TCConsultModel *consultModel =[[TCConsultModel alloc] init];
                [consultModel setValues:dataArray[i]];
                [tempArray addObject:consultModel];
            }
             _consultTab.mj_footer.hidden=tempArray.count<20;
            if (page==1) {
                consultArray = tempArray;
                blankView.hidden=tempArray.count>0;
            }else{
                [consultArray addObjectsFromArray:tempArray];
            }
        }else{
            _consultTab.mj_footer.hidden=YES;
        }
        [_consultTab.mj_header endRefreshing];
        [_consultTab.mj_footer endRefreshing];
        [_consultTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Event response
- (void)leftButtonAction{
    if (self.isSugar) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- 加载最新数据
-(void)loadNewConsultData{
    page =1;
    if (idArray.count>0) {
        [self requestConsultData:selectIndex];
    } else {
        [self requestExpertClass];
    }
}
#pragma mark -- 加载更多数据
-(void)loadMoreConsultData{
    page++;
    [self requestConsultData:selectIndex];
    
}
#pragma mark -- 初始化界面
- (void)initConsultView{
    
    menuView=[[TCMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 50)];
    menuView.delegate=self;
    [self.view addSubview:menuView];
    
    _consultTab = [[UITableView alloc] initWithFrame:CGRectMake(0, menuView.bottom, kScreenWidth, kScreenHeight-menuView.bottom)];
    _consultTab.backgroundColor = [UIColor clearColor];
    _consultTab.delegate = self;
    _consultTab.dataSource = self;
    _consultTab.showsVerticalScrollIndicator=NO;
    [_consultTab setTableFooterView:[[UIView alloc] init]];
    _consultTab.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.view addSubview:_consultTab];
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewConsultData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    _consultTab.mj_header=header;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreConsultData)];
    footer.automaticallyRefresh = NO;// 禁止自动加载
    _consultTab.mj_footer = footer;
    footer.hidden=YES;

    
    UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
    swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_consultTab addGestureRecognizer:swipGestureLeft];
    
    UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
    swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_consultTab addGestureRecognizer:swipGestureRight];

    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
    [_consultTab addSubview:blankView];
    blankView.hidden=YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
