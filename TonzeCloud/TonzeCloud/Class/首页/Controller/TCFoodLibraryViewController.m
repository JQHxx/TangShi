//
//  TCFoodLibraryViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodLibraryViewController.h"
#import "TCFoodCollectionViewCell.h"
#import "TCFoodClassModel.h"
#import "TCFoodClassViewController.h"
#import "TCSearchViewController.h"
#import "TCGIFoodLibViewController.h"
#import "TCGIFoodButton.h"

@interface TCFoodLibraryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>{

    UICollectionView *foodCollection;
    NSMutableArray   *toolArray;
    NSMutableArray   *idArray;
    NSMutableArray   *titleArray;
    NSArray          *imgArray;
}

@property(nonatomic,strong)UISearchBar *mySearchBar;

@end
@implementation TCFoodLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"食物库";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    toolArray = [[NSMutableArray alloc] init];
    titleArray = [[NSMutableArray alloc] init];
    idArray = [[NSMutableArray alloc] init];
    [self initFoodView];
    [self requestData]; 
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-06" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-06" type:2];
#endif
}

#pragma mark --UICollectionViewDelegate,UICollectionViewDataSource
//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}
//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return toolArray.count;
}
//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TCFoodCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TCFoodCollectionViewCell" forIndexPath:indexPath];
    [cell cellDisplayWithDict:toolArray[indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-06-01:%ld",indexPath.row+1]];
#endif
    
    [MobClick event:@"101_002011"];
    
    TCFoodClassViewController *foodClassVC = [[TCFoodClassViewController alloc] init];
    foodClassVC.index =indexPath.row;
    foodClassVC.titleArray = titleArray;
    foodClassVC.idarray = idArray;
    [self.navigationController pushViewController:foodClassVC animated:YES];
}

#pragma mark -- UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [MobClick event:@"101_002012"];
    TCSearchViewController *searchVC=[[TCSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark -- Event Response
-(void)pushToGIFoodLibrary:(UIButton *)sender{
    [MobClick event:@"101_002021"];
    TCGIFoodLibViewController *GIFoodVC=[[TCGIFoodLibViewController alloc] init];
    [self.navigationController pushViewController:GIFoodVC animated:YES];
}

#pragma mark--获取分类数据
- (void)requestData{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFoodCategory body:@"AccessToken=0" success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        [idArray addObject:@"全部"];
        if (dataArray.count>0) {
            for (int i=0; i<dataArray.count; i++) {
                NSDictionary *dataDic = dataArray[i];
                TCFoodClassModel *foodClass = [[TCFoodClassModel alloc] init];
                [foodClass setValues:dataDic];
                [toolArray addObject:foodClass];
                [titleArray addObject:foodClass.name];
                [idArray addObject:foodClass.id];
            }
            [foodCollection reloadData];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initFoodView{
    [self.view addSubview:self.mySearchBar];
    
    TCGIFoodButton *foodBtn=[[TCGIFoodButton alloc] initWithFrame:CGRectMake(0, self.mySearchBar.bottom+10, kScreenWidth, 80)];
    [foodBtn addTarget:self action:@selector(pushToGIFoodLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:foodBtn];
    
    
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(kScreenWidth/3-10, kScreenWidth/320*100);
    foodCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, foodBtn.bottom+10, kScreenWidth,kScreenHeight-foodBtn.bottom-20) collectionViewLayout:layout];
    foodCollection.backgroundColor = [UIColor whiteColor];
    foodCollection.delegate=self;
    foodCollection.dataSource=self;
    [foodCollection registerNib:[UINib nibWithNibName:NSStringFromClass([TCFoodCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"TCFoodCollectionViewCell"];
    [self.view addSubview:foodCollection];

}

#pragma mark 搜索框
-(UISearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kNavHeight)];
        _mySearchBar.delegate=self;
        _mySearchBar.text=@"请输入食物名称";
        UITextField *searchField = [_mySearchBar valueForKey:@"_searchField"];
        searchField.textColor = [UIColor grayColor];
        [searchField setClearButtonMode:UITextFieldViewModeNever];
    }
    return _mySearchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
