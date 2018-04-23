//
//  TCSugarMeasureViewController.m
//  TonzeCloud
//
//  Created by vision on 17/4/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarMeasureViewController.h"
#import "TCSugarDataViewController.h"
#import "TCBleConnectView.h"
#import "TCMeasureMainView.h"
#import "TimePickerView.h"
#import "TCMeasureResultView.h"
#import "NSData+Extension.h"
#import "NSDate+Extension.h"
#import "BlueToothManager.h"
#import "TCSugarModel.h"
#import "SVProgressHUD.h"
#import "TCSugarButton.h"
#import "TCConsultViewController.h"
#import "TCRecordSugarDetailsViewController.h"

@interface TCSugarMeasureViewController ()<UIActionSheetDelegate,BlueToothManagerDelegate,UIAlertViewDelegate>{
    TCMeasureMainView     *mainView;          //血糖值界面
    TCMeasureResultView   *resultView;        //测量结果显示
    UILabel               *contentLabel;
    UIButton              *resultDetailBtn;
    TimePickerView        *Picker;   //时间段选择
    UIImageView           *sugarImgView;
    NSString              *periodString;
    double                sugarValue;
    TCSugarModel          *sugarModel;
    NSString              *measureTimeStr;
    BOOL                  isGetDataSuccess;
    NSTimer               *timer;
    NSInteger             timeNum;
    NSString              *deviceMacStr;
    NSDictionary          *sugarDict;
}
@property (strong,nonatomic)BlueToothManager   *bluetoothManager;
@property (nonatomic,strong)TCBleConnectView   *bleConnectView;
@property (nonatomic,strong)UIButton           *periodButton;      //测量时段
@property (nonatomic,strong)UIImageView        *remindImageView;   //提示图
@property (nonatomic,strong)UIView             *sugarMeasureView;  //测量
@property (nonatomic,strong)UIScrollView       *resultTextView;    //文字结果视图
@property (nonatomic,strong)UIButton           *importDataBtn;     //批量导入数据
@property (nonatomic,strong)UIButton           *bgView;

@end

@implementation TCSugarMeasureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"糖士血糖仪";
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.rigthTitleName=@"统计";
    
    periodString=[[TCHelper sharedTCHelper] getInPeriodOfCurrentTime];
    sugarValue=0.0;
    sugarModel=[[TCSugarModel alloc] init];
    
    [self.view addSubview:self.bleConnectView];
    [self.view addSubview:self.periodButton];
    [self.view addSubview:self.remindImageView];
    [self.view addSubview:self.sugarMeasureView];
    self.sugarMeasureView.hidden=YES;
    [self.view addSubview:self.resultTextView];
    [self.view addSubview:self.importDataBtn];
    self.importDataBtn.hidden=YES;
    [self.view addSubview:self.bgView];

    [self startScanDevice];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([TCHelper sharedTCHelper].isSugarDetailBack==YES) {
        self.bgView.hidden = NO;
        [TCHelper sharedTCHelper].isSugarDetailBack = NO;
    }
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-05-01" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bluetoothManager disconnect];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-05-01" type:2];
#endif

    if (timer) {
        [timer invalidate];
        timer=nil;
    }
}

#pragma mark -- Custom Delegate
#pragma mark  UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_SugarPeriod) {
            NSInteger index=[Picker.locatePicker selectedRowInComponent:0];
            periodString=[[TCHelper sharedTCHelper].sugarPeriodArr objectAtIndex:index];
            [self.periodButton setTitle:[NSString stringWithFormat:@"测量时段：%@",periodString] forState:UIControlStateNormal];
        }
    }
}

#pragma mark BlueToothManagerDelegate
#pragma mark 更新状态
-(void)blueToothManagerRefreshManagerState:(BTManagerState)state{
    switch (state) {
        case BTManagerStateDisable:
        {
            [sugarImgView stopAnimating];
            mainView.sugarValueLabel.hidden = YES;
            mainView.sugarValueStr = @"--";
            self.importDataBtn.hidden=YES;
            resultView.hidden = YES;

            self.bleConnectView.connectType=ConnectTypeDisable;
            sugarImgView.hidden = NO;
            self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_01"];
        }
            break;
        case BTManagerStateEnable:
        {
            self.bleConnectView.connectType=ConnectTypeEnable;
           self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_01"];
        }
            break;
        case BTManagerStateScanning:
        {
            self.bleConnectView.connectType=ConnectTypeScanning;
            self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_02"];
        }
            break;
        case BTManagerStateConnecting:
        {
            self.bleConnectView.connectType=ConnectTypeConnecting;
            self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_02"];
        }
            break;
        case BTManagerStateConnected:
        {
            self.bleConnectView.connectType=ConnectTypeConnected;
            self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_03"];

        }
            break;
        case BTManagerStateInsertTestPaper:{
            self.bleConnectView.connectType=ConnectTypeInsertTestPaper;
            self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_04"];
            
            sugarImgView.animationImages=@[[UIImage imageNamed:@"xty_ic_nun"],[UIImage imageNamed:@"xty_ic_nun_bg"]];
            sugarImgView.animationDuration=1; //设置动画时间
            sugarImgView.animationRepeatCount=0; //设置动画次数 0 表示无限
//            [sugarImgView startAnimating];
            
        }
            break;
        case BTManagerStateMeasured:
        {
            self.remindImageView.hidden=YES;
            self.sugarMeasureView.hidden=NO;
            
//            [sugarImgView stopAnimating];
            sugarImgView.hidden = YES;
            mainView.sugarValueLabel.hidden = NO;

            self.bleConnectView.connectType=ConnectTypeMeasureSucess;
            
        }
            break;
        default:
            break;
    }
}

#pragma mark 获取设备mac地址
-(void)blueToothManagerGetMacAddress:(NSString *)macStr{
    MyLog(@"mac:%@",macStr);
    deviceMacStr=macStr;
}

#pragma mark 插入试纸
-(void)blueToothManagerInsertPaparAction{
    self.remindImageView.image=[UIImage imageNamed:@"xty01_link_img_04"];
    [self.view makeToast:@"检测到试纸" duration:1.0 position:CSToastPositionCenter];
}

#pragma mark 获取血糖值
-(void)blueToothManagerDidGetDataForString:(NSString *)dataString{
    //血糖值
    NSString *sugarValueStr1=[dataString substringWithRange:NSMakeRange(28, 2)];   //血糖值高 8 位
    NSString *sugarValueStr2=[dataString substringWithRange:NSMakeRange(31, 2)];   //血糖值低 8 位
    NSString *sugarValueStr=[sugarValueStr1 stringByAppendingString:sugarValueStr2];
    double value= [[sugarValueStr numberHexString] doubleValue];  //十六进制转十进制
    MyLog(@"longvalue:%f",value);
    sugarValue=value/18.0;
    MyLog(@"value:%fmmol/L",sugarValue);
    
    if (sugarValue<33.3&&sugarValue>1.1) {
        [self reloadMeasureView];
    }else{
        [self.view makeToast:@"测量失败，请重新测量" duration:1.0 position:CSToastPositionCenter];
    }
}

-(void)blueToothManagerDidGetBatchImportDataForString:(NSString *)dataString{
    [SVProgressHUD dismiss];
    
    NSInteger count=(dataString.length+1)/24;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSInteger i=0; i<count; i++) {
        NSString *dataStr=[dataString substringWithRange:NSMakeRange(i*24, 24)];  //00 84 04 0E 0F 1A 11 D0
        
        //血糖值
        NSString *sugarValueStr1=[dataStr substringWithRange:NSMakeRange(0, 2)];   //血糖值高 8 位
        NSString *sugarValueStr2=[dataStr substringWithRange:NSMakeRange(3, 2)];   //血糖值低 8 位
        NSString *sugarValueStr=[sugarValueStr1 stringByAppendingString:sugarValueStr2];
        NSString *valueStr= [sugarValueStr numberHexString];  //十六进制转十进制
        double value=[valueStr doubleValue]/18.0;

        //时间
        NSInteger month=[[[dataStr substringWithRange:NSMakeRange(6, 2)] numberHexString] integerValue];    //月
        NSInteger day=[[[dataStr substringWithRange:NSMakeRange(9, 2)] numberHexString] integerValue];      //日
        NSInteger hour=[[[dataStr substringWithRange:NSMakeRange(12, 2)] numberHexString] integerValue];    //时
        NSInteger minute=[[[dataStr substringWithRange:NSMakeRange(15, 2)] numberHexString] integerValue];  //分
        NSInteger year=[[[dataStr substringWithRange:NSMakeRange(18, 2)] numberHexString] integerValue];    //年
        NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",(long)(year+2000),(long)month,(long)day,(long)hour,(long)minute];
        
        //血糖时间段
        NSString *hourStr=[NSString stringWithFormat:@"%02ld",(long)hour];
        NSString *minuteStr=[NSString stringWithFormat:@"%02ld",(long)minute];
        NSString *periodCh=[[TCHelper sharedTCHelper] getInPeriodOfHour:[hourStr integerValue] minute:[minuteStr integerValue]];
        NSString *time_slot=[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodCh];
        
        //校验码
        NSString *codeStr=[[dataStr substringWithRange:NSMakeRange(21, 2)] numberHexString];
        
        NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%.1f",value],@"value",dateStr,@"time",codeStr,@"code",time_slot,@"time_slot",deviceMacStr,@"deviceid",@"tsxty_v1",@"product_name",nil];
        [tempArr addObject:dict];
    }
    
    NSArray *arr=[[tempArr reverseObjectEnumerator] allObjects];
    NSMutableArray *tempSugarArr=[[NSMutableArray alloc] init];
    
    if (isGetDataSuccess) {
        for (NSDictionary *dict in arr) {
            NSString *measureTime=nil;
            double bloodValue=0.0;
            if (sugarModel) {
                measureTime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:sugarModel.measurement_time format:@"yyyy-MM-dd HH:mm"];
                bloodValue=[sugarModel.glucose doubleValue];
            }
            double value=[dict[@"value"] doubleValue];
            if ([measureTime isEqualToString:dict[@"time"]]&&value==bloodValue) {
                break;
            }else{
                [tempSugarArr addObject:dict];
            }
        }
        
        __weak typeof(self) weakSelf=self;
        NSString *params=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:tempSugarArr];
        NSString *body=[NSString stringWithFormat:@"data_json=%@",params];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarImportData body:body success:^(id json) {
            if (timer) {
                [timer invalidate];
                timer=nil;
            }
            [self.importDataBtn setTitle:@"批量导入" forState:UIControlStateNormal];
            self.importDataBtn.backgroundColor = [UIColor lightGrayColor];
            self.importDataBtn.userInteractionEnabled = NO;
            [TCHelper sharedTCHelper].isBloodReload=YES;
            [weakSelf.view makeToast:@"血糖数据批量上传成功" duration:1.0 position:CSToastPositionCenter];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark -- Event Response
#pragma mark 血糖数据
-(void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-05-02"];
#endif

    [MobClick event:@"102_003013"];
    
    TCSugarDataViewController *sugarDataVC=[[TCSugarDataViewController alloc] init];
    [self.navigationController pushViewController:sugarDataVC animated:YES];
}

#pragma mark 查看详情
-(void)checkResultDetailAction{
    NSString *periodEn=[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodString];
    TCRecordSugarDetailsViewController *sugarDetailVC=[[TCRecordSugarDetailsViewController alloc] init];
    sugarDetailVC.isDeviceMesureIn=YES;
    sugarDetailVC.sugarDict=sugarDict;
    sugarDetailVC.sugarValue=sugarValue;
    sugarDetailVC.measureTimeStr=measureTimeStr;
    sugarDetailVC.isEditSugarRecord=YES;
    sugarDetailVC.timeSlotStr = periodEn;
    [self.navigationController pushViewController:sugarDetailVC animated:YES];
}

#pragma mark 选择血糖时段
-(void)chooseSugarPeriodAction:(UIButton *)sender{
    [MobClick event:@"102_003011"];
    
    Picker =[[TimePickerView alloc] initWithTitle:@"测量时段" delegate:self];
    Picker.pickerStyle=PickerStyle_SugarPeriod;
    NSInteger index=[[TCHelper sharedTCHelper].sugarPeriodArr indexOfObject:periodString];
    [Picker.locatePicker selectRow:index inComponent:0 animated:YES];
    [Picker showInView:self.view];
    [Picker pickerView:Picker.locatePicker didSelectRow:index inComponent:0];
}

#pragma mark 导入数据
-(void)batchImportDataAction{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"确认导入血糖仪所有数据吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [MobClick event:@"102_003012"];

        NSString *config = @"CA 55 AA 00 00";
        [self.bluetoothManager writeToPeripheralWithDataStr:config WriteType:BloodDeiveWriteTypeBatchImport];
        [SVProgressHUD show];
    }
}

#pragma mark -- Private Methods
#pragma mark 开始扫描
-(void)startScanDevice{
    self.bluetoothManager = [[BlueToothManager alloc] init];
    self.bluetoothManager.delegate=self;
    [self.bluetoothManager scan];
}

#pragma mark 刷新界面
-(void)reloadMeasureView{
    MyLog(@"sugarValue:%f",sugarValue);
    
    resultView.hidden=NO;
    
    sugarValue=floor((sugarValue)*10)/10;
    
    mainView.sugarValueStr=[NSString stringWithFormat:@"%.1f",sugarValue];
    
    NSDictionary *normalRangeDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:periodString];
    double normalMinValue=[normalRangeDict[@"min"] doubleValue];
    double normalMaxValue=[normalRangeDict[@"max"] doubleValue];
    if ([mainView.sugarValueStr floatValue]<normalMinValue) {
        mainView.sugarValueLabel.textColor = kRGBColor(254, 212, 92);
    }else if ([mainView.sugarValueStr floatValue]>=normalMinValue&&[mainView.sugarValueStr floatValue]<normalMaxValue){
        mainView.sugarValueLabel.textColor = kRGBColor(70, 222, 188);
    }else {
        mainView.sugarValueLabel.textColor = kRGBColor(247, 118, 119);
    }
    
    resultView.sugarValue=sugarValue;
    
    NSString *periodEn=[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodString];
    measureTimeStr=[[TCHelper sharedTCHelper] getCurrentDateTime];
    
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%.1f",sugarValue],@"value",measureTimeStr,@"time",@"",@"code",periodEn,@"time_slot",deviceMacStr,@"deviceid",@"tsxty_v1",@"product_name",nil];
    [tempArr addObject:dict];
    
    __weak typeof(self) weakSelf=self;
    NSString *params=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:tempArr];
    NSString *body=[NSString stringWithFormat:@"data_json=%@",params];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarImportData body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            [sugarModel setValues:result];
            
            //添加计时器
            if (!timer) {
                timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(importTimeProgressAction) userInfo:nil repeats:YES];
            }
            
            //刷新界面
            self.importDataBtn.hidden=NO;
            timeNum=55;
            [self.importDataBtn setTitle:[NSString stringWithFormat:@"批量导入%lds",(long)timeNum] forState:UIControlStateNormal];
            self.importDataBtn.backgroundColor = kSystemColor;
            self.importDataBtn.userInteractionEnabled = YES;
            
            NSString *body=[NSString stringWithFormat:@"time_slot=%@&glucose=%.1f",periodEn,sugarValue];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarResult body:body success:^(id json) {
                sugarDict=[json objectForKey:@"result"];
                if (kIsDictionary(sugarDict)) {
                    
                    contentLabel.text=[sugarDict valueForKey:@"info"];
                    CGFloat contentH=[contentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:contentLabel.font].height;
                    contentLabel.frame=CGRectMake(15, 0, kScreenWidth-30, contentH);
                    
                    resultDetailBtn.frame=CGRectMake(15, contentLabel.bottom+15, kScreenWidth-30, 35);
                    
                    self.resultTextView.contentSize=CGSizeMake(kScreenWidth, contentH+40);
                }
            } failure:^(NSString *errorStr) {
                
                
            }];
            
           // 获取积分
            [weakSelf getTaskPointsWithActionType:4 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                if (clickIndex == 1001 || isBack) {
                    // 测量获取积分
                    [weakSelf getTaskPointsWithActionType:5 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                        
                    }]; // 获取积分
                }
            }]; // 获取积分
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [TCHelper sharedTCHelper].isBloodReload=YES;
            
            
            //发送血糖消息提醒
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf sendSugarBloodReminderWithValue:sugarValue minValue:normalMinValue maxValue:normalMaxValue];
            });
        }
        isGetDataSuccess=YES;
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  倒计时
-(void)importTimeProgressAction{
    timeNum--;
    [self.importDataBtn setTitle:[NSString stringWithFormat:@"批量导入%lds",(long)timeNum] forState:UIControlStateNormal];
    if (timeNum<=0) {
        if (timer) {
            [timer invalidate];
            timer=nil;
        }
        
        [self.importDataBtn setTitle:@"批量导入" forState:UIControlStateNormal];
        self.importDataBtn.backgroundColor = [UIColor lightGrayColor];
        self.importDataBtn.userInteractionEnabled = NO;
        
        [self.view makeToast:@"已超出导入限制时间，请在下次测量后批量导入" duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark 发送血糖消息提醒
-(void)sendSugarBloodReminderWithValue:(double)value minValue:(double)minValue maxValue:(double)maxValue{
    NSInteger messageTitle = 0;
    if (value<minValue) {
        messageTitle = 3;
    }else if (value>=minValue&&value<=maxValue){
        messageTitle = 1;
    }else{
        messageTitle = 2;
    }
    NSInteger timeString =[[TCHelper sharedTCHelper] timeSwitchTimestamp:[[TCHelper sharedTCHelper] getCurrentDateTime] format:@"yyyy-MM-dd HH:mm"];
    NSString *timeSlot = [[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodString];
    NSString *messageBody = [NSString stringWithFormat:@"time_slot=%@&glucose=%.1f&status=%ld&measurement_time=%ld",timeSlot,value,(long)messageTitle,(long)timeString];
    [[TCHttpRequest  sharedTCHttpRequest] postMethodWithURL:kV1_3SendMessage body:messageBody success:^(id json) {
        MyLog(@"-------------%@",json);
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- Setters
#pragma mark 连接流程图
-(TCBleConnectView *)bleConnectView{
    if (_bleConnectView==nil) {
        _bleConnectView=[[TCBleConnectView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 90)];
    }
    return _bleConnectView;
}

#pragma mark 测量时段
- (UIButton *)periodButton{
    if (!_periodButton) {
        //测量时段
        _periodButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2,self.bleConnectView.bottom+20, 180, 35)];
        _periodButton.layer.cornerRadius=8;
        _periodButton.backgroundColor=[UIColor bgColor_Gray];
        _periodButton.titleLabel.font=[UIFont systemFontOfSize:14];
        [_periodButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_periodButton setImage:[UIImage imageNamed:@"ic_xty_arrow"] forState:UIControlStateHighlighted];
        [_periodButton setImage:[UIImage imageNamed:@"ic_xty_arrow"] forState:UIControlStateNormal];
        _periodButton.imageEdgeInsets=UIEdgeInsetsMake(0, 140, 0, 0);
        _periodButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [_periodButton addTarget:self action:@selector(chooseSugarPeriodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_periodButton setTitle:[NSString stringWithFormat:@"测量时段：%@",periodString] forState:UIControlStateNormal];
    }
    return _periodButton;
}

#pragma mark  提示图
- (UIImageView *)remindImageView{
    if (!_remindImageView) {
        _remindImageView=[[UIImageView alloc] initWithFrame:CGRectMake(18, self.periodButton.bottom+20, kScreenWidth-36, kScreenWidth-38)];
        _remindImageView.image=[UIImage imageNamed:@"ic_xty_testtips_01"];
    }
    return _remindImageView;
}

#pragma mark 测量
-(UIView *)sugarMeasureView{
    if (!_sugarMeasureView) {
        _sugarMeasureView=[[UIView alloc] initWithFrame:CGRectMake(0, self.periodButton.bottom+10, kScreenWidth, 190)];
        
        mainView=[[TCMeasureMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        [_sugarMeasureView addSubview:mainView];
        
        sugarImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-50)/2, (130-22)/2+5, 50, 22)];
        sugarImgView.image = [UIImage imageNamed:@"xty_ic_nun"];
        [_sugarMeasureView addSubview:sugarImgView];

        resultView=[[TCMeasureResultView alloc] initWithFrame:CGRectMake(0, mainView.bottom+10, kScreenWidth, 60)];
        resultView.periodString=periodString;
        resultView.sugarValue=0.0;
        [_sugarMeasureView addSubview:resultView];
        resultView.hidden=YES;
    }
    return _sugarMeasureView;
}

#pragma mark 文字结果视图
-(UIScrollView *)resultTextView{
    if (!_resultTextView) {
        _resultTextView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.sugarMeasureView.bottom+10, kScreenWidth, kRootViewHeight-self.sugarMeasureView.bottom-40)];
        
        contentLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.numberOfLines=0;
        contentLabel.textColor=[UIColor blackColor];
        contentLabel.font=[UIFont systemFontOfSize:16];
        [_resultTextView addSubview:contentLabel];
        
        resultDetailBtn=[[UIButton alloc] initWithFrame:CGRectZero];
        resultDetailBtn.layer.cornerRadius=8;
        resultDetailBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        [resultDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [resultDetailBtn setImage:[UIImage imageNamed:@"ic_xty_arrow"] forState:UIControlStateHighlighted];
        [resultDetailBtn setImage:[UIImage imageNamed:@"ic_xty_arrow"] forState:UIControlStateNormal];
        resultDetailBtn.imageEdgeInsets=UIEdgeInsetsMake(0, 140, 0, 0);
        resultDetailBtn.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [resultDetailBtn addTarget:self action:@selector(checkResultDetailAction) forControlEvents:UIControlEventTouchUpInside];
        [resultDetailBtn setTitle:[NSString stringWithFormat:@"查看详情"] forState:UIControlStateNormal];
        [_resultTextView addSubview:resultDetailBtn];
        
    }
    return _resultTextView;
}

#pragma mark 批量导入按钮
-(UIButton *)importDataBtn{
    if (!_importDataBtn) {
        _importDataBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, kScreenHeight-50, kScreenWidth-80, 40)];
        [_importDataBtn setTitle:@"批量导入" forState:UIControlStateNormal];
        [_importDataBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _importDataBtn.backgroundColor=kSystemColor;
        _importDataBtn.layer.cornerRadius=5;
        _importDataBtn.clipsToBounds=YES;
        [_importDataBtn addTarget:self action:@selector(batchImportDataAction) forControlEvents:UIControlEventTouchUpInside];
        _importDataBtn.hidden=YES;
    }
    return _importDataBtn;
}
- (UIButton *)bgView{
    if (_bgView==nil) {
        _bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.alpha= 1;
        _bgView.hidden = YES;
    }
    return _bgView;
}
@end
