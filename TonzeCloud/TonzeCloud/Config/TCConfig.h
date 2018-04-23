//
//  TCConfig.h
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#ifndef TCConfig_h
#define TCConfig_h


#endif /* TCConfig_h */

/********************常用宏定义*****************/
//ios系统版本号
#define kIOSVersion    ([UIDevice currentDevice].systemVersion.floatValue)
// appDelegate
#define kAppDelegate   (AppDelegate *)[[UIApplication  sharedApplication] delegate]
//主窗口
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]


//设备尺寸：屏幕宽、高
#define kScreenBounds     [UIScreen mainScreen].bounds
#define kScreenHeight     [UIScreen mainScreen].bounds.size.height
#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define kTabHeight        (isIPhoneX ? (49+ 34) : 49)
#define kNavHeight        44.0
#define kNewNavHeight     (isIPhoneX ? 88 : 64)
#define KStatusHeight     (isIPhoneX ? 44 : 20)
#define KTabbarSafeBottomMargin      (isIPhoneX ? 34.f : 0.f)
#define kRootViewHeight   kScreenHeight-kNewNavHeight - KTabbarSafeBottomMargin
#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height==2436 : NO)


//RGB颜色
#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kRGBColor(r, g, b)    [UIColor colorWithRed:(r)/255.0  green:(g)/255.0 blue:(b)/255.0  alpha:1]
/// 设置颜色与透明度 示例：UIColorHEX_Alpha(0x26A7E8, 0.5)
#define UIColorHex_Alpha(rgbValue, al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

#define kSystemColor          [UIColor colorWithHexString:@"#05d380"]
#define kbgBtnColor           [UIColor colorWithHexString:@"#05d380"]
#define kbgView               [UIColor colorWithHexString:@"#f0f0f0"]
#define kLineColor            kRGBColor(200, 199, 204)
#define kSysBlueColor         kRGBColor(77, 165, 248)

#define kBackgroundColor      kRGBColor(238,241,241)  // 灰色主题背景色

/// 设置颜色 示例：UIColorHex(0x26A7E8)
#define UIColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//字体
#define kFontWithSize(size)      [UIFont systemFontOfSize:size]
#define kBoldFontWithSize(size)  [UIFont boldSystemFontOfSize:size]

///APP版本号
#define APP_VERSION     [[NSBundle mainBundle].infoDictionary      objectForKey:@"CFBundleShortVersionString"]
#define APP_DISPLAY_NAME [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]

#pragma mark --Judge
//字符串为空判断
#define kIsEmptyString(s)       (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
//对象为空判断
#define kIsEmptyObject(obj)     (obj == nil || [obj isKindOfClass:[NSNull class]])
//字典类型判断
#define kIsDictionary(objDict)  (objDict != nil && [objDict isKindOfClass:[NSDictionary class]])
//数组类型判断
#define kIsArray(objArray)      (objArray != nil && [objArray isKindOfClass:[NSArray class]])
// 时间格式
#define kDateFormat_yyyyMdHm   @"yyyy-MM-dd HH:mm"
#define kDateFormat_yMd        @"yyyy-MM-dd"

//调试
#ifdef DEBUG
#define MyLog(...) NSLog(__VA_ARGS__)
#else
#define MyLog(...)
#endif

/// block self
#define kSelfWeak __weak typeof(self) weakSelf = self
#define kSelfStrong __strong __typeof__(self) strongSelf = weakSelf

#define kKeyWindow  [UIApplication sharedApplication].keyWindow

#define  kIsLogined   [[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue]

/*******第三方平台APPKEY********/
/*微博 微信 腾讯*/
#define kWeiboAPPKey             @"1311133631"
#define kWeiboAppSecret          @"d2f27d1bf86efd89edf92d537ff6e1e5"
#define kWeiboRedirectUri        @"http://open.weibo.com/apps/1311133631/privilege/oauth"
#define kWechatAppKey            @"wx12b8391698c37cc3"
#define kWechatAppSecret         @"6bfafbff29d6228d4b6e6cda48bfeda1"
#define kTencentAppKey           @"1106057888"
#define kTencentAppSecret        @"DHOzNHcsPPwtcoT7"

#define kHyAppKey          @"1146170209115909#tonze123"              //环信APPKEY
/*图灵机器人*/
#define kTuringAPIKey      @"6790ddba1f4f4e96ae35e9d52ef235f5"
/**活动盒子***/
#define kHuoDongHeziKey    @"f5b44a60fc97187755707b7e533d31df"
#define kHuoDongAPPID      @"mc_rstiqs6rhb9qorx"
#define kHuoDongAPPSecret  @"c15b2feba7507bdbe3af400db01c75b0"
//32位随机字符
#define kHuoDongRandomStr  @"S2PMOC6HFYKZ3ADQJT7G41XVN059BLIWREU8"

/*小能*/
#define kXNSiteid          @"kf_9316"
#define kXNSDKKey          @"FC5B72B9-0C91-4434-B8DA-3F6EBC728983"
/*友盟*/
#define kUMMobAppkey       @"595378e3310c936b07001a29"

#define kAppID      @"WzADcCcdsSCLBat0"                    //app标识ID
#define kAppSecret  @"xj4AdNPxcXaj4Qqw8jJrqwD0zxy0zqPe"
#define kAppScheme  @"TangShi"

#define kEaseMobAppKey             @"1146170209115909#tangshi"        //环信APPkey
#define kApnsCertDevName           @"tangshi_dev"                     //开发证书
#define kApnsCertDisName           @"tangshi_dis"                     //发布证书

#define kJPushAppKey               @"ca59a2c8c1839e7a63ec2b90"        //极光推送APPkey


/************************/
#define kShopAuthoriseCode        @"23df0021bf6866af2a7e3e23a7a7845a"    //商城授权码

/******************************通知中心************************************/
#define kStepKey                  @"kStepKey"
#define kUserKey                  @"kUserKey"
#define KPassWord                 @"kPassWord"
#define kUserSecret               @"kUserSecret"
#define kUserToken                @"kUserToken"
#define kPhoneNumber              @"phoneNumber"
#define kUserID                   @"kUserID"
#define kNickName                 @"kNickName"
#define kUserPhoto                @"kUserPhoto"
#define kIsLogin                  @"kIsLogin"
#define kDeviceIDFV               @"kDeviceIDFV"
#define kPaySuccessNotification   @"kPaySuccessNotification"
#define kShopPaySuccessNotification @"kShopPaySuccessNotification"
#define kStepKey                  @"kStepKey"       //当前步数
#define kWeekStepKey              @"kWeekStepKey"   //一周步数
#define kDistanceKey              @"kDistanceKey"   //距离
#define kIsSynchoriseHealth       @"kIsSynchoriseHealth" //是否同步健康
#define kOrderSn                  @"kOrderSn"
#define kScrollNotification       @"kScrollNotification"
#define kGetMessagesUnread        @"kGetMessagesUnread"      //获取未读会话消息
#define kImUserName               @"kImUserName"      //登录环信用户名
#define kImPassword               @"kImPassword"      //登录环信密码
#define kSetPushOption            @"kSetPushOption"
#define kPushPlaySound            @"kPushPlaySound"              //声音
#define kPushPlayVebration        @"kPushPlayVebration"          //震动
#define kResetWifiNotification    @"kResetWifiNotification"      //更新Wi-Fi名称
#define kReceivePushNotification  @"kReceivePushNotification"    //收到消息通知
#define kLaunchAdClickNotify      @"kLaunchAdClickNotify"
#define kAnnouncementClickNotify  @"kAnnouncementClickNotify"       // 公告栏关闭通知
#define kLoginOutNotify           @"kLoginOutNotify"          // 退出登录通知

#define kIsShopPayed              @"isShopPayed" 

#define kIMUsers                  @"kIMUsers"
#define kIMOrderExperts           @"kIMOrderExperts"
#define kIMUserNameKey            @"kIMUserNameKey"
#define kIMNickNameKey            @"kIMNickNameKey"

#import "TCApi.h"
#import "UIViewExt.h"
#import "UIColor+Extend.h"
#import "UIImage+Extend.h"
#import "Singleton.h"
#import "TCHelper.h"
#import "NSUserDefaultsInfos.h"
#import "TCHttpRequest.h"
#import "NSObject+Extend.h"
#import "UIImageView+EMWebCache.h"
#import "TCBlankView.h"
#import "UIView+Toast.h"
#import "JSON.h"
#import "MJRefresh.h"
#import "NSString+Extend.h"
#import "UIAlertView+Extension.h"
#import "SSKeychain.h"
#import "UIDevice+Extend.h"
#import <UMMobClick/MobClick.h>
#import "UITextView+Placeholder.h"
#import "UIButton+ImageTitleSpacing.h"
#import "UIButton+EMWebCache.h"
#import "DeviceConfig.h"
#import "TCFastLoginViewController.h"



