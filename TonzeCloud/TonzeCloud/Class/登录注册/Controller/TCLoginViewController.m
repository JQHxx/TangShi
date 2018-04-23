//
//  TCLoginViewController.m
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import "TCLoginViewController.h"
#import "TCRegisterViewController.h"
#import "TCLookCodeViewController.h"
#import "BaseTabBarViewController.h"
#import "AppDelegate.h"
#import "BackScrollView.h"
#import "PhoneText.h"
#import "TCSexViewController.h"
#import "TCUserModel.h"
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMError.h>
#import "TTGlobalUICommon.h"
#import <UMMobClick/MobClick.h>
#import "JPUSHService.h"
#import "TCLocialNotificationManager.h"
#import "IQKeyboardManager.h"
#import "XLinkExportObject.h"
#import "HttpRequest.h"
#import "ChatHelper.h"
#import "TCFastLoginViewController.h"

@interface TCLoginViewController ()<UITextFieldDelegate>{
    PhoneText      *loginField;
    UITextField    *passWordField;
    UIView        *navView;
}
@property (nonatomic,strong)BackScrollView    *backScrollView;
/// 登录小菊花
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseTitle=@"登录";
    self.isHiddenNavBar = YES;
    
    [self initLoginView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isGuidanceIn) {
        self.isHiddenNavBar=YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xlinkLoginNotification:) name:kOnLogin object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"002" type:1];
#endif
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.backScrollView endEditing:YES];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"002" type:2];
#endif

    if (self.isGuidanceIn) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

#pragma mark -- NSNotication
#pragma mark 登录云智易平台
-(void)xlinkLoginNotification:(NSNotification *)noti{
    NSDictionary *result=noti.object;
    MyLog(@"xlinkLoginNotification -- resutl:%@",result);
    int code=[[result objectForKey:@"result"] intValue];
    if (code==0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
    }else{
        [NSUserDefaultsInfos putKey:USER_DIC andValue:nil];
        MyLog(@"登录云智易平台失败：%ld",(long)code);
    }
}

#pragma mark 键盘弹出
-(void)loginKeyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void(^animation)() = ^{
        if (passWordField.bottom+60>keyBoardBounds.origin.y) {
            self.backScrollView.frame=CGRectMake(0, -(loginField.bottom+60-keyBoardBounds.origin.y), kScreenWidth, kScreenHeight);
        }
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark  键盘退出
-(void)loginKeyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    void (^animation)(void) = ^void(void) {
        self.backScrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginField resignFirstResponder];
    [passWordField resignFirstResponder];
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
    return NO;
}

#pragma mark -- Event Methods
#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark  设置密码可见
- (void)setPwVisbleAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    passWordField.secureTextEntry=!sender.selected;
}

#pragma mark -- Event Response
#pragma mark ====== 取消登录 =======
- (void)closeAction{
    if (self.isGuidanceIn) {
        BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
        AppDelegate *appDelegate=kAppDelegate;
        appDelegate.window.rootViewController=tabbarVC;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark 注册／找回密码
-(void)registerOrForgetPwAction:(UIButton *)sender{
    if (sender.tag == 101) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"002-01"];
#endif
        [MobClick event:@"201_001001"];

        TCLookCodeViewController *lookCodeVC = [[TCLookCodeViewController alloc] init];
        lookCodeVC.isChangePassWord = NO;
        [self.navigationController pushViewController:lookCodeVC animated:YES];
    }else if(sender.tag == 100){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"002-02"];
#endif
         [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark  点击登陆
- (void)loginAction{
    
    [loginField resignFirstResponder];
    [passWordField resignFirstResponder];
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length != 11){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(passWordField.text)) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (passWordField.text.length < 6){
        [self.view makeToast:@"请输入6-20位密码" duration:1.0 position:CSToastPositionCenter];
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
    
    [self.activityIndicatorView startAnimating]; // 菊花转动
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&sn=%@",loginField.text,passWordField.text,uuid];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kLoginAPI body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (result.count>0) {
            NSString *userKey=[result valueForKey:@"user_key"];
            NSString *userSec=[result valueForKey:@"user_secret"];
            NSString *userToken=[result valueForKey:@"user_token"];
            NSString *phoneStr=[result valueForKey:@"mobile"];
            NSString *photoStr=[result valueForKey:@"photo"];

            [NSUserDefaultsInfos putKey:kUserKey andValue:userKey];
            [NSUserDefaultsInfos putKey:KPassWord andValue:passWordField.text];
            [NSUserDefaultsInfos putKey:kUserSecret andValue:userSec];
            [NSUserDefaultsInfos putKey:kUserToken andValue:userToken];
            [NSUserDefaultsInfos putKey:kPhoneNumber andValue:phoneStr];
            [NSUserDefaultsInfos putKey:kUserPhoto andValue:photoStr];
            [NSUserDefaultsInfos putKey:kUserID andValue:[result valueForKey:@"id"]];
            
            
            //计算每日目标摄入
            if ([[result valueForKey:@"height"] integerValue]>0&&[[result valueForKey:@"weight"] doubleValue]>0.00) {
                [[TCHelper sharedTCHelper] calculateTargetIntakeEnergyWithHeight:[[result valueForKey:@"height"] integerValue] weight:[[result valueForKey:@"weight"] doubleValue] labor:[result valueForKey:@"labour_intensity"]];
            }

            TCUserModel *user=[[TCUserModel alloc] init];
            [user setValues:result];
            
            NSString *phone=[phoneStr substringWithRange:NSMakeRange(user.mobile.length-4, 4)];
            NSString *nickName=kIsEmptyString(user.nick_name)?[NSString stringWithFormat:@"糖友_%@",phone]:user.nick_name;
            [NSUserDefaultsInfos putKey:kNickName andValue:nickName];
            [NSUserDefaultsInfos putKey:kUserPhoto andValue:user.photo];
            
            NSString *tempStr=isTrueEnvironment?@"zs":@"cs";
            NSString *aliasStr=[NSString stringWithFormat:@"%@_%@",tempStr,phoneStr];
            [JPUSHService setAlias:aliasStr completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                MyLog(@"登录－－－设置别名回调 code:%ld content:%@ seq:%ld", (long)iResCode, iAlias, seq);
            } seq:10000];
            
            [MobClick profileSignInWithPUID:loginField.text];
            
            //登录环信
            if (!kIsEmptyString(user.im_username)&&!kIsEmptyString(user.im_password)) {
                [weakSelf loginInHySystemWithImUserName:user.im_username im_password:user.im_password];
            }else{
                [[EMClient sharedClient] logout:NO];
            }
          
            //登录云智易
            [NSUserDefaultsInfos  putKey:kThirdToken andValue:user.token];
            if (!kIsEmptyString(user.token)) {
                [weakSelf loginInXlinkWithToken:user.token];
            }

            [TCHelper sharedTCHelper].isLogin=YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [[TCLocialNotificationManager manager] setLocationNotification];// 设定消息提醒
            [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
            
            if (weakSelf.isGuidanceIn) {
                BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                AppDelegate *appDelegate=kAppDelegate;
                appDelegate.window.rootViewController=tabbarVC;
            }else{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                if (weakSelf.loginSuccess) {
                    weakSelf.loginSuccess();
                }
            }
            
        }
        [weakSelf.activityIndicatorView stopAnimating];
    } failure:^(NSString *errorStr) {
        [weakSelf.activityIndicatorView stopAnimating];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 登录环信
-(void)loginInHySystemWithImUserName:(NSString *)im_username im_password:(NSString *)im_password{
    //异步登陆账号
    MyLog(@"登录环信帐号");
    [NSUserDefaultsInfos putKey:kImUserName andValue:im_username];
    [NSUserDefaultsInfos putKey:kImPassword andValue:im_password];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:im_username password:im_password];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!error) {
                //设置是否自动登录
                MyLog(@"login-- 登录环信成功");
                
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                [[ChatHelper sharedChatHelper] loadAllImExperts];
            } else {
                MyLog(@"error--code:%ld",(long)error.code);
            }
        });
    });
}

#pragma mark 登录云智易
-(void)loginInXlinkWithToken:(NSString *)token{
    NSString *accountID=[[TCHelper sharedTCHelper] tokenToAccountId:token];
    [NSUserDefaultsInfos putKey:USER_ID andValue:accountID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HttpRequest thirdAuthWithOpenID:accountID withToken:token didLoadData:^(id result, NSError *err) {
            if (!err) {
                [NSUserDefaultsInfos putKey:USER_DIC andValue:result];
                NSNumber *user_id=[result objectForKey:@"user_id"];
                NSString *access_token=[result objectForKey:@"access_token"];
                NSString *authorize=[result objectForKey:@"authorize"];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[XLinkExportObject sharedObject] start];
                    [[XLinkExportObject sharedObject] setSDKProperty:SDK_DOMAIN withKey:PROPERTY_CM_SERVER_ADDR];
                    [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
                });
                
                //同步昵称到云智易后台
                NSString *nickName=[NSUserDefaultsInfos getValueforKey:kNickName];
                [HttpRequest modifyAccountNickname:nickName withUserID:user_id withAccessToken:access_token didLoadData:^(id result, NSError *err) {
                    if (err) {
                        MyLog(@"error:%ld,%@",(long)err.code,err.localizedDescription);
                    }
                }];
                
                //同步云智易用户id
                NSString *body=[NSString stringWithFormat:@"uid=%@",user_id];
                [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kSyncXlinkUserID body:body success:^(id json) {
                    
                } failure:^(NSString *errorStr) {
                    
                }];
            }else{
                MyLog(@"云智易第三方用户认证失败,error--code:%ld,error:%@",(long)err.code,err.localizedDescription);
            }
        }];
    });
}

#pragma mark -- Private Methods
#pragma mark  初始化登陆界面
- (void)initLoginView{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tangshi_logo"];
    [self.backScrollView addSubview:imgView];
    
    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(28 + 30, imgView.bottom+60, kScreenWidth-46 - 30, 38)];
    loginField.text = [NSUserDefaultsInfos getValueforKey:@"phoneNumber"];
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.font = [UIFont systemFontOfSize:16];
    loginField.placeholder = @"手机号码";
    [self.backScrollView addSubview:loginField];
    
    passWordField = [[UITextField alloc] initWithFrame:CGRectMake(28+30, loginField.bottom+15, kScreenWidth - 46 - 30 - 40, 38)];
    passWordField.text = [NSUserDefaultsInfos getValueforKey:KPassWord];
    passWordField.clearsOnBeginEditing = YES;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.keyboardType = UIKeyboardTypeASCIICapable;
    passWordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordField.delegate = self;
    passWordField.tag = 101;
    passWordField.placeholder  = @"登录密码";
    passWordField.font = [UIFont systemFontOfSize:16];
    passWordField.secureTextEntry = YES;
    [self.backScrollView addSubview:passWordField];
    
    for (int i= 0; i<2; i++) {
        UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, loginField.top+ 53*i, 30, 30)];
        phoneImg.image = [UIImage imageNamed:i==0?@"ic_login_num":@"ic_login_code"];
        [self.backScrollView addSubview:phoneImg];
        
        UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, loginField.bottom+53*i, kScreenWidth- 36, 1)];
        loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
        [self.backScrollView addSubview:loginlbl];
    }
    
    UIButton *seeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 48, passWordField.top+10, 30, 20)];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [seeButton addTarget:self action:@selector(setPwVisbleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:seeButton];
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(kScreenWidth - 88, passWordField.bottom + 15, 70, 20);
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    forgetBtn.tag = 101;
    [forgetBtn setTitleColor:UIColorFromRGB(0x959595) forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(registerOrForgetPwAction:) forControlEvents:UIControlEventTouchUpInside];
    forgetBtn.titleLabel.font = kFontWithSize(15);
    [self.backScrollView addSubview:forgetBtn];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(18, forgetBtn.bottom + 15, kScreenWidth-36, 48)];
    loginButton.layer.cornerRadius = 2;
    [loginButton setTitle:@" 登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
    loginButton.backgroundColor = kbgBtnColor;
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:loginButton];
    
    UIButton *registBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,loginButton.bottom + 24, kScreenWidth - 20, 20)];
    registBtn.tag = 100;
    [registBtn setTitle:@"快速登录（注册）" forState:UIControlStateNormal];
    registBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [registBtn setTitleColor:UIColorFromRGB(0x05d380) forState:UIControlStateNormal];
    [registBtn addTarget:self action:@selector(registerOrForgetPwAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:registBtn];
    
    [loginButton addSubview:self.activityIndicatorView];
    
    UIButton *cloceBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    cloceBtn.frame = CGRectMake(kScreenWidth - 60, 20, 40 , 40);
    [cloceBtn setImage:[UIImage imageNamed:@"ic_top_close"] forState:UIControlStateNormal];
    [cloceBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [cloceBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    [self.backScrollView addSubview:cloceBtn];
}
#pragma mark ====== dealloc =======

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
}
#pragma mark ====== Getter =======

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView= [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((kScreenWidth-80)/2 - 50, 13 , 22, 22)];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _activityIndicatorView.color  = [UIColor whiteColor];
        _activityIndicatorView.backgroundColor = kSystemColor;
    }
    return _activityIndicatorView;
}

@end
