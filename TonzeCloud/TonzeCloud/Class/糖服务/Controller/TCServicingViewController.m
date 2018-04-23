//
//  TCServicingViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServicingViewController.h"
#import "ChatViewController.h"
#import "TCServiceStateViewController.h"
#import "TCPaySuccessViewController.h"
#import "TCServiceDetailViewController.h"
#import "TCServiceEvaluateViewController.h"
#import "TCInformationViewController.h"
#import "TCExpertDetailController.h"
#import "TCClickViewGroup.h"
#import "TCEvaluateListViewController.h"
#import "TCChatWebViewController.h"
#import "QuestionnarieDetailViewController.h"
#import "TCInformationViewController.h"
#import "TCFilesViewController.h"
#import "TCCheckListViewController.h"


@interface TCServicingViewController ()<TCClickViewGroupDelegate,TCServiceStateViewControllerDelegate,ChatViewControllerDelegate>{
    
}
@property (nonatomic,strong)TCClickViewGroup                *viewGroup;
@property (nonatomic,strong)ChatViewController              *chatVC;
@property (nonatomic,strong)TCServiceStateViewController    *serviceStateVC;

@end

@implementation TCServicingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=self.serviceModel.expert_name;
    
    [self.view addSubview:self.viewGroup];
    
    [self loginHYSDKSystem];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([TCHelper sharedTCHelper].isReloadMyService) {
        if (self.serviceStateVC) {
            [self.serviceStateVC requestMyServiceStateInfo];
            [TCHelper sharedTCHelper].isReloadMyService=NO;
        }
    }
}

#pragma mark -- Custom Delegate
#pragma mark  ClickViewGroupDelegate
-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index{
    if (index==0) {
        [MobClick event:@"101_003007"];
        
        if (self.serviceStateVC) {
            [self.serviceStateVC.view removeFromSuperview];
            self.serviceStateVC=nil;
        }
        [self.view addSubview:self.chatVC.view];
    }else{
        [MobClick event:@"101_003008"];

        if (self.chatVC) {
            [self.chatVC.view removeFromSuperview];
            self.chatVC=nil;
        }
        [self.view addSubview:self.serviceStateVC.view];
    }
}

#pragma mark TCServiceStateViewControllerDelegate
#pragma mark 去服务详情页
-(void)serviceStateVCDidSelectedCellWithModel:(TCMineServiceModel *)myService{
    TCServiceDetailViewController *serviceDetailVC=[[TCServiceDetailViewController alloc] init];
    serviceDetailVC.myService=myService;
    [self.navigationController pushViewController:serviceDetailVC animated:YES];
}

#pragma mark 去评价
-(void)serviceStateVCPushToEvaluateWithModel:(TCMineServiceModel *)myService{
    TCServiceEvaluateViewController *evaluateVC=[[TCServiceEvaluateViewController alloc] init];
    evaluateVC.order_id=myService.order_id;
    [self.navigationController pushViewController:evaluateVC animated:YES];
}

#pragma mark ChatViewControllerDelegate
#pragma mark 点击链接
-(void)chatVCDidClickWithUrl:(NSURL *)url{
    TCChatWebViewController *chatWebVC=[[TCChatWebViewController alloc] init];
    chatWebVC.webUrl=url;
    [self.navigationController pushViewController:chatWebVC animated:YES];
}

#pragma mark 点击消息cell
-(void)chatVCDidSelectCellWithExt:(NSDictionary *)ext{
    NSString *msgType=ext[@"msg_type"];
    if ([msgType isEqualToString:@"question"]) {  //调查表
        NSDictionary *msgDict=[ext valueForKey:@"msg_info"];
        if (kIsDictionary(msgDict)) {
            QuestionnarieDetailViewController *questionDetailVC=[[QuestionnarieDetailViewController alloc] init];
            questionDetailVC.id=[[msgDict valueForKey:@"rs_id"] integerValue];
            questionDetailVC.titleStr = [msgDict valueForKey:@"name"];
            kSelfWeak;
            questionDetailVC.saveBlock=^(NSString *questionnarieTitle){
                NSString *textMessage=[NSString stringWithFormat:@"我已完成%@",questionnarieTitle];
                if(weakSelf.chatVC){
                    [weakSelf.chatVC sendTextMessage:textMessage];
                }
            };
            [self.navigationController pushViewController:questionDetailVC animated:YES];
        }
    }else if ([msgType isEqualToString:@"userInfo"]){  //基本信息
        TCInformationViewController *infoVC=[[TCInformationViewController alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
    }else if ([msgType isEqualToString:@"bloodRecord"]){ //糖档案
        TCFilesViewController *filesVC=[[TCFilesViewController alloc] init];
        [self.navigationController pushViewController:filesVC animated:YES];
    }else if ([msgType isEqualToString:@"checkForm"]){ //检查单
        TCCheckListViewController *checkListVC=[[TCCheckListViewController alloc] init];
        [self.navigationController pushViewController:checkListVC animated:YES];
    }else if ([msgType isEqualToString:@"comment"]){ //评价
        TCServiceEvaluateViewController *evaluateVC=[[TCServiceEvaluateViewController alloc] init];
        evaluateVC.order_id=self.serviceModel.order_id;
        [self.navigationController pushViewController:evaluateVC animated:YES];
    }
}

#pragma mark 点击头像
-(void)chatVCDidSelectUserAtavarWithName:(NSString *)nickName{
    NSString *userNickName=[NSUserDefaultsInfos getValueforKey:kNickName];
    if ([nickName isEqualToString:userNickName]) {
        TCInformationViewController *inforVC=[[TCInformationViewController alloc] init];
        [self.navigationController pushViewController:inforVC animated:YES];
    }else{
        TCExpertDetailController *expertDetailVC=[[TCExpertDetailController alloc] init];
        expertDetailVC.expert_id=[nickName isEqualToString:self.serviceModel.expert_name]?self.serviceModel.expert_id:self.serviceModel.helper_id;
        [self.navigationController pushViewController:expertDetailVC animated:YES];
    }
}

#pragma mark 购买服务
-(void)chatVCDidBuyServiceAction{
    [MobClick event:@"101_003009"];

    TCExpertDetailController *expertDetailVC=[[TCExpertDetailController alloc] init];
    expertDetailVC.expert_id=self.serviceModel.expert_id;
    [self.navigationController pushViewController:expertDetailVC animated:YES];
}

#pragma mark -- Event Response
#pragma mark  返回
-(void)leftButtonAction{
    BOOL  flag=NO;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TCPaySuccessViewController class]]) {
            flag=YES;
        }
    }
    if (flag) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 登录环信
-(void)loginHYSDKSystem{
    BOOL isAutoLogin = [EMClient sharedClient].isLoggedIn;
    if (!isAutoLogin) {
        MyLog(@"需要登录环信");
        //异步登陆账号
        __weak typeof(self) weakSelf=self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = [[EMClient sharedClient] loginWithUsername:self.serviceModel.im_username password:@"u_123456"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [NSUserDefaultsInfos putKey:kImUserName andValue:self.serviceModel.im_username];
                    [NSUserDefaultsInfos putKey:kImPassword andValue:@"u_123456"];
                    
                    [weakSelf.view addSubview:weakSelf.chatVC.view];
                    
                    //设置是否自动登录
                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                } else {
                    MyLog(@"登录IM用户失败:code:%u",error.code);
                }
            });
        });
    }else{
        MyLog(@"已登录环信");
        [self.view addSubview:self.chatVC.view];
    }
}


#pragma mark -- Getters
#pragma mark 菜单栏
-(TCClickViewGroup *)viewGroup{
    if (!_viewGroup) {
        _viewGroup=[[TCClickViewGroup alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 40) titles:@[@"对话",@"服务情况"] color:kSystemColor titleColor:kLineColor];
        _viewGroup.viewDelegate=self;
    }
    return _viewGroup;
}

#pragma mark 对话界面
-(ChatViewController *)chatVC{
    if (!_chatVC) {
        if (kIsEmptyString(self.serviceModel.im_groupid)) {
            _chatVC=[[ChatViewController alloc] initWithConversationChatter:self.serviceModel.im_expertname conversationType:EMConversationTypeChat];
        }else{
           _chatVC=[[ChatViewController alloc] initWithConversationChatter:self.serviceModel.im_groupid conversationType:EMConversationTypeGroupChat];
        }
        
        _chatVC.serviceModel=self.serviceModel;
        _chatVC.view.frame=CGRectMake(0, self.viewGroup.bottom, kScreenWidth, kRootViewHeight-40);
        _chatVC.chatdelegate=self;
    }
    return _chatVC;
}

#pragma mark 服务情况
-(TCServiceStateViewController *)serviceStateVC{
    if (!_serviceStateVC) {
        _serviceStateVC=[[TCServiceStateViewController alloc] init];
        _serviceStateVC.view.frame=CGRectMake(0, self.viewGroup.bottom, kScreenWidth, kRootViewHeight-40);
        _serviceStateVC.controllerDelegate=self;
    }
    return _serviceStateVC;
}

@end
