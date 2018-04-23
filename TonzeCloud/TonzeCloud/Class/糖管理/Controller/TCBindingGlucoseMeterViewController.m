//
//  TCBindingGlucoseMeterViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBindingGlucoseMeterViewController.h"
#import "SGQRCodeScanningView.h"
#import "SGQRCodeScanManager.h"
#import "SGQRCodeHelperTool.h"

/** 扫描内容的 W 值 */
#define scanBorderW 0.7 * self.frame.size.width
/** 扫描内容的 Y 值 */
#define scanBorderY 0.3 * (self.frame.size.height - scanBorderW - 64)

@interface TCBindingGlucoseMeterViewController ()<UITextFieldDelegate,SGQRCodeScanManagerDelegate>
{
    UITextField     *_deviceSnTF;
    UIButton        *_addDeviceBtn;
    UIButton        *_flashlightBtn;
    BOOL            _isAutoOpen;
}
@property (nonatomic, strong) SGQRCodeScanManager *manager;

@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
///
@property (nonatomic ,strong) UIView *flashlightView;

@end

@implementation TCBindingGlucoseMeterViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
    [SGQRCodeHelperTool SG_CloseFlashlight];
}
#pragma mark ====== dealloc =======
- (void)dealloc{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"绑定血糖仪";
    [self setBindingGlucoseMeterUI];
    [self.view addSubview:self.flashlightView];
}
#pragma mark ====== 布局UI =======
- (void)setBindingGlucoseMeterUI{
    [self.view addSubview:self.scanningView];
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    [self.manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    self.manager.delegate = self;
}
#pragma mark ====== 添加设备 =======
- (void)addGlucoseMeterAction{
    [_addDeviceBtn resignFirstResponder];
    if (kIsEmptyString(_deviceSnTF.text)) {
        [self.view makeToast:@"SN号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    [self loadGlucoseMeterRequestData:_deviceSnTF.text type:2];
}
#pragma mark ====== 闪光灯 =======
- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [SGQRCodeHelperTool SG_openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}
- (void)removeFlashlightBtn {
    kSelfWeak;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SGQRCodeHelperTool SG_CloseFlashlight];
        weakSelf.isSelectedFlashlightBtn = NO;
        _flashlightBtn.selected = NO;
    });
}
#pragma mark ====== SGQRCodeScanManagerDelegate =======
-(void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects{
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [self.manager stopRunning];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        [self loadGlucoseMeterRequestData:[obj stringValue] type:1];
    } else {
        MyLog(@"暂未识别出扫描的二维码");
    }
}
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue{
    if (brightnessValue < -0.2  && !_isAutoOpen) {
        [SGQRCodeHelperTool SG_openFlashlight];
        _flashlightBtn.selected = YES;
        _isAutoOpen = YES;
    }
}
#pragma mark ====== 进行绑定 =======
- (void)loadGlucoseMeterRequestData:(NSString *)sn type:(NSInteger)type{
    
    NSString *body = [NSString stringWithFormat:@"sn=%@&type=%ld",sn,(long)type];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KbindSn body:body success:^(id json) {
        [weakSelf.view makeToast:@"绑定成功" duration:1.0 position:CSToastPositionCenter];
        [TCHelper sharedTCHelper].isLoadGPRSGlucoseMeterList = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf showToast:errorStr];
    }];
}
#pragma mark ====== 绑定异常提示信息 =======
- (void)showToast:(NSString *)errorStr{
    NSString *message = errorStr;
    NSString *title = @"提示";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    //改变title的大小和颜色
    NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
    [titleAtt addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, title.length)];
    [titleAtt addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x313131) range:NSMakeRange(0, title.length)];
    [alertController setValue:titleAtt forKey:@"attributedTitle"];
    //改变message的大小和颜色
    NSMutableAttributedString *messageAtt;
    if ([message rangeOfString:@"请先解绑"].location !=NSNotFound) {
        messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
        [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
        [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, message.length)];
        [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 11)];
    }else{
        messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
        [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
        [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, message.length)];
    }
    
    [alertController setValue:messageAtt forKey:@"attributedMessage"];
    kSelfWeak;
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         [weakSelf.manager startRunning];
        MyLog(@"点击了确定");
    }];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_deviceSnTF resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        [_addDeviceBtn setBackgroundColor:[[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.25]];
        return YES;
    }
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}
#pragma mark ====== Setter  =======
- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        
        UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        hearView.backgroundColor = UIColorHex_Alpha(0x110D0A, 0.8);
        [_scanningView addSubview:hearView];
        
        _deviceSnTF = [[UITextField alloc] initWithFrame:CGRectMake(18,(44 - 38)/2, kScreenWidth-150, 38)];
        _deviceSnTF.placeholder = @"或手动输入设备SN码";
        _deviceSnTF.tintColor = kSystemColor;
        _deviceSnTF.textColor = UIColorFromRGB(0xffffff);
        _deviceSnTF.clearButtonMode=UITextFieldViewModeWhileEditing;
        _deviceSnTF.font=[UIFont systemFontOfSize:15];
        _deviceSnTF.textAlignment=NSTextAlignmentLeft;
        _deviceSnTF.keyboardType=UIKeyboardTypeASCIICapable;
        _deviceSnTF.delegate=self;
        [_deviceSnTF setValue:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forKeyPath:@"_placeholderLabel.textColor"];
        _deviceSnTF.backgroundColor = [UIColor clearColor];
        [_scanningView addSubview:_deviceSnTF];
        
        _addDeviceBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 64 - 18 , (44 - 26)/2, 64, 26)];
        [_addDeviceBtn setTitle:@"添加" forState:UIControlStateNormal];
        _addDeviceBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_addDeviceBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        _addDeviceBtn.layer.cornerRadius = 13;
        _addDeviceBtn.layer.borderWidth = 1;
        _addDeviceBtn.layer.borderColor = kSystemColor.CGColor;
        [_addDeviceBtn addTarget:self action:@selector(addGlucoseMeterAction) forControlEvents:UIControlEventTouchUpInside];
        [_scanningView addSubview:_addDeviceBtn];
        
        UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.3 * (kScreenHeight - 0.7 *kScreenWidth - 64) + (0.7 *kScreenWidth)+ 15, kScreenWidth - 20, 20)];
        tipLab.text =@"对准设备的二维码进行扫描";
        tipLab.textAlignment = NSTextAlignmentCenter;
        tipLab.textColor = [UIColor whiteColor];
        tipLab.font = kFontWithSize(12);
        [_scanningView addSubview:tipLab];
    }
    return _scanningView;
}
#pragma mark - - - 闪光灯按钮
- (UIView *)flashlightView{
    if (!_flashlightView) {
        CGFloat flashlightBtnY = 0.3 * (kScreenHeight - 0.7 *kScreenWidth - kNewNavHeight) + (0.7 *kScreenWidth)+ 55 + kNewNavHeight;
        _flashlightView = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth - 60)/2, flashlightBtnY, 60, 60)];
        _flashlightView.layer.cornerRadius = 30;
        _flashlightView.backgroundColor = UIColorFromRGB(0xacacac);
        
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnX = 0.5 * (_flashlightView.width - 40);
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, (_flashlightView.height - 40)/2, 40, 40);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"ic_sao_light_un"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"ic_sao_light_on"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
        [_flashlightView addSubview:_flashlightBtn];
    }
    return _flashlightView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
