//
//  TCSetWifiViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSetWifiViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "TCConnectDeviceViewController.h"
#import "TCMainDeviceHelper.h"

@interface TCSetWifiViewController ()<UITextFieldDelegate,TCConnectDeviceViewControllerDelegate>{
    UIScrollView       *rootView;
    UILabel            *wifiNameLbl;
    UITextField        *wifiPwdTF;
    UIButton           *setPwdSeenBtn;
    UIButton           *connectBtn;
    UILabel            *connectFailLbl;
    NSString     *wifiName;
}

@end

@implementation TCSetWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    [self initSetWifiView];
    [self loadViewWithWifiData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"添加设备-设置Wi-Fi"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewWithWifiData) name:kResetWifiNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWifiKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWifiKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    connectFailLbl.hidden=YES;
    
    [MobClick endLogPageView:@"添加设备-设置Wi-Fi"];
}

#pragma mark --ConnectingViewControllerDelegate
-(void)connectingViewControllerNetworkFailed{
    connectFailLbl.hidden=NO;
    rootView.contentSize = CGSizeMake(kScreenWidth, connectFailLbl.bottom+20);
}

#pragma mark -- NSNotification
-(void)setWifiKeyboardWillChangeFrame:(NSNotification *)notify{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notify.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void(^animation)() = ^{
        if (wifiPwdTF.bottom+60>keyBoardBounds.origin.y) {
            rootView.frame=CGRectMake(0, -(wifiPwdTF.bottom+60-keyBoardBounds.origin.y), kScreenWidth, kScreenHeight);
        }
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

-(void)setWifiKeyboardWillHide:(NSNotification *)notify{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notify.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        rootView.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark --Response Methods
#pragma mark 连接Wi-Fi
-(void)startConnectDevice{
    NSString * pswdStr = wifiPwdTF.text;
    TCConnectDeviceViewController *viewController = [[TCConnectDeviceViewController alloc] init];
    viewController.wifiPwd=pswdStr;
    viewController.wifiName =wifiName;
    viewController.delegate=self;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 设置密码可见性
-(void)setPwdVisibility:(id)sender{
    wifiPwdTF.secureTextEntry=!wifiPwdTF.secureTextEntry;
    UIButton *btn=sender;
    btn.selected=!btn.selected;
    
    NSString *tempString = wifiPwdTF.text;
    wifiPwdTF.text = tempString;
}

#pragma mark 退出编辑
-(void)backupEdit{
    NSTimeInterval animationDuration = 0.30f;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect frame = rootView.frame;
    frame.origin.y =64;
    rootView.frame = frame;
    
    [UIView commitAnimations];
    [wifiPwdTF resignFirstResponder];
}

#pragma mark 跳转到设置Wi-Fi页
-(void)gotoSystemSetAction{
    //宏定义，判断是否是 iOS10.0以上
    NSString * urlStr = @"App-Prefs:root=WIFI";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        [TCMainDeviceHelper sharedTCMainDeviceHelper].isGotoWifiSet=YES;
    }
}

#pragma mark -- Private Methods
-(void)initSetWifiView{
    
    rootView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    rootView.backgroundColor=[UIColor whiteColor];
    rootView.userInteractionEnabled=YES;
    [self.view insertSubview:rootView atIndex:0];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupEdit)];
    [rootView addGestureRecognizer:tap];
    
    UIImageView *wifiImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 20, 90, 75)];
    wifiImageView.image=[UIImage imageNamed:@"wifi-icon"];
    [rootView addSubview:wifiImageView];
    
    UILabel   *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, wifiImageView.bottom+10, kScreenWidth-40, 30)];
    lab.font=[UIFont systemFontOfSize:12];
    lab.text=@"请选择WiFi（暂不支持5GHz WiFi）";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor=[UIColor colorWithHexString:@"0xc3c3c3"];
    [rootView addSubview:lab];
    
    wifiNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(38, lab.bottom+10, kScreenWidth-76, 36)];
    wifiNameLbl.layer.cornerRadius=18.0;
    wifiNameLbl.layer.borderColor=kLineColor.CGColor;
    wifiNameLbl.textAlignment = NSTextAlignmentCenter;
    wifiNameLbl.textColor = kSystemColor;
    wifiNameLbl.font = [UIFont systemFontOfSize:15];
    wifiNameLbl.layer.borderWidth=1.0;
    wifiNameLbl.clipsToBounds=YES;
    wifiNameLbl.userInteractionEnabled=YES;
    [rootView addSubview:wifiNameLbl];
    
    UITapGestureRecognizer *wifiNameTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSystemSetAction)];
    [wifiNameLbl addGestureRecognizer:wifiNameTap];
    
    UIView *pwdView=[[UIView alloc] initWithFrame:CGRectMake(38, wifiNameLbl.bottom+15, kScreenWidth-76, 36)];
    pwdView.layer.cornerRadius=18;
    pwdView.layer.borderColor=kLineColor.CGColor;
    pwdView.layer.borderWidth=1.0;
    [rootView addSubview:pwdView];
    
    wifiPwdTF=[[UITextField alloc] initWithFrame:CGRectMake(30, 3, kScreenWidth-145, 30)];
    wifiPwdTF.delegate=self;
    wifiPwdTF.placeholder = @"请输入WiFi密码";
    wifiPwdTF.textAlignment = NSTextAlignmentCenter;
    wifiPwdTF.textColor = [UIColor lightGrayColor];
    wifiPwdTF.font = [UIFont systemFontOfSize:15];
    wifiPwdTF.clearsOnBeginEditing=YES;
    wifiPwdTF.secureTextEntry=YES;
    wifiPwdTF.returnKeyType=UIReturnKeyDone;
    wifiPwdTF.delegate=self;
    [pwdView addSubview:wifiPwdTF];
    
    UIButton *setWifiPwdBtn=[[UIButton alloc] initWithFrame:CGRectMake(wifiPwdTF.right+5, 5.5, 25, 25)];
    [setWifiPwdBtn setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [setWifiPwdBtn setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [setWifiPwdBtn addTarget:self action:@selector(setPwdVisibility:) forControlEvents:UIControlEventTouchUpInside];
    [pwdView addSubview:setWifiPwdBtn];
    
    connectFailLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, pwdView.bottom+20, kScreenWidth-60, 120)];
    connectFailLbl.numberOfLines=0;
    connectFailLbl.text=@"配网失败：\n1、请确保设备已进入配网状态\n2、请检查路由器网络是否畅通\n3、请确认WiFi密码无误\n4、请确保路由器设置是2.4GHz网络\n5、确保无线路由器已关闭黑白名单（mac地址过滤）功能";
    connectFailLbl.font=[UIFont systemFontOfSize:14];
    connectFailLbl.textColor=kSystemColor;
    [rootView addSubview:connectFailLbl];
    connectFailLbl.hidden=YES;
    
    connectBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, connectFailLbl.bottom+10, kScreenWidth-80, 40)];
    connectBtn.backgroundColor=kSystemColor;
    connectBtn.layer.cornerRadius=5;
    [connectBtn setTitle:@"下一步" forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [connectBtn setTitleColor:[UIColor colorWithHexString:@"0xf8fbfb"] forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(startConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:connectBtn];
    
    rootView.contentSize = CGSizeMake(kScreenWidth, kRootViewHeight);
}

#pragma mark 初始化wifi帐号和密码
-(void)loadViewWithWifiData{
    NSDictionary *ifs = (NSDictionary *)[self fetchSSIDInfo];
    wifiName = [ifs objectForKey:@"SSID"];
    if (wifiName.length>0) {
        wifiNameLbl.text=[NSString stringWithFormat:@"%@",wifiName];
    }else{
        wifiNameLbl.text = @"请连接WiFi";
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user objectForKey:@"WIFI"];
    NSString *wifiPwdStr=[dic objectForKey:wifiName];
    wifiPwdTF.text =kIsEmptyString(wifiPwdStr)?@"":wifiPwdStr;
}

#pragma mark 获取当前WiFi名称
- (NSString *)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    MyLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    MyLog(@"%@",info);
    return info;
}

#pragma mark--UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [wifiPwdTF resignFirstResponder];
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kResetWifiNotification object:nil];
}
@end
