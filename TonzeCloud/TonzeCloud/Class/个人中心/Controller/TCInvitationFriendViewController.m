//
//  TCInvitationFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInvitationFriendViewController.h"
#import "TCInvitationRecordViewController.h"
#import "ActionSheetView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>

@interface TCInvitationFriendViewController (){

    NSInteger     user_id;
    UIImageView  *activityImg;
    UILabel      *contentLabel;
    UIImageView  *recommendImg;
    UIScrollView *rootScrollerView;
    
    UIImageView  *shareImage;
    NSString     *titleStr;
    NSString     *subTitleStr;
}
@end

@implementation TCInvitationFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"糖友邀请";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    shareImage = [[UIImageView alloc] init];

    [self initInvitationFriendView];
    [self loadUserID];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-14" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-14" type:2];
#endif
}
#pragma mark -- Event Response
#pragma mark -- 邀请好友
- (void)invitationFriend{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-14-01"];
#endif
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {

        if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
            //分享代码
            [self shareWeixin:btnTag];
            
        }else if (btnTag==4){
            [self shareSinaWithBtnTag:btnTag];
        }else{
            
        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}
#pragma mark -- 获取用户ID
- (void)loadUserID{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kGetTonzeUserID body:@"" success:^(id json) {
        user_id = [[json objectForKey:@"result"] integerValue];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)btnTag{
    NSString *shareUrl = [NSString stringWithFormat:@"%@/share_get/index.html?user_id=%ld",kShareUrl,user_id];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:subTitleStr
                                     images:shareImage.image
                                        url:[NSURL URLWithString:shareUrl]
                                      title:titleStr
                                       type:SSDKContentTypeAuto];
    [shareParams SSDKEnableUseClientShare];
    if (btnTag==0) {

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信好友
            [MobClick event:@"104_002043"];
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==1){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信朋友圈
            [MobClick event:@"104_002044"];
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==2){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            //QQ好友
            [MobClick event:@"104_002045"];
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else{
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            //QQ空间
            [MobClick event:@"104_002046"];
            [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
    }
}
#pragma mark -- 分享新浪
- (void)shareSinaWithBtnTag:(NSInteger)btnTag{
    NSString *shareUrl = [NSString stringWithFormat:@"%@/share_get/index.html?user_id=%ld",kShareUrl,user_id];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",subTitleStr,[NSURL URLWithString:shareUrl]]
                                     images:shareImage.image
                                        url:[NSURL URLWithString:shareUrl]
                                      title:titleStr
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKEnableUseClientShare];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Sinaweibo://"]]) {
        //新浪微博
        [MobClick event:@"104_002047"];
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
    }else if (state==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- 邀请记录
- (void)incitationFriend:(UIButton *)button{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-14-02"];
#endif
    [MobClick event:@"104_002048"];
    TCInvitationRecordViewController *recordVC = [[TCInvitationRecordViewController alloc] init];
    [self.navigationController pushViewController:recordVC animated:YES];
}
#pragma mark -- Event Methon
#pragma mark -- 初始化界面
- (void)initInvitationFriendView{

    rootScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    rootScrollerView.backgroundColor = [UIColor bgColor_Gray];
    [self.view addSubview:rootScrollerView];
    
    activityImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, kScreenWidth-36, (kScreenWidth-40)*339/679)];
    activityImg.image = [UIImage imageNamed:@"banner_invite_01"];
    activityImg.backgroundColor = [UIColor lightGrayColor];
    [rootScrollerView addSubview:activityImg];
    
    UIButton *invitationBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-270)/2, activityImg.bottom+40, 270, 48)];
    invitationBtn.backgroundColor = kbgBtnColor;
    invitationBtn.layer.cornerRadius = 18;
    [invitationBtn setTitle:@"糖友邀请" forState:UIControlStateNormal];
    [invitationBtn addTarget:self action:@selector(invitationFriend) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollerView addSubview:invitationBtn];
    
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, invitationBtn.bottom+18, 100, 40)];
    [titleButton setTitle:@"邀请记录" forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor colorWithHexString:@"05d380"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(incitationFriend:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollerView addSubview:titleButton];
    
    
    recommendImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-84)/2, titleButton.bottom+18, 84, 22)];
    recommendImg.image = [UIImage imageNamed:@"pub_title_rule"];
    [rootScrollerView addSubview:recommendImg];
    
    UILabel *leftBgLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, recommendImg.top+10, recommendImg.left-18, 1)];
    leftBgLabel.backgroundColor = kbgBtnColor;
    [rootScrollerView addSubview:leftBgLabel];
    
    UILabel *rightBgLabel = [[UILabel alloc] initWithFrame:CGRectMake(recommendImg.right, recommendImg.top+10,  recommendImg.left-18, 1)];
    rightBgLabel.backgroundColor = kbgBtnColor;
    [rootScrollerView addSubview:rightBgLabel];

    contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.text = @"1、点“糖友邀请”分享链接；\n2、被邀请的用户需在分享页面中填入手机号领取奖励，号码需为未注册糖士的手机号；\n3、下载糖士并用领取奖励时填写的手机号注册登录后，系统将自动发放奖励；\n4、邀请一位新朋友送100积分，每月最多可邀请10位新朋友；\n5、本活动最终解释权归糖士所有";
    CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:15]];
    contentLabel.frame = CGRectMake(18, recommendImg.bottom+10, kScreenWidth-36, size.height);
    [rootScrollerView addSubview:contentLabel];
    
    rootScrollerView.contentSize = CGSizeMake(kScreenWidth, contentLabel.bottom+20);
}

@end
