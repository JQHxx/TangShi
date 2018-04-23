//
//  TCPaySuccessViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPaySuccessViewController.h"
#import "TCServiceViewController.h"
#import "TCServicingViewController.h"
#import "TCMineServiceModel.h"
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMError.h>
#import "TTGlobalUICommon.h"
#import "ChatHelper.h"

@interface TCPaySuccessViewController (){
    TCMineServiceModel   *serviceModel;
}

@end

@implementation TCPaySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"支付完成";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    serviceModel=[[TCMineServiceModel alloc] init];
    
    [ChatHelper sharedChatHelper];
    
    [self initSuccessView];
    [self loadServiceOrderInfo];
    [self getTaskPointsWithActionType:3 isTaskList:NO taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
        
    }]; // 获取积分
    [TCHelper sharedTCHelper].isTaskListRecord = YES;
    [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
}

#pragma mark -- Event response
#pragma mark  返回事件
-(void)leftButtonAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 开始服务
-(void)startServiceAciton{
    if (serviceModel) {
        TCServicingViewController *servicingVC=[[TCServicingViewController alloc] init];
        servicingVC.serviceModel=serviceModel;
        [TCHelper sharedTCHelper].expert_id=serviceModel.expert_id;
        [self.navigationController pushViewController:servicingVC animated:YES];
    }
}

#pragma mark 返回首页
-(void)backToHomeAciton{
  [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载服务订单信息
-(void)loadServiceOrderInfo{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"order_sn=%@",self.order_sn];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kOrderDetail body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            [serviceModel setValues:result];
            
            //保存环信用户昵称到本地
            NSMutableArray *tempImUsersArr=[[NSMutableArray alloc] init];
            NSArray *imUsers=[NSUserDefaultsInfos getValueforKey:kIMUsers];
            if (kIsArray(imUsers)&&imUsers.count>0) {
                [tempImUsersArr addObjectsFromArray:imUsers];
                
                for (NSDictionary *userDict in imUsers) {
                    NSString *imUserName=[userDict valueForKey:kIMUserNameKey];
                    if ((![imUserName isEqualToString:serviceModel.im_expertname])||(![imUserName isEqualToString:serviceModel.im_expertname])) {
                        if (![imUserName isEqualToString:serviceModel.im_expertname]) {
                            NSDictionary *imUserDict=[[NSDictionary alloc] initWithObjectsAndKeys:serviceModel.im_expertname,kIMUserNameKey,serviceModel.expert_name,kIMNickNameKey, nil];
                            [tempImUsersArr addObject:imUserDict];
                        }else if (![imUserName isEqualToString:serviceModel.im_expertname]){
                            NSDictionary *imHelperDict=[[NSDictionary alloc] initWithObjectsAndKeys:serviceModel.im_helpername,kIMUserNameKey,serviceModel.im_helperusername,kIMNickNameKey, nil];
                            [tempImUsersArr addObject:imHelperDict];
                        }
                        break;
                    }
                }
            }else{
                NSDictionary *imUserDict=[[NSDictionary alloc] initWithObjectsAndKeys:serviceModel.im_expertname,kIMUserNameKey,serviceModel.expert_name,kIMNickNameKey, nil];
                [tempImUsersArr addObject:imUserDict];
                
                NSDictionary *imHelperDict=[[NSDictionary alloc] initWithObjectsAndKeys:serviceModel.im_helpername,kIMUserNameKey,serviceModel.im_helperusername,kIMNickNameKey, nil];
                [tempImUsersArr addObject:imHelperDict];
            }
            [NSUserDefaultsInfos putKey:kIMUsers andValue:tempImUsersArr];
            
            
            BOOL isIMLogined=[EMClient sharedClient].isLoggedIn;
            if ((!isIMLogined)&&(!kIsEmptyString(serviceModel.im_username))) {
                 [[EMClient sharedClient] logout:NO];   //退出环信
                 [weakSelf loginHYSDK];
            }else{
                [[ChatHelper sharedChatHelper] loadAllImExperts];
                [weakSelf sendPushMessageWithOrderSn];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 登录环信云
-(void)loginHYSDK{
    //异步登陆账号
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:serviceModel.im_username password:@"u_123456"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [NSUserDefaultsInfos putKey:kImUserName andValue:serviceModel.im_username];
                [NSUserDefaultsInfos putKey:kImPassword andValue:@"u_123456"];
                //设置是否自动登录
                MyLog(@"登录环信成功");
                [[EMClient sharedClient].options setIsAutoLogin:YES];
            } else {
                MyLog(@"登录IM用户失败:code:%u",error.code);
            }
        });
    });
}

#pragma mark  购买服务后建立环信关系并发送推送
- (void)sendPushMessageWithOrderSn{
    NSString *body=[NSString stringWithFormat:@"order_sn=%@",self.order_sn];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kSendPushMsg body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark 初始化界面
- (void)initSuccessView{
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 200)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIImageView *successImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, kNewNavHeight + 40, 90, 90)];
    successImgView.layer.cornerRadius = 45;
    successImgView.image = [UIImage imageNamed:@"pub_ic_order_right"];
    [self.view addSubview:successImgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, successImgView.bottom+18, kScreenWidth, 20)];
    label.text = @"支付成功";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor  = [UIColor colorWithHexString:@"#ff9630"];
    [self.view addSubview:label];
    
    UIButton *serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(53,bgView.bottom+50, kScreenWidth-106, 41)];
    serviceButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [serviceButton setTitle:@"开始服务" forState:UIControlStateNormal];
    [serviceButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    serviceButton.backgroundColor =kbgBtnColor;
    serviceButton.layer.cornerRadius=1.0;
    serviceButton.clipsToBounds=YES;
    [serviceButton addTarget:self action:@selector(startServiceAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serviceButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(53,serviceButton.bottom+20, kScreenWidth-106, 41)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [backButton setTitle:@"返回首页" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithHexString:@"#626262"] forState:UIControlStateNormal];
    backButton.backgroundColor =[UIColor whiteColor];
    backButton.layer.borderWidth=1.0;
    backButton.layer.borderColor=kLineColor.CGColor;
    backButton.layer.cornerRadius=1.0;
    backButton.clipsToBounds=YES;
    [backButton addTarget:self action:@selector(backToHomeAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}


@end
