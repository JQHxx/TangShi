//
//  TCDeviceBindedViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDeviceBindedViewController.h"
#import "TCSetWifiLightViewController.h"

@interface TCDeviceBindedViewController ()

@end

@implementation TCDeviceBindedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    [self initDeviceBindedView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"添加设备-设备已绑定"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"添加设备-设备已绑定"];
}

-(void)initDeviceBindedView{
    UIImageView *deviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 90, 200, 200)];
    [deviceImageView setImage: [UIImage imageNamed:@"img_h_jtfb"]];
    [self.view addSubview:deviceImageView];
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, deviceImageView.bottom+20, kScreenWidth-100, 20)];
    textLabel.text=@"该设备已被绑定";
    textLabel.font=[UIFont systemFontOfSize:16];
    textLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    
    NSString *tempStr=@"【开始/取消】";
    UILabel *tipsLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, textLabel.bottom+30, kScreenWidth-40, 100)];
    tipsLabel.numberOfLines=0;;
    tipsLabel.text=[NSString stringWithFormat:@"1、若您需要使用该设备，可让该设备主帐号向您分享；\n2、若要将设备与APP解绑，请按住设备“WiFi”键再按%@键，蜂鸣三声即为解除绑定成功。",tempStr];
    tipsLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:tipsLabel];
    
    UIButton *completeBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, kRootViewHeight-60, kScreenWidth-80, 40)];
    completeBtn.backgroundColor=kSystemColor;
    completeBtn.layer.cornerRadius=5;
    [completeBtn setTitle:@"知道了" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(hasSeenDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
    
}

#pragma mark -- Event Response
-(void)leftButtonAction{
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[TCSetWifiLightViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}


- (void)hasSeenDevice{
    [self leftButtonAction];
}

@end
