//
//  TCNewsetVersionViewController.m
//  TonzeCloud
//
//  Created by vision on 17/9/5.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCNewsetVersionViewController.h"
#import "AppDelegate.h"
#import "HttpRequest.h"
#import "SVProgressHUD.h"

@interface TCNewsetVersionViewController (){
    
    AppDelegate *appDelegate;
}

@end

@implementation TCNewsetVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate=kAppDelegate;
    
    [self initNewestVersionView];
}

#pragma mark -- Event Response
#pragma mark 立即更新
-(void)upgrageNewestVersionAction{
    [SVProgressHUD show];
    kSelfWeak;
    [HttpRequest upgradeWithDeviceID:[NSString stringWithFormat:@"%ld",(long)self.device.device_id] withProduct_id:self.device.product_id withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [weakSelf.view makeToast:[HttpRequest getErrorInfoWithErrorCode:err.code] duration:1.0 position:CSToastPositionCenter];
        } else {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark 初始化界面
-(void)initNewestVersionView{
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, kNavHeight+50, 120, 120)];
    imgView.image=[UIImage imageNamed:@"img_h_jtfb"];
    [self.view addSubview:imgView];
    
    UILabel *versionLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+20, kScreenWidth-60, 30)];
    versionLab.textAlignment=NSTextAlignmentCenter;
    versionLab.font=[UIFont systemFontOfSize:16];
    versionLab.textColor=[UIColor blackColor];
    NSInteger newVersion = [[self.versionDict objectForKey:@"new_version"] integerValue];
    versionLab.text=[NSString stringWithFormat:@"最新版本：V%ld",(long)newVersion];
    [self.view addSubview:versionLab];
    
    UILabel *textLab=[[UILabel alloc] initWithFrame:CGRectMake(15, versionLab.bottom, kScreenWidth-30, 30)];
    textLab.text=@"版本信息";
    textLab.textColor=[UIColor blackColor];
    textLab.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:textLab];
    
    UILabel *versionDetailLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+20, kScreenWidth-60, 30)];
    versionDetailLab.font=[UIFont systemFontOfSize:14];
    versionDetailLab.textColor=[UIColor blackColor];
    versionDetailLab.numberOfLines=0;
    NSString *versionDetailStr=self.versionDict[@"description"];
    versionDetailLab.text=kIsEmptyString(versionDetailStr)?@"":versionDetailStr;
    CGFloat textH=[versionDetailLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:versionDetailLab.font].height;
    textH=textH>20?textH:20;
    versionDetailLab.frame=CGRectMake(15, textLab.bottom+10, kScreenWidth-30, textH);
    [self.view addSubview:versionDetailLab];
    
    
    UIButton *checkButton=[[UIButton alloc] initWithFrame:CGRectMake(30, versionLab.bottom+30, kScreenWidth-60, 40)];
    checkButton.layer.cornerRadius=5;
    checkButton.backgroundColor=kSystemColor;
    checkButton.clipsToBounds=YES;
    [checkButton setTitle:@"立即更新" forState:UIControlStateNormal];
    [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(upgrageNewestVersionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
}


@end
