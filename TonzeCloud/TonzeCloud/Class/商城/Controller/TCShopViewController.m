//
//  TCShopViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/5.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCShopViewController.h"
#import "TCShopCollectionViewCell.h"
#import "ShopModel.h"
#import "ShopDetailViewController.h"
#import "ShopCartViewController.h"
#import "PPBadgeLabel.h"

@interface TCShopViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    NSMutableArray *detailArray;
    
    NSInteger pageNumber;
    
    TCBlankView       *blankView;
    NSDictionary   *param;

    BOOL            isLogin;
}
/// 购物车消息图标
@property (nonatomic ,strong) PPBadgeLabel  *cartMessageNumLab;

@property (nonatomic ,strong) UICollectionView *collectionView;
@end

@implementation TCShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"商城";
    self.rightImageName = @"top_ic_car";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    pageNumber = 1;
    detailArray = [[NSMutableArray alloc] init];
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.cartMessageNumLab];
    [self loadShopData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (isLogin) {
        [self loadCartShopNum];
    }else{
        self.cartMessageNumLab.hidden = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"009-01" type:1];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"009-01" type:2];
}
#pragma mark --  UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return detailArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TCShopCollectionViewCell";
    
    TCShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ShopModel *model = detailArray[indexPath.row];
    [cell initShopCellModel:model];
    [cell sizeToFit];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"101_002032"];
    ShopModel *shopModel = detailArray[indexPath.row];
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"009-01-02:%ld",shopModel.default_product_id]];
    ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
    shopDetailVC.product_id = shopModel.default_product_id;
    [self.navigationController pushViewController:shopDetailVC animated:YES];
}
#pragma mark -- Event response
#pragma mark -- 获取购物车商品数量
- (void)loadCartShopNum{
    NSString *user_id = [NSUserDefaultsInfos getValueforKey:USER_ID];
    NSString *body=[NSString stringWithFormat:@"member_id=%@",user_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getShopMethodWithURL:kShopCartGoodsList body:body isLoading:NO success:^(id json) {
        NSDictionary *cartInfo=[json objectForKey:@"result"];
        if (kIsDictionary(cartInfo)) {
            weakSelf.cartMessageNumLab.hidden = [[cartInfo objectForKey:@"total_num"] integerValue]>0?NO:YES;
            weakSelf.cartMessageNumLab.text =[[cartInfo objectForKey:@"total_num"] integerValue]>99?@"99+":[NSString stringWithFormat:@"%ld",[[cartInfo objectForKey:@"total_num"] integerValue]];
        }else{
            weakSelf.cartMessageNumLab.hidden = YES;
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 获取商品列表数据
- (void)loadShopData{
    
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&orderBy_id=1&type=1",(long)pageNumber];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithURL:KShopGoodsList body:body success:^(id json) {
        NSArray *result = [[json objectForKey:@"result"] objectForKey:@"goods"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        param = [json objectForKey:@"param"];
        if (kIsArray(result)) {
            NSMutableArray *shopListArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                ShopModel *model = [[ShopModel alloc] init];
                [model setValues:dict];
                [shopListArr addObject:model];
            }
            if (pageNumber==1) {
                detailArray = shopListArr;
                blankView.hidden = shopListArr.count > 0;
            } else {
                [detailArray addObjectsFromArray:shopListArr];
            }
            weakSelf.collectionView.mj_footer.hidden=(total -pageNumber*20)<=0;
        }
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.collectionView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 购物车
- (void)rightButtonAction{
    if (isLogin) {
        [MobClick event:@"101_002031"];
        [[TCHelper sharedTCHelper] loginClick:@"009-01-01"];
        ShopCartViewController *shopCartVC = [[ShopCartViewController alloc] init];
        [self.navigationController pushViewController:shopCartVC animated:YES];
    } else {
        TCFastLoginViewController *loginVC = [[TCFastLoginViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark 加载最新记录
-(void)loadNewShopListData{
    pageNumber =1;
    [self loadShopData];
}

#pragma mark 加载更多记录
-(void)loadMoreShopListData{
    pageNumber++;
    [self loadShopData];
}

#pragma mark -- Getter --
#pragma mark ====== 购物车消息图标 =======
-(PPBadgeLabel *)cartMessageNumLab{
    if (!_cartMessageNumLab) {
        _cartMessageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( kScreenWidth-20, 26, 16, 16)];
        _cartMessageNumLab.hidden = YES;
    }
    return _cartMessageNumLab;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        static NSString *identifier = @"TCShopCollectionViewCell";
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-64) collectionViewLayout:flowLayout];
        flowLayout.itemSize = CGSizeMake((kScreenWidth-5)/2,(kScreenWidth-5)/2+75);
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 5;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 0;
        //定义每个UICollectionView 的边距距
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);//上左下右
        [_collectionView registerClass:[TCShopCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = kBackgroundColor;
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShopListData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _collectionView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShopListData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _collectionView.mj_footer = footer;
        footer.hidden=YES;
        
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
        [self.view addSubview:blankView];
        blankView.hidden=YES;
    }
    return _collectionView;
}
@end
