//
//  TCHealthQuestionResultViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthQuestionResultViewController.h"
#import "TCHealthQusetionViewController.h"
#import "TCHealthTestViewController.h"
#import "ActionSheetView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>


@interface TCHealthQuestionResultViewController (){

    UIImageView *shareImage;
}

@end

@implementation TCHealthQuestionResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"健康自测";
    self.rightImageName = @"ic_top_share";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    shareImage = [[UIImageView alloc] init];
    [shareImage sd_setImageWithURL:[NSURL URLWithString:self.imgUrl] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    [self initResultView];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCHealthTestViewController class]]) {
            TCHealthTestViewController *revise =(TCHealthTestViewController *)controller;
            [self.navigationController popToViewController:revise animated:YES];
        }
    }
}
#pragma mark -- 分享
- (void)rightButtonAction{

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
#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)btnTag{
    
    NSString *shareUrl=self.shareUrl;
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (shareImage) {
        [shareParams SSDKSetupShareParamsByText:self.titleStr
                                         images:shareImage.image
                                            url:[NSURL URLWithString:[NSString stringWithFormat:@"%@",shareUrl]]
                                          title:self.brief
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    if (btnTag==0) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==1){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信朋友圈
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (btnTag==2){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state btnTag:btnTag];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else{
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
- (void)shareSinaWithBtnTag:(NSInteger)btnTag{
    NSString *shareUrl=self.shareUrl;
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",self.titleStr,
                                             [NSURL URLWithString:shareUrl]]
                                     images:shareImage.image
                                        url:[NSURL URLWithString:shareUrl]
                                      title:self.brief
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

    }else if (state==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else{

        [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- 再次测试
- (void)againTest{
    NSInteger i=0;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCHealthQusetionViewController class]]) {
            TCHealthQusetionViewController *revise =(TCHealthQusetionViewController *)controller;
            [TCHelper sharedTCHelper].isHealthScore = YES;
            [self.navigationController popToViewController:revise animated:YES];
            i=1;
        }
    }
    if (i==0) {
        TCHealthQusetionViewController *revise = [[TCHealthQusetionViewController alloc] init];
        revise.assess_id = self.assess_id;
        revise.imgUrl   = self.imgUrl;
        revise.titleStr = self.titleStr;
        [self.navigationController pushViewController:revise animated:YES];
    }
}
#pragma mark -- 初始化界面
- (void)initResultView{
    UIScrollView *scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    scrollerView.backgroundColor = [UIColor bgColor_Gray];
    [self.view addSubview:scrollerView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:24];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.text = self.titleStr;
    titleLabel.numberOfLines = 2;
    CGSize size = [titleLabel.text sizeWithLabelWidth:kScreenWidth-20 font:[UIFont systemFontOfSize:24]];
    titleLabel.frame = CGRectMake(15, 30, kScreenWidth-20, size.height>59?59:size.height);
    [scrollerView addSubview:titleLabel];
    
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
    centerLabel.font = [UIFont systemFontOfSize:17];
    centerLabel.text =@"测试结果";
    CGSize centerSize = [centerLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:17]];
    centerLabel.frame = CGRectMake((kScreenWidth-centerSize.width)/2, titleLabel.bottom+30, centerSize.width, 20);
    [scrollerView addSubview:centerLabel];
    
    for (int i=0; i<2; i++) {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+(kScreenWidth/2+centerSize.width/2)*i, centerLabel.top+9.5,(kScreenWidth-centerSize.width)/2-30, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0x959595"];
        [scrollerView addSubview:lineLabel];
    }
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = self.brief;
    CGSize contentTextSize = [contentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 50, kScreenHeight) withTextFont:[UIFont systemFontOfSize:14]];
    contentLabel.frame =CGRectMake(25, centerLabel.bottom+40, kScreenWidth - 50, contentTextSize.height+10);
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
    [scrollerView addSubview:contentLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,contentTextSize.height>200?contentLabel.bottom+40:kScreenHeight-140-kNewNavHeight, kScreenWidth, 20)];
    NSString *timeStr =[[[TCHelper sharedTCHelper] getCurrentDateTime] substringToIndex:10];
    NSString *time = [NSString stringWithFormat:@"最后评测时间：%@",timeStr];
    timeLabel.text = time;
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
    [scrollerView addSubview:timeLabel];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-132)/2, timeLabel.bottom+10, 132, 41)];
    [nextBtn setTitle:@"重新测试" forState:UIControlStateNormal];
    nextBtn.backgroundColor = kbgBtnColor;
    nextBtn.layer.cornerRadius = 5;
    nextBtn.titleLabel.textColor = [UIColor whiteColor];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextBtn addTarget:self action:@selector(againTest) forControlEvents:UIControlEventTouchUpInside];
    [scrollerView addSubview:nextBtn];
    
    scrollerView.contentSize = CGSizeMake(kScreenWidth, nextBtn.bottom+40);
}


@end
