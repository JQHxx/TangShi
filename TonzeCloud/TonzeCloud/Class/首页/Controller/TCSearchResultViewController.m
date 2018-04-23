//
//  TCSearchResultViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSearchResultViewController.h"
#import "TCFoodAddModel.h"
#import "TCFoodSearchTableViewCell.h"
#import "TCArticleTableViewCell.h"
#import "TCFoodTableViewCell.h"
#import "TCArticleModel.h"
#import "TCFoodAddTool.h"
#import "TCFoodSelectView.h"
#import "TCScaleView.h"
#import "TCBlankView.h"

@interface TCSearchResultViewController ()<UITableViewDelegate,UITableViewDataSource,TCFoodSelectViewDelegate,TCScaleViewDelegate>{
    NSMutableArray      *resultData;
    NSInteger           page;
    NSInteger           dietCount;
    TCBlankView         *blankView;
    UIView              *coverView;
    UIButton            *foodBtn;
    UILabel             *countLabel;        //已选食物数量
    
}

@property (nonatomic,strong)UITableView       *tableView;
@property (nonatomic,strong)TCFoodSelectView  *foodSelectView;    //已选食物视图
@property (nonatomic,strong)UIView            *bottomView;        //底部视图

@end

@implementation TCSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    resultData=[[NSMutableArray alloc] init];
    page=1;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"搜索结果"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索结果"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type==FoodSearchType) {
        static NSString *cellIdntifier=@"TCFoodSearchTableViewCell";
        TCFoodSearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCFoodSearchTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
//        cell.cellType=0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCFoodAddModel *food=resultData[indexPath.row];
        [cell cellDisplayWithFood:food  searchText:self.keyword];
        return cell;
    }else if (_type==KnowledgeSearchType){
        static NSString *cellIdentifier=@"TCArticleTableViewCell";
        TCArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCArticleModel *article=resultData[indexPath.row];
        [cell cellDisplayWithModel:article searchText:self.keyword];
        return cell;
    }else if(_type==FoodAddSearchType){
        static NSString *cellIdntifier=@"TCFoodTableViewCell";
        TCFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"TCFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.cellType=0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TCFoodAddModel *food=resultData[indexPath.row];
        [cell cellDisplayWithFood:food searchText:self.keyword];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _type==KnowledgeSearchType?100:60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id  model=resultData[indexPath.row];
    if (_type==FoodAddSearchType) {
        if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerDidSelectModel:withType:)]) {
            [_controllerDelegate searchResultViewControllerDidSelectModel:model withType:_type];
        }
        
        TCFoodAddModel *food=(TCFoodAddModel*)model;
        TCScaleView *scaleView=[[TCScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 364) model:food];
        scaleView.scaleDelegate=self;
        [scaleView scaleViewShowInView:self.view];
        
        
    }else{
        if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerDidSelectModel:withType:)]) {
            [_controllerDelegate searchResultViewControllerDidSelectModel:model withType:_type];
        }
    }
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerBeginDraggingAction)]) {
        [_controllerDelegate searchResultViewControllerBeginDraggingAction];
    }
}

#pragma mark -- Event Response
#pragma mark 确定
-(void)confirmAddFoodAction:(UIButton *)sender{
    if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerConfirmAction)]) {
        [_controllerDelegate searchResultViewControllerConfirmAction];
    }
}

#pragma mark --Custom Delegate
#pragma mark TCFoodSelectViewDelegate
#pragma mark 清空已选食物列表
-(void)foodSelectViewDismissAction{
    for (TCFoodAddModel *model in resultData) {
        model.isSelected=[NSNumber numberWithBool:NO];
        model.weight=[NSNumber numberWithInteger:100];
    }
    [self.tableView reloadData];
    
    dietCount=0;
    [self reloadFoodAddView];
    [self closeFoodViewAction];
}

#pragma mark 删除已选食物
-(void)foodSelectViewDeleteFood:(TCFoodAddModel *)food{
    for (TCFoodAddModel *model in resultData) {
        if (food.id==model.id) {
            model.isSelected=[NSNumber numberWithBool:NO];
            model.weight=[NSNumber numberWithInteger:100];
        }
    }
    [self.tableView reloadData];
    
    NSMutableArray *tempArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    [self reloadFoodAddView];
}

#pragma mark 编辑食物
-(void)foodSelectViewDidSelectFood:(TCFoodAddModel *)food{
    [self closeFoodViewAction];
    
    TCScaleView *scaleView=[[TCScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 364) model:food];
    scaleView.scaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

#pragma mark  TCScaleViewDelegate
-(void)scaleView:(TCScaleView *)scaleView didSelectFood:(TCFoodAddModel *)food{
    if ([food.isSelected boolValue]) {
        [[TCFoodAddTool sharedTCFoodAddTool] updateFood:food];
    }else{
        food.isSelected=[NSNumber numberWithBool:YES];
        [[TCFoodAddTool sharedTCFoodAddTool] insertFood:food];
    }
    for (TCFoodAddModel *foodModel in resultData) {
        if (foodModel.id==food.id) {
            foodModel.isSelected=[NSNumber numberWithBool:YES];
            foodModel.weight=food.weight;
        }
    }
    [self.tableView reloadData];
    
    NSMutableArray *tempArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    
    [self reloadFoodAddView];
}

#pragma mark -- Event Rersponse
#pragma mark 显示已选食物视图
-(void)showSelectedFoodList{
    if (dietCount>0) {
        if (coverView==nil) {
            coverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight-50)];
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
            self.foodSelectView.frame=CGRectMake(0, kRootViewHeight-50-220, kScreenWidth, 220);
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

#pragma mark -- Private Methods
#pragma mark 刷新页面
-(void)reloadFoodAddView{
    foodBtn.selected=dietCount>0;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
    countLabel.attributedText=attributeStr;
}

#pragma mark -- Getters and Setters
-(void)setType:(SearchType)type{
    _type=type;
    if (self.type==FoodAddSearchType) {
        self.tableView.frame=CGRectMake(0, 0, kScreenWidth, kRootViewHeight-50);
        [self.view addSubview:self.foodSelectView];
        [self.view addSubview:self.bottomView];
    }
}

-(void)setKeyword:(NSString *)keyword{
    _keyword=keyword;
    
    NSString *url=nil;
    NSString *body=nil;
    if (_type==FoodSearchType||_type==FoodAddSearchType) {
        url=kFoodList;
        body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&name=%@",(long)page,keyword];
    }else if (_type==KnowledgeSearchType){
        url=kArticleList;
        body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&title=%@",(long)page,keyword];
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {

        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            self.tableView.mj_footer.hidden=(totalValues-page*20)<=0;
        }

        NSArray *list=[json objectForKey:@"result"];
        if (list.count>0) {
            
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            if (self.type==FoodSearchType||self.type==FoodAddSearchType) {
                NSMutableArray *selectFoodArr=[TCFoodAddTool sharedTCFoodAddTool].selectFoodArray;
                for (NSDictionary *dict in list) {
                    TCFoodAddModel *foodModel=[[TCFoodAddModel alloc] init];
                    [foodModel setValues:dict];
                    
                    if (self.type==FoodAddSearchType) {
                        for (TCFoodAddModel *food in selectFoodArr) {
                            if (food.id==foodModel.id) {
                                foodModel.weight=food.weight;
                                foodModel.isSelected=[NSNumber numberWithBool:YES];
                            }
                        }
                    }
                    [tempArr addObject:foodModel];
                }
                dietCount=selectFoodArr.count;
                [self reloadFoodAddView];
            }else if (self.type==KnowledgeSearchType){
                for (NSDictionary *dict in list) {
                    TCArticleModel *articleModel=[[TCArticleModel alloc] init];
                    [articleModel setValues:dict];
                    [tempArr addObject:articleModel];
                }
            }
            if (page==1) {
                resultData=tempArr;
            }else{
                [resultData addObjectsFromArray:tempArr];
            }
        }else{
            resultData = [[NSMutableArray alloc] init];
        }
        blankView.hidden=resultData.count>0;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];

    } failure:^(NSString *errorStr) {
        blankView.hidden = NO;
        [resultData removeAllObjects];
        [self.tableView reloadData];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 加载最新数据
-(void)loadNewSearchFoodData{
    page =1;
    [self setKeyword:_keyword];
    
}
#pragma mark -- 加载更多数据
-(void)loadMoreSearchFoodData{
    page++;
    [self setKeyword:_keyword];
    
}
#pragma mark -- Setters and Getters
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.backgroundColor=[UIColor bgColor_Gray];
        _tableView.tableFooterView=[[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSearchFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _tableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSearchFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden=YES;

        blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, 100, kScreenWidth, kScreenHeight - 100) Searchimg:@"img_sch_none" text:@"什么都没搜到哦"];
        [_tableView addSubview:blankView];
        blankView.hidden=YES;

    }
    return _tableView;
}

#pragma mark 已选食物视图
-(TCFoodSelectView *)foodSelectView{
    if (_foodSelectView==nil) {
        _foodSelectView=[[TCFoodSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _foodSelectView.delegate=self;
    }
    return _foodSelectView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (_bottomView==nil) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kRootViewHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        line.backgroundColor=kSystemColor;
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
        
        UIButton *confirmButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 1, 100, 49)];
        confirmButton.backgroundColor=kSystemColor;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAddFoodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:confirmButton];
    }
    return _bottomView;
}

@end
