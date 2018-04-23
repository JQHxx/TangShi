//
//  TCScanFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCScanFriendViewController.h"
#import "SGQRCode.h"
#import "TCAddRelativeFriendViewController.h"
#import "TCAddFriendModel.h"
#import "PhoneText.h"

@interface TCScanFriendViewController ()<SGQRCodeScanManagerDelegate,UITextFieldDelegate>{
    UITextField     *phoneField;
    BOOL            isAddFriend;
    UIButton        *button;
}
@property (nonatomic, strong) SGQRCodeScanManager *manager;

@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@end

@implementation TCScanFriendViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
    [MobClick endLogPageView:@"添加亲友－扫描二维码"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
    [_manager cancelSampleBufferDelegate];
    [MobClick beginLogPageView:@"添加亲友－扫描二维码"];
}
#pragma mark ====== dealloc =======
- (void)dealloc{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = @"添加亲友";
    
   [self.view addSubview:self.scanningView];
   [self setupQRCodeScanning];
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [phoneField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        [button setBackgroundColor:[[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.25]];
        return YES;
    }
    if (phoneField==textField) {
        if ([textField.text length]+string.length<=11) {
            if ([textField.text length]+string.length==11) {
                [button setBackgroundColor:[[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.5]];
            }
            return YES;
        }
    }
    return NO;
}
#pragma mark - - - SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-13-03"];
#endif
    [MobClick event:@"104_003001"];
    NSLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager palySoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        [self loadFriendRequestData:[obj stringValue]];
    } else {
        MyLog(@"暂未识别出扫描的二维码");
    }
}
#pragma mark -- 扫描
- (void)setupQRCodeScanning {
    _manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    _manager.delegate = self;
}
#pragma mark -- 添加亲友
- (void)addFriendForPhone{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-13-05"];
#endif

    [MobClick event:@"104_003002"];
    if (kIsEmptyString(phoneField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (phoneField.text.length !=11||![[phoneField.text substringToIndex:1] isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    isAddFriend=YES;
    [self loadFriendRequestData:phoneField.text];
}
#pragma mark -- 获取添加数据
- (void)loadFriendRequestData:(NSString *)phoneNumber{
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&doSubmit=0",phoneNumber];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFriendRequest body:body success:^(id json) {
        NSDictionary *dict = [json objectForKey:@"result"];
        if (kIsDictionary(dict)) {
            TCAddFriendModel *addFriendModel = [[TCAddFriendModel alloc] init];
            [addFriendModel setValues:dict];
            
            TCAddRelativeFriendViewController *jumpVC = [[TCAddRelativeFriendViewController alloc] init];
            jumpVC.FriendModel = addFriendModel;
            jumpVC.isTaskListLogin = self.isTaskListLogin;
            [weakSelf.navigationController pushViewController:jumpVC animated:YES];
        }
        
    } failure:^(NSString *errorStr) {
        if (isAddFriend) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionBottom];
        }else{
            weakSelf.scanBlock(errorStr);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}
#pragma mark -- setter or getter
- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight)];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth-40, 40)];
        lab.text=@"调用摄影头扫描亲友的二维码，即可与亲友实现绑定，可互相查看血糖数据";
        lab.numberOfLines=0;
        lab.font=[UIFont systemFontOfSize:13];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.textColor=[[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [_scanningView addSubview:lab];
        
        CGFloat scanW = 0.7 * kScreenWidth;
        UILabel *linelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0.3 * (kScreenHeight - scanW - 64) + scanW + 30, kScreenWidth-30, 1)];
        linelabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [_scanningView addSubview:linelabel];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, linelabel.bottom+10, kScreenWidth-100, 20)];
        textLabel.text = @"或手动输入手机号";
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [_scanningView addSubview:textLabel];
        
        phoneField = [[UITextField alloc] initWithFrame:CGRectMake(60, textLabel.bottom+10, kScreenWidth-120, 38)];
        phoneField.placeholder = @"请输入手机号";
        phoneField.textColor = [UIColor whiteColor];
        phoneField.clearButtonMode=UITextFieldViewModeWhileEditing;
        phoneField.font=[UIFont systemFontOfSize:14];
        phoneField.layer.cornerRadius = 3;
        phoneField.textAlignment=NSTextAlignmentCenter;
        phoneField.keyboardType=UIKeyboardTypePhonePad;
        phoneField.layer.borderWidth = 1;
        phoneField.layer.borderColor= [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
        phoneField.delegate=self;
        [phoneField setValue:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forKeyPath:@"_placeholderLabel.textColor"];
        phoneField.backgroundColor = [UIColor clearColor];
        [_scanningView addSubview:phoneField];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(60, phoneField.bottom+20, kScreenWidth-120, 38)];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setBackgroundColor:[[UIColor colorWithHexString:@"0xffffff"] colorWithAlphaComponent:0.25]];
        [button addTarget:self action:@selector(addFriendForPhone) forControlEvents:UIControlEventTouchUpInside];
        [_scanningView addSubview:button];
    }
    return _scanningView;
}
@end
