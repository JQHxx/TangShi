//
//  TCFastLoginViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCFastLoginViewController.h"
#import "PhoneText.h"
#import "BackScrollView.h"
#import "MYCoreTextLabel.h"
#import "TCLoginViewController.h"
#import "TCBasewebViewController.h"
#import "TCValidationViewController.h"
#import "AppDelegate.h"

@interface TCFastLoginViewController ()<UITextFieldDelegate,MYCoreTextLabelDelegate>{

    PhoneText      *loginField;
    UIButton       *nextButton;
    UIButton       *seleteButton;
}
@property (nonatomic,strong)BackScrollView    *backScrollView;
@end

@implementation TCFastLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isHiddenNavBar = YES; 
    
    [self initFastLoginView];
}
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (loginField.text.length+string.length>0) {
        seleteButton.selected=YES;
        if (loginField.text.length+string.length==11) {
            nextButton.enabled = seleteButton.selected;
            nextButton.backgroundColor = kbgBtnColor;
        }
    }
    if (1 == range.length) {//按下回格键
        nextButton.enabled = NO;
        nextButton.backgroundColor = [UIColor colorWithHexString:@"0x9ae9c9"];
        return YES;
    }
    if (loginField==textField) {
        if ([textField.text length]<11) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- MYCoreTextLabelDelegate
#pragma mark -- 点击标记区域
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    NSLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([clickString isEqualToString:@"普通登录"]) {
        TCLoginViewController *loginVC = [[TCLoginViewController alloc] init];
        loginVC.isGuidanceIn=self.isGuidanceIn;
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"http://api.360tj.com/article/agreement.html"];
        TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
        webVC.type=BaseWebViewTypeUserAgreement;
        webVC.titleText=@"糖士用户协议";
        webVC.urlStr=urlString;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
#pragma mark -- 退出
- (void)closeButton{
    if (self.isGuidanceIn) {
        BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
        AppDelegate *appDelegate=kAppDelegate;
        appDelegate.window.rootViewController=tabbarVC;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
#pragma mark -- 下一步
- (void)nextStepAction:(UIButton *)button{
    [loginField resignFirstResponder];
    NSString *str = nil;
    if (!kIsEmptyString(loginField.text)) {
        str = [loginField.text substringToIndex:1];
    }
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length != 11||![str isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    TCValidationViewController *validationVC = [[TCValidationViewController alloc] init];
    validationVC.codeType = FastLogin;
    validationVC.phoneNumber = loginField.text;
    validationVC.isGuidanceIn = self.isGuidanceIn;
    [self.navigationController pushViewController:validationVC animated:YES];
}
#pragma mark -- 选择用户协议
- (void)seleteAgreement:(UIButton *)button{
    button.selected=!button.selected;
    seleteButton.selected=button.selected;
    if (loginField.text.length==11&&seleteButton.selected) {
        nextButton.enabled = YES;
        nextButton.backgroundColor = kbgBtnColor;
    }else{
        nextButton.enabled = NO;
        nextButton.backgroundColor =[UIColor colorWithHexString:@"0x9ae9c9"];
    }
}
#pragma mark -- Private Methods
#pragma mark  初始化登陆界面
- (void)initFastLoginView{

    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];
    
    UIButton *cloceBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    cloceBtn.frame = CGRectMake(kScreenWidth - 50, 20, 40 , 40);
    [cloceBtn setImage:[UIImage imageNamed:@"ic_top_close"] forState:UIControlStateNormal];
    [cloceBtn addTarget:self action:@selector(closeButton) forControlEvents:UIControlEventTouchUpInside];
    [cloceBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    [self.backScrollView addSubview:cloceBtn];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tangshi_logo"];
    [self.backScrollView addSubview:imgView];
    
    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(18+30, imgView.bottom+60, kScreenWidth-66, 38)];
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.font = [UIFont systemFontOfSize:16];
    loginField.placeholder = @"手机号码";
    [self.backScrollView addSubview:loginField];

    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, loginField.bottom, kScreenWidth-36, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.backScrollView addSubview:loginlbl];
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, loginField.top+10, 20, 20)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_num"];
    [self.backScrollView addSubview:phoneImg];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(18, loginField.bottom + 24, kScreenWidth-36, 45)];
    nextButton.selected = NO;
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    nextButton.backgroundColor = [UIColor colorWithHexString:@"0x9ae9c9"];
    [nextButton addTarget:self action:@selector(nextStepAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:nextButton];
    
    seleteButton = [[UIButton alloc] initWithFrame:CGRectMake(nextButton.left, nextButton.bottom+20, 20, 20)];
    [seleteButton setImage:[UIImage imageNamed:@"pub_ic_unpick"] forState:UIControlStateNormal];
    [seleteButton setImage:[UIImage imageNamed:@"pub_ic_pick"] forState:UIControlStateSelected];
    [seleteButton addTarget:self action:@selector(seleteAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:seleteButton];
    seleteButton.selected= YES;
    
    MYCoreTextLabel *agreementLabel = [[MYCoreTextLabel alloc] initWithFrame:CGRectZero];
    agreementLabel.lineSpacing = 1.5;
    agreementLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    agreementLabel.textFont = [UIFont systemFontOfSize:12.f];   //设置普通内容文字大小
    agreementLabel.textColor = [UIColor colorWithHexString:@"0x939393"];   // 设置普通内容文字颜色
    agreementLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
    //设置关键字的属性
    agreementLabel.customLinkFont = [UIFont systemFontOfSize:12];
    agreementLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    agreementLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    [agreementLabel setText:@"未注册糖士的手机号，登录时将自动注册，且代表您已阅读并同意《糖士用户协议》。" customLinks:@[@"《糖士用户协议》"] keywords:@[@""]];
    CGSize size = [agreementLabel sizeThatFits:CGSizeMake(nextButton.width-seleteButton.width, [UIScreen mainScreen].bounds.size.height)];
    agreementLabel.frame = CGRectMake(seleteButton.right, seleteButton.top, size.width, size.height);
    [self.backScrollView addSubview:agreementLabel];
    
    MYCoreTextLabel *LoginLabel = [[MYCoreTextLabel alloc] initWithFrame:CGRectZero];
    LoginLabel.lineSpacing = 1.5;
    LoginLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    LoginLabel.textFont = [UIFont systemFontOfSize:15.f];   //设置普通内容文字大小
    LoginLabel.textColor = [UIColor colorWithHexString:@"0x959595"];   // 设置普通内容文字颜色
    LoginLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
    //设置关键字的属性
    LoginLabel.customLinkFont = [UIFont systemFontOfSize:15];
    LoginLabel.customLinkColor = kbgBtnColor;  //设置关键字颜色
    LoginLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    [LoginLabel setText:@"已有帐号，普通登录" customLinks:@[@"普通登录"] keywords:@[@""]];
    CGSize loginSize = [LoginLabel sizeThatFits:CGSizeMake(kScreenWidth, [UIScreen mainScreen].bounds.size.height)];
    LoginLabel.frame = CGRectMake((kScreenWidth-loginSize.width)/2, kScreenHeight-loginSize.height-40, loginSize.width, loginSize.height);
    [self.backScrollView addSubview:LoginLabel];
    self.backScrollView.contentSize = CGSizeMake(kScreenWidth, LoginLabel.bottom+20);
}
@end
