//
//  TCBasewebViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBasewebViewController.h"
#import "SVProgressHUD.h"
#import "ActionSheetView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import <WebKit/WebKit.h>
#import "TCMyDynamicViewController.h"
#import "TCFastLoginViewController.h"
#import "IQKeyboardManager.h"
#import "TCNoInputAccessoryView.h"

@interface TCBasewebViewController ()<WKUIDelegate,WKNavigationDelegate>{
    UIImageView    *shareImageView;
    BOOL            _isLogin;
}
@property (nonatomic, strong) WKWebView  *rootWebView;
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UILabel *menuNavLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation TCBasewebViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isLogin = [[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    [IQKeyboardManager sharedManager].enableAutoToolbar =NO;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self.baseTitle isEqualToString:@"糖士用户协议"]) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"003-10-06" type:1];
#endif
    }
    if (self.articleID==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-10-04" type:1];
#endif
    }else if (self.articleIndex==1){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-11-04" type:1];
#endif
        
    }else if (self.articleIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-09-04" type:1];
#endif
        
    }else if (self.articleIndex==3){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-12-04" type:1];
#endif
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //关闭键盘事件相应
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
    
    if ([self.baseTitle isEqualToString:@"糖士用户协议"]) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"003-10-06" type:2];
#endif
    }
    if (self.articleIndex==0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-10-04" type:2];
#endif
        
    }else if (self.articleIndex==1){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-11-04" type:2];
#endif
        
    }else if (self.articleIndex==2){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-09-04" type:2];
#endif
        
    }else if (self.articleIndex==3){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginAction:@"004-12-04" type:2];
#endif
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=self.titleText;
    
    shareImageView = [[UIImageView alloc] init];
    if (kIsEmptyString(self.image_url)) {
        shareImageView.image=[UIImage imageNamed:@"img_bg_title"];
    }else{
       [shareImageView sd_setImageWithURL:[NSURL URLWithString:self.image_url] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    }
    [self.view addSubview:self.rootWebView];
    
    TCNoInputAccessoryView *noInputAccessoryView = [TCNoInputAccessoryView new];
    [noInputAccessoryView removeInputAccessoryViewFromWKWebView:_rootWebView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.progressTintColor = UIColorFromRGB(0xfff100);
    //设置进度条的高度
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    //添加KVO，监听WKWebView加载进度
    [self.rootWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self requestWebView];
    [self lookCollectionArticle];
    
    if (self.type==BaseWebViewTypeArticle||self.type==BaseWebViewTypeNewsArticle) {
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        [self getTaskPointsWithActionType:12 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
            
        }]; // 获取积分
    }
    
    
    if (!kIsLogined &&self.isNeedLogin) {
        [self fastLoginAction];
    }
    
}
- (void)leftButtonAction{
    if (self.leftActionBlock) {
        self.leftActionBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 收藏
- (void)rightButtonAction{
    if (_isLogin) {
        NSString *body = [NSString stringWithFormat:@"id=%ld",self.articleID];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:articlemanagement body:body success:^(id json) {
            NSInteger is_collection = [[json objectForKey:@"is_collection"] integerValue];
            self.rightImageName = is_collection==1?@"ic_top_collect_on":@"ic_top_collect_un";
            [self.view makeToast:is_collection==1?@"收藏成功":@"已取消收藏" duration:1.0 position:CSToastPositionCenter];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    } else {
        [self fastLoginAction];
    }
}
#pragma mark - 监听web加载进度
// 在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.rootWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - WKWKNavigationDelegate Methods
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    //加载完成后隐藏progressView
    if (self.isSystemNewsIn) {
        if (self.backBlock) {
            self.backBlock();
        }
    }
    if (self.type==BaseWebViewTypeArticle||self.type==BaseWebViewTypeNewsArticle) {
        if (self.backBlock) {
            self.backBlock();
        }
    }
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    if (self.type == BaseWebViewTypeArticle||self.type==BaseWebViewTypeNewsArticle) {
        [self handleCustomAction:URL];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
#pragma mark -- Private Methods
#pragma mark -----  js事件处理 -------
- (void)handleCustomAction:(NSURL *)URL{
    NSString    *scheme = [URL absoluteString];
    NSArray     *urlArray = [scheme componentsSeparatedByString:@"?"];
    NSString    *urlTag = urlArray[1];
    NSArray     *shareArr = [urlTag componentsSeparatedByString:@"&"];
    NSString    *shareTag = shareArr[0];
    NSString    *typeStr = [urlTag substringWithRange:NSMakeRange(0, 4)];
    NSString    *artStr = [urlTag substringWithRange:NSMakeRange(0, 5)];
    
    if ([shareTag isEqualToString:@"share=1"]) {
        // 分享
        NSString *shareStr =shareArr[1];
        NSArray  *titleArr = [shareStr componentsSeparatedByString:@"="];
        NSString *titleStr = [titleArr[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
        [self shareAction:titleStr];
    }else if([typeStr isEqualToString:@"type"]){
        // 点击人或者头像
        if (_isLogin) {
            NSArray *dataArray =[urlTag componentsSeparatedByString:@"&"];
            NSString    *role_type =[dataArray[0] substringFromIndex:5];
            NSString    *useIdStr = [dataArray[1] substringFromIndex:7];
            TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
            userInfoVC.news_id = [useIdStr integerValue];
            userInfoVC.role_type_ed = [role_type integerValue];
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }else{
            [self fastLoginAction];
        }
    }else if ([urlTag isEqualToString:@"keyboard=1"]){
        // 键盘事件
        if (!_isLogin) {
            TCFastLoginViewController *loginVC = [[TCFastLoginViewController alloc] init];
            kSelfWeak;
            loginVC.loginSuccess = ^{
                [weakSelf requestWebView];
            };
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }else if ([artStr isEqualToString:@"artId"]){
        NSArray     *artArray = [urlTag componentsSeparatedByString:@"&"]; 
        NSString    *artID = [artArray[0] substringFromIndex:6];
        NSString    *imgUrl = [artArray[1] substringFromIndex:7];
//        NSString    *classifyId =[artArray[2] substringFromIndex:11];
        NSString    *titleStr =[[artArray[3] substringFromIndex:9]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
        webVC.type=BaseWebViewTypeArticle;
        webVC.titleText=@"糖士-糖百科";
        webVC.shareTitle = titleStr;
        webVC.image_url = imgUrl;
        webVC.articleID = [artID integerValue];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
-(void)requestWebView{
    if (_type == BaseWebViewTypeArticle||_type==BaseWebViewTypeNewsArticle) {
        // App版本信息
        NSString *version = [NSString getAppVersion];
        // 设备型号
        NSString *systemName = [UIDevice getSystemName];
        // 系统版本
        NSString *systemVersion = [UIDevice getSystemVersion];
        NSString *userKey=[NSUserDefaultsInfos getValueforKey:kUserKey];      //用户Key
        _isLogin = kIsEmptyString(userKey) ? NO : YES;
        NSString *url =_type==BaseWebViewTypeArticle?[NSString stringWithFormat:@"%@?key=%@&artId=%ld&type=0&appVersion=%@&systemName=%@&systemVersion=%@",kWebUrl,userKey,(long)_articleID,version,systemName,systemVersion]:[NSString stringWithFormat:@"%@?key=%@&artId=%ld&type=0&appVersion=%@&systemName=%@&systemVersion=%@&message_id=%ld&message_user_id=%ld",kWebUrl,userKey,(long)_articleID,version,systemName,systemVersion,(long)self.message_id,(long)self.message_user_id];
        MyLog(@"文章地址：%@",url);
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [self.rootWebView loadRequest:req];
    }else{
        MyLog(@"网页地址：%@",self.urlStr);
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlStr]];
        [self.rootWebView loadRequest:req];
    }
}
#pragma mark -- 查看文章是否收藏
- (void)lookCollectionArticle{
    NSString *body = [NSString stringWithFormat:@"id=%ld",self.articleID];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kArticleCollection body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        if (kIsDictionary(data)) {
            NSInteger is_collection = [[data objectForKey:@"is_collection"] integerValue];
            NSString *imgStr = is_collection==0?@"ic_top_collect_un":@"ic_top_collect_on";
            self.rightImageName =self.type==BaseWebViewTypeArticle?imgStr:@"";
        }
    } failure:^(NSString *errorStr) {
        
    }];

}
#pragma mark -- 分享文章
- (void)shareAction:(NSString *)title{
    
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
    
    NSArray *wayArr = @[@"2",@"3",@"5",@"1",@"4"];
    [[TCHelper sharedTCHelper] loginShare:self.articleID index:[wayArr[btnTag] integerValue] shareType:1 target_name:self.titleText];
        
        if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
            //分享代码
            [self shareWeixin:btnTag title:title];
            
        }else if (btnTag==4){
            [self shareSinaWithBtnTag:btnTag title:title];
        }else{
            
        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}
#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)btnTag title:(NSString *)title{
    NSString *shareUrl = [NSString stringWithFormat:@"%@?artId=%ld&flag=true",kWebUrl,(long)_articleID];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (shareImageView) {
        [shareParams SSDKSetupShareParamsByText:btnTag==1?title:@"糖士-糖百科"
                                         images:shareImageView.image
                                            url:[NSURL URLWithString:[NSString stringWithFormat:@"%@",shareUrl]]
                                          title:title
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    if (btnTag==0) {
#if !DEBUG
        [MobClick event:@"301_001001"];
#endif
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==1){
#if !DEBUG
        [MobClick event:@"301_001002"];
#endif
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==2){
#if !DEBUG
        [MobClick event:@"301_001003"];
#endif
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else{
#if !DEBUG
        [MobClick event:@"301_001004"];
#endif
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
    }
}
#pragma mark -- 分享新浪
- (void)shareSinaWithBtnTag:(NSInteger)btnTag title:(NSString *)title{
#if !DEBUG
    [MobClick event:@"301_001005"];
#endif
    NSString *shareUrl=[NSString stringWithFormat:@"%@?artId=%ld&flag=true",kWebUrl,(long)_articleID];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",title,
                                             [NSURL URLWithString:shareUrl]]
                                     images:shareImageView.image
                                        url:[NSURL URLWithString:shareUrl]
                                      title:@"糖士-糖百科"
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKEnableUseClientShare];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Sinaweibo://"]]) {
        //新浪微博
        [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state btnTag:btnTag];
        }];
    }else{
        [self.view makeToast:@"请先安装新浪微博客户端" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- 分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)state btnTag:(NSInteger)btnTag{
    if (state==1) {
        [self.view makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
        if (self.type==BaseWebViewTypeArticle) {
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [self getTaskPointsWithActionType:13 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
                
            }];// 获取积分
        }
    }else if (state==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else{
        if (btnTag == 2 || btnTag == 3) {
            [self getTaskPointsWithActionType:13 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
            }];// 获取积分(应对QQ分享停留在QQ不立即返回给予积分)
        }else{
            [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
        }
    }
}
#pragma mark -- setters and getters
-(WKWebView *)rootWebView{
    if (_rootWebView==nil) {
        _rootWebView=[[WKWebView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kNewNavHeight)];
        _rootWebView.UIDelegate=self;
        _rootWebView.navigationDelegate = self;
    }
    return _rootWebView;
}
#pragma mark ====== dealloc =======
- (void)dealloc {
    [self.rootWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}
@end
