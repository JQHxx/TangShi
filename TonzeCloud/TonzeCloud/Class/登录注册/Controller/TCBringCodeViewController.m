//
//  TCBringCodeViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBringCodeViewController.h"
#import "AppDelegate.h"
#import "BaseTabBarViewController.h"
#import "BackScrollView.h"
#import "TCLoginViewController.h"

@interface TCBringCodeViewController ()<UITextFieldDelegate>{
    UITextField     *passWordField;
}
@property (nonatomic,strong)BackScrollView    *backScrollView;
@end

@implementation TCBringCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseTitle=@"输入密码";
    [self initLookCodeView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [passWordField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (passWordField==textField) {
        if ([textField.text length]<20) {
            return YES;
        }
    }
    return NO;
}
#pragma mark -- Event Methods
#pragma mark  设置密码可见
- (void)setGetCodePwVisbleAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    passWordField.secureTextEntry=!sender.selected;
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
#pragma mark -- Event response
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --设置密码
- (void)confirmLoginAction:(UIButton *)sender{
    if (kIsEmptyString(passWordField.text)) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (passWordField.text.length < 6){
        [self.view makeToast:@"请输入6-20位密码" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&hashkey=%@",_phoneNumber,passWordField.text,_hashkey];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUpdatePassword body:body success:^(id json) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[TCLoginViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
                return ;
            }
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Custom Methods
#pragma mark -- 初始化界面
- (void)initLookCodeView{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];

    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 64+40, kScreenWidth, 48)];
    bgview.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:bgview];
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(16,passWordField.top+5, 30, 30)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_code"];
    [bgview addSubview:phoneImg];

    passWordField = [[UITextField alloc] initWithFrame:CGRectMake(40+20, 0,kScreenWidth-100, 48)];
    passWordField.delegate = self;
    passWordField.clearsOnBeginEditing = YES;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.font = [UIFont systemFontOfSize:16];
    passWordField.placeholder = @"请输入6-20位新密码";
    passWordField.keyboardType=UIKeyboardTypeASCIICapable;
    [bgview addSubview:passWordField];
    
    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(60, passWordField.bottom, kScreenWidth-60-20, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
    [bgview addSubview:loginlbl];

    UIButton *seeButton = [[UIButton alloc] initWithFrame:CGRectMake(passWordField.right-10, passWordField.top+15, 20, 20)];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [seeButton addTarget:self action:@selector(setGetCodePwVisbleAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgview addSubview:seeButton];

    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, bgview.bottom+40, kScreenWidth-40, 40)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(confirmLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.tag = 101;
    loginBtn.backgroundColor = kbgBtnColor;
    [self.backScrollView addSubview:loginBtn];
}
@end
