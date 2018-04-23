//
//  TCPasswordViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPasswordViewController.h"
#import "PhoneText.h"
#import "TCValidationViewController.h"

@interface TCPasswordViewController ()<UITextFieldDelegate>{
    
    PhoneText       *loginField;

}
@end
@implementation TCPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"修改密码";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    [self initAlertPassWordView];
}
#pragma mark -- textfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length+string.length > 11)
    {
        return NO;
    }
    return YES;
}
#pragma mark -- Event response
#pragma mark -- 获取验证码
- (void)certainButton{
//    if (kIsEmptyString(loginField.text)) {
//        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
//        return;
//    }
//    if (loginField.text.length!=11) {
//        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
//        return;
//    }
    TCValidationViewController *validationVC = [[TCValidationViewController alloc] init];
    validationVC.codeType = FastLogin;
    validationVC.phoneNumber = loginField.text;
    [self.navigationController pushViewController:validationVC animated:YES];
    
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
- (void)initAlertPassWordView{
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, 200, 30, 30)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_num"];
    [self.view addSubview:phoneImg];
    
    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(40+20, phoneImg.top-8, kScreenWidth-100, 38)];
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.font = [UIFont systemFontOfSize:16];
    loginField.placeholder = @"请输入手机号";
    [self.view addSubview:loginField];

    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(60, loginField.bottom, kScreenWidth-80, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.view addSubview:loginlbl];

    UIButton *certainButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-241)/2, loginlbl.bottom+80, 241, 40)];
    [certainButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [certainButton addTarget:self action:@selector(certainButton) forControlEvents:UIControlEventTouchUpInside];
    certainButton.layer.cornerRadius = 20;
    certainButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [certainButton setBackgroundColor:kSystemColor];
    [self.view addSubview:certainButton];
}
@end
