//
//  TCConnectSuccessViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCConnectSuccessViewController.h"
#import "TCIntelligentDeviceViewController.h"
#import "XLinkExportObject.h"
#import "TCMainDeviceHelper.h"

@interface TCConnectSuccessViewController ()

@end

@implementation TCConnectSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    self.isHiddenBackBtn=YES;
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    
    [[XLinkExportObject sharedObject] initDevice:self.device];
    self.device.version=2;
    [[XLinkExportObject sharedObject] connectDevice:self.device andAuthKey:self.device.accessKey];
    
    
    [self initConnectSuccessView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"添加设备-连接成功"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDeviceForNotifi:) name:kOnConnectDevice object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"添加设备-连接成功"];
}

#pragma mark -- 通知中心
#pragma mark  连接设备回调
-(void)connectDeviceForNotifi:(NSNotification *)notifi{
    MyLog(@"连接设备回调 connectDeviceForNotifi---object:%@",notifi.object);
}

#pragma mark -- Event Response
#pragma mark 完成
-(void)completeConnectDevice{
    BOOL flag = false;
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[TCIntelligentDeviceViewController class]]){
            [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=YES;
            [self.navigationController popToViewController:vc animated:YES];
            flag=YES;
            break;
        }
    }
    if (!flag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)leftButtonAction{
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[TCIntelligentDeviceViewController class]]){
            [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=YES;
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
}


#pragma mark -- Private Methods
-(void)initConnectSuccessView{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 300)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIImageView *successImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-89)/2, 70+64, 89, 89)];
    successImageView.image=[UIImage imageNamed:@"pub_ic_device_right"];
    [self.view addSubview:successImageView];
    
    UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(80, successImageView.bottom+20, kScreenWidth-160, 20)];
    lab1.text=@"添加成功";
    lab1.font=[UIFont boldSystemFontOfSize:18];
    lab1.textAlignment=NSTextAlignmentCenter;
    lab1.textColor=kSystemColor;
    [self.view addSubview:lab1];
    
    UILabel *tipsLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, lab1.bottom+10, kScreenWidth-80, 20)];
    tipsLbl.text=@"恭喜，您的设备已成功添加！";
    tipsLbl.font=[UIFont boldSystemFontOfSize:14];
    tipsLbl.textAlignment=NSTextAlignmentCenter;
    tipsLbl.textColor=[UIColor colorWithHexString:@"0x959595"];
    [self.view addSubview:tipsLbl];
    
    UIButton *completeBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, bgView.bottom+26, kScreenWidth-80, 40)];
    completeBtn.backgroundColor=kSystemColor;
    completeBtn.layer.cornerRadius=5;
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnConnectDevice object:nil];
}

@end
