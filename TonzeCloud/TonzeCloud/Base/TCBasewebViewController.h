//
//  TCBasewebViewController.h
//  TonzeCloud
//
//  Created by vision on 17/3/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    BaseWebViewTypeDefault         =0,    //默认
    BaseWebViewTypeArticle         =1,    //文章详情
    BaseWebViewTypeSystemNews      =2,    //系统消息
    BaseWebViewTypeOnlineService   =3,    //在线客服
    BaseWebViewTypeUserAgreement   =4,    //用户协议
    BaseWebViewTypeNewsArticle     =5,    //消息文章
} BaseWebViewType;

typedef void(^WebViewControllerBackBlock)();

typedef void(^LeftActionBlock)();

@interface TCBasewebViewController : BaseViewController

@property (nonatomic, copy )NSString   *titleText;
@property (nonatomic, copy )NSString   *urlStr;
@property (nonatomic, copy )NSString   *shareTitle;
@property (nonatomic, copy )NSString   *image_url;

@property (nonatomic,assign)NSInteger  classID;
@property (nonatomic,assign)NSInteger  articleID;
@property (nonatomic,assign)NSInteger  articleIndex;

@property (nonatomic,assign)BOOL       isArticleType;
@property (nonatomic,assign)BOOL       isSystemNewsIn;
@property (nonatomic,assign)BaseWebViewType   type;

//消息文章参数
@property (nonatomic,assign)NSInteger  message_id;
@property (nonatomic,assign)NSInteger  message_user_id;

@property (nonatomic,copy)WebViewControllerBackBlock backBlock;

/// 返回按钮返回事件
@property (nonatomic, copy) LeftActionBlock leftActionBlock;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;
// 是否需要登录
@property (nonatomic, assign) BOOL  isNeedLogin;


@end
