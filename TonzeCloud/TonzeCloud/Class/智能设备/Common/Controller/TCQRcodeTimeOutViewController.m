//
//  TCQRcodeTimeOutViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCQRcodeTimeOutViewController.h"
#import "TCAddDeviceViewController.h"

@interface TCQRcodeTimeOutViewController ()

@end

@implementation TCQRcodeTimeOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"添加设备";
    
    [self initTimeOutView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"添加设备－添加失败"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"添加设备－添加失败"];
}

-(void)reScanDeviceAction{
    /*
    BOOL flag=NO;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCAddDeviceViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            flag=YES;
            break;
        }
    }
    if (!flag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
     */
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 初始化界面
-(void)initTimeOutView{
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 100, 100, 100)];
    imgView.image=[UIImage imageNamed:@"pub_ic_cha"];
    [self.view addSubview:imgView];
    
    UILabel *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+20, kScreenWidth-60, 30)];
    titleLbl.text=@"添加失败";
    titleLbl.textAlignment=NSTextAlignmentCenter;
    titleLbl.font=[UIFont systemFontOfSize:16];
    titleLbl.textColor=[UIColor blackColor];
    [self.view addSubview:titleLbl];
    
    UILabel *detailLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, titleLbl.bottom, kScreenWidth-40, 30)];
    detailLbl.textColor=[UIColor lightGrayColor];
    detailLbl.text=@"二维码有误或已失效";
    detailLbl.font=[UIFont systemFontOfSize:14];
    detailLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:detailLbl];
    
    UIButton  *btn=[[UIButton alloc] initWithFrame:CGRectMake(50, detailLbl.bottom+20, kScreenWidth-100, 40)];
    btn.backgroundColor=kSystemColor;
    [btn setTitle:@"重新扫描" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(reScanDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
@end
