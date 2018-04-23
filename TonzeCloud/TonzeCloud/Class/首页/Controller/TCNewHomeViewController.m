//
//  TCNewHomeViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCNewHomeViewController.h"
#import "ConversationViewController.h"
#import "TCFastLoginViewController.h"
#import "TCRecordSugarViewController.h"
#import "TCFoodLibraryViewController.h"
#import "TCDailyRecipesViewController.h"
#import "TCBasewebViewController.h"
#import "TCArticleLibraryViewController.h"
#import "TCFoodDetailViewController.h"
#import "TCExpertDetailController.h"
#import "TCImageConsultViewController.h"
#import "TCCheckInDailyViewController.h"
#import "TCSugarDataViewController.h"
#import "TCSugarDeviceViewController.h"
#import "TCArticleTableView.h"
#import "TCManagerView.h"
#import "CustomButton.h"
#import "TCBannerModel.h"
#import "TCArticleModel.h"
#import <Hyphenate/Hyphenate.h>
#import "TCSystemNewsModel.h"
#import "TCFamilyBloodModel.h"
#import "HeziBanner.h"
#import "HeziTrigger.h"
#import "HeziSDKManager.h"
#import "ActionSheetView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "TCFirstGroupGuidePage.h"
#import "SDCycleScrollView.h"
#import "TCHealthTestViewController.h"
#import "TCHomeCenterView.h"
#import "TCArticleDetailViewController.h"
#import "HWPopTool.h"
#import "TCHomeCenterModel.h"
#import "TCColumnButton.h"
#import "TCColumnDetailViewController.h"
#import "TCHomeShopView.h"
#import "TCShopViewController.h"
#import "ShopDetailViewController.h"

@interface TCNewHomeViewController ()<TCManagerViewDelegate,TCArticleTableViewDelegate,HeziTriggerActivePageDelegate,SDCycleScrollViewDelegate,TCHomeCenterViewDelegate,TCHwpopDelegate,TCHomeShopViewDelegate>{
    UIImageView         *headImageView;
    UILabel             *greetLabel;
    UILabel             *loginCountLabel;  //登录次数统计
    UIButton            *_checkInBtn; // 签到
    NSMutableArray      *bannersArray;
    NSMutableArray      *activityList;
    NSMutableArray      *recommandArticleArr;  //推荐文章列表
    BOOL                isReceivedNewNotify;  //是否收到信的通知
    NSInteger           articlePage;
    TCBannerModel       *announceBanner;
    
    BOOL               isFirstPop;   //公告栏第一次弹出
    NSArray             *columnArray;  //专栏内容
    
    BOOL     isLogin;
}
/// 图片轮播
@property (nonatomic ,strong) SDCycleScrollView *sdCycleScrollView;
//  红点标记
@property (nonatomic,strong)UILabel              *badgeLbl;
//  根滚动视图
@property (nonatomic,strong)UIScrollView         *rootScrollView;
//  问候
@property (nonatomic,strong)UIView               *greetView;
//  未登录
@property (nonatomic,strong)UIView               *loginGreetView;
//  血糖数据
@property (nonatomic,strong)TCManagerView        *bloodManagerView;
//  工具栏
@property (nonatomic,strong)UIView               *toolView;
//  商城
@property (nonatomic,strong)TCHomeShopView       *homeShopView;
//  设备和方案购买入口
@property (nonatomic,strong)TCHomeCenterView     *programView;
//  专栏
@property (nonatomic,strong)UIScrollView         *columnScrollerView;
//  推荐活动
@property (nonatomic,strong)UIScrollView         *activityScrollView;
//  文章列表
@property (nonatomic,strong)TCArticleTableView  *articleTableView;

@end

@implementation TCNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"首页";
    self.rightImageName=@"h_ic_top_msg_nor";
    
    self.isHiddenBackBtn=YES;
    bannersArray=[[NSMutableArray alloc] init];
    activityList=[[NSMutableArray alloc] init];
    recommandArticleArr=[[NSMutableArray alloc] init];
    articlePage=1;
    
    
    
    [self initNewHomeView];
    [self requestNewHomeData];
    //活动触发
    [self initActitityTriggerView];
    
    //公告
    [self requestAnnouncementData];
}
#pragma mark ====== 引导页遮罩 =======
- (void)initFriendGroupGuidePageView{
    
    BOOL hasShowFirstGuidance=[[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShowFriendGroup"] boolValue];
    if (!hasShowFirstGuidance) {
        TCFirstGroupGuidePage *guidePageView = [[TCFirstGroupGuidePage alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [guidePageView show];
        kSelfWeak;
        guidePageView.nextClickBlock = ^{
            [weakSelf.tabBarController setSelectedIndex:4];
        };
    }
}
#pragma mark ====== 活动触发 =======
- (void)initActitityTriggerView{
    //活动盒子注册触发
    NSString *phone=[NSUserDefaultsInfos getValueforKey:kPhoneNumber];
    if (!kIsEmptyString(phone)) {
        NSDictionary *userInfo=@{@"username":phone,@"mobile":phone};
        [HeziTrigger trigger:@"startup" userInfo:userInfo showIconInView:self.view rootController:self delegate:self];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUnreadDeviceMessage:) name:kOnNotifyWithFlag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementViewBackup) name:kLaunchAdClickNotify object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(announcementViewClickBackup) name:kAnnouncementClickNotify object:nil];
    
    [self.sdCycleScrollView adjustWhenControllerViewWillAppera];
    
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        [self getUnreadMessageCount];
    }

    
    if ([TCHelper sharedTCHelper].isHomeReload) {
        [self requestNewHomeData];
        [TCHelper sharedTCHelper].isHomeReload=NO;
    }
    
    if ([TCHelper sharedTCHelper].isShowAnnouce) {
        [self popAnnouncementView];
        [TCHelper sharedTCHelper].isShowAnnouce=NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004" type:1];
#endif
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004" type:2];
#endif
    
}

#pragma mark -- NSNotification
#pragma mark 获取未读设备消息
-(void)getUnreadDeviceMessage:(NSNotification *)notify{
    NSDictionary *userInfo=notify.userInfo;
    isReceivedNewNotify=[[userInfo valueForKey:@"receiveNewNotify"] boolValue];
    MyLog(@"获取未读设备消息,%@",userInfo);
    self.badgeLbl.hidden=!isReceivedNewNotify;
}

#pragma mark -- Custom Delegate
#pragma mark  TCManagerViewDelegate
#pragma mark  血糖数据和血糖设备
-(void)managerViewDidClickToolButtonForIndex:(NSInteger)index{
#if !DEBUG
    if (index==0) {
        [[TCHelper sharedTCHelper] loginClick:@"004-03"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"004-05"];
    }
#endif

    if (index == 1) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-19"];
#endif
        [MobClick event:@"101_001006"];
        TCSugarDeviceViewController *sugarDeviceVC=[[TCSugarDeviceViewController alloc] init];
        sugarDeviceVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:sugarDeviceVC animated:YES];
    }else{
        if (isLogin) {
            [MobClick event:@"101_001004"];
            TCSugarDataViewController *sugarDataVC=[[TCSugarDataViewController alloc] init];
            sugarDataVC.isHomeIn=YES;
            sugarDataVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:sugarDataVC animated:YES];
        }else{
            [self fastLoginAction];
        }
    }
}

#pragma mark  添加血糖记录
-(void)managerViewAddSugarViewAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-04"];
#endif
    
    if (isLogin) {
        [MobClick event:@"101_001005"];
        TCRecordSugarViewController  *recordSugarVC=[[TCRecordSugarViewController alloc] init];
        recordSugarVC.hidesBottomBarWhenPushed=YES;
        recordSugarVC.isHomeIn=YES;
        [self.navigationController pushViewController:recordSugarVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}

#pragma mark TCArticleTableViewDelegate
#pragma mark 选择文章
-(void)articleTableViewDidSelectedCellWithArticle:(TCArticleModel *)article{
#if !DEBUG
    NSString *eventStr=[NSString stringWithFormat:@"004-09-%ld-%ld",(long)article.classification_id,(long)article.id];
    [[TCHelper sharedTCHelper] loginClick:eventStr];
#endif
    [MobClick event:@"101_001011"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)article.id];
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.type=BaseWebViewTypeArticle;
    webVC.titleText=@"糖士-糖百科";
    webVC.shareTitle = article.title;
    webVC.image_url = article.image_url;
    webVC.urlStr=urlString;
    webVC.articleID = article.id;
    kSelfWeak;
    webVC.backBlock=^(){
        for (TCArticleModel *model in recommandArticleArr) {
            if (model.id==article.id) {
                model.reading_number+=1;
            }
        }
        [weakSelf.articleTableView reloadData];
    };
    webVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:webVC animated:YES];
    
//    TCArticleDetailViewController *articleDetailVC=[[TCArticleDetailViewController alloc] init];
//    articleDetailVC.articleID=article.id;
//    articleDetailVC.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:articleDetailVC animated:YES];
 
}

#pragma mark  HeziTriggerActivePageDelegate
#pragma mark 活动页将要打开，返回NO会拦截。
- (BOOL)heziTriggerWillOpenActivePage:(HeziTrigger *)heziSDK activityURL:(NSString *)url {
    MyLog(@"%s", __FUNCTION__);
    return YES;
}

#pragma mark 活动页已经打开
- (void)heziTriggerDidOpenActivePage:(HeziTrigger *)heziSDK {
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 活动页已经关闭
- (void)heziTriggerDidCloseActivePage:(HeziTrigger *)heziSDK {
    //注意,默认情况下触发的图标点击后不会关闭,需要开发者调用 dismiss 方法
    [heziSDK dismiss];
    [self initFriendGroupGuidePageView];
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 触发失败
- (void)heziTirgger:(HeziTrigger *)trigger triggerError:(NSError *)error {
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 分享
-(void)heziTrigger:(HeziTrigger *)heziSDK share:(HeziShareModel *)shareContent activePage:(UIView *)activePage{
    MyLog(@"title:%@,content:%@,imageUrl:%@,linkUrl:%@,callbackUrl:%@",shareContent.title,shareContent.content,shareContent.imgUrl,shareContent.linkUrl,shareContent.callBackUrl);
    
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
        
        //可选 生成深度链接 第一个参数表示活动原始分享链接 scheme 表示为 app 设置的 url scheme, customerParams表示用户的自定义参数
        NSString *deepUrl = [[HeziSDKManager sharedInstance] buildDeepLinkWithUrl:shareContent.linkUrl  scheme:@"TangShi://" customeParams:@{@"banner":@"share"}];
        
        MyLog(@"深度链接:%@",deepUrl);
        //分享成功后 调用统计分享成功,并且给分享者增加次数
        [[HeziSDKManager sharedInstance] statisticsShareCallBack:shareContent.callBackUrl linkUrl:deepUrl];
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:shareContent.content
                                         images:[NSURL URLWithString:shareContent.imgUrl]
                                            url:[NSURL URLWithString:deepUrl]
                                          title:shareContent.title
                                           type:SSDKContentTypeAuto];
        
        if (btnTag==0) {
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if (btnTag==1){
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if (btnTag==2){
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if(btnTag==3){
            [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else{
            [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",shareContent.title,
                                                     [NSURL URLWithString:shareContent.linkUrl]]
                                             images:shareContent.imgUrl
                                                url:[NSURL URLWithString:shareContent.linkUrl]
                                              title:shareContent.title
                                               type:SSDKContentTypeAuto];
            [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }
        [shareParams SSDKEnableUseClientShare];
        
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}

#pragma mark ====== SDCycleScrollViewDelegate =======
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [self cycleScrollViewDidClickActionWithIndex:index];
}
#pragma mark 轮播图点击事件
-(void)cycleScrollViewDidClickActionWithIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-02:%ld",index+1]];
    [MobClick event:@"101_001003"];
    TCBannerModel *banner=bannersArray[index];
    
    //统计bannar
    NSString *deviceUUID = [[TCHelper sharedTCHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=1&imsi=%@&type_id=%ld",deviceUUID,banner.id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];

    [self showActivityDetailForChooseBanner:banner isAnnouce:NO];
}

#pragma mark TCHomeShopViewDelegate
- (void)homeShopViewDidClickWithTag:(NSInteger)tag Shop_id:(NSInteger)shop_id{

    if (tag==100||tag==101) {
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-21:%ld",shop_id]];
        [MobClick event:tag==100?@"101_001024":@"101_001025"];
        if (shop_id>0) {
            ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
            shopDetailVC.hidesBottomBarWhenPushed = YES;
            shopDetailVC.product_id = shop_id;
            [self.navigationController pushViewController:shopDetailVC animated:YES];
        }
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"004-23"];
        [MobClick event:@"101_001026"];
        TCShopViewController *shopVC = [[TCShopViewController alloc] init];
        shopVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:shopVC animated:YES];
    }
}

#pragma mark TCHomeCenterViewDelegate
-(void)homeCenterViewDidClickWithTag:(NSInteger)tag{

    NSString *eventID=tag==102?@"101_001018":@"101_001019";
    [MobClick event:eventID];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:tag==102?@"004-15":@"004-16"];
#endif
    [TCHelper sharedTCHelper].selIndex=tag;
    self.tabBarController.selectedIndex=3;
}

#pragma mark -- NSNotification
-(void)announcementViewBackup{
    [TCHelper sharedTCHelper].isShowAnnouce=YES;
    [[HWPopTool sharedInstance] closeAnimation:NO WithBlcok:^{
    
    }];
}
// 公告点击关闭消息处理
- (void)announcementViewClickBackup{
    kSelfWeak;
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        [weakSelf initFriendGroupGuidePageView];
    }];
}
#pragma mark -- Event Response
#pragma mark 导航栏右侧按钮
-(void)rightButtonAction{
    if (isLogin) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-01"];
#endif
        [MobClick event:@"101_001002"];
        ConversationViewController *conversationVC=[[ConversationViewController alloc] init];
        conversationVC.hidesBottomBarWhenPushed=YES;
        conversationVC.hasNewDeviceMessage=isReceivedNewNotify;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}

#pragma mark ====== 签到 =======
- (void)checkInClick{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-10"];
#endif
    
    [MobClick event:@"101_001013"];
    TCCheckInDailyViewController *checkInDailyVC = [TCCheckInDailyViewController new];
    checkInDailyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkInDailyVC animated:YES];
}

#pragma mark 工具栏
-(void)toolDidSelectForCustomButton:(CustomButton *)sender{
    if (sender.tag==0) {  //健康自测
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-11"];
#endif
        [MobClick event:@"101_001014"];
        TCHealthTestViewController *headthTestVC = [[TCHealthTestViewController alloc] init];
        headthTestVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:headthTestVC animated:YES];
    }else if (sender.tag==1){ //食物库
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-06"];
#endif
        [MobClick event:@"101_001007"];
        TCFoodLibraryViewController *foodLibraryVC=[[TCFoodLibraryViewController alloc] init];
        foodLibraryVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:foodLibraryVC animated:YES];
    }else if (sender.tag==2){ //每日菜谱
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-07"];
#endif
        [MobClick event:@"101_001008"];
        TCDailyRecipesViewController *recipesVC=[[TCDailyRecipesViewController alloc] init];
        recipesVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:recipesVC animated:YES];
    }else if (sender.tag==3){  //糖百科
        [MobClick event:@"101_001015"];
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-12"];
#endif
        TCArticleLibraryViewController *articleLibraryVC=[[TCArticleLibraryViewController alloc] init];
        articleLibraryVC.hidesBottomBarWhenPushed=YES;
        
        kSelfWeak;
        articleLibraryVC.articleBackBlock=^(NSInteger id,NSInteger read_numer){
            for (TCArticleModel *model in recommandArticleArr) {
                if (model.id==id) {
                    model.reading_number=read_numer;
                }
            }
            [weakSelf.articleTableView reloadData];
        };
        
        [self.navigationController pushViewController:articleLibraryVC animated:YES];
    }
}

#pragma mark 选择推荐方案
-(void)didSelectedActivityForButton:(UIButton *)sender{
    [MobClick event:@"101_001020"];
    TCBannerModel *banner=activityList[sender.tag-100];
    NSString *deviceUUID = [[TCHelper sharedTCHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=2&imsi=%@&type_id=%ld",deviceUUID,(long)banner.id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {

    }];
    [self showActivityDetailForChooseBanner:banner isAnnouce:NO];
}

#pragma mark 公告详情
- (void)getMoreAnnounceDetail:(UIButton *)sender{
    
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-18-02:%ld",(long)announceBanner.id]];
#endif
    [MobClick event:@"101_001022"];
    //统计bannar
    NSString *deviceUUID = [[TCHelper sharedTCHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=4&imsi=%@&type_id=%ld",deviceUUID,(long)announceBanner.id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {

    }];
    
    
    
    kSelfWeak;
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        [weakSelf showActivityDetailForChooseBanner:announceBanner isAnnouce:YES];
    }];
}

#pragma mark -- Private Methods
#pragma mark 初始化首页视图
-(void)initNewHomeView{
    [self.view addSubview:self.badgeLbl];
    self.badgeLbl.hidden=YES;
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.sdCycleScrollView];
    [self.rootScrollView addSubview:self.greetView];
    [self.rootScrollView addSubview:self.loginGreetView];
    [self.rootScrollView addSubview:self.bloodManagerView];
    [self.rootScrollView addSubview:self.toolView];
    [self.rootScrollView addSubview:self.homeShopView];
    [self.rootScrollView addSubview:self.programView];
    [self.rootScrollView addSubview:self.columnScrollerView];
    [self.rootScrollView addSubview:self.activityScrollView];
    [self.rootScrollView addSubview:self.articleTableView];
    
    self.articleTableView.frame=CGRectMake(0, self.activityScrollView.bottom+10, kScreenWidth,40);
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.articleTableView.top+self.articleTableView.height+64);
}
#pragma mark 下拉刷新
-(void)loadNewHomeAllData{
    [MobClick event:@"101_001012"];
    articlePage=1;
    [self requestNewHomeData];
}

#pragma mark 上拉加载更多推荐文章
-(void)loadMoreArticleListData{
    articlePage++;
    kSelfWeak;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)articlePage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kRecommandArticleList body:body success:^(id json) {
        NSArray *arr=[json objectForKey:@"result"];
        NSMutableArray *tempArticleArr=[[NSMutableArray alloc] init];
        if (kIsArray(arr)) {
            for (NSDictionary *dict in arr) {
                TCArticleModel *article=[[TCArticleModel alloc] init];
                [article setValues:dict];
                [tempArticleArr addObject:article];
            }
        }
        [recommandArticleArr addObjectsFromArray:tempArticleArr];
        weakSelf.articleTableView.articlesArray=recommandArticleArr;
        [weakSelf.articleTableView reloadData];
        weakSelf.articleTableView.frame=CGRectMake(0, self.activityScrollView.bottom+10, kScreenWidth, recommandArticleArr.count*100+40);
        weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, weakSelf.articleTableView.top+weakSelf.articleTableView.height);
        weakSelf.rootScrollView.mj_footer.hidden=tempArticleArr.count<20;
        [weakSelf.rootScrollView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.rootScrollView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 获取最新数据
-(void)requestNewHomeData{
    __weak typeof(self) weakSelf=self;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kHomeIndex body:nil success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            //轮播图
            NSArray *bannerList=[result valueForKey:@"bannerList"];
            NSMutableArray *bannerImgArray = [NSMutableArray array];
            if (kIsArray(bannerList) && bannerList.count > 0) {
                NSMutableArray *bannerTempArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in bannerList) {
                    TCBannerModel *banner=[[TCBannerModel alloc] init];
                    [banner setValues:dict];
                    [bannerTempArr addObject:banner];
                    [bannerImgArray addObject:banner.image_url];
                }
                bannersArray=bannerTempArr;
                weakSelf.sdCycleScrollView.imageURLStringsGroup = bannerImgArray;
            }
            //问候语
            NSDictionary *greetDict=[result valueForKey:@"welcomeWords"];
            
            if (isLogin) {
                weakSelf.loginGreetView.hidden = YES;
                if (kIsDictionary(greetDict)&&greetDict.count>0) {
                    weakSelf.greetView.hidden=NO;
                    [headImageView sd_setImageWithURL:[NSURL URLWithString:greetDict[@"photo"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
                    greetLabel.text=greetDict[@"words"];
                    loginCountLabel.text=[NSString stringWithFormat:@"这是您在糖士的第%@天",greetDict[@"login_num"]];
                    weakSelf.greetView.frame=CGRectMake(0,weakSelf.sdCycleScrollView.bottom, kScreenWidth, 70);
                }else{
                    weakSelf.greetView.hidden=YES;
                    weakSelf.greetView.frame=CGRectMake(0,weakSelf.sdCycleScrollView.bottom, kScreenWidth,0);
                }
            } else {
                weakSelf.loginGreetView.hidden = NO;
                weakSelf.greetView.hidden = YES;
                weakSelf.greetView.frame=CGRectMake(0,weakSelf.sdCycleScrollView.bottom, kScreenWidth,70);
                weakSelf.loginGreetView.frame =CGRectMake(0,weakSelf.sdCycleScrollView.bottom, kScreenWidth, 70);
            }
            
            // 是否签到
            BOOL signStatus = [[result valueForKey:@"sign_status"] boolValue];
            if (signStatus) {
                [_checkInBtn setTitle:@"已签到" forState:UIControlStateNormal];
                _checkInBtn.backgroundColor=[UIColor lightGrayColor];
            }else{
                [_checkInBtn setTitle:@"签到送积分" forState:UIControlStateNormal];
                _checkInBtn.backgroundColor=kSystemColor;
            }
            
            weakSelf.bloodManagerView.frame=CGRectMake(0, weakSelf.greetView.bottom+10, kScreenWidth, 160);
            weakSelf.toolView.frame=CGRectMake(0, weakSelf.bloodManagerView.bottom+10, kScreenWidth, 94);
            weakSelf.homeShopView.frame = CGRectMake(0, weakSelf.toolView.bottom+10, kScreenWidth, kScreenWidth/2+41);
            weakSelf.programView.frame=CGRectMake(0, weakSelf.homeShopView.bottom+10, kScreenWidth, 90);
            
            //健康自测  食物库  每日菜谱  糖百科
            NSDictionary *iconDict = [result objectForKey:@"icon"];
            NSArray *imgArr = @[@"zice_imageid",@"swk_imageid",@"cook_imageid",@"tangbk_imageid"];
            NSArray *toolArr=@[@"健康自测",@"食物库",@"每日菜谱",@"糖百科"];
            
            for (UIView *toolViews in weakSelf.toolView.subviews) {
                if ([toolViews isKindOfClass:[CustomButton class]]) {
                    [toolViews removeFromSuperview];
                }
            }
            for (NSInteger i=0;i<toolArr.count;i++) {
                CustomButton *btn=[[CustomButton alloc] initWithFrame:CGRectMake(i*kScreenWidth/4, 0, kScreenWidth/4, 94)];
                btn.iconImage =[iconDict objectForKey:imgArr[i]];
                btn.tag=i;
                btn.titleStr = toolArr[i];
                [btn addTarget:self action:@selector(toolDidSelectForCustomButton:) forControlEvents:UIControlEventTouchUpInside];
                [weakSelf.toolView addSubview:btn];
            }
            
            //商城
            NSDictionary *shopDict = [result objectForKey:@"shopCofig"];
            if (kIsDictionary(shopDict)) {
                [weakSelf.homeShopView homeShopData:shopDict];
            }
            
            //业务区  电商位  图文咨询位 营养服务位
            NSArray *positionListArr = [result objectForKey:@"businessPositionList"];
            if (kIsArray(positionListArr)&&positionListArr.count>0) {
                [weakSelf.programView homeCenterData:positionListArr];
            }

            //专栏
            columnArray = [result objectForKey:@"special_column"];
            if (kIsArray(columnArray)&&columnArray.count>0) {
                CGFloat width = 0.0;
                for (int i=0; i<columnArray.count; i++) {
                    
                    TCColumnButton *columnBtn = [[TCColumnButton alloc] initWithFrame:CGRectMake(i*kScreenWidth/3*2+10*(i+1), 10, kScreenWidth/375*250,kScreenWidth/375*130)];
                    [columnBtn columnBtnDict:columnArray[i]];
                    columnBtn.tag = i+100;
                    [columnBtn addTarget:self action:@selector(columnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                    [weakSelf.columnScrollerView addSubview:columnBtn];
                    width =(i+1)*(kScreenWidth/375*250+10);
                }
                weakSelf.columnScrollerView.frame = CGRectMake(0, weakSelf.programView.bottom+10, kScreenWidth, kScreenWidth/375*130+20);
                weakSelf.columnScrollerView.contentSize = CGSizeMake(width+10,  kScreenWidth/375*130);
            } else {
                weakSelf.columnScrollerView.frame = CGRectMake(0, weakSelf.programView.bottom, kScreenWidth, 0);
            }
            
            
            //推荐活动
            NSArray *proList=[result valueForKey:@"activityList"];
            if (kIsArray(proList)&&proList.count>0) {
                NSMutableArray *tempActivityArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0;i<proList.count;i++) {
                    NSDictionary *dict=proList[i];
                    TCBannerModel *banner=[[TCBannerModel alloc] init];
                    [banner setValues:dict];
                    [tempActivityArr addObject:banner];
                    
                    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0,kScreenWidth/750*240*i, kScreenWidth, kScreenWidth/750*240)];
                    btn.tag=100+i;
                    [btn sd_setImageWithURL:[NSURL URLWithString:banner.image_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
                    [btn addTarget:self action:@selector(didSelectedActivityForButton:) forControlEvents:UIControlEventTouchUpInside];
                    [weakSelf.activityScrollView addSubview:btn];
                }
                activityList=tempActivityArr;
                weakSelf.activityScrollView.frame=CGRectMake(0, weakSelf.columnScrollerView.bottom+10, kScreenWidth, kScreenWidth/750*240*activityList.count);
            }else{
                weakSelf.activityScrollView.frame=CGRectMake(0, weakSelf.columnScrollerView.bottom, kScreenWidth,0);
            }
            
            //文章列表
            NSArray  *articleList=[result valueForKey:@"articleList"];
            NSMutableArray *tempArticleArr=[[NSMutableArray alloc] init];
            if (kIsArray(articleList)) {
                for (NSDictionary *dict in articleList) {
                    TCArticleModel *article=[[TCArticleModel alloc] init];
                    [article setValues:dict];
                    [tempArticleArr addObject:article];
                }
            }
            recommandArticleArr=tempArticleArr;
            weakSelf.articleTableView.articlesArray=tempArticleArr;
            [weakSelf.articleTableView reloadData];
            weakSelf.articleTableView.frame=CGRectMake(0, self.activityScrollView.bottom+10, kScreenWidth, tempArticleArr.count*100+40);
            weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, weakSelf.articleTableView.top+weakSelf.articleTableView.height);
            weakSelf.rootScrollView.mj_footer.hidden=tempArticleArr.count<20;
        }
        [weakSelf.rootScrollView.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.rootScrollView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 获取系统消息未读数
-(void)getUnreadMessageCount{
    __weak typeof(self) weakSelf=self;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kMessageUnread body:nil success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            BOOL newsIsRead=[[result valueForKey:@"index_poi"] boolValue];
            BOOL articleCommentIsRead=[[result valueForKey:@"article_poi"] boolValue];
            
            //获取会话未读消息数
            NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
            NSInteger unreadCount = 0;
            for (EMConversation *conversation in conversations) {
                unreadCount += conversation.unreadMessagesCount;
            }
            
            MyLog(@"homeGetUnreadMessage --未读会话消息数:%ld",(long)unreadCount);
            
            if (unreadCount>0) {    //有会话时
                weakSelf.badgeLbl.hidden=NO;
                if (unreadCount>99) {
                    weakSelf.badgeLbl.frame=CGRectMake(kScreenWidth-22, 24,20, 16);
                    weakSelf.badgeLbl.layer.cornerRadius=8;
                    weakSelf.badgeLbl.text=@"99+";
                }else{
                    weakSelf.badgeLbl.frame=CGRectMake(kScreenWidth-22, 24,16, 16);
                    weakSelf.badgeLbl.layer.cornerRadius=8;
                    weakSelf.badgeLbl.text=[NSString stringWithFormat:@"%ld",(long)unreadCount];
                }
            }else{   //没有会话时
                weakSelf.badgeLbl.hidden=newsIsRead||articleCommentIsRead;
                weakSelf.badgeLbl.frame=CGRectMake(kScreenWidth-22, 30, 8, 8);
                weakSelf.badgeLbl.layer.cornerRadius=4;
                weakSelf.badgeLbl.text=@"";
            }
        }
    } failure:^(NSString *errorStr) {
        weakSelf.badgeLbl.hidden=YES;
    }];
}

#pragma mark 加载公告信息
- (void)requestAnnouncementData{
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kAdIndexUrl body:@"type=3" success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        if(kIsDictionary(dict)&&dict.count>0){
            announceBanner=[[TCBannerModel alloc] init];
            [announceBanner setValues:dict];
            
            NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDate];
            NSInteger popNum= [[NSUserDefaultsInfos getValueforKey:currentDateStr] integerValue];
            MyLog(@"弹出公告栏次数：%ld",(long)popNum);
            if ([announceBanner.num integerValue]>popNum) {
                if (!isFirstPop) {
                    popNum++;
                    [NSUserDefaultsInfos putKey:currentDateStr andValue:[NSNumber numberWithInteger:popNum]];
                }
                [weakSelf popAnnouncementView];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark 弹出公告
- (void)popAnnouncementView{
    
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor=[UIColor whiteColor];
    contentView.layer.cornerRadius=5;
    contentView.clipsToBounds=YES;
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-80, kScreenWidth-80)];
    [imgView sd_setImageWithURL:[NSURL URLWithString:announceBanner.image_url] placeholderImage:[UIImage imageNamed:@""]];
    [contentView addSubview:imgView];
    
    UILabel *contentLbl=[[UILabel alloc] initWithFrame:CGRectZero];
    contentLbl.textColor=[UIColor grayColor];
    contentLbl.textAlignment=NSTextAlignmentCenter;
    contentLbl.numberOfLines=0;
    contentLbl.text=announceBanner.desc_info;
    CGFloat contentH=[contentLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-110, kRootViewHeight) withTextFont:contentLbl.font].height;
    contentLbl.frame=CGRectMake(15, imgView.bottom+10, kScreenWidth-110, contentH);
    [contentView addSubview:contentLbl];
    
    UIButton  *detailBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-80-150)/2, contentLbl.bottom+10, 150, 35)];
    [detailBtn setTitle:announceBanner.btn_name forState:UIControlStateNormal];
    [detailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    detailBtn.backgroundColor=kSystemColor;
    [detailBtn addTarget:self action:@selector(getMoreAnnounceDetail:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:detailBtn];
    
    contentView.frame=CGRectMake(0, 0, kScreenWidth-80, detailBtn.bottom+20);
    
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeBottom;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}

#pragma mark  分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)index{
    if (index==1) {
        [KEY_WINDOW makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
    }else if (index==2){
        [KEY_WINDOW makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else if(index==3){
        [KEY_WINDOW makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark 选择专栏
-(void)columnBtnAction:(UIButton *)button{
    [MobClick event:@"101_001023"];
    [[TCHelper sharedTCHelper] loginClick:@"004-20"];
    NSDictionary *columnDict = columnArray[button.tag-100];
    TCColumnDetailViewController *columnDteailVC = [[TCColumnDetailViewController alloc] init];
    columnDteailVC.hidesBottomBarWhenPushed = YES;
    columnDteailVC.titleStr = [columnDict objectForKey:@"name"];
    columnDteailVC.column_id = [[columnDict objectForKey:@"column_id"] integerValue];
    [self.navigationController pushViewController:columnDteailVC animated:YES];
}
#pragma mark 选择活动对应事件
-(void)showActivityDetailForChooseBanner:(TCBannerModel *)banner isAnnouce:(BOOL)isAnnouce{
    [[TCHelper sharedTCHelper] loginClick:@"004-17"];
    
    BOOL isNeedLogin=[banner.login_limit boolValue];
    
    BOOL flag=NO;
    if (isNeedLogin&&isAnnouce) {
        flag=isLogin;
    }else{
        flag=YES;
    }
    
    switch (banner.type) {
        case 1: //url外部跳转
        {
            NSString *tmall_url=banner.info;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[tmall_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [self initFriendGroupGuidePageView];
        }
            break;
        case 2: //文章
        {
            NSString *urlString = [NSString stringWithFormat:@"%@article/%@",kWebUrl,banner.info];
            TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
            webVC.isNeedLogin=flag;
            webVC.type=BaseWebViewTypeArticle;
            kSelfWeak;
            webVC.leftActionBlock = ^{
                [weakSelf initFriendGroupGuidePageView];
            };
            webVC.titleText=@"糖士-糖百科";
            webVC.shareTitle = banner.name;
            webVC.image_url = banner.image_url;
            webVC.urlStr=urlString;
            webVC.articleID = [banner.info integerValue];
            webVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        case 3: //食物
        {
            TCFoodDetailViewController *foodDetailVC=[[TCFoodDetailViewController alloc] init];
            kSelfWeak;
            foodDetailVC.leftActionBlock = ^{
                [weakSelf initFriendGroupGuidePageView];
            };
            foodDetailVC.food_id=[banner.info integerValue];
            foodDetailVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:foodDetailVC animated:YES];
        }
            break;
        case 4: //专家
        {
            TCExpertDetailController *expertVC=[[TCExpertDetailController alloc] init];
            expertVC.isNeedLogin=flag;
            expertVC.expert_id=[banner.info integerValue];
            expertVC.hidesBottomBarWhenPushed=YES;
            kSelfWeak;
            expertVC.leftActionBlock = ^{
                [weakSelf initFriendGroupGuidePageView];
            };
            [self.navigationController pushViewController:expertVC animated:YES];
        }
            break;
        case 5: //活动盒子
        {
            if (flag) {
                NSString *phone=[NSUserDefaultsInfos getValueforKey:kPhoneNumber];
                NSDictionary *userInfo=@{@"username":phone,@"mobile":phone};
                [HeziTrigger trigger:banner.info userInfo:userInfo showIconInView:self.view rootController:self delegate:self];
            }else{
                [self fastLoginAction];
            }
        }
            break;
        case 6: //url内部链接
        {
            TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
            webVC.isNeedLogin=flag;
            webVC.type=BaseWebViewTypeDefault;
            webVC.titleText=banner.name;
            webVC.urlStr=banner.info;
            kSelfWeak;
            webVC.leftActionBlock = ^{
                [weakSelf initFriendGroupGuidePageView];
            };
            webVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        default:
            break;
    }
    
    
    if (flag) {
        
    }else{
       [self fastLoginAction];
    }
}

#pragma mark -- Setters and Getters
#pragma mark 红色标记
-(UILabel *)badgeLbl{
    if (_badgeLbl==nil) {
        _badgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-22, 30, 8, 8)];
        _badgeLbl.backgroundColor=[UIColor redColor];
        _badgeLbl.layer.cornerRadius=4;
        _badgeLbl.clipsToBounds=YES;
        _badgeLbl.textColor=[UIColor whiteColor];
        _badgeLbl.textAlignment=NSTextAlignmentCenter;
        _badgeLbl.font=[UIFont systemFontOfSize:10];
    }
    return _badgeLbl;
}

#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kNewNavHeight - kTabHeight)];
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewHomeAllData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _rootScrollView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreArticleListData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _rootScrollView.mj_footer = footer;
        footer.hidden=YES;
        
    }
    return _rootScrollView;
}

#pragma mark 轮播图
- (SDCycleScrollView *)sdCycleScrollView{
    if (!_sdCycleScrollView) {
        _sdCycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 128 * kScreenWidth/320) delegate:self placeholderImage:[UIImage imageNamed:@"ic_h_banner_nor"]];
        _sdCycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        _sdCycleScrollView.autoScrollTimeInterval = 4;
        _sdCycleScrollView.currentPageDotColor = kSystemColor;
        _sdCycleScrollView.pageDotColor = [UIColor whiteColor];
    }
    return _sdCycleScrollView;
}

#pragma mark 问候语
-(UIView *)greetView{
    if (_greetView==nil) {
        _greetView=[[UIView alloc] initWithFrame:CGRectMake(0, self.sdCycleScrollView.bottom+10, kScreenWidth, 0)];
        _greetView.backgroundColor=[UIColor whiteColor];
        
        headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10,15, 40, 40)];
        headImageView.layer.cornerRadius=20;
        headImageView.clipsToBounds=YES;
        [_greetView addSubview:headImageView];
        
        greetLabel=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10,15, kScreenWidth-headImageView.right-90, 20)];
        greetLabel.font=[UIFont systemFontOfSize:15];
        greetLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        [_greetView addSubview:greetLabel];
        
        loginCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, greetLabel.bottom, kScreenWidth-headImageView.right-20, 20)];
        loginCountLabel.font=[UIFont systemFontOfSize:13];
        loginCountLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        [_greetView addSubview:loginCountLabel];
        
        
        _checkInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkInBtn.frame = CGRectMake(kScreenWidth - 110, 20,100, 30);
        [_checkInBtn setTitle:@"签到送积分" forState:UIControlStateNormal];
        [_checkInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _checkInBtn.backgroundColor=kSystemColor;
        _checkInBtn.layer.cornerRadius=15;
        _checkInBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        _checkInBtn.clipsToBounds=YES;
        [_checkInBtn addTarget:self action:@selector(checkInClick) forControlEvents:UIControlEventTouchUpInside];
        [_greetView addSubview:_checkInBtn];
    }
    return _greetView;
}
#pragma mark 登陆问候语
-(UIView *)loginGreetView{
    if (_loginGreetView==nil) {
        _loginGreetView=[[UIView alloc] initWithFrame:CGRectMake(0, self.sdCycleScrollView.bottom+10, kScreenWidth, 0)];
        _loginGreetView.backgroundColor=[UIColor whiteColor];
        
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(20,25, kScreenWidth-110, 20)];
        textLabel.font=[UIFont systemFontOfSize:15];
        textLabel.text = @"登录糖士，开启您的控糖之旅";
        textLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        [_loginGreetView addSubview:textLabel];
        
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(kScreenWidth - 90, 20,80, 30);
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.backgroundColor=kSystemColor;
        loginButton.layer.cornerRadius=15;
        loginButton.titleLabel.font=[UIFont systemFontOfSize:14];
        loginButton.clipsToBounds=YES;
        [loginButton addTarget:self action:@selector(fastLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginGreetView addSubview:loginButton];
    }
    return _loginGreetView;
}
#pragma mark 血糖管理
-(TCManagerView *)bloodManagerView{
    if (_bloodManagerView==nil) {
        _bloodManagerView=[[TCManagerView alloc] initWithFrame:CGRectMake(0, self.greetView.bottom+10, kScreenWidth, 160)];
        _bloodManagerView.delegate=self;
        _bloodManagerView.periodString=[[TCHelper sharedTCHelper] getInPeriodOfCurrentTime];
    }
    return _bloodManagerView;
}

#pragma mark 工具栏（食物库和美日菜谱）
-(UIView *)toolView{
    if (!_toolView) {
        _toolView=[[UIView alloc] initWithFrame:CGRectMake(0, self.bloodManagerView.bottom+10, kScreenWidth, 94)];
        _toolView.backgroundColor=[UIColor whiteColor];
    }
    return _toolView;
}
#pragma mark 商城
- (TCHomeShopView *)homeShopView{
    if (!_homeShopView) {
        _homeShopView = [[TCHomeShopView alloc] initWithFrame:CGRectMake(0, self.toolView.bottom+10, kScreenWidth, kScreenWidth/2+41)];
        _homeShopView.delegate = self;
    }
    return _homeShopView;
}


#pragma mark 设备和方案
-(TCHomeCenterView *)programView{
    if(!_programView){
        _programView=[[TCHomeCenterView alloc] initWithFrame:CGRectMake(0, self.homeShopView.bottom+10, kScreenWidth, 90)];
        _programView.delegate=self;
    }
    return _programView;
}
#pragma mark -- 专栏
- (UIScrollView *)columnScrollerView{
    if (!_columnScrollerView) {
        _columnScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.programView.bottom, kScreenWidth, 0)];
        _columnScrollerView.backgroundColor = [UIColor whiteColor];
    }
    return _columnScrollerView;
}
#pragma mark 推荐活动
-(UIScrollView *)activityScrollView{
    if (!_activityScrollView) {
        _activityScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.programView.bottom, kScreenWidth, 0)];
        _activityScrollView.backgroundColor=[UIColor whiteColor];
    }
    return _activityScrollView;
}

#pragma mark 文章列表
-(TCArticleTableView *)articleTableView{
    if (!_articleTableView) {
        _articleTableView=[[TCArticleTableView alloc] initWithFrame:CGRectMake(0, self.activityScrollView.bottom+10, kScreenWidth, 200) style:UITableViewStylePlain];
        _articleTableView.scrollEnabled=NO;
        _articleTableView.articleDetagate=self;
        _articleTableView.type=0;
    }
    return _articleTableView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLaunchAdClickNotify object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnNotifyWithFlag object:nil];
}


@end
