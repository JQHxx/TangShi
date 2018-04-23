//
//  TCServiceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceViewController.h"
#import "TCCustomButton.h"
#import "TCMineServiceViewController.h"
#import "TCConsultViewController.h"
#import "TCImageConsultViewController.h"
#import "TCServiceModel.h"
#import "TCLoginViewController.h"
#import "TCIntelligentViewController.h"
#import "TCServiceCollectCell.h"
#import <Hyphenate/Hyphenate.h>
#import "ConversationViewController.h"
#import "TCImageServiceModel.h"
#import "TCPlanConsultViewController.h"
#import "TCImageCollectionViewCell.h"
#import "SVProgressHUD.h"
#import "TCServiceClickViewGroup.h"
#import "TCFastLoginViewController.h"

@interface TCServiceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ServiceViewGroupDelegate,UIScrollViewDelegate>{
    
    NSMutableArray  *toolArray;
    NSMutableArray  *serviceArray;
    NSMutableArray  *imageArray;
    NSInteger        foodPage;      //推荐页数
    NSInteger        imagePage;     //图文推荐页数
    UIImageView     *imgView;
    UILabel         *messageLabel;
    UIImageView     *image;
    NSInteger        reply;
    
    BOOL isLogin;
    
    BOOL                   isImageServiceReload;
    BOOL                   isPlanServiceReload;
}
@property (nonatomic, strong)  UIScrollView       *rootScrollView;    //根滚动视图
@property (nonatomic, strong)  UIButton           *messageView;
@property (nonatomic, strong) UICollectionView    *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *imgFlowLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *serviceFlowLayout;
@property (nonatomic, strong) UIButton         *imageButton;
@property (nonatomic, strong) UIButton         *planButton;
@property (nonatomic, strong) UILabel          *lineLabel;
@property (nonatomic, strong) TCServiceClickViewGroup *serviceClickView;
@property (nonatomic, strong) TCServiceClickViewGroup *bgServiceClickView;

@end
@implementation TCServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"糖服务";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.isHiddenBackBtn=YES;
    self.rigthTitleName = @"我的服务";
    foodPage =1;
    imagePage = 1;
    reply = 1;
    imageArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    
    
    [self initSevieceView];
    [self requestImageData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isImageServiceReload = isPlanServiceReload = NO;
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    
    [self serviceVCGetUnreadMessage];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    NSInteger selIndex=[TCHelper sharedTCHelper].selIndex;
    MyLog(@"selindex:%ld",selIndex);
    if (selIndex>101) {
        [self ServiceViewGroupActionWithIndex:selIndex-102];
        [TCHelper sharedTCHelper].selIndex=0;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006" type:2];
#endif
}
#pragma mark --UICollectionViewDelegate or UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return reply==1?imageArray.count:serviceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (reply==1) {
        TCImageCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TCImageCollectionViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        TCImageServiceModel *imageModel = imageArray[indexPath.row];
        [cell cellimageCollectService:imageModel];
        return cell;
    } else {
        TCServiceCollectCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"TCServiceCollectCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        TCServiceModel *serviceModel = serviceArray[indexPath.row];
        [cell cellDisCollectService:serviceModel];
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"006-04"];
#endif
    
    [MobClick event:@"103_001005"];
    if (reply==1) {
        TCImageServiceModel *serviceModel = imageArray[indexPath.row];
        TCPlanConsultViewController *planVC = [[TCPlanConsultViewController alloc] init];
        planVC.hidesBottomBarWhenPushed = YES;
        planVC.expert_id = serviceModel.expert_id;
        [self.navigationController pushViewController:planVC animated:YES];
    } else {
        TCServiceModel *serviceModel = serviceArray[indexPath.row];
        TCImageConsultViewController *imgConsultVC = [[TCImageConsultViewController alloc] init];
        imgConsultVC.hidesBottomBarWhenPushed = YES;
        imgConsultVC.expertId = serviceModel.expert_id;
        imgConsultVC.position = 1;
        [self.navigationController pushViewController:imgConsultVC animated:YES];
    }
}
#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.rootScrollView) {
        if (self.messageView.hidden==NO) {
            if (scrollView.contentOffset.y>self.messageView.bottom) {
                _bgServiceClickView.hidden = NO;
            } else {
                _bgServiceClickView.hidden = YES;
            }
        } else {
            if (scrollView.contentOffset.y>160+2.5) {
                _bgServiceClickView.hidden = NO;
            } else {
                _bgServiceClickView.hidden = YES;
            }
        }
    }
}

#pragma mark NSNotification
-(void)serviceVCGetUnreadMessage{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    MyLog(@"未读消息数:%ld",(long)unreadCount);
    messageLabel.text = [NSString stringWithFormat:@"有%ld条未读的专家消息",(long)unreadCount];
    
    if (unreadCount>0&&isLogin) {
        self.messageView.hidden = NO;
        _serviceClickView.frame =CGRectMake(0, self.messageView.bottom+10, kScreenWidth, 40);
        if (reply==1) {
            if (imageArray.count>0) {
                self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,222*((imageArray.count-1)/2+1)+9) ;
                self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            }
        } else {
            if (serviceArray.count>0) {
                self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,((kScreenWidth-27)/2+134)*((serviceArray.count-1)/2+1)) ;
                self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            }
        }
    }else{
        self.messageView.hidden = YES;
        _serviceClickView.frame =CGRectMake(0,  KStatusHeight + 140+2.5, kScreenWidth, 40);
        if (reply==1) { 
            if (imageArray.count>0) {
                self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,222*((imageArray.count-1)/2+1)+9) ;
                self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            }
        } else {
            if (serviceArray.count>0) {
                self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,((kScreenWidth-27)/2+134)*((serviceArray.count-1)/2+1));
                self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            }
        }
    }
}

#pragma mark -- Event Response
#pragma mark -- 智能咨询／专家咨询
-(void)connectServiceForButton:(UIButton *)sender{
    NSInteger index=sender.tag-100;
    if (index==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"006-02"];
#endif
        [MobClick event:@"103_001003"];
        TCIntelligentViewController *intelligentVC=[[TCIntelligentViewController alloc] init];
        intelligentVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:intelligentVC animated:YES];
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"006-03"];
#endif
        [MobClick event:@"103_001004"];
        TCConsultViewController *consultVC = [[TCConsultViewController alloc] init];
        consultVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:consultVC animated:YES];
        
    }
}
#pragma mark -- 加载图文方案
- (void)requestImageData{
    NSString *urlString = [NSString stringWithFormat:@"page_size=20&page_num=%ld",(long)imagePage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kV2_0RecommendList body:urlString success:^(id json) {
        NSInteger total = [[[json objectForKey:@"pager"] objectForKey:@"total"] integerValue];
        NSArray *result = [json objectForKey:@"result"];
        NSMutableArray *imgArr = [[NSMutableArray alloc] init];
        if (kIsArray(result)) {
            for (NSDictionary *dict in result) {
                TCImageServiceModel *imgModel = [[TCImageServiceModel alloc] init];
                [imgModel setValues:dict];
                [imgArr addObject:imgModel];
            }
            self.rootScrollView.mj_footer.hidden=(total -imagePage*20)<=0;
            if (imagePage==1) {
                imageArray = imgArr;
            } else {
                [imageArray addObject:imgArr];
            }
            self.collectionView.collectionViewLayout =_imgFlowLayout;
            self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,222*((imageArray.count-1)/2+1)+9) ;
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
        }
        isImageServiceReload = YES;
        [self.collectionView reloadData];
        [self.rootScrollView.mj_header endRefreshing];
        [self.rootScrollView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [imageArray removeAllObjects];
        self.collectionView.mj_footer.hidden = YES;
        [self.rootScrollView.mj_header endRefreshing];
        [self.rootScrollView.mj_footer endRefreshing];
        [self.collectionView reloadData];
    }];
}
#pragma mark -- 加载疗养方案
- (void)requestServiceData{
    NSString *urlString = [NSString stringWithFormat:@"page_size=20&page_num=%ld",(long)foodPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kV1_2RecommendSrevice body:urlString success:^(id json) {
        NSInteger total = [[[json objectForKey:@"pager"] objectForKey:@"total"] integerValue];
        NSArray *result = [json objectForKey:@"result"];
        toolArray = [[NSMutableArray alloc] init];
        if (kIsArray(result)) {
            _serviceClickView.hidden = NO;
            for (int i=0; i<result.count; i++) {
                TCServiceModel *serviceModel = [[TCServiceModel alloc] init];
                [serviceModel setValues:result[i]];
                [toolArray addObject:serviceModel];
            }
            self.rootScrollView.mj_footer.hidden=(total -foodPage*20)<=0;
            if (foodPage==1) {
                serviceArray = [[NSMutableArray alloc] init];
                serviceArray = toolArray;
            }else{
                [serviceArray addObjectsFromArray:toolArray];
            }
            self.collectionView.collectionViewLayout =_serviceFlowLayout;
            self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,((kScreenWidth-27)/2+134)*((serviceArray.count-1)/2+1)+5) ;
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
        }
        isPlanServiceReload = YES;
        [self.collectionView reloadData];
        [self.rootScrollView.mj_header endRefreshing];
        [self.rootScrollView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [serviceArray removeAllObjects];
        self.collectionView.mj_footer.hidden = YES;
        [self.rootScrollView.mj_header endRefreshing];
        [self.rootScrollView.mj_footer endRefreshing];
        [self.collectionView reloadData];
    }];
}
#pragma mark -- 加载最新数据
-(void)loadNewServiceData{
    if (reply==1) {
        imagePage =1;
        [self requestImageData];
    } else {
        foodPage =1;
        [self requestServiceData];
    }
}
#pragma mark -- 加载更多数据
-(void)loadMoreServiceData{
    if (reply==1) {
        imagePage++;
        [self requestImageData];
    } else {
        foodPage++;
        [self requestServiceData];
    }
}
#pragma mark -- Event response
#pragma mark 我的服务
-(void)rightButtonAction{
    [MobClick event:@"103_001002"];

    if (isLogin) {
        TCMineServiceViewController *mineVC = [[TCMineServiceViewController alloc] init];
        mineVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mineVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark -- 消息列表
- (void)messageTab{
    if (isLogin) {
        ConversationViewController *conversationVC=[[ConversationViewController alloc] init];
        conversationVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark --ServiceViewGroupDelegate
-(void)ServiceViewGroupActionWithIndex:(NSUInteger)index{

    UIButton *btn;
    for (UIView *view in self.bgServiceClickView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == index+100)) {
            btn = (UIButton*)view;
        }
    }
    [_bgServiceClickView serviceBgChangeViewWithButton:btn];
    for (UIView *view in self.serviceClickView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == index+100)) {
            btn = (UIButton*)view;
        }
    }
    [_serviceClickView serviceBgChangeViewWithButton:btn];
    
    if (index==0) {
        [_collectionView registerClass:[TCImageCollectionViewCell class] forCellWithReuseIdentifier:@"TCImageCollectionViewCell"];
        reply = 1;
        if (!isImageServiceReload) {
            [self requestImageData];
        }else{
            self.collectionView.collectionViewLayout =_imgFlowLayout;
            self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,222*((imageArray.count-1)/2+1)+9) ;
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            self.collectionView.mj_footer.hidden=imageArray.count%20<20;
            [self.collectionView reloadData];
        }
    } else {
        [_collectionView registerClass:[TCServiceCollectCell class] forCellWithReuseIdentifier:@"TCServiceCollectCell"];
        reply = 2;
        if (!isPlanServiceReload) {
            [self requestServiceData];
        }else{
            self.collectionView.collectionViewLayout =_serviceFlowLayout;
            self.collectionView.frame = CGRectMake(0, _serviceClickView.bottom, kScreenWidth,((kScreenWidth-27)/2+134)*((serviceArray.count-1)/2+1)+5) ;
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.collectionView.bottom);
            self.collectionView.mj_footer.hidden=serviceArray.count%20<20;
            [self.collectionView reloadData];
        }
    }

}

#pragma mark --Private methods
#pragma mark  初始化界面
-(void)initSevieceView{
    self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kRootViewHeight-kTabHeight)];
    self.rootScrollView.showsVerticalScrollIndicator=NO;
    self.rootScrollView.delegate = self;
    self.rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:self.rootScrollView];
    
    /****智能咨询和专家咨询****/
    NSArray *arr=[[NSArray alloc] initWithObjects:@{@"icon":@"ic_t_ask_ai",
                                                    @"title":@"智能咨询",
                                                    @"subtitle":@"24小时免费智能咨询"},
                  @{@"icon":@"ic_t_ask_experts",
                    @"title":@"专家咨询",
                    @"subtitle":@"专业人士提供咨询和方案"},nil];
    for (NSInteger i=0; i<arr.count; i++) {
        TCCustomButton *btn=[[TCCustomButton alloc] initWithFrame:CGRectMake(i*kScreenWidth/2, 0, kScreenWidth/2, 160)  info:arr[i]];
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag=i+100;
        [btn addTarget:self action:@selector(connectServiceForButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
    }
    
    [self.rootScrollView addSubview:self.messageView];
    //推荐方案
    
    NSArray *titleArr = @[@"图文咨询",@"营养服务"];
    _serviceClickView = [[TCServiceClickViewGroup alloc] initWithFrame:CGRectZero titles:titleArr color:kbgBtnColor line:YES];
    _serviceClickView.serviceDelegate = self;
    if (self.messageView.hidden==NO) {
        _serviceClickView.frame =CGRectMake(0, self.messageView.bottom, kScreenWidth, 40);
    } else {
        _serviceClickView.frame =CGRectMake(0, 160+2.5, kScreenWidth, 40);
    }
    _serviceClickView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollView addSubview:_serviceClickView];
    [self.rootScrollView addSubview:self.collectionView];
    
    _bgServiceClickView = [[TCServiceClickViewGroup alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 40) titles:titleArr color:kbgBtnColor line:NO];
    _bgServiceClickView.serviceDelegate = self;
    _bgServiceClickView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgServiceClickView];
    _bgServiceClickView.hidden = YES;
}
#pragma mark -- setters or getters
- (UIView *)messageView{
    if (_messageView==nil) {
        _messageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 160+2.5, kScreenWidth, 38)];
        _messageView.backgroundColor = [UIColor whiteColor];
        [_messageView addTarget:self action:@selector(messageTab) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *imgUrl = [NSUserDefaultsInfos getValueforKey:kUserPhoto];
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 6, 27, 27)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
        [_messageView addSubview:imgView];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+9, 9, kScreenWidth-imgView.right-50, 20)];
        messageLabel.text = @"有0条未读的专家消息";
        messageLabel.font = [UIFont systemFontOfSize:15];
        [_messageView addSubview:messageLabel];
        
        image = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, 14, 10, 10)];
        image.backgroundColor = [UIColor colorWithHexString:@"0xff455c"];
        image.layer.cornerRadius = 5;
        [_messageView addSubview:image];
    }
    return _messageView;
}
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        _imgFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _imgFlowLayout.itemSize = CGSizeMake((kScreenWidth-27)/2, 213);
        _imgFlowLayout.minimumLineSpacing = 9;
        _imgFlowLayout.minimumInteritemSpacing = 9;
        _imgFlowLayout.sectionInset = UIEdgeInsetsMake(9, 9, 9, 9);//上左下右
        
        _serviceFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _serviceFlowLayout.itemSize = CGSizeMake((kScreenWidth-27)/2, (kScreenWidth-27)/2+125);
        _serviceFlowLayout.minimumLineSpacing = 9;
        _serviceFlowLayout.minimumInteritemSpacing = 9;
        _serviceFlowLayout.sectionInset = UIEdgeInsetsMake(9, 9, 9, 9);//上左下右
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _serviceClickView.bottom, kScreenWidth, kScreenHeight - _serviceClickView.bottom-kTabHeight) collectionViewLayout:_imgFlowLayout];

        //注册cell和ReusableView（相当于头部）
        [_collectionView registerClass:[TCImageCollectionViewCell class] forCellWithReuseIdentifier:@"TCImageCollectionViewCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

        //设置代理
        _collectionView.scrollEnabled = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //背景颜色
        _collectionView.backgroundColor =[UIColor bgColor_Gray];
        
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewServiceData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        self.rootScrollView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreServiceData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        self.rootScrollView.mj_footer = footer;
        footer.hidden = NO;
    }
    return _collectionView;
}

- (UILabel *)lineLabel{
    if (_lineLabel==nil) {
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageButton.left+35, 38,_imageButton.width-70, 2)];
        _lineLabel.backgroundColor = kbgBtnColor;
    }
    return _lineLabel;
}
@end
