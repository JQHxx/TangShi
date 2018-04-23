//
//  TCSugarRemindViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarRemindViewController.h"
#import "TCMineButton.h"

@interface TCSugarRemindViewController (){

    TCMineButton *messageBtn;
    TCMineButton *sugarRemindBtn;
    UISwitch     *messageSwitch;
    UISwitch     *sugarSwitch;
}

@end

@implementation TCSugarRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"血糖提醒";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initSugarRemindView];
    [self loadRemindData];
}
#pragma mark -- 消息提醒
- (void)switchAction:(UISwitch *)Switch{
    NSString *body = [NSString stringWithFormat:@"is_start=%d&is_start_record=%d&family_id=%ld&doSubmit=1",sugarSwitch.on==YES?1:0,messageSwitch.on==YES?1:0,(long)self.family_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUpdateFamilyStart body:body success:^(id json) {
        [self.view makeToast:@"设置成功" duration:1.0 position:CSToastPositionCenter];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --获取消息提醒
- (void)loadRemindData{

    NSString *body = [NSString stringWithFormat:@"family_id=%ld&doSubmit=0",(long)self.family_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUpdateFamilyStart body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            sugarSwitch.on = [[result objectForKey:@"is_start"] integerValue]==0?NO:YES;
            messageSwitch.on = [[result objectForKey:@"is_start_record"] integerValue]==0?NO:YES;
        }
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 初始化界面
- (void)initSugarRemindView{

    NSDictionary *dict = @{@"title":@"应用消息提醒",@"content":@"",@"image":@""};
    messageBtn = [[TCMineButton alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 48) dict:dict];
    messageBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:messageBtn];
    
    messageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
    [messageSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    messageSwitch.tag =101;
    [messageBtn addSubview:messageSwitch];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, messageBtn.bottom+15, kScreenWidth-20, 20)];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.text = @"当您的亲友记录血糖后，将使用应用消息通知您";
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.numberOfLines = 0;
    [self.view addSubview:messageLabel];
    CGSize size = [messageLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    messageLabel.frame = CGRectMake(10, messageBtn.bottom+15, kScreenWidth-20, size.height);
    
    dict = @{@"title":@"血糖异常短信提醒",@"content":@"",@"image":@""};
    sugarRemindBtn = [[TCMineButton alloc] initWithFrame:CGRectMake(0, messageLabel.bottom+15, kScreenWidth, 48) dict:dict];
    sugarRemindBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sugarRemindBtn];
    
    sugarSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
    sugarSwitch.tag =102;
    [sugarSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [sugarRemindBtn addSubview:sugarSwitch];
    
    UILabel *sugarRemindLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, sugarRemindBtn.bottom+10, kScreenWidth-20, 20)];
    sugarRemindLabel.font = [UIFont systemFontOfSize:14];
    sugarRemindLabel.text = @"当您的亲友血糖值异常时，将免费发送短信通知本糖士帐号注册的手机号";
    sugarRemindLabel.textColor = [UIColor grayColor];
    sugarRemindLabel.numberOfLines = 0;
    [self.view addSubview:sugarRemindLabel];
    CGSize size1 = [sugarRemindLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    sugarRemindLabel.frame = CGRectMake(10, sugarRemindBtn.bottom+15, kScreenWidth-20, size1.height);
}

@end
