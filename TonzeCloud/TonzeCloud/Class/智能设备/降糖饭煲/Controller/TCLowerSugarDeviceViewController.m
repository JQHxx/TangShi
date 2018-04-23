  //
//  TCLowerSugarDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLowerSugarDeviceViewController.h"
#import "TCShareManagerViewController.h"
#import "TCRiceTypeViewController.h"
#import "TCLowerSuagrDetailViewController.h"
#import "TCFirmwareUpgradeViewController.h"
#import "DeviceCloudMenuViewController.h"
#import "TCLowerSugarButton.h"
#import "TCFunctionButton.h"
#import "DeviceFunctionView.h"
#import "DevicePeferenceFunctionView.h"
#import "TCMainDeviceHelper.h"
#import "TimePickerView.h"
#import "TCRiceModel.h"
#import "NSData+Extension.h"
#import "XLinkExportObject.h"
#import "HttpRequest.h"
#import "SVProgressHUD.h"
#import "TCMessageHelper.h"



@interface TCLowerSugarDeviceViewController ()<UITextFieldDelegate,DeviceFunctionViewDelegate,UIActionSheetDelegate,DevicePeferenceFunctionViewDelegate>{
    UILabel             *titleLabel;           //标题
    UIButton            *deviceStateBtn;       //设备状态
    UITextField         *renameText;
    DeviceFunctionView  *deviceFunctionView;
    DevicePeferenceFunctionView   *peferenceFunctionView;
    UIView              *coverView;
    BOOL                isChooseLowerSugar;     //是否选择降糖饭
    BOOL                isChooseLowerSugarCook;  //是否选择降糖煮
    
    TimePickerView      *timePicker;
    NSString            *functionTitle;
    
    NSArray             *functionArray;
    NSArray             *functionEventIdArr;
    NSArray             *functionOrderEventIdArr;
    NSInteger           selectIndex;
    NSInteger           workHour;        //烹饪时间（小时）
    NSInteger           workMinute;      //烹饪时间（分钟）
    
    NSInteger           orderSelectHour;
    NSInteger           orderSelectminute;
    
    TCRiceModel         *lastSelRice;    //上次烹饪
    
    NSString            *currentTime;     //
    NSString            *riceKey;
}

@property (nonatomic,strong)UIView              *headView;
@property (nonatomic,strong)UIView              *lowerSugarView;     //降糖视图
@property (nonatomic,strong)UIView              *functionView;       //功能视图

@end


@implementation TCLowerSugarDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=self.deviceModel.deviceName;
    self.rightImageName=@"more";
    
    functionArray=@[@"降糖饭",@"降糖煮",@"蒸煮",@"煲粥",@"杂粮粥",@"煮饭",@"煲汤",@"热饭",@"保温",@"云菜谱"];
    functionEventIdArr=@[@"104_003021",@"104_003023",@"104_003025",@"104_003027",@"104_003029",@"104_003031",@"104_003033",@"104_003035",@"104_003037",@"104_003039"];
    functionOrderEventIdArr=@[@"104_003022",@"104_003024",@"104_003026",@"104_003028",@"104_003030",@"104_003032",@"104_003034",@"104_003036",@"104_003038",@"104_003040"];
    
    riceKey=[NSString stringWithFormat:@"%@riceId",self.deviceModel.mac];
    NSInteger riceID=[[NSUserDefaultsInfos getValueforKey:riceKey] integerValue];
    if (riceID>0) {
        MyLog(@"riceKey:%@,riceID:%ld",riceKey,riceID);
        lastSelRice=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getControlRiceWithRiceId:riceID];
    }else{
        lastSelRice=[[TCRiceModel alloc] init];
    }
    self.deviceModel.rice=lastSelRice;
    
    [self initDeviceFucntionView];
    
    [[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateForSendCommandWithDevice:self.deviceModel];  //获取降糖饭煲设备状态
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFunctionOnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFunctionOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFunctionOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFunctionOnPipeData:) name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFunctionStatusChanged:) name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewPeferenceMenu:) name:KSetPeferenceMenuSuccess object:nil];  //设置偏好回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutNotifyCallBack) name:kLoginOutNotify object:nil];
}


#pragma mark -- Custom Delegate
#pragma mark DeviceFunctionViewDelegate
#pragma mark 立即启动
-(void)deviceFunctionViewStartNow{
    [self backUpPopupView];
    
    if (!self.deviceModel.isConnected) {
        [self showOfflineAlertView];
        return;
    }
    
    NSString *stateName=functionArray[selectIndex];
    [self.deviceModel.stateDict setObject:stateName forKey:@"state"];
    if (selectIndex==5||selectIndex==7||selectIndex==8) {
        [self.deviceModel.stateDict setObject:@"00" forKey:@"workHour"];
        [self.deviceModel.stateDict setObject:@"00" forKey:@"workMin"];
    }else{
        if (selectIndex==0) {
            if (kIsEmptyString(self.deviceModel.rice.riceName)) {
                [self.view makeToast:@"请先选择米种" duration:1.0 position:CSToastPositionCenter];
                return;
            }else{
                MyLog(@"米种，id:%ld,riceName：%@,percent：%@",(long)self.deviceModel.rice.riceId,self.deviceModel.rice.riceName,self.deviceModel.rice.lowSugarPercent);
                isChooseLowerSugar=NO;
            }
        }else{
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)workHour] forKey:@"workHour"];
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)workMinute] forKey:@"workMin"];
        }
    }
    
    [MobClick event:functionEventIdArr[selectIndex]];
    
    [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.deviceModel];
}

#pragma mark  预约启动
-(void)deviceFunctionViewReserveStartup{
    [self backUpPopupView];
    
    timePicker =[[TimePickerView alloc] initWithTitle:@"选择预约时间（北京时间）" delegate:self];
    timePicker.pickerStyle=PickerStyle_OrderTime;
    //获取当前时间
    currentTime=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
    orderSelectHour=[currentTime substringWithRange:NSMakeRange(11, 2)].integerValue;
    orderSelectminute=[currentTime substringWithRange:NSMakeRange(14, 2)].integerValue;
    
    timePicker.minHours=orderSelectHour+1;
    timePicker.minMinutes=orderSelectminute;
    timePicker.maxHours=orderSelectHour+8;
    MyLog(@"selectHour:%ld,selectmin:%ld maxhours:%ld",(long)timePicker.minHours,(long)orderSelectminute,(long)timePicker.maxHours);
    
    timePicker.descLabel.text=@"预约时间范围1～8小时";
    timePicker.descLabel.hidden=NO;
    
    [timePicker.locatePicker selectRow:0 inComponent:0 animated:YES];
    [timePicker.locatePicker selectRow:0 inComponent:2 animated:YES];
    [timePicker showInView:self.view];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:0 inComponent:0];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:0  inComponent:2];
}

#pragma mark 设置属性
-(void)deviceFunctionViewSetPorperty{
    if (isChooseLowerSugar) {
        kSelfWeak;
        TCRiceTypeViewController *riceTypeVC=[[TCRiceTypeViewController alloc] init];
        riceTypeVC.selRiceCallBack=^(TCRiceModel *rice){
            deviceFunctionView.detailStr=rice.riceName;
            weakSelf.deviceModel.rice=rice;
        };
        riceTypeVC.selRiceModel=lastSelRice;
        [self.navigationController pushViewController:riceTypeVC animated:YES];
    }else{
        timePicker =[[TimePickerView alloc] initWithTitle:@"选择时间" delegate:self];
        timePicker.pickerStyle=PickerStyle_Time;
        if ([functionTitle isEqualToString:@"蒸煮"]) {
            timePicker.maxHours=2;
            timePicker.minHours=0;
            timePicker.minMinutes=15;
            [timePicker.locatePicker selectRow:1 inComponent:0 animated:YES];
            [timePicker showInView:self.view];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:1 inComponent:0];
            workHour=1;
            workMinute=0;
        }else if ([functionTitle isEqualToString:@"煲粥"]){
            timePicker.maxHours=2;
            timePicker.minHours=0;
            timePicker.minMinutes=50;
            [timePicker.locatePicker selectRow:1 inComponent:0 animated:YES];
            [timePicker.locatePicker selectRow:30 inComponent:1 animated:YES];
             [timePicker showInView:self.view];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:1 inComponent:0];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:30 inComponent:1];
            workHour=1;
            workMinute=30;
        }else if([functionTitle isEqualToString:@"杂粮粥"]){
            timePicker.maxHours=3;
            timePicker.minHours=1;
            timePicker.minMinutes=30;
            [timePicker.locatePicker selectRow:1 inComponent:0 animated:YES];
            [timePicker showInView:self.view];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:1 inComponent:0];
            workHour=2;
            workMinute=0;
        }else{
            timePicker.maxHours=4;
            timePicker.minHours=1;
            timePicker.minMinutes=30;
            [timePicker.locatePicker selectRow:1 inComponent:0 animated:YES];
            [timePicker showInView:self.view];
            [timePicker pickerView:timePicker.locatePicker didSelectRow:1 inComponent:0];
            workHour=2;
            workMinute=0;
        }
    }
}

#pragma mark DevicePeferenceFunctionViewDelegate
#pragma mark 降糖煮立即启动和预约启动
-(void)devicePeferenceFunctionViewDidSelectedFunctionWithTag:(NSInteger)tag{
    if (tag==100) {  //立即启动
        if (!self.deviceModel.isConnected) {
            [self showOfflineAlertView];
            return;
        }
        
        [self.deviceModel.stateDict setObject:@"降糖煮" forKey:@"state"];
        [self.deviceModel.stateDict setObject:@"00" forKey:@"orderHour"];
        [self.deviceModel.stateDict setObject:@"00" forKey:@"orderMin"];
        
        [MobClick event:@"104_003023"];
        
        [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.deviceModel];
    }else{  //预约启动
        [self deviceFunctionViewReserveStartup];
    }
}

#pragma mark 降糖煮更换偏好
-(void)devicePeferenceFunctionViewChangePeferenceMenuAction{
//    [self backUpPopupView];
    DeviceCloudMenuViewController *cloudMenuVC=[[DeviceCloudMenuViewController alloc] init];
    cloudMenuVC.model=self.deviceModel;
    cloudMenuVC.titleText=@"更换偏好";
    [self.navigationController pushViewController:cloudMenuVC animated:YES];
}

#pragma mark UIActionSheetDelegate (TimePickerView)
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (timePicker.pickerStyle==PickerStyle_OrderTime) {
            NSInteger hour=[timePicker.locatePicker selectedRowInComponent:0]+1;
            NSInteger minute=[timePicker.locatePicker selectedRowInComponent:2];
            if (hour==1) {
                if (minute>=orderSelectminute) {
                    minute=minute-orderSelectminute;
                }
            }else{
                if (minute>=orderSelectminute) {
                    minute=minute-orderSelectminute;
                }else{
                    minute=minute+60-orderSelectminute;
                    hour--;
                }
            }
            
            MyLog(@"预约时间：%@",[NSString stringWithFormat:@"%li时%li分",(long)hour,(long)minute]);
            
            NSString *stateName=functionArray[selectIndex];
            [self.deviceModel.stateDict setObject:stateName forKey:@"state"];
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)hour] forKey:@"orderHour"];
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)minute] forKey:@"orderMin"];
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)workHour] forKey:@"workHour"];
            [self.deviceModel.stateDict setObject:[NSString stringWithFormat:@"%02li",(long)workMinute] forKey:@"workMin"];
            
            [MobClick event:functionOrderEventIdArr[selectIndex]];
            
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.deviceModel];
        }else{
            workHour=[timePicker.locatePicker selectedRowInComponent:0]+timePicker.minHours;
            if (workHour==timePicker.minHours) {
                workMinute=[timePicker.locatePicker selectedRowInComponent:1]+timePicker.minMinutes;
            }else{
                workMinute=[timePicker.locatePicker selectedRowInComponent:1];
            }
            MyLog(@"时间：%@",[NSString stringWithFormat:@"%02li小时%02li分钟",(long)workHour,(long)workMinute]);
            deviceFunctionView.detailStr=[NSString stringWithFormat:@"%02li小时%02li分钟",(long)workHour,(long)workMinute];
        }
    }
}


#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 当点击键盘的返回键（右下角）时，执行该方法。
    [renameText resignFirstResponder];
    return YES;
}

#pragma mark -- NSNotification
#pragma mark 设备连接回调
-(void)deviceFunctionOnConnectDevice:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    MyLog(@"deviceFunctionOnConnectDevice 设备(%@)连接回调",[device getMacAddressSimple]);
    
    if ([self.deviceModel.mac isEqualToString:[device getMacAddressSimple]]) {
        NSNumber *result=[dict objectForKey:@"result"];
        if (result.intValue==0) {
            NSData *Data=[NSData nsstringToHex:@"0000000000120000"];
            MyLog(@"降糖饭煲 发送查询设备(%@)状态>>：%@", device.getMacAddressSimple,[Data hexString]);
            //获取最新状态
            if (device.isWANOnline) {
                [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
            }else{
                [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
            }
        }
    }
}

#pragma mark 接收到设备发送的数据
-(void)deviceFunctionOnPipeData:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    MyLog(@"deviceFunctionOnPipeData mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,[recvData hexString]);
    
    ///如果是控制命令的返回就隐藏
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    
    if ([self.deviceModel.mac isEqualToString:[device getMacAddressSimple]]) {
        if (cmd_data[0]==0x16&&self.deviceModel.role ==0) {
            //重置设备返回命令
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] dismissProgressView];
            [self disbindingDevice];
            return;
        }
        
        if (cmd_data[5]==0x13||cmd_data[5]==0x11) {
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] dismissProgressView];
            return;
        }
        
        NSMutableDictionary *dic=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateDicWithDevice:device Data:recvData];
        NSString *stateStr=[dic valueForKey:@"state"];
        if (self.deviceModel.isConnected &&!kIsEmptyString(stateStr)&&![stateStr isEqualToString:@"空闲"]&&![stateStr isEqualToString:@"传感器异常"]&&![stateStr isEqualToString:@"干烧报警"]) {
            NSString *stateStr=[self.deviceModel.stateDict objectForKey:@"state"];
            if (!kIsEmptyString(stateStr)) {
                MyLog(@"保存设备状态state:%@",stateStr);
                
                [NSUserDefaultsInfos putKey:@"name" andValue:[self.deviceModel.stateDict objectForKey:@"name"]];
                [NSUserDefaultsInfos putKey:@"commandType" andValue:stateStr];
                
                if ([stateStr isEqualToString:@"降糖饭"]) {   //保存煮过的米种
                    NSInteger riceID=[[self.deviceModel.stateDict valueForKey:@"rice"] integerValue];
                    if (riceID>0) {
                        MyLog(@"deviceFunctionOnPipeData---riceKey:%@,riceID:%ld",riceKey,riceID);
                        [NSUserDefaultsInfos putKey:riceKey andValue:[NSNumber numberWithInteger:riceID]];
                        lastSelRice=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getControlRiceWithRiceId:riceID];
                        self.deviceModel.rice=lastSelRice;
                    }
                }
            }
            
            kSelfWeak;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    BOOL isFalg=NO;
                    for (UIViewController *viewController in self.navigationController.viewControllers) {
                        if ([viewController isKindOfClass:[TCLowerSuagrDetailViewController class]]) {
                            isFalg=YES;
                            break ;
                        }
                    }
                    if (!isFalg) {
                        weakSelf.deviceModel.stateDict=dic;
                        TCLowerSuagrDetailViewController *detailVC=[[TCLowerSuagrDetailViewController alloc] init];
                        detailVC.deviceModel=self.deviceModel;
                        [weakSelf.navigationController pushViewController:detailVC animated:YES];
                    }
                });
            });
        }
    }else{
        
    }
}

#pragma mark 设备状态改变
-(void)deviceFunctionStatusChanged:(NSNotification *)notifi{
    MyLog(@"deviceFunctionStatusChanged");
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    if ([self.deviceModel.mac isEqualToString:[device getMacAddressSimple]]) {
        self.deviceModel.isConnected=device.isConnected;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [deviceStateBtn setImage:[UIImage imageNamed:self.deviceModel.isConnected?@"pub_shebei_wifi_ic_on":@"pub_shebei_wifi_ic_off"] forState:UIControlStateNormal];
                [deviceStateBtn setTitle:self.deviceModel.isConnected?@"在线":@"离线" forState:UIControlStateNormal];
            });
        });
    }
}

#pragma mark  设置偏好菜谱成功回调
-(void)getNewPeferenceMenu:(NSNotification *)notify{
    NSDictionary *menuDict=notify.userInfo;
    [peferenceFunctionView performSelectorOnMainThread:@selector(getCloudMenuDetailWithMenuDict:) withObject:menuDict waitUntilDone:YES];
}

#pragma mark  退出登录
-(void)loginOutNotifyCallBack{
    MyLog(@"loginOutNotifyCallBack");
    if (self.navigationController.viewControllers.count>1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark -- Event Response
#pragma mark  降糖饭和降糖煮
-(void)lowerSugarButtonDidClick:(UIButton *)sender{
    if (!self.deviceModel.isConnected) {
        [self showOfflineAlertView];
        return;
    }
    
    if (sender.tag==0) {  //降糖饭
        isChooseLowerSugarCook=NO;
        isChooseLowerSugar=YES;
        deviceFunctionView=[[DeviceFunctionView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 160)];
        deviceFunctionView.delegate=self;
        deviceFunctionView.isSetProperty=YES;
        deviceFunctionView.titleStr=@"选择米种";
        deviceFunctionView.detailStr=kIsEmptyString(self.deviceModel.rice.riceName)?@"米种名称":self.deviceModel.rice.riceName;
    }else{ //降糖煮
        isChooseLowerSugarCook=YES;
        peferenceFunctionView=[[DevicePeferenceFunctionView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 220)];
        peferenceFunctionView.model=self.deviceModel;
        peferenceFunctionView.viewDelegate=self;
        [peferenceFunctionView showForGetDevicePreference];
    }
    
    coverView=[[UIView alloc] initWithFrame:self.view.bounds];
    coverView.backgroundColor=[UIColor blackColor];
    coverView.alpha=0.0;
    coverView.userInteractionEnabled=YES;
    [self.view addSubview:coverView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverViewAction:)];
    [coverView addGestureRecognizer:tap];
    
    coverView.alpha=0.5;
    if (sender.tag==0) {
        [self.view addSubview:deviceFunctionView];
        [UIView animateWithDuration:0.3 animations:^{
            deviceFunctionView.frame=CGRectMake(0, kScreenHeight-160, kScreenWidth, 160);
        }];
    }else{
        [self.view addSubview:peferenceFunctionView];
        [UIView animateWithDuration:0.3 animations:^{
            peferenceFunctionView.frame=CGRectMake(0, kScreenHeight-225, kScreenWidth, 225);
        }];
    }
    selectIndex=sender.tag;
}

#pragma mark 饭煲功能选择
-(void)functionViewDidClick:(UIButton *)sender{
    if (!self.deviceModel.isConnected) {
        [self showOfflineAlertView];
        return;
    }
    
    isChooseLowerSugar=NO;
    NSInteger index=sender.tag;
    if (index==7) {  //云菜谱
        DeviceCloudMenuViewController *cloudMenuVC=[[DeviceCloudMenuViewController alloc] init];
        cloudMenuVC.titleText=@"云菜谱";
        cloudMenuVC.model=self.deviceModel;
        [self.navigationController pushViewController:cloudMenuVC animated:YES];
    }else{
        isChooseLowerSugarCook=NO;
        deviceFunctionView=[[DeviceFunctionView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 160)];
        deviceFunctionView.delegate=self;
        if (index==0||index==1||index==2||index==4) {
            deviceFunctionView.isSetProperty=YES;
            if (index==0) {
                deviceFunctionView.titleStr=@"蒸煮时间";
                deviceFunctionView.detailStr=@"01小时";
                functionTitle=@"蒸煮";
                workHour=1;
                workMinute=0;
            }else if (index==1){
                deviceFunctionView.titleStr=@"煲粥时间";
                deviceFunctionView.detailStr=@"01小时30分";
                functionTitle=@"煲粥";
                workHour=1;
                workMinute=30;
            }else if (index==2){
                deviceFunctionView.titleStr=@"杂粮粥时间";
                deviceFunctionView.detailStr=@"02小时";
                functionTitle=@"杂粮粥";
                workHour=2;
                workMinute=0;
            }else if (index==4){
                deviceFunctionView.titleStr=@"煲汤时间";
                deviceFunctionView.detailStr=@"02小时";
                functionTitle=@"煲汤";
                workHour=2;
                workMinute=0;
            }
        }else{
            workHour=workMinute=0;
            deviceFunctionView.isSetProperty=NO;
        }
       
        coverView=[[UIView alloc] initWithFrame:self.view.bounds];
        coverView.backgroundColor=[UIColor blackColor];
        coverView.alpha=0.0;
        coverView.userInteractionEnabled=YES;
        [self.view addSubview:coverView];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverViewAction:)];
        [coverView addGestureRecognizer:tap];
        
        coverView.alpha=0.5;
        [self.view addSubview:deviceFunctionView];
        [UIView animateWithDuration:0.3 animations:^{
            deviceFunctionView.frame=CGRectMake(0, kScreenHeight-160, kScreenWidth, 160);
        }];
    }
    selectIndex=index+2;
    
}

#pragma mark  点击遮罩
-(void)tapCoverViewAction:(UITapGestureRecognizer *)gesture{
    [self backUpPopupView];
}

#pragma mark 退出弹出框
-(void)backUpPopupView{
    if (isChooseLowerSugarCook) {
        [UIView animateWithDuration:0.3 animations:^{
            peferenceFunctionView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 225);
        } completion:^(BOOL finished) {
            coverView.alpha=0;
            [coverView removeFromSuperview];
            [peferenceFunctionView removeFromSuperview];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            deviceFunctionView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 160);
        } completion:^(BOOL finished) {
            coverView.alpha=0;
            [coverView removeFromSuperview];
            [deviceFunctionView removeFromSuperview];
        }];
    }
}

#pragma mark 更多按钮事件
-(void)rightButtonAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf=self;
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf renameAction];
    }];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享管理" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [MobClick event:@"104_003042"];
        TCShareManagerViewController *shareVC=[[TCShareManagerViewController alloc] init];
        shareVC.deviceModel=weakSelf.deviceModel;
        [weakSelf.navigationController pushViewController:shareVC animated:YES];
    }];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"固件升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (!weakSelf.deviceModel.isConnected) {
            [weakSelf showOfflineAlertView];
            return;
        }
        [MobClick event:@"104_003043"];
        TCFirmwareUpgradeViewController  *firmwareUpgradeVC=[[TCFirmwareUpgradeViewController alloc] init];
        firmwareUpgradeVC.deviceModel=weakSelf.deviceModel;
        [self.navigationController pushViewController:firmwareUpgradeVC animated:YES];

    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [weakSelf deleteLowerSugarDeviceAction];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:renameAction];
    if (self.deviceModel.role==0) {
        //管理员才能显示
        [alertController addAction:shareAction];
        [alertController addAction:updateAction];
    }
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark 重命名
-(void)renameAction{
    __weak typeof(self) weakSelf=self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:[NSString stringWithFormat:@"%@",weakSelf.deviceModel.deviceName]];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        textField.delegate=self;
        renameText=textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        NSString *deviceName=nil;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"设备名称不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8) {
            [weakSelf.view makeToast:@"不能超过8个字" duration:1.0 position:CSToastPositionCenter];
        }else{
            [MobClick event:@"104_003041"];
            
            deviceName=alertController.textFields.firstObject.text;
            MyLog(@"deviceName:%@",deviceName);
            NSString *key = [NSString stringWithFormat:@"%@name", self.deviceModel.mac];
            NSDictionary *properties = @{key: deviceName};
            NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
            [SVProgressHUD show];
            [HttpRequest setDevicePropertyDictionary:properties withDeviceID:[NSNumber numberWithInteger:self.deviceModel.device_id] withProductID:self.deviceModel.product_id withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                [SVProgressHUD dismiss];
                if (err) {
                    MyLog(@"重命名失败,error:%ld,desc;%@",(long)err.code,err.localizedDescription);
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            weakSelf.baseTitle=deviceName;
                            [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=YES;
                            [weakSelf.view makeToast:@"重命名成功" duration:1.0 position:CSToastPositionCenter];
                        });
                    });
                }
            }];
            
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 删除设备
-(void)deleteLowerSugarDeviceAction{
    NSString *otherButtonTitle = NSLocalizedString(@"删除", nil);
    NSString *title = NSLocalizedString(@"提示", nil);
    NSString *message =(!self.deviceModel.isConnected&&self.deviceModel.role==0)?@"离线状态下成功删除设备，再次绑定设备时，需要重置硬件设备": NSLocalizedString(@"删除设备，您将失去该设备的使用权限，且与该设备绑定的成员将会全部被解绑。", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    kSelfWeak;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [MobClick event:@"104_003044"];
        if (self.deviceModel.role==0&&self.deviceModel.isConnected) {
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] resetDevice:weakSelf.deviceModel];  //设备在线时，管理员需要重置设备
        }else{
            [weakSelf disbindingDevice];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 初始化操作界面
-(void)initDeviceFucntionView{
    UIScrollView *rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    [rootScrollView addSubview:self.headView];
    [rootScrollView addSubview:self.lowerSugarView];
    [rootScrollView addSubview:self.functionView];
    
    rootScrollView.contentSize=CGSizeMake(kScreenWidth, 160+110+self.functionView.height+10);
    
}


#pragma mark 设备离线提示
-(void)showOfflineAlertView{
    NSString *ButtonTitle = NSLocalizedString(@"确定", nil);
    NSString *title=@"设备已离线";
    NSString *message=@"请检查:\n\t      1.设备是否连接电源;\n2.WiFi是否正常;\n\t  3.请尝试重新连接";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __block __typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:ButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf) {
            [[TCMainDeviceHelper sharedTCMainDeviceHelper] connectDevice:weakSelf.deviceModel];
        }
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消设备绑定
-(void)disbindingDevice{
    [SVProgressHUD show];
    kSelfWeak;
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    [HttpRequest unsubscribeDeviceWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withDeviceID:[NSNumber numberWithInteger:self.deviceModel.device_id] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            if (err.code==4001034) {
                //返回这个证明已经取消订阅了该设备
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=YES;
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                });
            }else if (err.code==4031003) {
                
            }
        }else{
            [NSUserDefaultsInfos removeObjectForKey:riceKey];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=YES;
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            });
        }
    }];

}

#pragma mark 获取时间间隔
-(NSTimeInterval )getDateIntervalWithHour:(NSInteger )hour Min:(NSInteger )min{
    NSTimeInterval interval;
    //生成时间
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone systemTimeZone];//系统所在时区
    [df setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    NSString *dateStr=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
    dateStr=[[dateStr substringToIndex:11] stringByAppendingString:[NSString stringWithFormat:@"%li:%li:00",(long)hour,(long)min]];
    
    NSDate *date=[df dateFromString:dateStr];
    interval=[date timeIntervalSinceDate:[NSDate date]];
    
    //避免一分钟差异
    if (interval>60) {
        interval+=60;
    }
    
    //避免一分钟立刻操作
    if (interval<60 && interval > 0) {
        interval+=60;
    }
    
    //如果比当前时间少则计算到明天
    if (interval<-60) {
        interval+=24*60*60+60;
    }
    return interval;
}

#pragma mark -- Getters and Setters
#pragma mark 头部视图
-(UIView *)headView{
    if (!_headView) {
        _headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
        _headView.backgroundColor=kSystemColor;
        
        UIImageView *deviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 30, 100, 100)];
        deviceImageView.image=[UIImage imageNamed:@"img_h_jtfb"];
        [_headView addSubview:deviceImageView];
        
        deviceStateBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-70, 10, 60, 60)];
        [deviceStateBtn setImage:[UIImage imageNamed:self.deviceModel.isConnected?@"pub_shebei_wifi_ic_on":@"pub_shebei_wifi_ic_off"] forState:UIControlStateNormal];
        [deviceStateBtn setTitle:self.deviceModel.isConnected?@"在线":@"离线" forState:UIControlStateNormal];
        [deviceStateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deviceStateBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        deviceStateBtn.titleEdgeInsets=UIEdgeInsetsMake(20, -5, 0, 5);
        deviceStateBtn.imageEdgeInsets=UIEdgeInsetsMake(-20, 20, 10, -20);
        [_headView addSubview:deviceStateBtn];
    }
    return _headView;
}

#pragma mark 降糖饭和降糖煮
-(UIView *)lowerSugarView{
    if (!_lowerSugarView) {
        _lowerSugarView=[[UIView alloc] initWithFrame:CGRectMake(0, self.headView.bottom, kScreenWidth, 100)];
        _lowerSugarView.backgroundColor=[UIColor whiteColor];
        
        NSArray *arr=@[@{@"title":@"降糖饭",@"desc":@"可降低米的糖分",@"image":@"jtfb_ic_menu_JTF"},@{@"title":@"降糖煮",@"desc":@"可降低食物的糖分",@"image":@"jtfb_ic_menu_JTZ"}];
        for (NSInteger i=0; i<arr.count; i++) {
            TCLowerSugarButton *btn=[[TCLowerSugarButton alloc] initWithFrame:CGRectMake(i*kScreenWidth/2, 0, kScreenWidth/2, 100) info:arr[i]];
            btn.tag=i;
            [btn addTarget:self action:@selector(lowerSugarButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [_lowerSugarView addSubview:btn];
        }
        
        UILabel *verLine=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 40, 1, 30)];
        verLine.backgroundColor=kLineColor;
        [_lowerSugarView addSubview:verLine];
        
        UILabel *bottomLine=[[UILabel alloc] initWithFrame:CGRectMake(0, 99, kScreenWidth, 0.5)];
        bottomLine.backgroundColor=kLineColor;
        [_lowerSugarView addSubview:bottomLine];
        
    }
    return _lowerSugarView;
}

#pragma mark 功能视图
-(UIView *)functionView{
    if (!_functionView) {
        _functionView=[[UIView alloc] initWithFrame:CGRectZero];
        _functionView.backgroundColor=[UIColor whiteColor];
        
        NSArray *arr=@[@"jtfb_ic_menu_01",@"jtfb_ic_menu_02",@"jtfb_ic_menu_03",@"jtfb_ic_menu_04",@"jtfb_ic_menu_05",@"jtfb_ic_menu_06",@"jtfb_ic_menu_07",@"jtfb_ic_menu_08"];
        
        NSInteger count=kScreenWidth>320?4:3;
        CGFloat btnW=kScreenWidth/count;
        for (NSInteger i=0; i<arr.count; i++) {
            NSDictionary *dict=@{@"name":functionArray[i+2],@"image":arr[i]};
            TCFunctionButton *btn=[[TCFunctionButton alloc] initWithFrame:CGRectMake((i%count)*btnW, (i/count)*btnW, btnW, btnW) info:dict];
            btn.tag=i;
            [btn addTarget:self action:@selector(functionViewDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [_functionView addSubview:btn];
        }
        
        NSInteger rowCount=arr.count/(double)count+0.5;
        for (NSInteger i=0; i<rowCount+1; i++) {
            UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(0, btnW*i, kScreenWidth, 0.5)];
            line1.backgroundColor=kLineColor;
            [_functionView addSubview:line1];
        }
        
        for (NSInteger i=0; i<count-1; i++) {
            UILabel *line2=[[UILabel alloc] initWithFrame:CGRectMake(btnW*(i+1), 0, 0.5, rowCount*btnW)];
            line2.backgroundColor=kLineColor;
            [_functionView addSubview:line2];
        }
        
        _functionView.frame=CGRectMake(0, self.lowerSugarView.bottom+10, kScreenWidth,kScreenWidth>320?btnW*2:btnW*3);
        
    }
    return _functionView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KSetPeferenceMenuSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOutNotify object:nil];
}

@end
