//
//  TCFirmwareUpgradeViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFirmwareUpgradeViewController.h"
#import "TCUpgradeSuccessViewController.h"
#import "TCNewsetVersionViewController.h"
#import "TCMainDeviceHelper.h"
#import "HttpRequest.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface TCFirmwareUpgradeViewController (){
    AppDelegate *appDelegate;
    
    UILabel  *versionLab;
}

@end

@implementation TCFirmwareUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"固件升级";
    
    appDelegate=kAppDelegate;
    
    [self initFirmwareUpgradeView];
    [self getCurrentVersion];
}

#pragma mark -- Event Response
#pragma mark  检查更新
-(void)checkNewestVersionAction{
    [SVProgressHUD show];
    [HttpRequest getVersionWithDeviceID:[NSString stringWithFormat:@"%ld",(long)self.deviceModel.device_id] withProduct_id:self.deviceModel.product_id withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [self.view makeToast:[HttpRequest getErrorInfoWithErrorCode:err.code] duration:1.0 position:CSToastPositionCenter];
        } else {
            NSDictionary *dic = (NSDictionary *)result;
            //1.判断是否为升级完成
            NSInteger current = [[dic objectForKey:@"current"] integerValue];
            NSInteger newVersion = [[dic objectForKey:@"newest"] integerValue];
            //1.5 更新界面显示
            versionLab.text = [NSString stringWithFormat:@"当前固件版本：V%ld",(long)current];
            
            if (current < newVersion) {
                TCNewsetVersionViewController *newsetVersionVC = [[TCNewsetVersionViewController alloc] init];
                newsetVersionVC.versionDict=dic;
                newsetVersionVC.device=self.deviceModel;
                [self.navigationController pushViewController:newsetVersionVC animated:YES];
            }else if (current >= newVersion){
                TCUpgradeSuccessViewController *upgradeSuccessVC = [[TCUpgradeSuccessViewController alloc] init];
                [self.navigationController pushViewController:upgradeSuccessVC animated:YES];
            }
        }
    }];
}

#pragma mark -- Private Methods
#pragma mark 获取设备当前固件版本
-(void)getCurrentVersion{
    if ([[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"]) {
        if (self.deviceModel && self.deviceModel.device_id>0 && self.deviceModel.product_id && self.deviceModel.product_id.length > 0) {
            [SVProgressHUD show];
            kSelfWeak;
            [HttpRequest getVersionWithDeviceID:[NSString stringWithFormat:@"%ld",(long)self.deviceModel.device_id] withProduct_id:self.deviceModel.product_id withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                [SVProgressHUD dismiss];
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    [weakSelf.view makeToast:[HttpRequest getErrorInfoWithErrorCode:err.code] duration:1.0 position:CSToastPositionCenter];
                } else {
                    NSDictionary *dic = (NSDictionary *)result;
                    NSInteger current = [[dic objectForKey:@"current"] integerValue];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        versionLab.text = [NSString stringWithFormat:@"当前固件版本：V%ld",(long)current];
                    });
                }
            }];
        }
    }
}

#pragma mark 初始化界面
-(void)initFirmwareUpgradeView{
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, kNavHeight+50, 120, 120)];
    imgView.image=[UIImage imageNamed:@"img_h_jtfb"];
    [self.view addSubview:imgView];
    
    versionLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+20, kScreenWidth-60, 30)];
    versionLab.textAlignment=NSTextAlignmentCenter;
    versionLab.font=[UIFont systemFontOfSize:16];
    versionLab.textColor=[UIColor blackColor];
    [self.view addSubview:versionLab];
    
    UIButton *checkButton=[[UIButton alloc] initWithFrame:CGRectMake(30, versionLab.bottom+30, kScreenWidth-60, 40)];
    checkButton.layer.cornerRadius=5;
    checkButton.backgroundColor=kSystemColor;
    checkButton.clipsToBounds=YES;
    [checkButton setTitle:@"检查更新" forState:UIControlStateNormal];
    [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(checkNewestVersionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
}


@end
