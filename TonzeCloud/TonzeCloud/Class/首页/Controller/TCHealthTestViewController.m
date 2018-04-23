//
//  TCHealthTestViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthTestViewController.h"
#import "TCBlankView.h"
#import "TCHealthTestModel.h"
#import "TCHealthTestCollectionViewCell.h"
#import "TCFastLoginViewController.h"
#import "TCHealthQusetionViewController.h"
#import "TCHealthQuestionResultViewController.h"

@interface TCHealthTestViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    NSMutableArray *detailArray;
    
    NSInteger pageNumber;
    
    TCBlankView       *blankView;
    
}

@property (nonatomic ,strong) UICollectionView *collectionView;

@end


@implementation TCHealthTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"健康自测";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    pageNumber = 1;
    detailArray = [[NSMutableArray alloc] init];
    [self buildUI];
    [self requrestHealthListData];
}

#pragma mark --  UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return detailArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TCHealthTestCollectionViewCell";
    
    TCHealthTestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    TCHealthTestModel *healthListModel = detailArray[indexPath.row];
    [cell.titleImg sd_setImageWithURL:[NSURL URLWithString:healthListModel.image_url] placeholderImage:nil];
    cell.titleLabel.text = healthListModel.name;
    cell.content = healthListModel.brief;
    [cell sizeToFit];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-11-01"];
#endif
        TCHealthTestModel *healthListModel = detailArray[indexPath.row];
        NSDictionary *dict = [NSUserDefaultsInfos getDicValueforKey:[NSString stringWithFormat:@"%ld",healthListModel.assess_id]];
        
        if ( [dict count]>0&&[[dict objectForKey:@"accs_id"] integerValue]==healthListModel.assess_id) {
            TCHealthQuestionResultViewController *resultVC = [[TCHealthQuestionResultViewController alloc] init];
            resultVC.index = healthListModel.assess_id;
            resultVC.titleStr = healthListModel.name;
            resultVC.num = [[dict objectForKey:@"num"] integerValue];
            resultVC.brief = [dict objectForKey:@"brief"];
            resultVC.shareUrl = [dict objectForKey:@"share"];
            resultVC.imgUrl = healthListModel.image_url;
            resultVC.assess_id = healthListModel.assess_id;
            [self.navigationController pushViewController:resultVC animated:YES];
        } else {
            TCHealthQusetionViewController *testVC = [TCHealthQusetionViewController new];
            testVC.assess_id = healthListModel.assess_id;
            testVC.titleStr = healthListModel.name;
            testVC.imgUrl = healthListModel.image_url;
            [self.navigationController pushViewController:testVC animated:YES];
        }
    }else{
        [self fastLoginAction];
    }
}
#pragma mark -- 获取评估列表
- (void)requrestHealthListData{

    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",pageNumber];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAssessindexList body:body success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            self.collectionView.mj_footer.hidden=(totalValues-pageNumber*20)<=0;
        }
        NSArray *array = [json objectForKey:@"result"];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        if (kIsArray(array)) {
            for (int i=0; i<array.count; i++) {
                TCHealthTestModel *healthListModel = [[TCHealthTestModel alloc] init];
                NSDictionary *dict = array[i];
                [healthListModel setValues:dict];
                [dataArray addObject:healthListModel];
            }
            if (pageNumber==1) {
                detailArray = dataArray;
                blankView.hidden=dataArray.count>0;
                self.collectionView.mj_footer.hidden=detailArray.count<20;
                
            }else{
                [detailArray addObjectsFromArray:dataArray];
            }
        }else{
            blankView.hidden=dataArray.count>0;
            self.collectionView.hidden=NO;
            self.collectionView.mj_footer.hidden=YES;
        }
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];

    } failure:^(NSString *errorStr) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 加载最新记录
-(void)loadNewHealthListData{
    pageNumber =1;
    [self requrestHealthListData];
}

#pragma mark 加载更多记录
-(void)loadMoreHealthListData{
    pageNumber++;
    [self requrestHealthListData];
}
#pragma mark -- Build UI

- (void)buildUI{
    
    [self.view addSubview:self.collectionView];
}
#pragma mark -- Getter --
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        static NSString *identifier = @"TCHealthTestCollectionViewCell";
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-64) collectionViewLayout:flowLayout];
        flowLayout.itemSize = CGSizeMake((kScreenWidth-15)/2,212);
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 5;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 0;
        //定义每个UICollectionView 的边距距
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//上左下右
        [_collectionView registerClass:[TCHealthTestCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = kBackgroundColor;
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewHealthListData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _collectionView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreHealthListData)];
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
