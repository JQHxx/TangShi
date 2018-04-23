//
//  BaseViewController.m
//  Product
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "SVProgressHUD.h"
#import "TCPointslMallViewController.h"
#import "TCMissionCompletedAlertView.h"
#import <UMMobClick/MobClick.h>
#import "TCFastLoginViewController.h"

@interface BaseViewController ()<UIAlertViewDelegate>{
    UIView        *navView;
    UIButton      *backBtn;
    UILabel       *titleLabel;
    UIButton      *rightBtn;
    BOOL          isBack;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    //ScrollView莫名其妙不能在viewController划到,加上这句解决
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.navigationController setNavigationBarHidden:YES];

    [self customNavBar];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    
    [MobClick endLogPageView:self.baseTitle];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:self.baseTitle];
}

#pragma mark --Response
#pragma mark 返回方法
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 导航栏右侧按钮事件
-(void)rightButtonAction{
    
}

#pragma mark 重新加载
-(void)reloadForNetwork{
    
}

#pragma mark --setters and getters
#pragma mark 隐藏导航栏
-(void)setIsHiddenNavBar:(BOOL)isHiddenNavBar{
    _isHiddenNavBar=isHiddenNavBar;
    navView.hidden=isHiddenNavBar;
}

#pragma mark 隐藏返回按钮
-(void)setIsHiddenBackBtn:(BOOL)isHiddenBackBtn{
    _isHiddenBackBtn=isHiddenBackBtn;
    backBtn.hidden=isHiddenBackBtn;
}
#pragma mark ====== 右按钮是否可以点击 =======
- (void)setRightBtnEnabled:(BOOL)rightBtnEnabled{
    rightBtn.enabled = rightBtnEnabled;
}

#pragma makr 设置导航栏左侧按钮图片
-(void)setLeftImageName:(NSString *)leftImageName{
    _leftImageName=leftImageName;
    if (_leftImageName) {
        backBtn.hidden=NO;
        [backBtn setImage:[UIImage drawImageWithName:_leftImageName size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsZero];
    }
}
#pragma mark 设置导航栏左侧按钮文字
- (void)setLeftTitleName:(NSString *)leftTitleName{
    _leftTitleName = leftTitleName;
    [backBtn setTitle:leftTitleName forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    backBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

#pragma mark 设置导航栏右侧按钮图片
-(void)setRightImageName:(NSString *)rightImageName{
    _rightImageName=rightImageName;
    [rightBtn setImage:[UIImage drawImageWithName:rightImageName size:CGSizeMake(24, 24)] forState:UIControlStateNormal];
}

#pragma mark 设置导航栏右侧按钮文字
-(void)setRigthTitleName:(NSString *)rigthTitleName{
    _rigthTitleName=rigthTitleName;
    [rightBtn setTitle:rigthTitleName forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (rigthTitleName.length>=4) {
        CGSize size = [rigthTitleName sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:16]];
        rightBtn.frame = CGRectMake(kScreenWidth-size.width-5,KStatusHeight +2, size.width, 40);
    }
    rightBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    rightBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
}

#pragma mark 设置标题
-(void)setBaseTitle:(NSString *)baseTitle{
    _baseTitle=baseTitle;
    titleLabel.text=baseTitle;
}

#pragma mark 设置状态栏样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark --Private Methods
#pragma mark 自定义导航栏
-(void)customNavBar{
    navView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
    navView.backgroundColor=kSystemColor;
    [self.view addSubview:navView];
    
    backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back.png"size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, KStatusHeight, 180, 44)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
    [rightBtn addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:rightBtn];

}

#pragma mark --自定义弹出框
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ====== 获取任务积分 =======
- (void)getTaskPointsWithActionType:(NSInteger)actionType isTaskList:(BOOL)isTaskList taskAleartViewClickBlock:(TaskAleartViewClickBlock)taskAleartViewClickBlock{
    self.taskAleartViewClickBlock = taskAleartViewClickBlock;
    // App版本信息
    NSString *version = [NSString getAppVersion];
    NSString *body = [NSString stringWithFormat:@"action_type=%ld&app_version=%@",actionType,version];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KIntegralTask body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            NSInteger points = [[resultDic objectForKey:@"points"] integerValue];
            NSInteger clickNum = [[resultDic objectForKey:@"click_num"] integerValue];
            NSInteger sumNum = [[resultDic objectForKey:@"max_num"] integerValue];
            [weakSelf showTaskSuccessAlertViewWithPoints:points sumNum:sumNum clickNum:clickNum actionType:actionType isTaskList:isTaskList];
            if (self.taskAleartViewClickBlock) {
                self.taskAleartViewClickBlock(100,NO);// 该回调用于判断获取积分成功（发布动态处使用）
            }
        }
    } failure:^(NSString *errorStr) {
        isBack = YES;
        if (self.taskAleartViewClickBlock) {
          self.taskAleartViewClickBlock(1001,isBack);
        }
    }];
}
- (void)showTaskSuccessAlertViewWithPoints:(NSInteger )points sumNum:(NSInteger)sumNum clickNum:(NSInteger)clickNum actionType:(NSInteger)actionType isTaskList:(BOOL)isTaskList{
    NSString *taskSuccessStr = taskSuccessStr = [[TCHelper sharedTCHelper]getTaskNameWithActionType:actionType sumNum:sumNum clickNum:clickNum points:points];
    BOOL isHideRedeem;
    if(actionType == 4) {
        isHideRedeem = YES;
    }else{
        isHideRedeem = NO;
    }
    TCMissionCompletedAlertView *alertView =[[TCMissionCompletedAlertView alloc]initWithTaskSuccessStr:taskSuccessStr points:points rewardIntegralStr:@"" isHideBonusPoints:YES isHideRedeemBtn: isHideRedeem];
    alertView.alertResultBlcok = ^(NSInteger index){
        switch (index) {
            case 1001:
            {
                if (self.taskAleartViewClickBlock) {
                    self.taskAleartViewClickBlock(1001,isBack);
                }
            }
                break;
            case 1002:
            {
                TCPointslMallViewController *mallVC = [[TCPointslMallViewController alloc]init];
                mallVC.isTaskAleartLogin = isTaskList;
                [self.navigationController pushViewController:mallVC animated:YES];
            }
                break;
            default:
                break;
        }
    };
    [alertView show];
}

#pragma mark 快速登录
-(void)fastLoginAction{
    TCFastLoginViewController *loginVC = [[TCFastLoginViewController alloc] init];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)dealloc{
    
}


@end
