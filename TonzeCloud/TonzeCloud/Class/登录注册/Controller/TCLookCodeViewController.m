//
//  TCLookCodeViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLookCodeViewController.h"
#import "TCBringCodeViewController.h"
#import "BackScrollView.h"
#import "PhoneText.h"
#import "TCValidationViewController.h"

@interface TCLookCodeViewController ()<UITextFieldDelegate>{
    PhoneText       *loginField;
    UIButton        *_getCodeBtn;
}
@property (nonatomic,strong)BackScrollView    *backScrollView;
@end

@implementation TCLookCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_isChangePassWord) {
        self.baseTitle = @"修改密码";
    }else{
        self.baseTitle=@"忘记密码";
    }
    [self initLookCodeView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (loginField.text.length+string.length>0) {
        if (loginField.text.length+string.length==11) {
            _getCodeBtn.enabled = YES;
            _getCodeBtn.backgroundColor = kbgBtnColor;
        }
    }
    if (1 == range.length) {//按下回格键
        _getCodeBtn.enabled = NO;
        _getCodeBtn.backgroundColor = UIColorFromRGB(0x9ae9c9);
        return YES;
    }
    if (loginField==textField) {
        if ([textField.text length]<11) {
            return YES;
        }
    }
    return NO;
}
#pragma mark -- Event Response
#pragma mark  获取验证码
- (void)getVerifyCodeAction{
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length !=11) {
        [self.view makeToast:@"手机号输入有误" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (![[loginField.text substringToIndex:1] isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:0.5 position:CSToastPositionCenter];
        return;
    }
    
    if (!_isChangePassWord) {
        TCValidationViewController *validationVC = [[TCValidationViewController alloc]init];
        validationVC.codeType = _isChangePassWord ? ChangePassWord  :  ForgetPassWord;
        validationVC.phoneNumber = loginField.text;
        [self.navigationController pushViewController:validationVC animated:YES];
    }else{
        TCValidationViewController *validationVC = [[TCValidationViewController alloc]init];
        validationVC.codeType = _isChangePassWord ? ChangePassWord  :  ForgetPassWord;
        validationVC.phoneNumber = loginField.text;
        [self.navigationController pushViewController:validationVC animated:YES];
    }
}
#pragma mark -- Event response
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
#pragma mark -- Custom Methods
#pragma mark -- 初始化注册界面
- (void)initLookCodeView{
    
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];

    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(48 + 8 ,kNewNavHeight + 28 ,kScreenWidth - 48- 25, 45)];
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.clearsOnBeginEditing = YES;
    loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.font = [UIFont systemFontOfSize:15];
    loginField.placeholder = @"手机号码";
    [self.backScrollView addSubview:loginField];
    if (_isChangePassWord) {
        NSString *phoneNumber = [NSUserDefaultsInfos getValueforKey:kPhoneNumber];
        loginField.text = phoneNumber;
        loginField.enabled = NO;
    }
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18,loginField.top + 8, 30, 30)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_num"];
    [_backScrollView addSubview:phoneImg];
    
    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, loginField.bottom, kScreenWidth-36, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
    [self.backScrollView addSubview:loginlbl];
    
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, loginField.bottom+ 30, kScreenWidth-38, 48)];
    [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getCodeBtn setBackgroundColor:_isChangePassWord ? kbgBtnColor  : UIColorFromRGB(0x9ae9c9)];
    _getCodeBtn.layer.cornerRadius = 2;
    _getCodeBtn.enabled = _isChangePassWord ? YES : NO;
    [_getCodeBtn addTarget:self action:@selector(getVerifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:_getCodeBtn];
}
@end
