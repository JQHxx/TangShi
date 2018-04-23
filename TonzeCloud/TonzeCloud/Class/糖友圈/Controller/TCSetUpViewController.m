//
//  TCSetUpViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSetUpViewController.h"

@interface TCSetUpViewController (){
    NSArray    *nameArr;
    NSString   *titleStr;
    UISwitch   *setUpSwitch;
}

@end

@implementation TCSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"设置";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    nameArr = @[@"新朋友提醒",@"@我的提醒",@"评论我的提醒",@"赞我的提醒"];
    titleStr=nameArr[self.type-1];
    
    [self initSetUpView];
    [self loadSetUpData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MyLog(@"beginLogPage,title:%@",titleStr);
    [MobClick beginLogPageView:titleStr];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    MyLog(@"endLogPage,title:%@",titleStr);
    [MobClick endLogPageView:titleStr];
}

#pragma mark -- 设置新朋友提醒
- (void)setUpAction{
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&is_news_attr=%d&role_type=0&fun_type=%ld",setUpSwitch.on==YES?1:0,self.type];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kattr_setUpdate body:body success:^(id json) {
        [self.view makeToast:@"设置成功" duration:1.0 position:CSToastPositionCenter];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 获取提醒数据
- (void)loadSetUpData{

    NSString *body = [NSString stringWithFormat:@"doSubmit=0&is_news_attr=0&role_type=0&fun_type=%ld",self.type];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kattr_setUpdate body:body success:^(id json) {
        NSDictionary *dict = [json objectForKey:@"result"];
        if (self.type==1) {
            setUpSwitch.on = [[dict objectForKey:@"is_news_follow"] integerValue]==1?YES:NO;
        }else if (self.type==2){
            setUpSwitch.on = [[dict objectForKey:@"is_news_at"] integerValue]==1?YES:NO;
        }else if (self.type==3){
            setUpSwitch.on = [[dict objectForKey:@"is_news_comment"] integerValue]==1?YES:NO;
        }else{
            setUpSwitch.on = [[dict objectForKey:@"is_news_like"] integerValue]==1?YES:NO;
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 初始化界面
- (void)initSetUpView{
    
    NSArray *remindArr = @[@"关闭后，有新朋友关注你时，将不再提醒",@"关闭后，有新@我的消息，将不再提醒",@"关闭后，有新评论我的消息，将不再提醒",@"关闭后，有新赞我的消息，将不再提醒"];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 48)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, kScreenWidth/2, 20)];
    nameLabel.text = nameArr[self.type-1];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:nameLabel];
    
    setUpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
    [setUpSwitch addTarget:self action:@selector(setUpAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:setUpSwitch];

    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, bgView.bottom+10, kScreenWidth, 20)];
    remindLabel.text = remindArr[self.type-1];
    remindLabel.textColor = [UIColor grayColor];
    remindLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:remindLabel];
}

@end
