//
//  TCScanDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCScanDeviceViewController.h"
#import "TCSetWifiLightViewController.h"
#import "TCConnectSuccessViewController.h"
#import "TCQRcodeTimeOutViewController.h"
#import "AppDelegate.h"
#import "SGQRCode.h"
#import "TCAddDeviceModel.h"
#import "TCMainDeviceHelper.h"
#import "HttpRequest.h"
#import "TCShareModel.h"

@interface TCScanDeviceViewController ()<SGQRCodeScanManagerDelegate>{
    NSString                   *inviteCode;
}
@property (nonatomic, strong) SGQRCodeScanManager *manager;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation TCScanDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"扫描二维码";
    
    [self.view addSubview:self.scanningView];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.flashlightBtn];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setupQRCodeScanning];
    
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01-01" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01-01" type:2];
#endif
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
}

#pragma mark -- Custom Delegate
#pragma mark  SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    MyLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager palySoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        for (AVMetadataObject *metadataObject in metadataObjects) {
            if (![metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                continue;
            }
            AVMetadataMachineReadableCodeObject *machineReadableCode = (AVMetadataMachineReadableCodeObject *)metadataObject;
            if ([machineReadableCode.stringValue isEqualToString:LowerSuagerCooker_ProductID]) {   //扫描添加设备
                TCAddDeviceModel *deviceModel=[[TCAddDeviceModel alloc] init];
                deviceModel.deviceName=@"降糖饭煲";
                deviceModel.productID=machineReadableCode.stringValue;
                deviceModel.desc=@"可降低食物糖分约20%";
                deviceModel.wifiImage=@"img_jtfc_link";
                [TCMainDeviceHelper sharedTCMainDeviceHelper].mainDevice=deviceModel;
                TCSetWifiLightViewController *setWifiLightVC=[[TCSetWifiLightViewController alloc] init];
                [self.navigationController pushViewController:setWifiLightVC animated:YES];
            }else{
                //扫描二维码接受分享
                AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
                NSString *stringValue = metadataObject.stringValue ;
                
                MyLog(@"扫描结果，scan--result:%@",stringValue);
                if ([[stringValue substringToIndex:8] isEqualToString:@"tangshi-"]) {
                    inviteCode=[stringValue substringFromIndex:8];
                    MyLog(@"分享码:%@",inviteCode);
                    //接受分享
                    NSDictionary *userDict=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
                    [HttpRequest acceptShareWithInviteCode:inviteCode withAccessToken:[userDict valueForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                        if (!err) {
                            __weak typeof(self) weakSelf = self;
                            [HttpRequest getDeviceListWithUserID:[userDict objectForKey:@"user_id"] withAccessToken:[userDict objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                                if (!err) {
                                    NSArray *deviceList=[result objectForKey:@"list"];
                                    [weakSelf addNewDeviceFromShareWithList:deviceList];
                                } else {
                                    [scanManager startRunning];
                                    [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                                }
                            }];
                        }else{
                             dispatch_sync(dispatch_get_main_queue(), ^{
                                TCQRcodeTimeOutViewController *viewController = [[TCQRcodeTimeOutViewController alloc] init];
                                [self.navigationController pushViewController:viewController animated:YES];
                             });
                        }
                    }];
                }else{
                    TCQRcodeTimeOutViewController *viewController = [[TCQRcodeTimeOutViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            }
        }
    } else {
        MyLog(@"暂未识别出扫描的二维码");
    }
}

#pragma mark -- Event Response

- (void)flashlightBtn_action:(UIButton *)button {
    button.selected=!button.selected;
    if (button.selected) {
        [SGQRCodeHelperTool SG_openFlashlight];
    } else {
        [SGQRCodeHelperTool SG_CloseFlashlight];
    }
}

#pragma mark -- Private Methods
#pragma mark 添加设备
-(void)addNewDeviceFromShareWithList:(NSArray *)deviceList{
    kSelfWeak;
    [HttpRequest getShareListWithAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSArray *tem = (NSArray *)result;
            for (NSDictionary *newsDict in tem) {
                TCShareModel *model = [[TCShareModel alloc] init];
                [model setValues:newsDict];
                model.to_id = newsDict[@"user_id"];
                if ([model.invite_code isEqualToString:inviteCode]) {
                    for (NSDictionary *deviceDic in deviceList) {
                        if ([@([deviceDic[@"id"] intValue]) isEqualToNumber:model.device_id]) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            [weakSelf performSelectorOnMainThread:@selector(pushToSuccess:) withObject:newDevice waitUntilDone:YES];
                            break;
                        }
                    }
                }
            }
        }else{
            if (err.code==4031003) {
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate updateAccessToken];
            }
            [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

#pragma mark 跳转到连接成功页
- (void)pushToSuccess:(DeviceEntity *)device{
    TCConnectSuccessViewController *connectSuccessVC=[[TCConnectSuccessViewController alloc] init];
    connectSuccessVC.device=device;
    [self.navigationController pushViewController:connectSuccessVC animated:YES];
}

#pragma mark 扫描
- (void)setupQRCodeScanning {
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    _manager.delegate = self;
}

#pragma mark -- setter or getter
- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    }
    return _scanningView;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        _promptLabel.frame = CGRectMake(0, 0.70 * kScreenHeight, kScreenWidth, 25);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.text = @"请对准设备的二维码进行扫描";
    }
    return _promptLabel;
}

#pragma mark -  闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnX = 0.5 * (kScreenWidth - 30);
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, self.promptLabel.bottom+20, 30, 30);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"ic_sao_light_un"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"ic_sao_light_on"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

@end
