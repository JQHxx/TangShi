//
//  IntegralMallViewController.m
//  Product
//
//  Created by 肖栋 on 17/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCPointslMallViewController.h"
#import "TCIntegralMallButon.h"
#import "TCIntegralMallCell.h"
#import "TCMyScoresViewController.h"
#import "TCExchangeRecordsViewController.h"
#import "TCIntegralGoodsViewController.h"
#import "TCGoodsListModel.h"
#import "QLCoreTextManager.h"
#import "TCFastLoginViewController.h"

static NSString *headerViewIdentifier  = @"headerViewIdentifier";
static NSString *integralViewIdentifier = @"integralViewIdentifier";

@interface TCPointslMallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSInteger _pageNmber;
    NSInteger _userIntegral;// 用户积分
}
///
@property (nonatomic ,strong) UICollectionView *integralCollectionView;
/// 商品数据
@property (nonatomic ,strong) NSMutableArray *goodsDataArr;
/// 我的积分
@property(nonatomic ,strong) TCIntegralMallButon *myIntegralBtn;
/// 兑换记录
@property(nonatomic ,strong) TCIntegralMallButon *exchangeRecordsBtn;
/// 提示页面
@property (nonatomic ,strong) TCBlankView *blankView;

@end

@implementation TCPointslMallViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isIntegralMallRecord) {
        [self.goodsDataArr removeAllObjects];
        [self requestIntegralMallData];
        [TCHelper sharedTCHelper].isIntegralMallRecord = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"积分商城";
    _pageNmber = 1;

    self.view.backgroundColor = [UIColor bgColor_Gray];

    [self.view addSubview:self.integralCollectionView];
    [self requestIntegralMallData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"007" type:1];
#endif

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"007" type:2];
#endif
}
#pragma mark ====== request Data =======
- (void)requestIntegralMallData{
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)_pageNmber];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KGoodsList body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        NSDictionary *pagerDic = [json objectForKey:@"pager"];
        NSArray *arr =  [resultDic objectForKey:@"goods"];
        _userIntegral = [[resultDic objectForKey:@"point"] integerValue];
        [self setUserIntegralWithPoint:_userIntegral];
        
        if (kIsDictionary(pagerDic)) {
            NSInteger totalNumber = [[pagerDic objectForKey:@"total"] integerValue];
            weakSelf.integralCollectionView.mj_footer.hidden=(totalNumber-_pageNmber*20)<=0;
        }
        if (arr.count > 0 && kIsArray(arr)) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *goosDic in arr) {
                TCGoodsListModel *goodListModel = [TCGoodsListModel new];
                [goodListModel setValues:goosDic];
                [weakSelf.goodsDataArr addObject:goodListModel];
            }
        }else{
            [weakSelf.goodsDataArr removeAllObjects];
            [weakSelf.integralCollectionView reloadData];
            weakSelf.blankView.hidden = weakSelf.goodsDataArr.count > 0;
        }
        [weakSelf.integralCollectionView reloadData];
        [weakSelf.integralCollectionView.mj_header endRefreshing];
        [weakSelf.integralCollectionView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.integralCollectionView.mj_header endRefreshing];
        [weakSelf.integralCollectionView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 设置用户积分 ======= 
- (void)setUserIntegralWithPoint:(NSUInteger )point
{
    NSString *integralStr =[NSString stringWithFormat:@"%ld 积分",(long)point];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
    [QLCoreTextManager setAttributedValue:attStr text:[NSString stringWithFormat:@"%ld",(unsigned long)point] font:kFontWithSize(15) color:UIColorFromRGB(0xf9c92b)];
    self.myIntegralBtn.label.attributedText = attStr;
}
#pragma mark ====== 加载更多商品数据 =======
- (void)loadMoreGoodsData{
    _pageNmber++;
    [self requestIntegralMallData];
}
#pragma mark ====== 加载最新商品数据 =======
- (void)loadNewGoodsData{
    _pageNmber = 1;
    [self.goodsDataArr removeAllObjects];
    [self requestIntegralMallData];
}
#pragma mark ===== Event Response =======
#pragma mark ====== 返回按钮 =======
- (void)leftButtonAction{
    if (_isTaskAleartLogin) {
        NSMutableArray *vcArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        // 将上级页面从数组中移除
        [vcArr removeObjectAtIndex:vcArr.count-2];
        self.navigationController.viewControllers = vcArr;
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark ====== 我的积分 、兑换记录 =======

- (void)integralButton:(UIButton *)button{
    
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) { // 判断用户是否登录
        switch (button.tag) {
            case 1000:
            {///积分
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"007-01-01"];
#endif
                 [MobClick event:@"104_002030"];
                TCMyScoresViewController *myScoresVC = [TCMyScoresViewController new];
                myScoresVC.userIntegral = _userIntegral;
                [self.navigationController pushViewController:myScoresVC animated:YES];
            }break;
            case 1001:
            {/// 兑换记录
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"007-02"];
#endif
                [MobClick event:@"104_002031"];
                TCExchangeRecordsViewController *exchangeRecordsVC = [TCExchangeRecordsViewController new];
                [self.navigationController pushViewController:exchangeRecordsVC animated:YES];
            }break;
            default:
                break;
        }
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ======  UICollectionViewDelegate   ======
#pragma mark ======  UICollectionViewDataSource ======

/*  头部视图 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        //添加头视图的内容
        UIView *sectionHeaderBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 122 + 76/2 + 20)];
        sectionHeaderBgView.backgroundColor = UIColorFromRGB(0xfafafa);
        
        [sectionHeaderBgView addSubview:self.myIntegralBtn];
        [sectionHeaderBgView addSubview:self.exchangeRecordsBtn];
        // 竖线
        UILabel *Line = [[UILabel alloc] initWithFrame:CGRectMake(self.myIntegralBtn.right, 10, 0.5, self.myIntegralBtn.height - 20)];
        Line.backgroundColor = kLineColor;
        [sectionHeaderBgView addSubview:Line];
        // 提示标题
        UIView *tipView = [[UIView alloc]initWithFrame:CGRectMake(0, 132,kScreenWidth ,76/2)];
        tipView.backgroundColor = [UIColor whiteColor];
        [sectionHeaderBgView addSubview:tipView];
    
        UILabel *exchangeLab = [[UILabel alloc]initWithFrame: CGRectMake(10, (76/2 - 20)/2, 120, 20)];
        exchangeLab.textAlignment = NSTextAlignmentCenter;
        exchangeLab.text =@"积分兑换";
        exchangeLab.font = kFontWithSize(15);
        exchangeLab.textColor = UIColorFromRGB(0x313131);
        [tipView addSubview:exchangeLab];
    
        [header addSubview:sectionHeaderBgView];
        return header;
    }else{
       return [[UICollectionReusableView alloc] init];
    }
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  _goodsDataArr.count > 0 ? _goodsDataArr.count : 0 ;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   TCIntegralMallCell *integralMallCell = [collectionView dequeueReusableCellWithReuseIdentifier:integralViewIdentifier forIndexPath:indexPath];
    if (self.goodsDataArr.count > 0) {
        TCGoodsListModel *goodsListModel = self.goodsDataArr[indexPath.row];
        [integralMallCell cellWithGoodsListModel:goodsListModel];
    }
    // 设置阴影
    integralMallCell.layer.contentsScale = [UIScreen mainScreen].scale;
    integralMallCell.layer.masksToBounds = NO;
    integralMallCell.layer.shadowOpacity = 0.1f;//0.0（不可见）和1.0（完全不透明）
    integralMallCell.layer.shadowRadius = 4.0f; // 阴影的模糊度
    integralMallCell.layer.shadowOffset = CGSizeMake(0,0);
    integralMallCell.layer.shadowPath = [UIBezierPath bezierPathWithRect:integralMallCell.bounds].CGPath;
    [integralMallCell sizeToFit];
    
    return integralMallCell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"007-01-02"];
#endif

    [MobClick event:@"104_002032"];
    if (self.goodsDataArr.count > 0) {
        TCIntegralGoodsViewController *integralGoodsVC = [TCIntegralGoodsViewController new];
        TCGoodsListModel *goodListModel = self.goodsDataArr[indexPath.row];
        integralGoodsVC.good_id = [goodListModel.good_id integerValue];
        [self.navigationController pushViewController:integralGoodsVC animated:YES];
    }
}
#pragma mark ====== Getter  =======

- (UICollectionView *)integralCollectionView{
    if (!_integralCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _integralCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) collectionViewLayout:flowLayout];
        flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 142 + 76/2);
        flowLayout.itemSize = CGSizeMake((kScreenWidth - 27)/2, 174 * kScreenWidth/375 +  50);
        flowLayout.minimumLineSpacing = 9;
        flowLayout.minimumInteritemSpacing = 9;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 9, 0, 9);//上左下右
        _integralCollectionView.delegate = self;
        _integralCollectionView.dataSource = self;
        _integralCollectionView.backgroundColor = [UIColor whiteColor];
        //自适应大小
        _integralCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //注册cell单元格
        [_integralCollectionView registerClass:[TCIntegralMallCell class] forCellWithReuseIdentifier:integralViewIdentifier];
        //注册头视图
        [_integralCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewGoodsData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _integralCollectionView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreGoodsData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _integralCollectionView.mj_footer = footer;
        footer.hidden=YES;
        
        [_integralCollectionView addSubview:self.blankView];
    }
    return _integralCollectionView;
}
- (TCIntegralMallButon *)myIntegralBtn{
    if (_myIntegralBtn==nil) {
        _myIntegralBtn = [[TCIntegralMallButon alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2, 122) imagename:@"integra_shop"];
        _myIntegralBtn.backgroundColor = [UIColor whiteColor];
        [_myIntegralBtn addTarget:self action:@selector(integralButton:) forControlEvents:UIControlEventTouchUpInside];
        _myIntegralBtn.tag = 1000;
    }
    return _myIntegralBtn;
}
- (TCIntegralMallButon *)exchangeRecordsBtn{
    if (_exchangeRecordsBtn==nil) {
        _exchangeRecordsBtn = [[TCIntegralMallButon alloc] initWithFrame:CGRectMake(kScreenWidth/2, 0, kScreenWidth/2, 122)imagename:@"ic_record"];
        _exchangeRecordsBtn.backgroundColor = [UIColor whiteColor];
        _exchangeRecordsBtn.title = @"兑换记录";
        [_exchangeRecordsBtn addTarget:self action:@selector(integralButton:) forControlEvents:UIControlEventTouchUpInside];
        _exchangeRecordsBtn.tag = 1001;
    }
    return _exchangeRecordsBtn;
}
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, 180 , kScreenWidth, kScreenHeight -  180) img:@"img_tips_no" text:@"暂无商品"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
- (NSMutableArray *)goodsDataArr{
    if (!_goodsDataArr) {
        _goodsDataArr =[NSMutableArray array];
    }
    return _goodsDataArr;
}
@end
