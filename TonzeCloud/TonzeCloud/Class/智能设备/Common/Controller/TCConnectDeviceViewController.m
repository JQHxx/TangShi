//
//  TCConnectDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCConnectDeviceViewController.h"
#import "TCConnectSuccessViewController.h"
#import "TCDeviceBindedViewController.h"
#import "TCMainDeviceHelper.h"
#import "TCAddDeviceModel.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "HttpRequest.h"
#import "DeviceConfig.h"
#import "EasyLink.h"
#import "ZBBonjourService.h"

@interface TCConnectDeviceViewController ()<ZBBonjourServiceDelegate>{
    UILabel              *connectLbl;
    UILabel              *scanLbl ;
    UILabel              *subscribeLbl;
    
    DeviceEntity         *connectDeviceEntity;
    NSTimer              *progressTimer;
    
    TCAddDeviceModel     *mainDevice;
    NSMutableDictionary  *wifiDict;
    NSInteger            userAccessKey;
    NSInteger            subAccessKey;
}

@property (nonatomic,strong)UIImageView  *actImageView;

@end

@implementation TCConnectDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=kSystemColor;
    
    self.baseTitle=@"添加设备";
    
    userAccessKey =(int)(100000000 + (arc4random() % (999999999 - 100000000 + 1)));//获取一个随机整数
    MyLog(@"userAccessKey = %ld",(long)userAccessKey);
    
    mainDevice=[TCMainDeviceHelper sharedTCMainDeviceHelper].mainDevice;
    MyLog(@"deviceName:%@,productID:%@",mainDevice.deviceName,mainDevice.productID);
    
    [self initConnectingView];
    [self startConnectWifiDevice];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"添加设备-连接设备"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGotDeviceByScan:) name:kOnGotDeviceByScan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetDeviceAccessKey:) name:kOnSetDeviceAccessKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetDeviceSubKey:) name:kOnGotSubkey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSubscription:) name:kOnSubscription object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"添加设备-连接设备"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (progressTimer) {
        [progressTimer invalidate];
        progressTimer=nil;
    }
}


#pragma mark -- 通知中心回调
#pragma mark SDK扫描到的设备结果回调
-(void)OnGotDeviceByScan:(NSNotification *)notify{
    DeviceEntity *device=notify.object;
    MyLog(@"扫描设备回调 mac = %@ accesskey = %@ ,MaindDeviceMac:%@",device.getMacAddressSimple,device.accessKey,mainDevice.macAddress);
    if ([device.productID isEqualToString:mainDevice.productID]&&[mainDevice.macAddress isEqualToString:device.getMacAddressSimple]) {
        if (progressTimer) {
            [progressTimer invalidate];
            progressTimer=nil;
        }
        
        mainDevice.macAddress=device.getMacAddressSimple;
        
        MyLog(@"扫描成功");
        if ([device isDeviceInitted]&&device.accessKey.integerValue>0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                TCDeviceBindedViewController *repeatVC=[[TCDeviceBindedViewController alloc] init];
                [self.navigationController pushViewController:repeatVC animated:YES];
            });
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    scanLbl.textColor=kSystemColor;
                    connectDeviceEntity=device;
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(setAccessKeyForDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    }
}

#pragma mark 设置设备AccessKey回调
-(void)OnSetDeviceAccessKey:(NSNotification *)notify{
    NSDictionary *dics=notify.object;
    int result=[[dics objectForKey:@"result"]intValue];
    DeviceEntity *device=[dics objectForKey:@"device"];
    MyLog(@"设置accesskey回调 ,result:%d",result);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddress]) {
        if (result==0) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            
            MyLog(@"设置accesskey成功");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    connectDeviceEntity=device;
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getSubKeyForDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    }
}

#pragma mark 获取subkey回调
-(void)OnSetDeviceSubKey:(NSNotification *)notify{
    NSDictionary *dics=notify.object;
    int result=[[dics objectForKey:@"result"]intValue];
    DeviceEntity *device=[dics objectForKey:@"device"];
    NSNumber *subkey=[dics objectForKey:@"subkey"];
    MyLog(@"获取subkey回调 ,result:%d,subkeey:%d",result,[subkey intValue]);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddress]) {
        if (result==CODE_SUCCEED) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            
            subAccessKey=[subkey integerValue];
            MyLog(@"获取subkey回调成功,subkey:%ld",(long)subAccessKey);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    connectDeviceEntity=device;
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(subDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    }
}

#pragma mark 设备订阅状态回调
-(void)OnSubscription:(NSNotification *)noti{
    NSDictionary *dics = noti.object;
    DeviceEntity *device=[dics objectForKey:@"device"];
    int result=[[dics objectForKey:@"result"] intValue];
    MyLog(@"设备订阅状态回调 ,result:%d",result);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddress]) {
        if (result==CODE_SUCCEED) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            MyLog(@"设备订阅成功");
            
            if (device.accessKey.integerValue <= 0) {
                device.accessKey = @(userAccessKey);
            }
            //设置设备的默认名称，保存到设备扩展属性中
            NSString *key = [NSString stringWithFormat:@"%@name", device.getMacAddressSimple];
            NSDictionary *properties = @{
                                         key: mainDevice.deviceName
                                         };
            [HttpRequest setDevicePropertyDictionary:properties withDeviceID:@(device.deviceID) withProductID:device.productID withAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    subscribeLbl.textColor=kSystemColor;
                    [self.actImageView stopAnimating];
                    
                    TCConnectSuccessViewController *connectSuccessVC=[[TCConnectSuccessViewController alloc] init];
                    connectSuccessVC.device=device;
                    [self.navigationController pushViewController:connectSuccessVC animated:YES];
                    
                });
            }];
        }
    }
}


-(void)bonjourService:(ZBBonjourService *)service didReturnDevicesArray:(NSArray *)array{
    MyLog(@"搜索到设备----，%@",array);
    NSMutableArray *searchDeviceArr=[NSMutableArray arrayWithArray:array];
    if (searchDeviceArr.count>0) {
        [[ZBBonjourService sharedInstance] stopSearchDevice];
        
        connectLbl.textColor=kSystemColor;
        //当给设备配网成功之后保存Wi-Fi密码
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        wifiDict = [userDefaults objectForKey:@"WIFI"];
        wifiDict = [wifiDict mutableCopy];
        if (wifiDict == nil) {
            NSMutableDictionary *dics = [[NSMutableDictionary alloc] init];
            [dics setObject:self.wifiPwd forKey:self.wifiName];
            [userDefaults setObject:dics forKey:@"WIFI"];
        } else {
            [wifiDict setObject:self.wifiPwd forKey:self.wifiName];
            [userDefaults setObject:wifiDict forKey:@"WIFI"];
        }
        
        /*
         RecordData =         {
         FTC = T;
         FW = "FD20A-I";
         HD = 3080B;
         ID = 5d2889c7;
         IP = "192.168.1.182";
         MAC = "B0:F8:93:10:0E:2B";
         MD = EMW3080B;
         MF = "MXCHIP Inc.";
         Name = "EMW3080B(100E2B)";
         OS = "3080B002.010";
         PO = "com.mxchip.spp";
         Port = 8000;
         RF = "3080B-3.6a";
         "wlan unconfigured" = F;
         };
         
     */
        NSDictionary *deviceData =[searchDeviceArr lastObject];
        NSString *mac=deviceData[@"RecordData"][@"MAC"];
        mainDevice.macAddress=[mac stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!progressTimer) {
                    progressTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanDevice) userInfo:nil repeats:YES];
                }
            });
        });
    }
    
}

#pragma mark -- Events Response
- (void)cancelConnectDeviceAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- Private Methods
#pragma mark 开始连接设备
-(void)startConnectWifiDevice{
    [self.actImageView startAnimating];
    
    MyLog(@"wifi-pwd:%@",self.wifiPwd);
    
    NSData *ssidData = [EASYLINK ssidDataForConnectedNetwork];
    NSMutableDictionary *innerParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [innerParams setObject:ssidData forKey:KEY_SSID];
    [innerParams setObject:self.wifiPwd forKey:KEY_PASSWORD];
    [innerParams setObject:[NSNumber numberWithBool:YES] forKey:KEY_DHCP];
    
    EASYLINK *easylink_config=[[EASYLINK alloc] init];
    [easylink_config prepareEasyLink:innerParams info:nil mode:EASYLINK_V2_PLUS];
    [easylink_config transmitSettings];
    
    
    /*此处是开启搜索设备的方法*/
    [[ZBBonjourService sharedInstance] stopSearchDevice];
    [ZBBonjourService sharedInstance].delegate = self;
    [ZBBonjourService sharedInstance].serviceType = @"_easylink_config._tcp";
    [[ZBBonjourService sharedInstance] startSearchDevice];
    
    MyLog(@"开始搜索设备");
}

#pragma mark 扫描设备
-(void)scanDevice{
    MyLog(@"扫描设备----productID:%@",mainDevice.productID);
    [[XLinkExportObject sharedObject] scanByDeviceProductID:mainDevice.productID];
}

#pragma mark 设置access key
-(void)setAccessKeyForDevice{
    MyLog(@"设置设备accesskey:%ld",(long)userAccessKey);
    [[XLinkExportObject sharedObject] setAccessKey:@(userAccessKey) withDevice:connectDeviceEntity];
}

#pragma mark 获取subkey（需要在内网使用）
-(void)getSubKeyForDevice{
    [[XLinkExportObject sharedObject] getSubKeyWithDevice:connectDeviceEntity withAccesskey:@(userAccessKey)];
}

#pragma mark 订阅设备
- (void)subDevice{
    NSNumber *authKey=subAccessKey>0?[NSNumber numberWithInteger:subAccessKey]:[NSNumber numberWithInteger:userAccessKey];
    MyLog(@"订阅设备 mac:%@,accesskey:%@",[connectDeviceEntity getMacAddressSimple],authKey);
    [[XLinkExportObject sharedObject] subscribeDevice:connectDeviceEntity andAuthKey:authKey andFlag:YES];
}

#pragma mark 初始化界面
- (void)initConnectingView{
    [self.view addSubview:self.actImageView];
    
    UIImageView *bottomCoverView=[[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenHeight/2-100, kScreenWidth, 47*kScreenWidth/75)];
    bottomCoverView.image=[UIImage imageNamed:@"pub_link_wifi_cover"];
    bottomCoverView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:bottomCoverView];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-30, 68-30, 60, 60)];
    imgView.image=[UIImage imageNamed:@"pub_link_wifi_ic"];
    [bottomCoverView addSubview:imgView];
    
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, bottomCoverView.bottom, kScreenWidth, kScreenHeight-bottomCoverView.bottom)];
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //连接网络
    connectLbl = [[UILabel alloc] initWithFrame:CGRectMake(80, bottomCoverView.top+120,kScreenWidth-160, 30)];
    connectLbl.text = @"连接网络";
    connectLbl.font=[UIFont systemFontOfSize:16];
    connectLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:connectLbl];

    //扫描设备
    scanLbl = [[UILabel alloc] initWithFrame:CGRectMake(80, connectLbl.bottom,kScreenWidth-160, 30)];
    scanLbl.text = @"扫描设备";
    scanLbl.font=[UIFont systemFontOfSize:16];
    scanLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:scanLbl];
    
    
    //订阅设备
    subscribeLbl = [[UILabel alloc] initWithFrame:CGRectMake(80, scanLbl.bottom,kScreenWidth-160, 30)];
    subscribeLbl.text = @"订阅设备";
    subscribeLbl.font=[UIFont systemFontOfSize:16];
    subscribeLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:subscribeLbl];
    
    
    UIButton *cancelBtn=[[UIButton alloc] initWithFrame:CGRectMake(60, kScreenHeight-90, kScreenWidth-120, 40)];
    cancelBtn.backgroundColor=kSystemColor;
    cancelBtn.layer.cornerRadius=5;
    cancelBtn.clipsToBounds=YES;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelConnectDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
}

#pragma mark -- Setters and Getters
#pragma mark 连接动画
-(UIImageView *)actImageView{
    if (!_actImageView) {
        _actImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-kScreenWidth)/2,kScreenHeight/2-kScreenWidth/2-30, kScreenWidth, kScreenWidth)];
        _actImageView.animationImages=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"pub_link_wifi_01"],[UIImage imageNamed:@"pub_link_wifi_02"],[UIImage imageNamed:@"pub_link_wifi_03"],[UIImage imageNamed:@"pub_link_wifi_04"], nil];
        _actImageView.animationDuration=1.0f;
    }
    return _actImageView;
}


-(void)dealloc{
    [ZBBonjourService sharedInstance].delegate=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnGotDeviceByScan object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnSetDeviceAccessKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnGotSubkey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnSubscription object:nil];
}


@end
