//
//  TCValidationViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCValidationViewController.h"
#import "TCUserModel.h"
#import "JPUSHService.h"
#import "XLinkExportObject.h"
#import "TCSexViewController.h"
#import "HttpRequest.h"
#import "TCLocialNotificationManager.h"
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMError.h>
#import "BaseTabBarViewController.h"
#import "AppDelegate.h"
#import "ChatHelper.h"
#import "TCNewPassWordViewController.h"
#import "QLVerificationCodeView.h"

@interface TCValidationViewController (){
    
    UIButton        *obtainBtn;
}

@property (nonatomic ,strong) QLVerificationCodeView *verificationCodeView;
@end

@implementation TCValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"验证码";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initVerificationCodeView];
    [self getVerificationCodeAction];
}
#pragma mark ====== Event  Response =======
#pragma mark -- getTextFieldContentDelegate
#pragma mark -- 验证码输入完成回调
-(void)returnTextFieldContent:(NSString *)content{
    
    if (_codeType == ChangePassWord) {
        NSString *body = [NSString stringWithFormat:@"code=%@",content];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KCheckCode body:body success:^(id json) {
            
            TCNewPassWordViewController *chanagepassWordVC = [[TCNewPassWordViewController alloc]init];
            chanagepassWordVC.isChangePassWord = YES;
            chanagepassWordVC.messageCode = content;
            [weakSelf.navigationController pushViewController:chanagepassWordVC animated:YES];
            
        } failure:^(NSString *errorStr) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                   [_verificationCodeView celanVerificationCode];  // 清空验证码
                }
            }];
            [alertView show];
        }];
    }else if (_codeType == ForgetPassWord){
        NSString *body = [NSString stringWithFormat:@"mobile=%@&code=%@",_phoneNumber,content];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kForgetPassword body:body success:^(id json) {
            NSDictionary *resultDic = [json objectForKey:@"result"];
            if (kIsDictionary(resultDic)) {
                NSString *hashkey = [resultDic objectForKey:@"hashkey"];
                TCNewPassWordViewController *forgetpassWordVC = [[TCNewPassWordViewController alloc]init];
                forgetpassWordVC.isChangePassWord = NO;
                forgetpassWordVC.messageCode = content;
                forgetpassWordVC.phoneNumber = _phoneNumber;
                forgetpassWordVC.hashkeyStr = hashkey;
                [weakSelf.navigationController pushViewController:forgetpassWordVC animated:YES];
            }
        } failure:^(NSString *errorStr) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [_verificationCodeView celanVerificationCode]; // 清空验证码
                }
            }];
            [alertView show];
        }];
    }else{
        [self registTonzeCloudWithContent:content];
    }
}
#pragma mark -- 快速登录注册
- (void)registTonzeCloudWithContent:(NSString *)content{
    
        NSLog(@"%@================验证码",content);
        NSString *body = [NSString stringWithFormat:@"mobile=%@&code=%@&sn=%@network=%@&request_platform=iOS&app_version=%@&phone_sn=%@&phone_version=%@&phone_screen=%@&phone_seller=%@&way=Appstore&type=2",self.phoneNumber,content,[[TCHelper sharedTCHelper] deviceUUID],[UIDevice getNetworkType],[UIDevice getSoftwareVer],[UIDevice getSystemName],[UIDevice getSystemVersion],[UIDevice getScreenResolution],[UIDevice getCarrierName]];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kRegisterAPI body:body success:^(id json) {
            
            NSString *type = [json objectForKey:@"type"];
            //快速注册
            if ([type isEqualToString:@"register"]) {
                NSDictionary *result=[json objectForKey:@"result"];
                if (result.count>0) {
                    NSString *userKey=[result valueForKey:@"user_key"];
                    NSString *userSec=[result valueForKey:@"user_secret"];
                    NSString *userToken=[result valueForKey:@"user_token"];
                    [NSUserDefaultsInfos putKey:kUserKey andValue:userKey];
                    [NSUserDefaultsInfos putKey:kUserSecret andValue:userSec];
                    [NSUserDefaultsInfos putKey:kUserToken andValue:userToken];
                    [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
                    [NSUserDefaultsInfos putKey:kPhoneNumber andValue:self.phoneNumber];
                    [NSUserDefaultsInfos putKey:kUserID andValue:[result valueForKey:@"user_id"]];
                    
                    TCUserModel *user=[[TCUserModel alloc] init];
                    [user setValues:result];
                    
                    NSString *phone=[self.phoneNumber substringWithRange:NSMakeRange(self.phoneNumber.length-4, 4)];
                    NSString *nickName=[NSString stringWithFormat:@"糖友_%@",phone];
                    [NSUserDefaultsInfos putKey:kNickName andValue:nickName];
                    
                    NSString *tempStr=isTrueEnvironment?@"zs":@"cs";
                    NSString *aliasStr=[NSString stringWithFormat:@"%@_%@",tempStr,self.phoneNumber];
                    [JPUSHService setAlias:aliasStr completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        MyLog(@"注册－－－设置别名回调 code:%ld content:%@ seq:%ld", (long)iResCode, iAlias, seq);
                    } seq:10000];
                    
                    [MobClick profileSignInWithPUID:self.phoneNumber];
                    
                    
                    //登录云智易
                    [NSUserDefaultsInfos  putKey:kThirdToken andValue:user.token];
                    if (!kIsEmptyString(user.token)) {
                        [weakSelf loginInXlinkWithToken:user.token];
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
                    NSString *registBody = [NSString stringWithFormat:@"invited_mobile=%@",self.phoneNumber];
                    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kRegisterInvite body:registBody success:^(id json) {
                        NSLog(@"registerBody==%@",json);
                    } failure:^(NSString *errorStr) {
                        
                    }];
                }
                
            }else{
                //快速登录
                NSDictionary *result=[json objectForKey:@"result"];
                if (result.count>0) {
                    
                    
                    NSString *userKey=[result valueForKey:@"user_key"];
                    NSString *userSec=[result valueForKey:@"user_secret"];
                    NSString *userToken=[result valueForKey:@"user_token"];
                    NSString *phoneStr=[result valueForKey:@"mobile"];
                    NSString *photoStr=[result valueForKey:@"photo"];
                    

                    [NSUserDefaultsInfos putKey:kUserKey andValue:userKey];
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
                    
                    [MobClick profileSignInWithPUID:self.phoneNumber];
                    
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
                        [weakSelf.view endEditing:YES];
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
            }
            
        } failure:^(NSString *errorStr) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                   // 清空验证码
                    [_verificationCodeView celanVerificationCode];
                }
            }];
            [alertView show];
//            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
}
#pragma mark -- Event Response

#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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

#pragma mark -- 登录云智易
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
#pragma mark  获取验证码
- (void)getVerificationCodeAction{

    NSString *typeStr;
    if (_codeType == ChangePassWord) {
        typeStr = @"modifyPwd";
    }else if (_codeType == ForgetPassWord){
        typeStr = @"forget";
    }else if(_codeType == FastLogin){
        typeStr = @"login";
    }
    
    NSString *body = [NSString stringWithFormat:@"mobile=%@&type=%@",self.phoneNumber,typeStr];
    kSelfWeak;
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
                    [obtainBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
                    [obtainBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
                    obtainBtn.backgroundColor = [UIColor bgColor_Gray];
                    obtainBtn.userInteractionEnabled = YES;
                });
            }else{
                int seconds = timeout % 61;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [obtainBtn setTitle:[NSString stringWithFormat:@"%@s",strTime] forState:UIControlStateNormal];
                    obtainBtn.backgroundColor = [UIColor bgColor_Gray];
                    obtainBtn.userInteractionEnabled = NO;
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
        [weakSelf.view makeToast:@"验证码已发送" duration:1.0 position:CSToastPositionCenter];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [obtainBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [obtainBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        obtainBtn.backgroundColor = [UIColor bgColor_Gray];
        obtainBtn.userInteractionEnabled = YES;
    }];
}
#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initVerificationCodeView{

    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, kScreenWidth, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.text = @"已发送验证码至";
    [self.view addSubview:titleLabel];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, kScreenWidth, 20)];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    phoneLabel.font = [UIFont systemFontOfSize:15];
    phoneLabel.text = self.phoneNumber;
    [self.view addSubview:phoneLabel];

    _verificationCodeView = [[QLVerificationCodeView alloc]initWithFrame:CGRectMake(15, phoneLabel.bottom + 30, kScreenWidth - 30, (kScreenWidth - 30 - 50)/6)];
    _verificationCodeView.selectedColor = kSystemColor;
    _verificationCodeView.deselectColor = [UIColor colorWithHexString:@"0xd2d2d2"];
    _verificationCodeView.VerificationCodeNum = 6;
    _verificationCodeView.Spacing = 10;//每个格子间距属性
    kSelfWeak;
    _verificationCodeView.vertificationCodeBlock = ^(NSString *codeStr) {
        [weakSelf returnTextFieldContent:codeStr];
    };
    [self.view addSubview:self.verificationCodeView];
    
    
    obtainBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-25-100, self.verificationCodeView.bottom+20, 100, 40)];
    obtainBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [obtainBtn setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateNormal];
    obtainBtn.backgroundColor =[UIColor bgColor_Gray];
    obtainBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    obtainBtn.tag = 100;
    [obtainBtn addTarget:self action:@selector(getVerificationCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:obtainBtn];
}


@end
