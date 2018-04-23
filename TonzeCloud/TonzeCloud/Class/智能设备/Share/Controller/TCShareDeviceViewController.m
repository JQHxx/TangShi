//
//  TCShareDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCShareDeviceViewController.h"
#import "HttpRequest.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "TCDeviceShareHelper.h"
#import "SGQRCode.h"

@interface TCShareDeviceViewController ()<UITextFieldDelegate>{
    UIImageView       *qrcodeImageView;
    UITextField       *phoneTextField;
}

@end

@implementation TCShareDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"分享设备";
   
    [self initShareDeviceView];
    [self createQrcodeImage];
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [phoneTextField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    //判断是否时我们想要限定的那个输入框
    if (phoneTextField == textField)
    {
        if ([toBeString length] > 11)
        {
            textField.text = [toBeString substringToIndex:11];
            return NO;
        }
    }
    return YES;
}

#pragma mark -- Event Response
-(void)shareUserPhoneAction:(UIButton *)sender{
    if (kIsEmptyString(phoneTextField.text)) {
        [self.view makeToast:@"请输入要分享的用户手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *phoneStr=[NSUserDefaultsInfos getValueforKey:kPhoneNumber];
    if ([phoneTextField.text isEqualToString:phoneStr]) {
        [self.view makeToast:@"不能分享设备给自己" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    kSelfWeak;
    [SVProgressHUD show];
    NSString *body=[NSString stringWithFormat:@"mobile=%@",phoneTextField.text];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kGetXlinkUserID body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSString *uid=[result valueForKey:@"uid"];
            if (!kIsEmptyString(uid)) {
                [HttpRequest shareDeviceWithDeviceID:[NSNumber numberWithInteger:weakSelf.model.device_id] withAccessToken:XL_USER_TOKEN withShareAccount:uid withExpire:@(3600*24) didLoadData:^(id result, NSError *err) {
                    [SVProgressHUD dismiss];
                    if (err) {
                        if (err.code==4041011) {
                            [weakSelf.view makeToast:@"帐号不存在，请检查是否拼写有误" duration:1.0 position:CSToastPositionCenter];
                        }else{
                            if (err.code==4031003) {
                                AppDelegate *appDelegate=kAppDelegate;
                                [appDelegate updateAccessToken];
                            }
                            [weakSelf.view makeToast:[HttpRequest getErrorInfoWithErrorCode:err.code] duration:1.0 position:CSToastPositionCenter];
                        }
                    }else{
                        MyLog(@"result=%@",result);
                        [TCDeviceShareHelper sharedTCDeviceShareHelper].isReloadShareList=YES;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf showAlertWithTitle:nil Message:@"邀请已发送，等待用户处理"];
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    }
                }];
            }
        }
    } failure:^(NSString *errorStr) {
        [SVProgressHUD dismiss];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Private methods
#pragma mark 生成二维码
-(void)createQrcodeImage{
    NSDictionary *userDict=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    [HttpRequest shareDeviceInQRcodeWithDeviceID:@(self.model.device_id) withAccessToken:[userDict valueForKey:@"access_token"] withExpire:@(60*20) didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSString *invite_code = [@"tangshi-" stringByAppendingString:[result objectForKey:@"invite_code"]];
            [self performSelectorOnMainThread:@selector(configCodeImageView:) withObject:invite_code waitUntilDone:YES];
        }else{
            if (err.code==4031003) {
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate updateAccessToken];
            }
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

#pragma mark  生成二维码
-(void)configCodeImageView:(NSString *)str{
    
    qrcodeImageView.image = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:str imageViewWidth:210];
}

#pragma mark 初始化界面
-(void)initShareDeviceView{
    UILabel *descLab=[[UILabel alloc] initWithFrame:CGRectMake(20, kNewNavHeight + 20, kScreenWidth-40, 20)];
    descLab.textAlignment=NSTextAlignmentCenter;
    descLab.text=@"用糖士扫描此二维码获取设备分享";
    descLab.textColor=[UIColor colorWithHexString:@"#626262"];
    descLab.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:descLab];
    
    qrcodeImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-210)/2, descLab.bottom+20, 210, 210)];
    [self.view addSubview:qrcodeImageView];
    
    UILabel *expireLab=[[UILabel alloc] initWithFrame:CGRectMake(40, qrcodeImageView.bottom+20, kScreenWidth-80, 20)];
    expireLab.textColor=[UIColor lightGrayColor];
    expireLab.textAlignment=NSTextAlignmentCenter;
    expireLab.font=[UIFont systemFontOfSize:14];
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:@"本二维码有效期为20分钟"];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kSystemColor range:NSMakeRange(8, 2)];
    expireLab.attributedText=attributeStr;
    [self.view addSubview:expireLab];
    
    UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(20, expireLab.bottom+20, kScreenWidth-40, 1)];
    lineLab.backgroundColor=kLineColor;
    [self.view addSubview:lineLab];
    
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(30, lineLab.bottom+24, kScreenWidth-60, 20)];
    titleLab.text=@"或输入对方手机号分享设备";
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.font=[UIFont systemFontOfSize:14];
    titleLab.textColor=[UIColor lightGrayColor];
    [self.view addSubview:titleLab];
    
    phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, titleLab.bottom+10, kScreenWidth-40, 38)];
    phoneTextField.placeholder = @"请输入手机号";
    phoneTextField.textColor = [UIColor colorWithHexString:@"#939393"];
    phoneTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    phoneTextField.font=[UIFont systemFontOfSize:15];
    phoneTextField.layer.cornerRadius = 3;
    phoneTextField.textAlignment=NSTextAlignmentCenter;
    phoneTextField.keyboardType=UIKeyboardTypePhonePad;
    phoneTextField.layer.borderWidth = 1;
    phoneTextField.layer.borderColor= [UIColor colorWithHexString:@"#bfbfbf"].CGColor;
    phoneTextField.delegate=self;
    [self.view addSubview:phoneTextField];
    
    UIButton *shareBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, phoneTextField.bottom+24, 180, 35)];
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shareBtn.backgroundColor=[UIColor colorWithHexString:@"#05d380"];
    shareBtn.layer.cornerRadius=5;
    [shareBtn addTarget:self action:@selector(shareUserPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
}
@end
