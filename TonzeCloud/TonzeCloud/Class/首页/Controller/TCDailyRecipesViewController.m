 //
//  TCDailyRecipesViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDailyRecipesViewController.h"
#import "TCMenuView.h"
#import "TCDailyRecipesTableView.h"
#import "TCRecipeModel.h"
#import "TCConsultViewController.h"

@interface TCDailyRecipesViewController ()<TCMenuViewDelegate>{
    NSArray        *crowdArray;
    TCBlankView    *blankView;
    NSInteger       selectIndex;
}
@property (nonatomic,strong)TCMenuView               *crowdMenuView;
@property (nonatomic,strong)TCDailyRecipesTableView  *dailyRecipesTableView;

@end

@implementation TCDailyRecipesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"每日菜谱";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    crowdArray=@[@"消瘦",@"肥胖",@"妊娠",@"老年",@"儿童"];
    [self.view addSubview:self.crowdMenuView];
    [self createView];
    [self.view addSubview:self.dailyRecipesTableView];
    
    [self requestRecipeListWithIndex:0];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-07" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-07" type:2];
#endif
}

#pragma mark -- CustomDelegate
#pragma mark TCMenuViewDelegate
-(void)menuView:(TCMenuView *)menuView actionWithIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-07-02:%@",crowdArray[index]]];
    [MobClick event:@"101_002013"];
    selectIndex = index;
    [self requestRecipeListWithIndex:selectIndex];
}
#pragma mark -- 专家咨询
-(void)consultAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-07-01"];
#endif
    [MobClick event:@"101_002014"];
    TCConsultViewController *consultVC = [[TCConsultViewController alloc] init];
    [self.navigationController pushViewController:consultVC animated:YES];
}
#pragma mark -- Event Response
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
    for (UIView  *view in _crowdMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_crowdMenuView changeViewWithButton:btn];
}
#pragma mark --Network
#pragma mark 获取菜谱列表
-(void)requestRecipeListWithIndex:(NSInteger)index{
    MyLog(@"人群:%@",crowdArray[index]);
    NSString *body = [NSString stringWithFormat:@"type=%ld",(long)(index+1)];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kEverydayMenu body:body success:^(id json) {
        NSDictionary *menuDic = [json objectForKey:@"result"];
        if (!kIsDictionary(menuDic)) {
            [self.view makeToast:@"暂无数据" duration:1.0 position:CSToastPositionCenter];
        }
        NSMutableDictionary *dataMenuDic=[[NSMutableDictionary alloc] init];
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        id breakfast = [menuDic objectForKey:@"breakfast"];
        id lunchfast = [menuDic objectForKey:@"lunch"];
        id dinnerfast = [menuDic objectForKey:@"dinner"];
        id snackfast = [menuDic objectForKey:@"snack"];
        if ((kIsArray(breakfast)&&[(NSArray *)breakfast count]>0)||(kIsDictionary(breakfast)&&[(NSDictionary *)breakfast count]>0)) {

        if (!kIsEmptyObject(breakfast)) {
            [titleArray addObject:[breakfast objectForKey:@"name"]];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSArray *breakfastArray=[breakfast valueForKey:@"list"];
            for (NSInteger i=0; i<breakfastArray.count; i++) {
                TCRecipeModel *recipeModel=[[TCRecipeModel alloc] init];
                [recipeModel setValues:breakfastArray[i]];
                [dataArray addObject:recipeModel];
            }
            [dataMenuDic setValue:dataArray forKey:[breakfast objectForKey:@"name"]];
        }
    }
        if ((kIsArray(lunchfast)&&[(NSArray *)lunchfast count]>0)||(kIsDictionary(lunchfast)&&[(NSDictionary *)lunchfast count]>0)) {

        if (!kIsEmptyObject(lunchfast)) {
            [titleArray addObject:[lunchfast objectForKey:@"name"]];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSArray *lunchfastArray=[lunchfast valueForKey:@"list"];
            for (NSInteger i=0; i<lunchfastArray.count; i++) {
                TCRecipeModel *recipeModel=[[TCRecipeModel alloc] init];
                [recipeModel setValues:lunchfastArray[i]];
                [dataArray addObject:recipeModel];
            }
            [dataMenuDic setValue:dataArray forKey:[lunchfast objectForKey:@"name"]];
        }
    }
        if ((kIsArray(dinnerfast)&&[(NSArray *)dinnerfast count]>0)||(kIsDictionary(dinnerfast)&&[(NSDictionary *)dinnerfast count]>0)) {

        if (!kIsEmptyObject(dinnerfast)) {
            [titleArray addObject:[dinnerfast objectForKey:@"name"]];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSArray *dinnerArray=[dinnerfast valueForKey:@"list"];
            for (NSInteger i=0; i<dinnerArray.count; i++) {
                TCRecipeModel *recipeModel=[[TCRecipeModel alloc] init];
                [recipeModel setValues:dinnerArray[i]];
                [dataArray addObject:recipeModel];
            }
            [dataMenuDic setValue:dataArray forKey:[dinnerfast objectForKey:@"name"]];
        }
    }
        if ((kIsArray(snackfast)&&[(NSArray *)snackfast count]>0)||(kIsDictionary(snackfast)&&[(NSDictionary *)snackfast count]>0)) {
            
            NSArray *titleFoodArray = @[@"上午加餐",@"下午加餐",@"睡前加餐"];
            NSArray *menuArray = [snackfast allKeys];
            for (int i=0; i<titleFoodArray.count; i++) {
                for (int j=0; j<menuArray.count; j++) {
                    if ([menuArray[j] isEqualToString:titleFoodArray[i]]) {
                        [titleArray addObject:menuArray[j]];
                        
                        NSDictionary *snackDic=[snackfast valueForKey:menuArray[j]];
                        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                        NSArray *snackfastArray = [snackDic objectForKey:@"list"];
                        for (NSInteger i=0; i<snackfastArray.count; i++) {
                            TCRecipeModel *recipeModel=[[TCRecipeModel alloc] init];
                            [recipeModel setValues:snackfastArray[i]];
                            [dataArray addObject:recipeModel];
                        }
                        [dataMenuDic setValue:dataArray forKey:menuArray[j]];

                    }
                }
            }
        }
        self.dailyRecipesTableView.headTitles = titleArray;
        self.dailyRecipesTableView.dataMenuDic=dataMenuDic;
        [self.dailyRecipesTableView  reloadData];

    } failure:^(NSString *errorStr) {
        blankView.hidden=NO;
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- getters and setters
#pragma mark 分类菜单
-(TCMenuView *)crowdMenuView{
    if (_crowdMenuView==nil) {
        _crowdMenuView=[[TCMenuView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 49)];
        _crowdMenuView.menusArray=[[NSMutableArray alloc] initWithArray:crowdArray];
        _crowdMenuView.delegate=self;
    }
    return _crowdMenuView;
}

#pragma mark -- 初始化界面
- (void)createView{
    UIButton *consultBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-320)/2+230, _crowdMenuView.bottom+5, 90, 20)];
    [consultBtn setTitle:@"咨询营养师。" forState:UIControlStateNormal];
    [consultBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
    consultBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    consultBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [consultBtn addTarget:self action:@selector(consultAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:consultBtn];
    
    UILabel *bgLine = [[UILabel alloc] initWithFrame:CGRectMake(consultBtn.left+5, consultBtn.bottom, consultBtn.width-20, 1)];
    bgLine.backgroundColor = kbgBtnColor;
    [self.view addSubview:bgLine];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-320)/2, consultBtn.top, 230, 20)];
    textLabel.text = @"此为特殊糖尿病人群菜谱，更详细菜谱请";
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.textAlignment = NSTextAlignmentRight;
    textLabel.textColor = [UIColor grayColor];
    [self.view addSubview:textLabel];
}

-(TCDailyRecipesTableView *)dailyRecipesTableView{
    if (_dailyRecipesTableView==nil) {
        _dailyRecipesTableView=[[TCDailyRecipesTableView alloc] initWithFrame:CGRectMake(0, _crowdMenuView.bottom+30, kScreenWidth, kRootViewHeight-49-30) style:UITableViewStyleGrouped];
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_dailyRecipesTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_dailyRecipesTableView addGestureRecognizer:swipGestureRight];
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
        [_dailyRecipesTableView addSubview:blankView];
        blankView.hidden=YES;

    }
    return _dailyRecipesTableView;
}
@end
