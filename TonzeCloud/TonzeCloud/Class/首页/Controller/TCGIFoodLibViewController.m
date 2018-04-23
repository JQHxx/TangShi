//
//  TCGIFoodLibViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGIFoodLibViewController.h"
#import "TCFoodDetailViewController.h"
#import "TCFoodClassTableViewCell.h"
#import "TCFoodModel.h"

@interface TCGIFoodLibViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray   *foodArray;
    NSInteger        foodPage;
    NSInteger        sortType;
}
@property (nonatomic,strong)UIButton    *navRightItem;
@property (nonatomic,strong)UITableView *foodTableView;

@end

@implementation TCGIFoodLibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"GI食物库";
    
    foodPage=1;
    foodArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.navRightItem];
    [self.view addSubview:self.foodTableView];
    [self requestGIFoodListData];
}
#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFoodClassTableViewCell";
    TCFoodClassTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex:0];
    }
    TCFoodModel *foodmodel = foodArray[indexPath.row];
    [cell cellDisplayWithDict:foodmodel type:1];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"102_003020"];

    TCFoodDetailViewController *foodDetailVC = [[TCFoodDetailViewController alloc] init];
    TCFoodModel *foodmodel = foodArray[indexPath.row];
    foodDetailVC.food_id=foodmodel.id;
    [self.navigationController pushViewController:foodDetailVC animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,10,0,0)];
    }
}
#pragma mark -- Event Response
-(void)filterGIFoodListAction:(UIButton *)sender{
    [MobClick event:@"102_003021"];

    sender.selected=!sender.selected;
    sortType=sender.selected;
    foodPage=1;
    [self requestGIFoodListData];
}
#pragma mark -- Private Methods
#pragma mark 获取最新GI食物
-(void)loadNewGIFoodData{
    foodPage=1;
    [self requestGIFoodListData];
}
#pragma mark 获取更多GI食物
-(void)loadMoreGIFoodData{
    foodPage++;
    [self requestGIFoodListData];
}
#pragma mark 获取食物列表
-(void)requestGIFoodListData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&is_gi=1&gi_sort=%ld",(long)foodPage,(long)sortType];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodList body:body success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        NSInteger totalValues = [[[json objectForKey:@"pager"] objectForKey:@"total"] integerValue];
        if (kIsArray(dataArray)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in dataArray) {
                TCFoodModel *model=[[TCFoodModel alloc] init];
                [model setValues:dict];
                [tempArr addObject:model];
            }
            weakSelf.foodTableView.mj_footer.hidden=(totalValues - foodPage*20)<=0;
            weakSelf.foodTableView.tableFooterView =(totalValues - foodPage*20)<=0 ? [weakSelf tableVieFooterView] : [UIView new];
            if (foodPage==1) {
                foodArray=tempArr;
            }else{
                [foodArray addObjectsFromArray:tempArr];
            }
            [weakSelf.foodTableView reloadData];
            [weakSelf.foodTableView.mj_header endRefreshing];
            [weakSelf.foodTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ======  没有更多了 =======
- (UIView *)tableVieFooterView{
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
#pragma mark -- Setters and getters
#pragma mark 导航栏右侧按钮
-(UIButton *)navRightItem{
    if (_navRightItem==nil) {
        _navRightItem=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, KStatusHeight + 10, 30, 30)];
        [_navRightItem setImage:[UIImage imageNamed:@"ic_top_GI_01"] forState:UIControlStateNormal];
        [_navRightItem setImage:[UIImage imageNamed: @"ic_top_GI_02"] forState:UIControlStateSelected];
        [_navRightItem addTarget:self action:@selector(filterGIFoodListAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navRightItem;
}
#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (!_foodTableView) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _foodTableView.delegate=self;
        _foodTableView.dataSource=self;
        _foodTableView.backgroundColor=[UIColor bgColor_Gray];
        _foodTableView.tableFooterView=[[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewGIFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _foodTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreGIFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _foodTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _foodTableView;
}

@end
