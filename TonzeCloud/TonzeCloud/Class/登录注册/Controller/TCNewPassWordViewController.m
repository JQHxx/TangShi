//
//  TCNewPassWorldViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCNewPassWordViewController.h"
#import "BackScrollView.h"
#import "PhoneText.h"
#import "TCUserinfoViewController.h"
#import "TCLoginViewController.h"

@interface TCNewPassWordViewController ()<UITextFieldDelegate>
{
    PhoneText       *passWordField;
    UIButton        *_getCodeBtn;
}
@property (nonatomic,strong) BackScrollView    *backScrollView;
/// 小菊花
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TCNewPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"输入密码";
    [self buildNewPassWorldVC];
}
- (void)buildNewPassWorldVC{
    
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];
    
    passWordField = [[PhoneText alloc] initWithFrame:CGRectMake(48 + 8 , kNewNavHeight + 28 ,kScreenWidth - 48- 18 - 40, 45)];
    passWordField.delegate = self;
    passWordField.tag = 100;
    passWordField.clearsOnBeginEditing = YES;
    passWordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.secureTextEntry = YES;
    passWordField.keyboardType = UIKeyboardTypeASCIICapable;
    passWordField.font = [UIFont systemFontOfSize:15];
    passWordField.placeholder = @"请输入6-20位新密码";
    [passWordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.backScrollView addSubview:passWordField];
    
    UIButton *seeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 48, passWordField.top+ 12, 30, 20)];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [seeButton addTarget:self action:@selector(setPwVisbleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:seeButton];
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18,passWordField.top + 8, 30, 30)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_code"];
    [_backScrollView addSubview:phoneImg];
    
    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, passWordField.bottom, kScreenWidth-36, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
    [self.backScrollView addSubview:loginlbl];
    
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, passWordField.bottom+ 30, kScreenWidth-36, 48)];
    [_getCodeBtn setTitle:@" 完成" forState:UIControlStateNormal];
    [_getCodeBtn setBackgroundColor:UIColorFromRGB(0x9ae9c9)];
    _getCodeBtn.layer.cornerRadius = 2;
    _getCodeBtn.enabled = NO;
    [_getCodeBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:_getCodeBtn];
    
    [_getCodeBtn addSubview:self.activityIndicatorView];
}
#pragma mark ====== Event  Response  =======
#pragma mark ====== 返回 =======
- (void)leftButtonAction{
    if (_isChangePassWord) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)textFieldDidChange:(UITextField *)textField{
    if (textField == passWordField) {
        if ([textField.text length] > 5) {
            [_getCodeBtn setBackgroundColor:kbgBtnColor];
            _getCodeBtn.enabled = YES;
        }else{
            [_getCodeBtn setBackgroundColor:UIColorFromRGB(0x9ae9c9)];
            _getCodeBtn.enabled = NO;
        }
        
        if(textField.text.length > 19) {
            textField.text = [textField.text substringToIndex:19];
        }
    }
}
#pragma mark  设置密码可见
- (void)setPwVisbleAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    passWordField.secureTextEntry=!sender.selected;
}
- (void)completeAction{
    
    if (kIsEmptyString(passWordField.text)) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:CSToastPositionCenter];
    }else if (passWordField.text.length > 19){
        [self.view makeToast:@"密码不可超过20位" duration:1.0 position:CSToastPositionCenter];
    }
    [self.activityIndicatorView  startAnimating];
    
    if (_isChangePassWord) {
        kSelfWeak;
        NSString *body=[NSString stringWithFormat:@"type=2&new_password=%@&code=%@",passWordField.text,_messageCode];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kChangePassWord body:body success:^(id json) {
            [weakSelf.view makeToast:@"修改成功" duration:1.0 position:CSToastPositionCenter];
            // 返回个人信息界面
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[TCUserinfoViewController class]]) {
                    [weakSelf.navigationController popToViewController:temp animated:YES];
                }
            }
            [NSUserDefaultsInfos putKey:KPassWord andValue:passWordField.text];
            [weakSelf.activityIndicatorView stopAnimating];
        } failure:^(NSString *errorStr) {
            [weakSelf.activityIndicatorView stopAnimating];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        // 忘记密码
        NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&hashkey=%@",_phoneNumber,passWordField.text,_hashkeyStr];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUpdatePassword body:body success:^(id json) {
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[TCLoginViewController class]]) {
                    TCLoginViewController *loginVC =(TCLoginViewController *)controller;
                    [self.navigationController popToViewController:loginVC animated:YES];
                }
            }
            [weakSelf.activityIndicatorView stopAnimating];
        } failure:^(NSString *errorStr) {
            [weakSelf.activityIndicatorView stopAnimating];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark ====== UITextFieldDelegate =======

#pragma mark ====== Getter =======

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView= [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((kScreenWidth-80)/2 - 50, 9, 22, 22)];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _activityIndicatorView.color  = [UIColor whiteColor];
        _activityIndicatorView.backgroundColor = kSystemColor;
    }
    return _activityIndicatorView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
