//
//  TCRegisterViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRegisterViewController.h"
#import "TCSexViewController.h"
#import "BackScrollView.h"
#import "PhoneText.h"
#import "SSKeychain.h"
#import "UIDevice+Extend.h"
#import "PhoneText.h"
#import "TCBasewebViewController.h"
#import "NSString+Extend.h"
#import "TCUserModel.h"
#import <UMMobClick/MobClick.h>
#import "JPUSHService.h"
#import "HttpRequest.h"
#import "XLinkExportObject.h"


@interface TCRegisterViewController ()<UITextFieldDelegate>{

    PhoneText       *loginField;
    UITextField     *passWordField;
    UITextField     *typenumField;
    UIButton        *obtainBtn;

}
@property (nonatomic,strong)BackScrollView    *backScrollView;
@end
@implementation TCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle=@"注册";
    [self initRegisterView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xlinkRegisterNotification:) name:kOnLogin object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
}

#pragma mark -- NSNotication
#pragma mark 登录云智易回调
-(void)xlinkRegisterNotification:(NSNotification *)noti{
    NSDictionary *result=noti.object;
    MyLog(@"xlinkRegisterNotification -- resutl:%@",result);
    
    int code=[[result objectForKey:@"result"] intValue];
    if (code==0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
    }else{
        [NSUserDefaultsInfos putKey:USER_DIC andValue:nil];
        MyLog(@"登录云智易平台失败：%ld",(long)code);
    }
}

#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginField resignFirstResponder];
    [passWordField resignFirstResponder];
    [typenumField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (loginField==textField) {
        if ([textField.text length]<11) {
            return YES;
        }
    }
    if (passWordField==textField) {
        if ([textField.text length]<20) {
            return YES;
        }
    }
    if (typenumField==textField) {
        if ([textField.text length]<6) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -- Event Methods
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
#pragma mark  获取验证码
- (void)getVerificationCodeAction:(UIButton *)button{
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length != 11){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *body = [NSString stringWithFormat:@"mobile=%@&type=register",loginField.text];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSendSign body:body success:^(id json) {
        __block int timeout=60; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){ //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [obtainBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [obtainBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
                    obtainBtn.backgroundColor = [UIColor whiteColor];
                    obtainBtn.userInteractionEnabled = YES;
                });
            }else{
                int seconds = timeout % 61;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [obtainBtn setTitle:[NSString stringWithFormat:@"%@s",strTime] forState:UIControlStateNormal];
                    obtainBtn.backgroundColor = [UIColor whiteColor];
                    obtainBtn.userInteractionEnabled = NO;
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
        
        [self.view makeToast:@"验证码已发送" duration:1.0 position:CSToastPositionCenter];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

    }];
}
#pragma mark  设置密码可见
- (void)setRegisterPwVisbleAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    passWordField.secureTextEntry=!sender.selected;
}
#pragma mark -- Event Response
#pragma mark -- 糖士用户协议
- (void)consultAction{
    NSString *urlString = [NSString stringWithFormat:@"http://api.360tj.com/article/agreement.html"];
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.type=BaseWebViewTypeUserAgreement;
    webVC.titleText=@"糖士用户协议";
    webVC.urlStr=urlString;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark 返回
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 注册
-(void)registerAction:(UIButton *)sender{
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length !=11||![[loginField.text substringToIndex:1] isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (passWordField.text.length<6) {
        [self.view makeToast:@"密码不能少于6位" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(typenumField.text)) {
        [self.view makeToast:@"验证码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&code=%@&sn=%@network=%@&request_platform=iOS&app_version=%@&phone_sn=%@&phone_version=%@&phone_screen=%@&phone_seller=%@&way=Appstore",loginField.text,passWordField.text,typenumField.text,uuid,[UIDevice getNetworkType],[UIDevice getSoftwareVer],[UIDevice getSystemName],[UIDevice getSystemVersion],[UIDevice getScreenResolution],[UIDevice getCarrierName]];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kRegisterAPI body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (result.count>0) {
            NSString *userKey=[result valueForKey:@"user_key"];
            NSString *userSec=[result valueForKey:@"user_secret"];
            NSString *userToken=[result valueForKey:@"user_token"];
            [NSUserDefaultsInfos putKey:kUserKey andValue:userKey];
            [NSUserDefaultsInfos putKey:kUserSecret andValue:userSec];
            [NSUserDefaultsInfos putKey:kUserToken andValue:userToken];
            [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
            [NSUserDefaultsInfos putKey:kPhoneNumber andValue:loginField.text];
            [NSUserDefaultsInfos putKey:kUserID andValue:[result valueForKey:@"user_id"]];
            
            TCUserModel *user=[[TCUserModel alloc] init];
            [user setValues:result];
            
            NSString *phone=[loginField.text substringWithRange:NSMakeRange(loginField.text.length-4, 4)];
            NSString *nickName=[NSString stringWithFormat:@"糖友_%@",phone];
            [NSUserDefaultsInfos putKey:kNickName andValue:nickName];
            
            NSString *tempStr=isTrueEnvironment?@"zs":@"cs";
            NSString *aliasStr=[NSString stringWithFormat:@"%@_%@",tempStr,loginField.text];
            [JPUSHService setAlias:aliasStr completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                MyLog(@"注册－－－设置别名回调 code:%ld content:%@ seq:%ld", iResCode, iAlias, seq);
            } seq:10000];
            
            [MobClick profileSignInWithPUID:loginField.text];
            
           
            //登录云智易
            [NSUserDefaultsInfos  putKey:kThirdToken andValue:user.token];
            if (!kIsEmptyString(user.token)) {
                [weakSelf registerInXlinkWithToken:user.token];
            }
            
            
            [TCHelper sharedTCHelper].isLogin=YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
            
            // 获取积分
            // App版本信息
            NSString *version = [NSString getAppVersion];
            NSString *body = [NSString stringWithFormat:@"action_type=17&app_version=%@",version];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KIntegralTask body:body success:^(id json) {
                TCSexViewController *sexVC=[[TCSexViewController alloc] init];
                [weakSelf.navigationController pushViewController:sexVC animated:YES];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                TCSexViewController *sexVC=[[TCSexViewController alloc] init];
                [weakSelf.navigationController pushViewController:sexVC animated:YES];
            }];

            //注册成功回调（糖友邀请）
            NSString *registBody = [NSString stringWithFormat:@"invited_mobile=%@",loginField.text];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kRegisterInvite body:registBody success:^(id json) {
                NSLog(@"registerBody==%@",json);
            } failure:^(NSString *errorStr) {
                
            }];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Private Methods
#pragma mark  初始化注册界面
- (void)initRegisterView{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight)];
    _backScrollView.backgroundColor = [UIColor bgColor_Gray ];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];

    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+40, kScreenWidth, 49*3)];
    bgview.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:bgview];

    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(40+20, 0,kScreenWidth-100, 48)];
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.clearsOnBeginEditing = YES;
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.font = [UIFont systemFontOfSize:16];
    loginField.placeholder = @"请输入手机号";
    [bgview addSubview:loginField];

    passWordField = [[UITextField alloc] initWithFrame:CGRectMake(40+20,loginField.bottom+1,kScreenWidth-100, 48)];
    passWordField.delegate = self;
    passWordField.tag = 100;
    passWordField.clearsOnBeginEditing = YES;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.font = [UIFont systemFontOfSize:16];
    passWordField.placeholder = @"请输入6-20位密码";
    passWordField.secureTextEntry = YES;
    [bgview addSubview:passWordField];
    
    typenumField = [[PhoneText alloc] initWithFrame:CGRectMake(40+20, passWordField.bottom+1,kScreenWidth-160, 48)];
    typenumField.delegate = self;
    typenumField.tag = 100;
    typenumField.clearsOnBeginEditing = YES;
    typenumField.returnKeyType=UIReturnKeyDone;
    typenumField.font = [UIFont systemFontOfSize:16];
    typenumField.placeholder = @"验证码";
    [bgview addSubview:typenumField];
    
    NSArray   *imgArray = @[@"ic_login_num",@"ic_login_code",@"ic_login_msg"];
    for (int i=0; i<3; i++) {
            UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, loginField.top+20+49*i, 30, 30)];
            phoneImg.image = [UIImage imageNamed:imgArray[i]];
            [bgview addSubview:phoneImg];
        
            UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(60, loginField.bottom+49*i, kScreenWidth-60-20, 1)];
            loginlbl.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
            [bgview addSubview:loginlbl];

        if (i==1) {
            UIButton *seeButton = [[UIButton alloc] initWithFrame:CGRectMake(passWordField.right-10, loginField.bottom+49+70, 30, 20)];
            [seeButton setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
            [seeButton setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
            [seeButton addTarget:self action:@selector(setRegisterPwVisbleAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:seeButton];
        }else if (i==2) {
            obtainBtn = [[UIButton alloc] initWithFrame:CGRectMake(typenumField.right+1, typenumField.top+9, 80, 30)];
            [obtainBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            obtainBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [obtainBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
            obtainBtn.backgroundColor =[UIColor whiteColor];
            obtainBtn.tag = 100;
            [obtainBtn addTarget:self action:@selector(getVerificationCodeAction:) forControlEvents:UIControlEventTouchUpInside];
            [bgview addSubview:obtainBtn];
        }
    }
    
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, bgview.bottom+40,kScreenWidth-40, 40)];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    registerBtn.backgroundColor = kbgBtnColor;
    [self.backScrollView addSubview:registerBtn];
    
    UIButton *consultBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-320)/2+190, registerBtn.bottom+20, 110, 20)];
    [consultBtn setTitle:@"《糖士用户协议》" forState:UIControlStateNormal];
    [consultBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
    consultBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    consultBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [consultBtn addTarget:self action:@selector(consultAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:consultBtn];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-320)/2, consultBtn.top, 190, 20)];
    textLabel.text = @"点击“注册”表示已阅读并同意";
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.textAlignment = NSTextAlignmentRight;
    textLabel.textColor = [UIColor grayColor];
    [self.view addSubview:textLabel];
}


#pragma mark 登录云智易
-(void)registerInXlinkWithToken:(NSString *)token{
    NSString *accountID=[[TCHelper sharedTCHelper] tokenToAccountId:token];
    [NSUserDefaultsInfos putKey:USER_ID andValue:accountID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HttpRequest thirdAuthWithOpenID:accountID withToken:token didLoadData:^(id result, NSError *err) {
            if (!err) {
                [NSUserDefaultsInfos putKey:USER_DIC andValue:result];
                NSNumber *user_id=[result objectForKey:@"user_id"];
                NSString *access_token=[result objectForKey:@"access_token"];
                NSString *authorize=[result objectForKey:@"authorize"];
                
                //同步昵称到云智易后台
                NSString *nickName=[NSUserDefaultsInfos getValueforKey:kNickName];
                [HttpRequest modifyAccountNickname:nickName withUserID:user_id withAccessToken:access_token didLoadData:^(id result, NSError *err) {
                    
                }];
                
                //登录云智易
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[XLinkExportObject sharedObject] start];
                    [[XLinkExportObject sharedObject] setSDKProperty:SDK_DOMAIN withKey:PROPERTY_CM_SERVER_ADDR];
                    [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
                });
                
                //同步云智易用户id
                NSString *body=[NSString stringWithFormat:@"uid=%@",user_id];
                [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kSyncXlinkUserID body:body success:^(id json) {
                    
                } failure:^(NSString *errorStr) {
                    
                }];
            }else{
                MyLog(@"云智易第三方用户认证失败,error--code:%ld,error:%@",err.code,err.localizedDescription);
            }
        }];
    });
}

@end
