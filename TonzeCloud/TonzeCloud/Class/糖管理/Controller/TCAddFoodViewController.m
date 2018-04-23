//
//  TCAddFoodViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddFoodViewController.h"
#import "TCSearchViewController.h"
#import "TCFoodMenuView.h"
#import "TCFoodTableViewCell.h"
#import "TCScaleView.h"
#import "TCFoodAddTool.h"
#import "TCFoodAddModel.h"
#import "TCFoodClassModel.h"
#import "TCFoodSelectView.h"


@interface TCAddFoodViewController ()<TCFoodMenuViewDelegate,UITableViewDelegate,UITableViewDataSource,TCScaleViewDelegate,TCFoodSelectViewDelegate>{
    NSMutableArray      *categoryArray;    //食物分类
    NSMutableArray      *foodArray;        //食物列表
    NSNumber            *category_id;      //分类
    NSInteger           page;
    NSInteger           dietCount;
    UIButton            *foodBtn;
    UILabel             *countLabel;        //已选食物数量
    UIView              *coverView;
    NSInteger           selectIndex;
    NSMutableArray      *selectaddFoodArr;
    UILabel             *line;
    UIButton            *confirmButton;
}
@property (nonatomic,strong)TCFoodMenuView    *menuView;          //菜单栏
@property (nonatomic,strong)UITableView       *foodTableView;     //食物列表
@property (nonatomic,strong)TCFoodSelectView  *foodSelectView;    //已选食物视图
@property (nonatomic,strong)UIView            *bottomView;        //底部视图
@property (nonatomic,strong)TCBlankView       *foodBlankView;


@end

@implementation TCAddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加食物";
    
    self.rightImageName=@"ic_top_search";
    
    selectaddFoodArr =[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    categoryArray=[[NSMutableArray alloc] init];
    foodArray=[[NSMutableArray alloc] init];
    category_id=[NSNumber numberWithInteger:0];
    dietCount=0;
    page=1;
    selectIndex=0;
    
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.foodTableView];
    [self.view addSubview:self.foodSelectView];
    [self.view addSubview:self.bottomView];
    [self.foodTableView addSubview:self.foodBlankView];
    self.foodBlankView.hidden=YES;
    
    [self requestCategoryData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *selectFoodArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    dietCount=selectFoodArr.count;
    [self reloadFoodAddView];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdntifier=@"TCFoodTableViewCell";
    TCFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TCFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.cellType=0;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCFoodAddModel *food=foodArray[indexPath.row];
    [cell cellDisplayWithFood:food searchText:nil];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"102_003006"];
    TCFoodAddModel *food=foodArray[indexPath.row];
    TCScaleView *scaleView=[[TCScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) model:food];
    scaleView.scaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -- Custom Delegate
#pragma mark  TCScaleViewDelegate
-(void)scaleView:(TCScaleView *)scaleView didSelectFood:(TCFoodAddModel *)food{
    if ([food.isSelected boolValue]) {
        [[TCFoodAddTool sharedTCFoodAddTool] updateFood:food];
    }else{
        food.isSelected=[NSNumber numberWithBool:YES];
        [[TCFoodAddTool sharedTCFoodAddTool] insertFood:food];
    }
    for (TCFoodAddModel *foodModel in foodArray) {
        if (foodModel.id==food.id) {
            foodModel.isSelected=[NSNumber numberWithBool:YES];
            foodModel.weight=food.weight;
        }
    }
    [self.foodTableView reloadData];
    
    NSMutableArray *tempArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    
    [self reloadFoodAddView];
}
#pragma mark -- Custom Delegate
#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(TCFoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    selectIndex=index;
    TCFoodClassModel *foodClass=categoryArray[index];
    category_id=foodClass.id;
    page=1;
    [self requestFoodData];
}
#pragma mark TCFoodSelectViewDelegate
#pragma mark 清空已选食物列表
-(void)foodSelectViewDismissAction{
    for (TCFoodAddModel *model in foodArray) {
        model.isSelected=[NSNumber numberWithBool:NO];
        model.weight=[NSNumber numberWithInteger:100];
    }
    [self.foodTableView reloadData];
    
    dietCount=0;
    [self reloadFoodAddView];
    [self closeFoodViewAction];
}

#pragma mark 删除已选食物
-(void)foodSelectViewDeleteFood:(TCFoodAddModel *)food{
    for (TCFoodAddModel *model in foodArray) {
        if (food.id==model.id) {
            model.isSelected=[NSNumber numberWithBool:NO];
            model.weight=[NSNumber numberWithInteger:100];
        }
    }
    [self.foodTableView reloadData];
    
    NSMutableArray *tempArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    [self reloadFoodAddView];
}

#pragma mark 编辑食物
-(void)foodSelectViewDidSelectFood:(TCFoodAddModel *)food{
    [self closeFoodViewAction];
    
    TCScaleView *scaleView=[[TCScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) model:food];
    scaleView.scaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

#pragma mark -- Event Response
#pragma mark 确定
-(void)confirmAddFoodAction:(UIButton *)sender{
    [MobClick event:@"102_003009"];
    [TCHelper sharedTCHelper].isAddFood=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 搜索(导航栏右侧按钮)
-(void)rightButtonAction{
    TCSearchViewController *searchViewController=[[TCSearchViewController alloc] init];
    searchViewController.type=FoodAddSearchType;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    
    if (selectaddFoodArr.count>0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}
#pragma mark 显示已选食物视图
-(void)showSelectedFoodList{
    if (dietCount>0) {
        if (coverView==nil) {
            coverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-50)];
            coverView.backgroundColor=[UIColor blackColor];
            coverView.alpha=0.3;
            coverView.userInteractionEnabled=YES;
            
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFoodViewAction)];
            [coverView addGestureRecognizer:tap];
        }
        [self.view insertSubview:coverView belowSubview:self.foodSelectView];
        
        self.foodSelectView.foodSelectArray=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
        [self.foodSelectView.tableView reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.foodSelectView.frame=CGRectMake(0, kScreenHeight-50-220, kScreenWidth, 220);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 关闭已选食物视图
-(void)closeFoodViewAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.foodSelectView.frame=CGRectMake(0, kScreenHeight-50, kScreenWidth, 50);
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
    }];
}
#pragma mark -- Event Response
-(void)swipFoodTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex>categoryArray.count) {
            selectIndex=categoryArray.count;
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
    for (UIView *view in self.menuView.rootScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == selectIndex+100)) {
            btn = (UIButton*)view;
        }
    }
    [self.menuView changeFoodViewWithButton:btn];
}

#pragma mark -- Network
#pragma mark 分类数据
-(void)requestCategoryData{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodCategory body:@"AccessToken=0" success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        NSMutableArray *cateArr=[[NSMutableArray alloc] init];
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary *dataDic = dataArray[i];
            TCFoodClassModel *foodClass = [[TCFoodClassModel alloc] init];
            [foodClass setValues:dataDic];
            [tempArr addObject:foodClass];
            [cateArr addObject:foodClass.name];
        }
        categoryArray=tempArr;
        self.menuView.foodMenusArray=cateArr;
        
        TCFoodClassModel *foodClass=categoryArray[0];
        category_id=foodClass.id;
        [self requestFoodData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 加载食物列表
-(void)requestFoodData{
    NSMutableArray *selectFoodArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&cat_id=%@",(long)page,category_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodList body:body success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            self.foodTableView.mj_footer.hidden=(totalValues-page*20)<=0;
        }
        
        NSArray *list=[json objectForKey:@"result"];
        if (list.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in list) {
                TCFoodAddModel *model=[[TCFoodAddModel alloc] init];
                [model setValues:dict];
                model.weight=[NSNumber numberWithInteger:0];
                model.isSelected=[NSNumber numberWithBool:NO];
                for (TCFoodAddModel *food in selectFoodArr) {
                    if (food.id==model.id) {
                        model.weight=food.weight;
                        model.isSelected=[NSNumber numberWithBool:YES];
                    }
                }
                [tempArr addObject:model];
            }
            if (page==1) {
                foodArray=tempArr;
                self.foodBlankView.hidden=foodArray.count>0;
            }else{
                [foodArray addObjectsFromArray:tempArr];
            }
        }else{
            if (page==1) {
                [foodArray removeAllObjects];
                self.foodBlankView.hidden=NO;
            }
            self.foodTableView.mj_footer.hidden=YES;
        }
        [self.foodTableView reloadData];
        
        [self.foodTableView.mj_header endRefreshing];
        [self.foodTableView.mj_footer endRefreshing];
        
        dietCount=selectFoodArr.count;
        [self reloadFoodAddView];
    } failure:^(NSString *errorStr) {
        [self.foodTableView.mj_header endRefreshing];
        [self.foodTableView.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 加载最新食材
-(void)loadNewFoodData{
    page=1;
    [self requestFoodData];
}

#pragma mark 加载更多食材
-(void)loadMoreFoodData{
    page++;
    [self requestFoodData];
}

#pragma mark 刷新页面
-(void)reloadFoodAddView{
    foodBtn.selected=dietCount>0;
    line.backgroundColor=dietCount>0?kSystemColor:[UIColor lightGrayColor];
    confirmButton.backgroundColor=dietCount>0?kSystemColor:[UIColor lightGrayColor];

    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
    countLabel.attributedText=attributeStr;
}

#pragma mark -- Setters and Getters
#pragma mark 菜单栏
-(TCFoodMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[TCFoodMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 40)];
        _menuView.delegate=self;
    }
    return _menuView;
}

#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (_foodTableView==nil) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,self.menuView.bottom, kScreenWidth, kScreenHeight-self.menuView.bottom-50) style:UITableViewStylePlain];
        _foodTableView.dataSource=self;
        _foodTableView.delegate=self;
        _foodTableView.showsVerticalScrollIndicator=NO;
        _foodTableView.tableFooterView=[[UIView alloc] init];
        _foodTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _foodTableView.mj_header=header;
        
        // 上拉加载更多
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _foodTableView.mj_footer = footer;
        footer.hidden=YES;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipFoodTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_foodTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipFoodTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_foodTableView addGestureRecognizer:swipGestureRight];
    }
    return _foodTableView;
}

#pragma mark 已选食物视图
-(TCFoodSelectView *)foodSelectView{
    if (_foodSelectView==nil) {
        _foodSelectView=[[TCFoodSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _foodSelectView.delegate=self;
    }
    return _foodSelectView;
}

#pragma mark 无数据空白页
-(TCBlankView *)foodBlankView{
    if (_foodBlankView==nil) {
        _foodBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200) img:@"img_tips_no" text:@"该分类下暂无食材"];
    }
    return _foodBlankView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (_bottomView==nil) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        line=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        line.backgroundColor=selectaddFoodArr.count>0?kSystemColor:[UIColor lightGrayColor];
        [_bottomView addSubview:line];
        
        //点击查看已选食物
        foodBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [foodBtn setImage:[UIImage imageNamed:@"ic_n_meal_nor"] forState:UIControlStateNormal];
        [foodBtn setImage:[UIImage imageNamed:@"ic_n_meal_sel"] forState:UIControlStateSelected];
        [foodBtn addTarget:self action:@selector(showSelectedFoodList) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:foodBtn];
        foodBtn.selected=dietCount>0;
        
        countLabel=[[UILabel alloc] initWithFrame:CGRectMake(foodBtn.right+5, 10, 100, 30)];
        countLabel.textColor=[UIColor blackColor];
        countLabel.font=[UIFont systemFontOfSize:14.0f];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
        countLabel.attributedText=attributeStr;
        [_bottomView addSubview:countLabel];
        
        confirmButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 1, 100, 49)];
        confirmButton.backgroundColor=selectaddFoodArr.count>0?kSystemColor:[UIColor lightGrayColor];;

        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAddFoodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:confirmButton];
    }
    return _bottomView;
}

@end
