//
//  TCSetWifiLightViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSetWifiLightViewController.h"
#import "TCSetWifiViewController.h"
#import "TCScanDeviceViewController.h"
#import "TCAddDeviceViewController.h"
#import "TCMainDeviceHelper.h"
#import "TCAddDeviceModel.h"

@interface TCSetWifiLightViewController ()

@property (nonatomic,strong)UIImageView  *WifiImageView;
@property (nonatomic,strong)UILabel      *contentLabel;
@property (nonatomic,strong)UIButton     *setFlashBtn;
@property (nonatomic,strong)UIButton     *nextBtn;

@end

@implementation TCSetWifiLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"添加设备";
    
    [self initWifiTipsView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01-02" type:1];
#endif
    [MobClick beginLogPageView:@"添加设备－设置Wi-Fi灯闪烁"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01-02" type:2];
#endif
    [MobClick endLogPageView:@"添加设备－设置Wi-Fi灯闪烁"];
}

#pragma mark -- Event Response
#pragma mark wifi灯是否闪烁
-(void)setDeviceWifiIsFlashForSender:(UIButton *)sender{
    sender.selected=!sender.selected;
    self.nextBtn.enabled=sender.selected;
    self.nextBtn.backgroundColor=sender.selected?kSystemColor:[UIColor lightGrayColor];
}

#pragma mark 下一步
-(void)getToNextStepAction{
    TCSetWifiViewController *setwifiVC=[[TCSetWifiViewController alloc] init];
    [self.navigationController pushViewController:setwifiVC animated:YES];
}

#pragma mark 返回
-(void)leftButtonAction{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCScanDeviceViewController class]]) {
            TCAddDeviceViewController *addDeviceVC=[self.navigationController.viewControllers objectAtIndex:2];
            [self.navigationController popToViewController:addDeviceVC animated:YES];
            return;
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
}

#pragma mark -- Private Methods
-(void)initWifiTipsView{
    [self.view addSubview:self.WifiImageView];
    [self.view addSubview:self.contentLabel];
    [self.view addSubview:self.setFlashBtn];
    [self.view addSubview:self.nextBtn];
    
}

#pragma mark -- Setters and Getters
#pragma mark 设备wifi灯显示图
-(UIImageView *)WifiImageView{
    if (!_WifiImageView) {
        _WifiImageView=[[UIImageView alloc] initWithFrame:CGRectMake(40, kNewNavHeight + 20, kScreenWidth-80,  kScreenWidth-80)];
        TCAddDeviceModel *device =  [TCMainDeviceHelper sharedTCMainDeviceHelper].mainDevice;
        _WifiImageView.image = [UIImage imageNamed:device.wifiImage];
    }
    return _WifiImageView;
}

#pragma mark 设备wifi灯操作说明
-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(30, self.WifiImageView.bottom+15, kScreenWidth-60, 80)];
        _contentLabel.text=@"1、请长按设备的WiFi按键3秒后松开；\n2、WiFi指示灯处于闪烁，表示设备已进入配网模式。";
        _contentLabel.numberOfLines=0;
        _contentLabel.font=[UIFont systemFontOfSize:16];
    }
    return _contentLabel;
}

#pragma mark 确认设备wifi灯是否闪烁
-(UIButton *)setFlashBtn{
    if (!_setFlashBtn) {
        _setFlashBtn=[[UIButton alloc] initWithFrame:CGRectMake(100, self.contentLabel.bottom+20, kScreenWidth-200, 30)];
        [_setFlashBtn setTitle:@"WiFi灯闪烁" forState:UIControlStateNormal];
        [_setFlashBtn setTitleColor:[UIColor colorWithHexString:@"0xffbe23"] forState:UIControlStateNormal];
        [_setFlashBtn setImage:[UIImage imageNamed:@"ic_eqment_pick_un"] forState:UIControlStateNormal];
        [_setFlashBtn setImage:[UIImage imageNamed:@"ic_eqment_pick_on"] forState:UIControlStateSelected];
        _setFlashBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        _setFlashBtn.imageEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 10);
        _setFlashBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [_setFlashBtn addTarget: self action:@selector(setDeviceWifiIsFlashForSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setFlashBtn;
}

#pragma mark 下一步
-(UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, self.setFlashBtn.bottom+10, kScreenWidth-80, 40)];
        _nextBtn.backgroundColor=[UIColor lightGrayColor];
        _nextBtn.layer.cornerRadius=5;
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_nextBtn setTitleColor:[UIColor colorWithHexString:@"0xf8fbfb"] forState:UIControlStateNormal];
        _nextBtn.layer.masksToBounds=YES;
        _nextBtn.enabled=NO;
        [_nextBtn addTarget: self action:@selector(getToNextStepAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}


@end
