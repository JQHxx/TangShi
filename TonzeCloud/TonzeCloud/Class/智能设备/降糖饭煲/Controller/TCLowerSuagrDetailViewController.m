//
//  TCLowerSuagrDetailViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLowerSuagrDetailViewController.h"
#import "TCLowerSugarDeviceViewController.h"
#import "TCIntelligentDeviceViewController.h"
#import "CloudMenuDetailViewController.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "NSData+Extension.h"
#import "TCMainDeviceHelper.h"
#import "TCRiceModel.h"
#import "HttpRequest.h"

@interface TCLowerSuagrDetailViewController (){
    UILabel        *foodNameLbl;         //烹饪食物名称
    UILabel        *lowerSugarLbl;       //降糖比
    UIImageView    *workImageView;        //工作图
    UILabel        *workStateLbl;         //工作状态
    UILabel        *timeLbl;              //时间

    UILabel        *timeDetailLbl;
    UILabel        *temperatureLbl;       //温度
    UILabel        *potTempLbl;
    
    BOOL           needPopToView; //是否需要返回
    NSTimer        *myProgressTimer;
    
}

@end

@implementation TCLowerSuagrDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=self.deviceModel.stateDict[@"state"];
    
    [self initDeviceProgressView];
    [self updateDeviceProgressView];
    
    
    [[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateForSendCommandWithDevice:self.deviceModel];  //获取降糖饭煲设备状态
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceProgressOnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceProgressOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceProgressOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceProgressOnPipeData:) name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceProgressStatusChanged:) name:kOnDeviceStateChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutNotifyCallBack) name:kLoginOutNotify object:nil];
}


#pragma mark -- NSNotification
#pragma mark 设备连接回调
-(void)deviceProgressOnConnectDevice:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    MyLog(@"deviceProgressOnConnectDevice 设备(%@)连接回调",[device getMacAddressSimple]);
    
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
-(void)deviceProgressOnPipeData:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    MyLog(@"deviceProgressOnPipeData mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,[recvData hexString]);
    
    uint8_t cmd_data[[recvData length]];
    uint32_t cmd_len = (uint32_t)[recvData length];
    memset(cmd_data, 0, [recvData length]);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    if ([self.deviceModel.mac isEqualToString:[device getMacAddressSimple]]) {
        NSMutableDictionary *dic=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateDicWithDevice:device Data:recvData];
        NSString *stateStr=[dic valueForKey:@"state"];
        MyLog(@"state:%@",stateStr);
        kSelfWeak;
        if (![stateStr isEqualToString:@"空闲"]) {
            if ([dic[@"state"] isEqualToString:[self.deviceModel.stateDict objectForKey:@"state"]]) {
                self.deviceModel.stateDict=dic;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [weakSelf updateDeviceProgressView];
                    });
                });
            }
        }else{
            if (needPopToView||[stateStr isEqualToString:@"空闲"]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                });
            }
        }
        
    }
}

#pragma mark 设备状态改变
-(void)deviceProgressStatusChanged:(NSNotification *)notifi{
    MyLog(@"deviceFunctionStatusChanged");
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    if ([self.deviceModel.mac isEqualToString:[device getMacAddressSimple]]) {
        self.deviceModel.isConnected=device.isConnected;
    }
}

#pragma mark  退出登录
-(void)loginOutNotifyCallBack{
    MyLog(@"loginOutNotifyCallBack");
    if (self.navigationController.viewControllers.count>1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark -- Event Response
#pragma mark 取消操作设备
-(void)cancelControlDevice:(UIButton *)sender{
    needPopToView=YES;
    self.deviceModel.stateDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
    [[TCMainDeviceHelper sharedTCMainDeviceHelper] sendCommandForDevice:self.deviceModel];
}

-(void)leftButtonAction{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCIntelligentDeviceViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            return ;
        }
    }
}

#pragma mark -- Private Methods
#pragma mark 更新界面
-(void)updateDeviceProgressView{
    NSMutableDictionary *dict=self.deviceModel.stateDict;
    NSString *stateStr=[dict valueForKey:@"state"];
    if ([stateStr isEqualToString:@"降糖饭"]||[stateStr isEqualToString:@"降糖煮"]||[stateStr isEqualToString:@"云菜谱"]) {
        foodNameLbl.hidden=lowerSugarLbl.hidden=NO;
        if ([stateStr isEqualToString:@"降糖饭"]) {
            NSInteger riceId=[[self.deviceModel.stateDict objectForKey:@"rice"] integerValue];
            if (riceId>0) {
                TCRiceModel *rice=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getControlRiceWithRiceId:riceId];
                foodNameLbl.text=rice.riceName;
                NSInteger percent=[[self.deviceModel.stateDict objectForKey:@"percent"] integerValue];
                lowerSugarLbl.text=[NSString stringWithFormat:@"约降%li%%糖分",(long)percent];
            }
        }else if([stateStr isEqualToString:@"降糖煮"]){
            foodNameLbl.text=[self.deviceModel.stateDict objectForKey:@"name"];
            lowerSugarLbl.text=[NSString stringWithFormat:@"约降%li%%糖分",(long)[[self.deviceModel.stateDict objectForKey:@"percent"] integerValue]];
        }else{
            foodNameLbl.text=[self.deviceModel.stateDict objectForKey:@"name"];
            
            NSInteger calories1=[[self.deviceModel.stateDict objectForKey:@"calories1"] integerValue];
            NSInteger calories2=[[self.deviceModel.stateDict objectForKey:@"calories2"] integerValue];
            
            NSInteger calorie=(NSInteger)(((calories1 & 0xFF)<<8)|(calories2 & 0xFF));
            
            lowerSugarLbl.hidden=calorie<=0;
            lowerSugarLbl.text=[NSString stringWithFormat:@"热量约%ld千卡",(long)calorie];
        }
    }else{
        foodNameLbl.hidden=lowerSugarLbl.hidden=YES;
    }
    
    NSInteger progress=[[dict valueForKey:@"progress"] integerValue];
    if (progress==1) {
        workStateLbl.text=@"预约中";
        temperatureLbl.hidden=potTempLbl.hidden=YES;
        timeDetailLbl.text=@"预约剩余时间";
        
        NSInteger workHour=[[dict valueForKey:@"orderHour"] integerValue];
        NSInteger workMinute=[[dict valueForKey:@"orderMin"] integerValue];
        if (workMinute>60) {
            timeLbl.text=@"--:--";
        }else{
            timeLbl.text=[NSString stringWithFormat:@"%02li:%02li",(long)workHour,(long)workMinute];
        }
    }else{
        if (progress==2){
            workStateLbl.text=@"炊煮中";
            temperatureLbl.hidden=potTempLbl.hidden=NO;
            timeDetailLbl.text=@"剩余烹饪时间";
        }else if (progress==3){
            workStateLbl.text=@"保温中";
            temperatureLbl.hidden=potTempLbl.hidden=NO;
            timeDetailLbl.text=@"保温用时";
        }
        NSInteger workHour=[[dict valueForKey:@"WorkHour"] integerValue];
        NSInteger workMinute=[[dict valueForKey:@"WorkMin"] integerValue];
        if (workMinute>60) {
            timeLbl.text=@"--:--";
        }else{
            timeLbl.text=[NSString stringWithFormat:@"%02li:%02li",(long)workHour,(long)workMinute];
        }
    }
    
    if ([stateStr isEqualToString:@"干烧报警"]||[stateStr isEqualToString:@"传感器异常"]) {
        temperatureLbl.text=@"--:--";
    }else{
        NSInteger temperature=[[dict valueForKey:@"temperature"] integerValue];
        if (temperature>0) {
            NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%li℃",(long)temperature]];
            [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(attributeStr.length-1, 1)];
            temperatureLbl.attributedText=attributeStr;
        }else{
            temperatureLbl.text=@"--:--";
        }
        
    }
    potTempLbl.text=@"锅内温度";
}


#pragma mark 初始化界面
-(void)initDeviceProgressView{
    CGFloat bottomH=kRootViewHeight>505?kRootViewHeight-155:kRootViewHeight-105;
    
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, bottomH)];
    bottomView.backgroundColor=kSystemColor;
    [self.view addSubview:bottomView];
    
    UIImageView *bottomImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, bottomH-2*kScreenWidth/15, kScreenWidth,2*kScreenWidth/15)];
    bottomImageView.image=[UIImage imageNamed:@"img_h_cloud"];
    [bottomView addSubview:bottomImageView];
    
    foodNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, 10, kScreenWidth-60, 30)];
    foodNameLbl.textColor=[UIColor whiteColor];
    foodNameLbl.textAlignment=NSTextAlignmentCenter;
    foodNameLbl.font=[UIFont systemFontOfSize:16];
    [bottomView addSubview:foodNameLbl];
    
    lowerSugarLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, foodNameLbl.bottom, kScreenWidth-100, 20)];
    lowerSugarLbl.textColor=[UIColor whiteColor];
    lowerSugarLbl.font=[UIFont systemFontOfSize:14];
    lowerSugarLbl.textAlignment=NSTextAlignmentCenter;
    [bottomView addSubview:lowerSugarLbl];
    
    
    NSString *stateStr=[self.deviceModel.stateDict valueForKey:@"state"];
    if ([stateStr isEqualToString:@"降糖饭"]||[stateStr isEqualToString:@"降糖煮"]||[stateStr isEqualToString:@"云菜谱"]) {
        foodNameLbl.hidden=lowerSugarLbl.hidden=NO;
        if ([stateStr isEqualToString:@"降糖饭"]) {
            NSInteger riceID=[[self.deviceModel.stateDict valueForKey:@"rice"] integerValue];
            TCRiceModel *rice=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getControlRiceWithRiceId:riceID];
            foodNameLbl.text=rice.riceName;
            NSInteger percent=[[self.deviceModel.stateDict objectForKey:@"percent"] integerValue];
            lowerSugarLbl.text=[NSString stringWithFormat:@"约降%li%%糖分",(long)percent];
            lowerSugarLbl.hidden=percent==0;
        }else if([stateStr isEqualToString:@"降糖煮"]){
            foodNameLbl.text=[self.deviceModel.stateDict objectForKey:@"name"];
            lowerSugarLbl.text=[NSString stringWithFormat:@"约降%li%%糖分",(long)[[self.deviceModel.stateDict objectForKey:@"percent"] integerValue]];
        }else{
            foodNameLbl.text=[self.deviceModel.stateDict objectForKey:@"name"];
            NSInteger calories1=[[self.deviceModel.stateDict objectForKey:@"calories1"] integerValue];
            NSInteger calories2=[[self.deviceModel.stateDict objectForKey:@"calories2"] integerValue];
            
            NSInteger calorie=(NSInteger)(((calories1 & 0xFF)<<8)|(calories2 & 0xFF));
            
            lowerSugarLbl.hidden=calorie<=0;
            lowerSugarLbl.text=[NSString stringWithFormat:@"热量约%ld千卡",(long)calorie];
        }
    }else{
        foodNameLbl.hidden=lowerSugarLbl.hidden=YES;
    }
    
    
    UIImageView *workBgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, lowerSugarLbl.bottom+10, 120, 120)];
    workBgView.image=[UIImage imageNamed:@"jtfb_ic_work_BG"];
    [bottomView addSubview:workBgView];
    
    workImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, lowerSugarLbl.bottom+10,100, 100)];
    NSString *imageName=[self getWorkTypeImageName];
    workImageView.image=[UIImage imageNamed:imageName];
    [bottomView addSubview:workImageView];
    
    workStateLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, workBgView.bottom+10, kScreenWidth-100, 20)];
    workStateLbl.textColor=[UIColor whiteColor];
    workStateLbl.textAlignment=NSTextAlignmentCenter;
    workStateLbl.font=[UIFont systemFontOfSize:16];
    [bottomView addSubview:workStateLbl];
    
    timeLbl=[[UILabel alloc] initWithFrame:CGRectZero];
    timeLbl.font=[UIFont boldSystemFontOfSize:30];
    timeLbl.textAlignment=NSTextAlignmentCenter;
    timeLbl.textColor=[UIColor whiteColor];
    NSString *timeStr=@"00:00";
    CGFloat timeW=[timeStr boundingRectWithSize:CGSizeMake(kScreenWidth, 40) withTextFont:timeLbl.font].width;
    timeLbl.frame=CGRectMake((kScreenWidth-timeW-20)/2, workStateLbl.bottom, timeW+20, 40);
    [bottomView addSubview:timeLbl];
    
    timeDetailLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, timeLbl.bottom, kScreenWidth-100, 20)];
    timeDetailLbl.textColor=[UIColor whiteColor];
    timeDetailLbl.font=[UIFont systemFontOfSize:14];
    timeDetailLbl.textAlignment=NSTextAlignmentCenter;
    [bottomView addSubview:timeDetailLbl];
    
    temperatureLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, timeDetailLbl.bottom+10, kScreenWidth-100, 35)];
    temperatureLbl.textAlignment=NSTextAlignmentCenter;
    temperatureLbl.font=[UIFont boldSystemFontOfSize:30];
    temperatureLbl.textColor=[UIColor whiteColor];
    [bottomView addSubview:temperatureLbl];
    
    potTempLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, temperatureLbl.bottom, kScreenWidth-100, 30)];
    potTempLbl.textColor=[UIColor whiteColor];
    potTempLbl.font=[UIFont systemFontOfSize:15];
    potTempLbl.textAlignment=NSTextAlignmentCenter;
    [bottomView addSubview:potTempLbl];
    
    UIButton *cancelBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2, kScreenHeight-90, 240, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.backgroundColor=kSystemColor;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius=20;
    cancelBtn.layer.masksToBounds=YES;
    [cancelBtn addTarget:self action:@selector(cancelControlDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
}

#pragma mark -- Private Methods
#pragma mark 获取设备工作图
-(NSString *)getWorkTypeImageName{
    NSString *stateName=[self.deviceModel.stateDict objectForKey:@"state"];
    if ([stateName isEqualToString:@"降糖饭"]) {
        return @"jtfb_ic_work_04";
    }else if ([stateName isEqualToString:@"降糖煮"]){
        return @"jtfb_ic_work_05";
    }else if ([stateName isEqualToString:@"蒸煮"]){
        return @"jtfb_ic_work_01";
    }else if ([stateName isEqualToString:@"煲粥"]){
        return @"jtfb_ic_work_02";
    }else if ([stateName isEqualToString:@"杂粮粥"]){
        return @"jtfb_ic_work_03";
    }else if ([stateName isEqualToString:@"煮饭"]){
        return @"jtfb_ic_work_04";
    }else if ([stateName isEqualToString:@"煲汤"]){
        return @"jtfb_ic_work_05";
    }else if ([stateName isEqualToString:@"热饭"]){
        return @"jtfb_ic_work_06";
    }else if ([stateName isEqualToString:@"保温"]){
        return @"jtfb_ic_work_07";
    }else if([stateName isEqualToString:@"云菜谱"]){
        return @"jtfb_ic_work_08";
    }else if([stateName isEqualToString:@"干烧报警"]){
        return @"jtfb_ic_work_01";
    }else{
        return @"";
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOutNotify object:nil];
}


@end
