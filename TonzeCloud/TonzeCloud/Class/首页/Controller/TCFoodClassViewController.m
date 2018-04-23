//
//  TCFoodClassViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodClassViewController.h"
#import "TCFoodMenuView.h"
#import "TCFoodModel.h"
#import "TCFoodClassTableViewCell.h"
#import "TCFoodDetailViewController.h"
#import "TCSearchViewController.h"
#import "TCFoodClassModel.h"

@interface TCFoodClassViewController ()<TCFoodMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView    *_foodClassTab;
    NSMutableArray *toolArray;
    NSMutableArray *crowdArray;
    TCFoodMenuView *foodMenuView;
    TCBlankView    *blankView;
    NSInteger       selectIndex;
    NSInteger       foodPage;    //食物页数
    NSMutableArray *foodArray;
    UIButton        *_foodSelectionBtn;
    NSString        *_energykcal_sort;   // 热量值筛选
}
/// 导航栏
@property (nonatomic ,strong) UIView *navBarView;

@end

@implementation TCFoodClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.isHiddenNavBar = YES;
    self.baseTitle = @"食物分类";
    self.rightImageName = @"ic_top_search";
    
    crowdArray= [[NSMutableArray alloc] init];
    toolArray = [[NSMutableArray alloc] init];
    foodPage = 1;
    _energykcal_sort = @"asc";
    [self initFoodClassView];
    [self changeMenuItem];
}
#pragma mark --Delegate
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return toolArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCFoodClassTableViewCell";
    TCFoodClassTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex:0];
    }
    TCFoodModel *foodmodel = toolArray[indexPath.row];
    [cell cellDisplayWithDict:foodmodel type:0];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"101_003015"];
        TCFoodModel *foodmodel = toolArray[indexPath.row];
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-06-03:%ld",foodmodel.id]];

    TCFoodDetailViewController *foodDetailVC = [[TCFoodDetailViewController alloc] init];
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
#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(TCFoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-06-02:%ld",index+1]];
    [MobClick event:@"101_003014"];
    if (index == -100) {
        index = _index;
    }
    foodPage=1;
    selectIndex = index;
    [self requestfoodDetail:selectIndex];
}
#pragma mark -- Event Response 
#pragma mark -- 食物搜索
-(void)searchFoodAction{
    [MobClick event:@"101_003016"];
    TCSearchViewController *searchViewController=[[TCSearchViewController alloc] init];
    searchViewController.type=FoodSearchType;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
#pragma mark ====== 食物筛选 =======
- (void)foodSelectionBtn:(UIButton *)sender{
    foodPage = 1;
    sender.selected=!sender.selected;
    _energykcal_sort = sender.selected == 0 ? @"asc" : @"desc";
    [self requestfoodDetail:selectIndex];
}
#pragma mark -- 滑动按钮
-(void)changeMenuItem{
    UIButton *btn;
    for (UIView  *view in foodMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_index+101)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [foodMenuView changeFoodViewWithButton:btn];
}
-(void)swipRecordTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex>crowdArray.count-1) {
            selectIndex=crowdArray.count;
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
    for (UIView  *view in foodMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [foodMenuView changeFoodViewWithButton:btn];
}
#pragma mark -- 加载最新数据
-(void)loadNewFoodData{
    foodPage =1;
    [self requestfoodDetail:selectIndex];
}
#pragma mark -- 加载更多数据
-(void)loadMoreFoodData{
    foodPage++;
    [self requestfoodDetail:selectIndex];
}
#pragma mark --加载分类数据
- (void)requestfoodDetail:(NSInteger)index{
    NSString *urlstr = nil;
    if (index == 0) {
        urlstr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&energykcal_sort=%@",(long)foodPage,_energykcal_sort];
    }else{
        urlstr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&cat_id=%@&energykcal_sort=%@",foodPage,_idarray[index],_energykcal_sort];
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodList body:urlstr success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        NSArray *dataArray = [json objectForKey:@"result"];
        if (dataArray.count>0) {
            NSInteger totalValues = 0;
            if (kIsDictionary(pager)) {
                totalValues=[[pager valueForKey:@"total"] integerValue];
            }
            _foodClassTab.mj_footer.hidden=(totalValues-foodPage*20)<=0;
            _foodClassTab.tableFooterView = (totalValues -foodPage*20)<=0 ? [weakSelf tableVieFooterView] : [UIView new];
            NSMutableArray *foodmutArray = [[NSMutableArray alloc] init];
            for (int i=0; i<dataArray.count; i++) {
                NSDictionary *dict=dataArray[i];
                TCFoodModel *foodModel = [[TCFoodModel alloc] init];
                [foodModel setValues:dict];
                [foodmutArray addObject:foodModel];
            }
            if (foodPage==1) {
                toolArray = [[NSMutableArray alloc] init];
                toolArray = foodmutArray;
                blankView.hidden=toolArray.count>0;
            }else{
                [toolArray addObjectsFromArray:foodmutArray];
            }
            [_foodClassTab reloadData];
            [_foodClassTab.mj_header endRefreshing];
            [_foodClassTab.mj_footer endRefreshing];
        }else{
            toolArray = [[NSMutableArray alloc] init];
            _foodClassTab.mj_footer.hidden=YES;
            [_foodClassTab reloadData];
            blankView.hidden=toolArray.count>0;
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        blankView.hidden=toolArray.count>0;
        [_foodClassTab.mj_header endRefreshing];
        [_foodClassTab.mj_footer endRefreshing];
    }];
}
#pragma mark -- 初始化界面
- (void)initFoodClassView{
    [self.view addSubview:self.navBarView];
    
    foodMenuView=[[TCFoodMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 49)];
    foodMenuView.delegate=self;
    [self.view addSubview:foodMenuView];
    
    [crowdArray addObject:@"全部"];
    [crowdArray addObjectsFromArray:_titleArray];
    foodMenuView.foodMenusArray = [NSMutableArray arrayWithArray:crowdArray];
    
    _foodClassTab = [[UITableView alloc] initWithFrame:CGRectMake(0, foodMenuView.bottom, kScreenWidth, kScreenHeight-foodMenuView.bottom)];
    _foodClassTab.delegate = self;
    _foodClassTab.dataSource = self;
    [_foodClassTab setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview:_foodClassTab];
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFoodData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    _foodClassTab.mj_header=header;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFoodData)];
    footer.automaticallyRefresh = NO;// 禁止自动加载
    _foodClassTab.mj_footer = footer;
    footer.hidden=YES;
    
    UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
    swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_foodClassTab addGestureRecognizer:swipGestureLeft];
    
    UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
    swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_foodClassTab addGestureRecognizer:swipGestureRight];

    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
    [_foodClassTab addSubview:blankView];
    blankView.hidden=YES;
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
#pragma mark ====== Getter =======
#pragma mark ====== 导航栏 =======
- (UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth ,kNewNavHeight)];
        _navBarView.backgroundColor = kSystemColor;
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, 44)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text=@"食物分类";
        [_navBarView addSubview:titleLabel];
        //  返回
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, KStatusHeight+2, 40, 40)];
        [backBtn setImage:[UIImage drawImageWithName:@"back.png"size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:backBtn];
        // 搜索
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(kScreenWidth - 24 - 50 ,KStatusHeight + 10 , 24, 24);
        [searchBtn setImage:[UIImage imageNamed:@"ic_top_search"] forState:UIControlStateNormal];
        [searchBtn addTarget:self action:@selector(searchFoodAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:searchBtn];
        // 筛选
        _foodSelectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _foodSelectionBtn.frame = CGRectMake(kScreenWidth- 40, KStatusHeight + 7, 30, 30);
        [_foodSelectionBtn setImage:[UIImage imageNamed:@"ic_top_GI_01"] forState:UIControlStateNormal];
        [_foodSelectionBtn setImage:[UIImage imageNamed: @"ic_top_GI_02"] forState:UIControlStateSelected];
        [_foodSelectionBtn addTarget:self action:@selector(foodSelectionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:_foodSelectionBtn];
    }
    return _navBarView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
