//
//  TCUpgradeSuccessViewController.m
//  TonzeCloud
//
//  Created by vision on 17/9/5.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCUpgradeSuccessViewController.h"
#import "TCFirmwareUpgradeViewController.h"

@interface TCUpgradeSuccessViewController ()

@end

@implementation TCUpgradeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"固件升级";
    
    [self initUpgradeSuccessView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"固件升级-当前是最新固件版本"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"固件升级-当前是最新固件版本"];
}

#pragma mark Event Response
#pragma mark 确定
-(void)confirmAction{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isMemberOfClass:[TCFirmwareUpgradeViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
}

#pragma mark 初始化界面
-(void)initUpgradeSuccessView{
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, kNavHeight+50, 120, 120)];
    imgView.image=[UIImage imageNamed:@"img_h_jtfb"];
    [self.view addSubview:imgView];
    
    UILabel *versionLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+20, kScreenWidth-60, 30)];
    versionLab.textAlignment=NSTextAlignmentCenter;
    versionLab.font=[UIFont systemFontOfSize:16];
    versionLab.textColor=[UIColor blackColor];
    versionLab.text=@"当前已是最新固件版本";
    [self.view addSubview:versionLab];
    
    UIButton *checkButton=[[UIButton alloc] initWithFrame:CGRectMake(30, versionLab.bottom+30, kScreenWidth-60, 40)];
    checkButton.layer.cornerRadius=5;
    checkButton.backgroundColor=kSystemColor;
    checkButton.clipsToBounds=YES;
    [checkButton setTitle:@"确定" forState:UIControlStateNormal];
    [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
}

@end
