//
//  AppDelegate.m
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import "AppDelegate.h"
#import "GuidanceViewController.h"
#import "TCHealthManager.h"
#import "HeziSDKManager.h"
#import "UIDevice+Extend.h"
#import "SSKeychain.h"
//shareSDK分享
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TCUserModel.h"
#import "NSDate+Extension.h"
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMOptions+PrivateDeploy.h>
#import "EaseSDKHelper.h"
#import "ChatHelper.h"
#import <AdSupport/AdSupport.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

#import <UserNotifications/UserNotifications.h>

#endif

#import <UMMobClick/MobClick.h>
#import "JPUSHService.h"
#import "IQKeyboardManager.h"
#import "HeziSDK.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "HttpRequest.h"
#import "TCDeviceShareHelper.h"
#import "TCMainDeviceHelper.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate,XlinkExportObjectDelegate,UIAlertViewDelegate,HeziTriggerActivePageDelegate,WXApiDelegate>{
    BOOL         isRefreshToken;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }

    
    isRefreshToken=NO;
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    
    [self initAllInfo];
    
    //51壁纸回调
    NSString *body = [NSString stringWithFormat:@"idfa=%@&sn=%@",[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString],[[TCHelper sharedTCHelper] deviceUUID]];

    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kChannelCallBack body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
    }];

    //环信
    NSString *apnsCertName = nil;
    BOOL isProduction;
#if DEBUG
    isProduction=NO;
    apnsCertName = kApnsCertDevName;
#else
    isProduction=YES;
    apnsCertName = kApnsCertDisName;
#endif
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if (!appkey) {
        appkey = kEaseMobAppKey;
        [ud setObject:appkey forKey:@"identifier_appkey"];
    }
    
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:appkey apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        
        //初始化jpush
        [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                              channel:@"App Store"
                     apsForProduction:isProduction];

        [self loginInXlink];
        [self refleshXlinkToken];
    }
    
    [XLinkExportObject sharedObject].delegate = self;
    
    BOOL hasShowGuidance=[[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShowGuidance"] boolValue];
    if (!hasShowGuidance) {
        GuidanceViewController *guidanceVC=[[GuidanceViewController alloc] init];
        self.window.rootViewController=guidanceVC;
    }else{
        self.tabbarVC=[[BaseTabBarViewController alloc] init];
        self.window.rootViewController=self.tabbarVC;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark 注册通知，将得到的deviceToken传给SDK
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //将device token转换为字符串
    MyLog(@"deviceTokenStr : %@",[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]stringByReplacingOccurrencesOfString:@" "withString:@""]stringByReplacingOccurrencesOfString:@">"withString:@""]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
        [JPUSHService registerDeviceToken:deviceToken];
    });
}

#pragma mark 注册deviceToken失败，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    MyLog(@"注册推送失败------error:%@",error.description);
}


#pragma mark －－ 本地推送
#pragma mark APP在前台或者后台进入前台时
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    MyLog(@"didReceiveLocalNotification---userinfo:%@",notification.userInfo);
    
    if ([notification.alertTitle isEqualToString:@"设备分享"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:notification.alertTitle message:notification.alertBody delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"接受",@"拒绝", nil];
        alertView.tag=99;  //标记为分享的alert
        [alertView show];
    }else if([notification.alertTitle isEqualToString:@"设备工作"]){
        [self.window makeToast:notification.alertBody duration:1.5 position:CSToastPositionBottom];
    }else{
        
    }
}

#pragma mark －－ 远程推送
#pragma mark iOS10之前 点击通知栏
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //跳转界面
    MyLog(@"iOS10之前，点击通知栏:%@", userInfo);
    if (self.tabbarVC) {
        [self.tabbarVC handerUserNotificationWithUserInfo:userInfo];
    }
     [[EaseSDKHelper shareHelper] hyphenateApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}


#pragma mark iOS10之前 在前台收到通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    MyLog(@"iOS10之前，收到通知:%@", userInfo);
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
    
    if (application.applicationState == UIApplicationStateActive) {
        [JPUSHService setBadge:0];
    }else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

#pragma mark -- UNUserNotificationCenterDelegate
#pragma mark iOS10及以上前台收到推送回调
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        MyLog(@"iOS10 前台收到远程通知----userInfo:%@",userInfo);
    }else {
        MyLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",content.body, content.title,content.subtitle,content.badge,content.sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

#pragma mark iOS10及以上 点击推送消息后回调 点击通知栏
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    MyLog(@"系统（iOS10及以上）点击通知栏调用 didReceiveNotificationResponse, userInfo:%@",userInfo);
    
    //跳转界面
    if (self.tabbarVC) {
        [self.tabbarVC handerUserNotificationWithUserInfo:userInfo];
    }
    // 判断是否为记录血糖消息
    if ([response.notification.request.identifier   isEqualToString:@"testBloodSugar"]) {
        if (self.tabbarVC) {
            [self.tabbarVC pushRecordSugarVC];
        }
    }
    completionHandler();
}



#pragma mark -- 极光推送
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark iOS10以上收到推送通知 （程序在前台）
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSString *body = content.body;    // 推送消息体
    NSString *title = content.title;  // 推送消息的标题
    MyLog(@"极光收到推送通知---%@,title:%@,body:%@",request.identifier,title,body);
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
         //iOS10 前台收到远程通知
         [JPUSHService handleRemoteNotification:userInfo];
        
         //前台收到推送的时候 转成本地通知
         UILocalNotification *notification = [[UILocalNotification alloc] init];
         notification.alertTitle =title;
         notification.alertBody = body;
         notification.userInfo = userInfo;
         [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    }else {
        if ([title isEqualToString:@"设备分享"]) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:body delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"接受",@"拒绝", nil];
            alertView.tag=99;  //标记为分享的alert
            [alertView show];
        }else if([title isEqualToString:@"设备工作"]){
            MyLog(@"设备工作：%@",body);
            
            [self.window makeToast:body duration:1.5 position:CSToastPositionBottom];
        }else{
            //iOS10处理本地通知 添加到通知栏
            completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
            // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
        }
    }
}

#pragma mark iOS10以上 点击推送消息后回调 点击通知栏
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        MyLog(@"iOS10以上 极光推送 收到远程通知:%@", userInfo);
        
        //跳转界面
        if (self.tabbarVC) {
            [self.tabbarVC handerUserNotificationWithUserInfo:userInfo];
        }
    }else {
        // 判断为本地通知
        MyLog(@"iOS10以上极光推送 收到本地通知:userInfo：%@",userInfo);
        //跳转界面
        if (self.tabbarVC) {
            [self.tabbarVC handerUserNotificationWithUserInfo:userInfo];
        }
        // 判断是否为记录血糖消息
        if ([response.notification.request.identifier   isEqualToString:@"testBloodSugar"]) {
            if (self.tabbarVC) {
                [self.tabbarVC pushRecordSugarVC];
            }
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
#endif


#pragma mark APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    MyLog(@"applicationDidEnterBackground");
    isRefreshToken=YES;
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"001" type:3];
#endif
    
    [[HeziSDKManager sharedInstance] applicationBackground];
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

#pragma mark APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    MyLog(@"applicationWillEnterForeground");
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"001" type:4];
#endif
    
    [[HeziSDKManager sharedInstance] applicationForeground];
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //刷新用户凭证
    if (isRefreshToken) {
       [[TCHttpRequest sharedTCHttpRequest] refreshUserTokenAction];
    }
    
    [JPUSHService setBadge:0];
    [application setApplicationIconBadgeNumber:0];   //清除角标
    [application cancelAllLocalNotifications];
    
    if ([TCMainDeviceHelper sharedTCMainDeviceHelper].isGotoWifiSet) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetWifiNotification object:nil];
        [TCMainDeviceHelper sharedTCMainDeviceHelper].isGotoWifiSet=NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//跳转其他应用回调
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *hostStr=[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MyLog(@"host:%@",hostStr);
    MyLog(@"query:%@",[[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    if ([hostStr isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        kSelfWeak;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            MyLog(@"result : %@",resultDic);
            [weakSelf alipayCallBackHandleWithResult:resultDic];
        }];
    }else if ([hostStr isEqualToString:@"pay"]){
        [WXApi handleOpenURL:url delegate:self];
    }else{
        //活动盒子 解析 url
        [[HeziSDKManager sharedInstance]dealWithUrl:url];
    }
    return YES;
}
// 跳转其他应用回调 （9.0以后使用新API接口）
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *hostStr=[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MyLog(@"host:%@",hostStr);
    MyLog(@"query:%@",[[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    
    if ([hostStr isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        kSelfWeak;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            MyLog(@"result : %@",resultDic);
            [weakSelf alipayCallBackHandleWithResult:resultDic];
        }];

    }else if ([hostStr isEqualToString:@"pay"]){
        [WXApi handleOpenURL:url delegate:self];
    }else{
        //活动盒子 解析 url
        [[HeziSDKManager sharedInstance] dealWithUrl:url];
    }
    return YES;
}

#pragma mark -- Private methods
#pragma mark -初始化
-(void)initAllInfo{
    
    /******shareSD初始化******/
    [ShareSDK registerApp:@"糖士"
          activePlatforms:@[
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            @(SSDKPlatformTypeQQ),
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType) {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
            case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
                 
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         switch (platformType) {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:kWechatAppKey appSecret:kWechatAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:kTencentAppKey appKey:kTencentAppSecret authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [appInfo SSDKSetupSinaWeiboByAppKey:kWeiboAPPKey appSecret:kWeiboAppSecret redirectUri:kWeiboRedirectUri authType:SSDKAuthTypeBoth];
                 break;

             default:
                 break;
         }
         
     }];
    
    /*注册微信*/
    [WXApi registerApp:kWechatAppKey];


    //获取健康权限
    [[TCHealthManager sharedTCHealthManager] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (!success) {
            MyLog(@"获取健康权限失败，error:%@",error.localizedDescription);
        }
        [NSUserDefaultsInfos putKey:kIsSynchoriseHealth andValue:[NSNumber numberWithBool:success]];
        
        //今日步数
        [[TCHealthManager sharedTCHealthManager] getStepCountWithDays:1 complete:^(NSMutableArray *valuesArray, NSError *error) {
            if (!error) {
                if (kIsArray(valuesArray)&&valuesArray.count>0) {
                    NSDictionary *dict=valuesArray[0];
                    NSString *currentDate=[[TCHelper sharedTCHelper] getCurrentDate];
                    NSNumber *value=[dict valueForKey:currentDate];
                    [NSUserDefaultsInfos putKey:kStepKey andValue:value];
                }
            }
        }];

    }];
    /*
     初始化活动盒子
     */
    // 设置KEY
    [[HeziSDKManager sharedInstance] configureKey:kHuoDongHeziKey];
    // 针对私有化部署的用户需要设置私有化的域名，域名后需要有'/'
    [[HeziSDKManager sharedInstance] configureServerDomain:@"http://emma.360tj.com/"];
    // 是否开启debug模式
    [[HeziSDKManager sharedInstance] openDebug:YES];
    // 设置导航栏样式
    [[HeziSDKManager sharedInstance] setNavigationBarBackgroundImage:[UIImage imageWithColor:kSystemColor size:CGSizeMake(kScreenWidth, kNavHeight)]];
    [[HeziSDKManager sharedInstance] initializeWithTest:NO];
    
    
    // 初始化 deepLink 可选功能
    [[HeziSDKManager sharedInstance] initializaDeepLinks:^(HeziSDKAppLinksModel *hzLinksModel) {
        
        MyLog(@"applinek paramsToken==%@",hzLinksModel.token);
        MyLog(@"applink custome==%@",hzLinksModel.customeParams);
        MyLog(@"applink uid == %@",hzLinksModel.sharerId);
        //新增邀请类型 用于邀请有礼
        MyLog(@"applink  invitation == %@",hzLinksModel.invitation);
        
    }];
   
    
//友盟统计［测试数据不上传数据］
    /***/
    UMConfigInstance.appKey=kUMMobAppkey;
    UMConfigInstance.channelId=@"App Store";
    [MobClick startWithConfigure:UMConfigInstance];  //初始化SDK
    
    //应用程序的版本标识
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setCrashReportEnabled:YES];
    [MobClick setLogEnabled:YES];
    
    //上传设备信息
    [self uploadAppInfo];
    
    /**********初始化APNs（极光）************/
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
}

#pragma mark 登录Xlink
-(void)loginInXlink{
    NSMutableDictionary *result=[NSMutableDictionary dictionaryWithDictionary:[NSUserDefaultsInfos getDicValueforKey:USER_DIC]];
    if (kIsDictionary(result)&&result.count>0) {
        NSString *authorize=[result objectForKey:@"authorize"];
        NSString *user_id=[result objectForKey:@"user_id"];
        [[XLinkExportObject sharedObject] start];
        [[XLinkExportObject sharedObject] setSDKProperty:SDK_DOMAIN withKey:PROPERTY_CM_SERVER_ADDR];
        [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
    }
}

#pragma mark 刷新xlink accessToken
- (void)refleshXlinkToken{
    NSDictionary *result=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    NSString *token=[result objectForKey:@"access_token"];
    NSString *refresh=[result objectForKey:@"refresh_token"];
    if (!kIsEmptyString(token)&&!kIsEmptyString(refresh)) {
        kSelfWeak;
        [HttpRequest refreshAccessToken:token withRefreshToken:refresh didLoadData:^(id result, NSError *err) {
            if (err) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [weakSelf performSelector:@selector(refleshXlinkToken) withObject:nil afterDelay:1];
                });
            }else{
                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithDictionary:[NSUserDefaultsInfos getDicValueforKey:USER_DIC]];
                [userDict setValue:[result objectForKey:@"access_token"] forKey:@"access_token"];
                [userDict setValue:[result objectForKey:@"refresh_token"] forKey:@"refresh_token"];
                [NSUserDefaultsInfos putKey:USER_DIC andValue:userDict];
                
                NSString *body=[NSString stringWithFormat:@"uid=%@",[userDict valueForKey:@"user_id"]];
                [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kSyncXlinkUserID body:body success:^(id json) {
                    
                } failure:^(NSString *errorStr) {
                    
                }];
                
                [weakSelf performSelector:@selector(refleshXlinkToken) withObject:nil afterDelay:3600];
            }
        }];
    }
    
}


#pragma mark  添加应用设备信息
-(void)uploadAppInfo{
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    
    NSString *body=[NSString stringWithFormat:@"sn=%@&app_version=%@&phone_sn=%@&phone_version=%@&country=%@&province=&city=&language=%@&network=%@&request_platform=iOS&phone_brand=Apple&phone_screen=%@&phone_seller=%@&way=Appstore&idfa=%@",uuid,[UIDevice getSoftwareVer],[UIDevice getSystemName],[UIDevice getSystemVersion],[UIDevice getCountry],[UIDevice getLanguage],[UIDevice getNetworkType],[UIDevice getScreenResolution],[UIDevice getCarrierName],[UIDevice getIDFA]];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kUploadAppInfo body:body success:^(id json) {
        MyLog(@"上传设备信息，result：%@",json);
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark  添加推送
- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions appkey:(NSString *)appkey apnsCertName:(NSString *)apnsCertName otherConfig:(NSDictionary *)otherConfig{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL isHttpsOnly = [ud boolForKey:@"identifier_httpsonly"];
    
    //初始化环信SDK
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:appkey
                                         apnsCertName:apnsCertName
                                          otherConfig:@{@"httpsOnly":[NSNumber numberWithBool:isHttpsOnly], kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES],@"easeSandBox":[NSNumber numberWithBool:[self isSpecifyServer]]}];
    [ChatHelper sharedChatHelper];
    
    //登录环信
    NSString *imUsername=[NSUserDefaultsInfos getValueforKey:kImUserName];
    NSString *imPassword=[NSUserDefaultsInfos getValueforKey:kImPassword];
    if (!kIsEmptyString(imUsername)&&!kIsEmptyString(imPassword)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = [[EMClient sharedClient] loginWithUsername:imUsername password:imPassword];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    //设置是否自动登录
                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                    
                    [[ChatHelper sharedChatHelper] asyncPushOptions];
                    
                    NSString *tempStr=isTrueEnvironment?@"zs":@"cs";
                    NSString *aliasStr=[NSString stringWithFormat:@"%@_%@",tempStr,[NSUserDefaultsInfos getValueforKey:kPhoneNumber]];
                    [JPUSHService setAlias:aliasStr completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        MyLog(@"登录 －－－－设置推送别名，code:%ld content:%@ seq:%ld", (long)iResCode, iAlias, (long)seq);
                    } seq:10000];
                } else {
                    MyLog(@"error:%@",error.errorDescription);
                }
            });
        });
    }
}

#pragma mark
-(BOOL)isSpecifyServer{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *specifyServer = [ud objectForKey:@"identifier_enable"];
    if ([specifyServer boolValue]) {
        NSString *apnsCertName = nil;
#if DEBUG
        apnsCertName = kApnsCertDevName;
#else
        apnsCertName = kApnsCertDisName;
#endif
        NSString *appkey = [ud stringForKey:@"identifier_appkey"];
        if (!appkey)
        {
            appkey = @"easemob-demo#chatdemoui";
            [ud setObject:appkey forKey:@"identifier_appkey"];
        }
        NSString *imServer = [ud stringForKey:@"identifier_imserver"];
        if (!imServer)
        {
            imServer = @"msync-im1.sandbox.easemob.com";
            [ud setObject:imServer forKey:@"identifier_imserver"];
        }
        NSString *imPort = [ud stringForKey:@"identifier_import"];
        if (!imPort)
        {
            imPort = @"6717";
            [ud setObject:imPort forKey:@"identifier_import"];
        }
        NSString *restServer = [ud stringForKey:@"identifier_restserver"];
        if (!restServer)
        {
            restServer = @"a1.sdb.easemob.com";
            [ud setObject:restServer forKey:@"identifier_restserver"];
        }
        
        BOOL isHttpsOnly = NO;
        NSNumber *httpsOnly = [ud objectForKey:@"identifier_httpsonly"];
        if (httpsOnly) {
            isHttpsOnly = [httpsOnly boolValue];
        }
        
        [ud synchronize];
        
        EMOptions *options = [EMOptions optionsWithAppkey:appkey];
        if (![ud boolForKey:@"enable_dns"])
        {
            options.enableDnsConfig = NO;
            options.chatPort = [[ud stringForKey:@"identifier_import"] intValue];
            options.chatServer = [ud stringForKey:@"identifier_imserver"];
            options.restServer = [ud stringForKey:@"identifier_restserver"];
        }
        options.apnsCertName = apnsCertName;
        options.enableConsoleLog = YES;
        options.usingHttpsOnly = isHttpsOnly;
        
        [[EMClient sharedClient] initializeSDKWithOptions:options];
        return YES;
    }
    
    return NO;
}

#pragma mark 解析token
-(NSString *)tokenToAccountId:(NSString *)token{
    NSString *tempStr=[token base64Decoded];
    NSArray *arr = [tempStr componentsSeparatedByString:@"|"];
    return [arr objectAtIndex:0];
}

#pragma mark 支付宝支付回调处理
- (void)alipayCallBackHandleWithResult:(NSDictionary *)resultDic{
    NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
    if (resultStatus==9000) {
        BOOL isShopPayed=[[NSUserDefaultsInfos getValueforKey:kIsShopPayed] boolValue];
        if (isShopPayed) {
            NSString *paymentId=[NSUserDefaultsInfos getValueforKey:@"paymentId"];
            NSString *body=[NSString stringWithFormat:@"payment_id=%@",paymentId];
            [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithoutLoadingURL:kOrderAliPayCallBack body:body success:^(id json) {
#if !DEBUG
                [MobClick event:@"501_001004"];
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:kShopPaySuccessNotification object:nil];
            } failure:^(NSString *errorStr) {
                
            }];
        }else{
            NSString *order_sn=[NSUserDefaultsInfos getValueforKey:kOrderSn];
            NSString *body=[NSString stringWithFormat:@"order_sn=%@",order_sn];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSyncAlipayStatus body:body success:^(id json) {
#if !DEBUG
                [MobClick event:@"501_001002"];
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNotification object:nil];
            } failure:^(NSString *errorStr) {
                
            }];
        }
    }else{
        NSString *memo=[resultDic valueForKey:@"memo"];
        MyLog(@"alipay--error:%@",memo);
        [self.window makeToast:memo duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark -- Public Methods
#pragma mark 重新获取accessToken
-(void)updateAccessToken{
    NSString *token = [NSUserDefaultsInfos getValueforKey:kThirdToken];
    if (!kIsEmptyString(token)) {
        NSString *openId=[self tokenToAccountId:token];
        [HttpRequest thirdAuthWithOpenID:openId withToken:token didLoadData:^(NSDictionary *result, NSError *err) {
            if (!err) {
                if (kIsDictionary(result)&&result.count>0) {
                    [NSUserDefaultsInfos putKey:USER_DIC andValue:result];
                }
            }
        }];
    }
}

#pragma mark WXApiDelegate
#pragma mark 收到一个来自微信的处理结果。
//调用一次sendReq后会收到onResp。
-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass: [PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                MyLog(@"微信支付成功");
                
                BOOL isShopPayed=[[NSUserDefaultsInfos getValueforKey:kIsShopPayed] boolValue];
                if (isShopPayed) {
                    NSString *paymentId=[NSUserDefaultsInfos getValueforKey:@"paymentId"];
                    NSString *body=[NSString stringWithFormat:@"payment_id=%@",paymentId];
                    [[TCHttpRequest sharedTCHttpRequest] postShopMethodWithoutLoadingURL:kOrderWxPayCallBack body:body success:^(id json) {
#if !DEBUG
                        [MobClick event:@"501_001003"];
#endif
                        [[NSNotificationCenter defaultCenter] postNotificationName:kShopPaySuccessNotification object:nil];
                    } failure:^(NSString *errorStr) {
                        
                    }];
                }else{
                    NSString *order_sn=[NSUserDefaultsInfos getValueforKey:kOrderSn];
                    NSString *body=[NSString stringWithFormat:@"order_sn=%@",order_sn];
                    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSyncWepayStatus body:body success:^(id json) {
#if !DEBUG
                        [MobClick event:@"501_001001"];
#endif
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNotification object:nil];
                    } failure:^(NSString *errorStr) {
                        
                    }];

                }
                
            }
                break;
            default:
                MyLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}


#pragma mark -- Custom Delegate
#pragma mark -- HeziTriggerActivePageDelegate
#pragma mark 活动页将要打开，返回NO会拦截。
- (BOOL)heziTriggerWillOpenActivePage:(HeziTrigger *)heziSDK activityURL:(NSString *)url {
    MyLog(@"heziTriggerWillOpenActivePage--%s", __FUNCTION__);
    return YES;
}

#pragma mark 活动页已经打开
- (void)heziTriggerDidOpenActivePage:(HeziTrigger *)heziSDK {
    MyLog(@"heziTriggerDidOpenActivePage--%s", __FUNCTION__);
}

#pragma mark 活动页已经关闭
- (void)heziTriggerDidCloseActivePage:(HeziTrigger *)heziSDK {
    //注意,默认情况下触发的图标点击后不会关闭,需要开发者调用 dismiss 方法
    [heziSDK dismiss];
    MyLog(@"heziTriggerDidCloseActivePage--%s", __FUNCTION__);
}

#pragma mark 触发失败
- (void)heziTirgger:(HeziTrigger *)trigger triggerError:(NSError *)error {
    MyLog(@"triggerError--%s", __FUNCTION__);
}

#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==99){
        if (buttonIndex==1) {
            //接受分享
            [[TCDeviceShareHelper sharedTCDeviceShareHelper] acceptShare];
        }else if(buttonIndex==2){
            [[TCDeviceShareHelper sharedTCDeviceShareHelper] refuseShare];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginOutNotify object:nil];
    }
}

#pragma mark -- XlinkExportObjectDelegate
-(void)onStart{
    MyLog(@"AppDelegate  --- onStart");
}

#pragma mark 登录状态回调
-(void)onLogin:(int)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLogin object:@{@"result" : [NSNumber numberWithInt:result]}];
    MyLog(@"AppDelegate  --- 登录状态回调 onLogin: %d",result);
    if (result==CODE_SUCCEED) {
        MyLog(@"登录云智易平台成功");
    }else if(result==CODE_SERVER_KICK_DISCONNECT){
        [NSUserDefaultsInfos removeObjectForKey:USER_DIC];
        [NSUserDefaultsInfos removeObjectForKey:USER_ID];
        
        [[XLinkExportObject sharedObject] logout]; //退出xlink
        
        [[TCHelper sharedTCHelper] loginOutForClearData];

        // 处理糖友圈角标清除
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendGroupBadgeNumberNotification" object:[NSString stringWithFormat:@"%d",0]];
        
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的帐号已在别处登录，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [TCHelper sharedTCHelper].isUserReload = YES;
        alertView.tag=100;
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }else{
        BOOL isConnectNet= [TCHttpRequest sharedTCHttpRequest].isConnectedToNet;
        if (isConnectNet) {
            NSString * token= [NSUserDefaultsInfos getValueforKey:USER_ID];
            if (!kIsEmptyString(token)) {
                NSDictionary *result=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
                NSString *authorize=[result objectForKey:@"authorize"];
                NSString *user_id=[result objectForKey:@"user_id"];
                if (authorize && user_id && authorize.integerValue > 0 && user_id.integerValue > 0) {
                    [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
                }
            }
        }
    }
}

#pragma mark SDK扫描到的设备结果回调
-(void)onGotDeviceByScan:(DeviceEntity *)device{
    MyLog(@"onGotDeviceByScan SDK扫描到的设备结果回调,mac:%@",device.getMacAddressSimple);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotDeviceByScan object:device];
}

#pragma mark  设置设备AccessKey回调
-(void)onSetDeviceAccessKey:(DeviceEntity *)device withResult:(unsigned char)result withMessageID:(unsigned short)messageID{
    MyLog(@"onSetDeviceAccessKey 设置设备AccessKey回调,mac:%@",device.getMacAddressSimple);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetDeviceAccessKey object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark 获取到SUBKEY
-(void)onGotSubKeyWithDevice:(DeviceEntity *)device withResult:(int)result withSubKey:(NSNumber *)subkey{
    MyLog(@"onGotSubKeyWithDevice,mac:%@,获取到SUBKEY,subkey:%ld",device.getMacAddressSimple,(long)[subkey integerValue]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotSubkey object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"subkey" : subkey}];
}

#pragma mark 与设备订阅状态回调
-(void)onSubscription:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSubscription object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
    if (result == 0) {
        MyLog(@"与设备订阅状态回调,订阅成功,MessageID = %d", messageID);
    }else{
        MyLog(@"与设备订阅状态回调,订阅失败,MessageID = %d; Result = %d", messageID, result);
    }
}

#pragma mark 连接设备回调
-(void)onConnectDevice:(DeviceEntity *)device andResult:(int)result andTaskID:(int)taskID {
    MyLog(@"连接设备回调--onConnectDevice. result: %d", result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectDevice object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"taskID" : [NSNumber numberWithInt:taskID]}];
}

#pragma mark 设备上下线状态回调
-(void)onDeviceStatusChanged:(DeviceEntity *)device{
    MyLog(@"设备上下线状态回调,onDeviceStateChanged,DataLength mac:%@,isConnecting:%d", [device getMacAddressString],device.isConnected);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnDeviceStateChanged object:@{@"device":device}];
}

#pragma mark 发送云端透传数据结果
-(void)onSendPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    MyLog(@"发送云端透传数据结果---- onSendPipeData:%d",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark 发送本地透传消息结果回调
-(void)onSendLocalPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID {
    MyLog(@"发送本地透传数据结果---- onSendLocalPipeData:%d",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendLocalPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark  接收到设备发送过来的透传数据
-(void)onRecvLocalPipeData:(DeviceEntity *)device withPayload:(NSData *)payload{
    MyLog(@" 接收到设备发送过来的透传数据 ---- onRecvLocalPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 接收到云端设备发送回来的透传数据
-(void)onRecvPipeData:(DeviceEntity *)device withMsgID:(UInt16)msgID withPayload:(NSData *)payload{
    MyLog(@"接收到云端设备发送回来的透传数据 ---- onRecvPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 接收到云端设备发送的广播透传数据
-(void)onRecvPipeSyncData:(DeviceEntity *)device withPayload:(NSData *)payload{
    MyLog(@"接收到云端设备发送的广播透传数据 ---- onRecvPipeSyncData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeSyncData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 云端探测回调
-(void)onDeviceProbe:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    MyLog(@"云端探测回调--onDeviceProbe,result:%d,messageId:%d",result,messageID);
}

#pragma mark 接收到云端通知
-(void)onGetEventNotify:(EventNotifyRetPacket *)packet{
    MyLog(@"接收到云端通知--onGetEventNotify:%@",packet);
    [[TCDeviceShareHelper sharedTCDeviceShareHelper] getLastestDeviceShareData];
}



@end
