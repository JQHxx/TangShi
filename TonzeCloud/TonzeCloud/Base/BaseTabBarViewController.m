//
//  BaseTabBarViewController.m
//  Tianjiyun
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 vision. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "BaseNavigationController.h"
#import "TCManagerViewController.h"
#import "TCPersonalViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "TCFriendGroupViewController.h"
#import "PPBadgeView.h"
#import "TCMySugarFriendModel.h"
#import "TCServicingViewController.h"
#import "TCBasewebViewController.h"
#import "TCFamilyBloodDetailViewController.h"
#import "TCLoginViewController.h"
#import "TCMineServiceModel.h"
#import "TCExpertDetailModel.h"
#import "TCRecordSugarViewController.h"
#import "ChatHelper.h"
#import "XLinkExportObject.h"
#import "TCFastLoginViewController.h"
#import "TCMyFriendViewController.h"
#import "TCNewFriendViewController.h"
#import "TCLookForMyViewController.h"
#import "TCMyCommentsViewController.h"
#import "TCMyPraiseViewController.h"
#import "TCMyMessageViewController.h"
#import "NSObject+Tool.h"

@interface BaseTabBarViewController ()<UITabBarControllerDelegate>
{
    NSInteger _messagesNumber;   // 消息个数
}

@property (nonatomic ,strong)  UITabBarItem * friendItem;

@end

@implementation BaseTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kTabHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    lineLab.backgroundColor=kbgBtnColor;
    [backView addSubview:lineLab];
    
    [self.tabBar insertSubview:backView atIndex:0];
    [self.tabBar setTintColor:kSystemColor];
    self.delegate = self;
    self.tabBar.opaque=YES;
    // 隐藏tabbar顶端的灰色线条
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:img];
    [self.tabBar setShadowImage:img];
    
    [self initTabBar];
    
    //糖友圈消息
    BOOL isLogin =[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        [self loadFriendGroupMessageNumber];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chanageBadgeNumber:) name:@"FriendGroupBadgeNumberNotification" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHomeUnreadMessage) name:kGetMessagesUnread object:nil];
}


#pragma mark -- NSNotification
-(void)reloadHomeUnreadMessage{
    if (self.homeVC) {
        [self.homeVC getUnreadMessageCount];
    }
    if (self.serviceVC) {
        [self.serviceVC serviceVCGetUnreadMessage];
    }
}

#pragma mark ====== 通知改变糖友圈Badge 数量 =======

- (void)chanageBadgeNumber:(NSNotification *)sender{
    NSString *numberStr = [sender object];
    NSInteger badgeNumber = [numberStr integerValue];
    if (badgeNumber > 0 && badgeNumber <= 99) {
        [self.friendItem pp_addBadgeWithText:numberStr];
        [self.friendItem pp_moveBadgeWithX:-9 Y:18];
    }else if (badgeNumber > 99){
        [self.friendItem pp_addBadgeWithText:@"99+"];
        [self.friendItem pp_moveBadgeWithX:-9 Y:18];
    }else{
        [self.friendItem pp_hiddenBadge];
    }
}
#pragma mark ====== dealloc =======

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FriendGroupBadgeNumberNotification" object:@"badgeNumber"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetMessagesUnread object:nil];
}
#pragma mark ====== 获取糖友圈消息个数 =======
- (void)loadFriendGroupMessageNumber{

    NSString *body = [NSString stringWithFormat:@"role_type=0"];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KLoadMySugarFriendInfo body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TCMySugarFriendModel *mySugarFriendModel = [[TCMySugarFriendModel alloc] init];
            [mySugarFriendModel setValues:result];
            _messagesNumber = mySugarFriendModel.ated + mySugarFriendModel.liked + mySugarFriendModel.new_followed + mySugarFriendModel.commented;
            
            NSString *numberStr = [NSString stringWithFormat:@"%ld",_messagesNumber];
            if (_messagesNumber > 0 && _messagesNumber < 100) {
                [weakSelf.friendItem pp_addBadgeWithText:numberStr];
                [weakSelf.friendItem pp_moveBadgeWithX:-9 Y:18];
            }else if (_messagesNumber > 100){
                [weakSelf.friendItem pp_addBadgeWithText:@"99+"];
                [weakSelf.friendItem pp_moveBadgeWithX:-9 Y:18];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark ======   =======

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    MyLog(@"选中tabbar：%ld",(long)tabBarController.selectedIndex);
    if (tabBarController.selectedIndex==0) {

#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004"];
        [MobClick event:@"101_001001"];
#endif
    }else if(tabBarController.selectedIndex == 1){
#if !DEBUG
        [MobClick event:@"102_001001"];
        [[TCHelper sharedTCHelper] loginClick:@"005"];
#endif
    }else if (tabBarController.selectedIndex == 2){

        [MobClick event:@"105_001001"];
        [[TCHelper sharedTCHelper] loginClick:@"008"];

    }else if (tabBarController.selectedIndex == 3){
#if !DEBUG
        [MobClick event:@"103_001001"];
        [[TCHelper sharedTCHelper] loginClick:@"006"];
#endif
    }else if (tabBarController.selectedIndex == 4){
#if !DEBUG
        [MobClick event:@"104_001001"];
        [[TCHelper sharedTCHelper] loginClick:@"003"];
#endif
    }
}
#pragma mark -- Private methods
#pragma mark 初始化

-(void)initTabBar{
    self.homeVC = [[TCNewHomeViewController alloc] init];
    BaseNavigationController *nav1=[[BaseNavigationController alloc] initWithRootViewController:self.homeVC];
    UITabBarItem * reportItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[[UIImage imageNamed:@"ic_btn_h_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_h_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav1.tabBarItem = reportItem;
    
    
    TCManagerViewController *managerVC=[[TCManagerViewController alloc] init];
    BaseNavigationController *nav2=[[BaseNavigationController alloc] initWithRootViewController:managerVC];
    UITabBarItem * homeItem = [[UITabBarItem alloc] initWithTitle:@"糖记录" image:[[UIImage imageNamed:@"ic_btn_n_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_n_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeItem pp_addBadgeWithText:@"9"];
    [homeItem pp_showBadge];
    nav2.tabBarItem = homeItem;
    
    TCFriendGroupViewController *groupVC=[[TCFriendGroupViewController alloc] init];
    BaseNavigationController *nav3=[[BaseNavigationController alloc] initWithRootViewController:groupVC];
    _friendItem = [[UITabBarItem alloc] initWithTitle:@"糖友圈" image:[[UIImage imageNamed:@"ic_tab_quan_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_tab_quan_hl"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav3.tabBarItem = _friendItem;

    
    self.serviceVC=[[TCServiceViewController alloc] init];
    BaseNavigationController *nav4=[[BaseNavigationController alloc] initWithRootViewController:self.serviceVC];
    UITabBarItem * sportsItem = [[UITabBarItem alloc] initWithTitle:@"糖服务" image:[[UIImage imageNamed:@"ic_btn_t_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_t_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav4.tabBarItem = sportsItem;
    

    TCPersonalViewController *personalVC=[[TCPersonalViewController alloc] init];
    BaseNavigationController *nav5=[[BaseNavigationController alloc] initWithRootViewController:personalVC];
    UITabBarItem * personalItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"ic_btn_m_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_m_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav5.tabBarItem = personalItem;
    
    self.viewControllers = @[nav1,nav2,nav3,nav4,nav5];
}


#pragma mark 处理推送通知
-(void)handerUserNotificationWithUserInfo:(NSDictionary *)userInfo{
    MyLog(@"handerUserNotificationWithUserInfo--%@",userInfo);
    
    if (kIsDictionary(userInfo)&&userInfo.count>0) {
        BaseViewController *controller=(BaseViewController *)[self currentViewController];
        
        NSInteger type=[[userInfo valueForKey:@"type"] integerValue];
        BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
        if (isLogin) {
            if (type==1||type==2) {  //糖百科、系统消息
                NSInteger message_id=[[userInfo valueForKey:@"message_id"] integerValue];
                NSInteger message_user_id=[[userInfo valueForKey:@"message_user_id"] integerValue];
                NSString *urlString=nil;
                TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
                if (type==1) {
                    webVC.type=BaseWebViewTypeArticle;
                    webVC.titleText=@"糖士-糖百科";
                    webVC.shareTitle = [[userInfo valueForKey:@"aps"] objectForKey:@"alert"];
                    webVC.image_url = [userInfo valueForKey:@"article_url"];
                    urlString = [NSString stringWithFormat:@"%@article/%ld/%ld",kWebUrl,(long)message_id,(long)message_user_id];
                    webVC.articleID = message_id;
                }else{
                    webVC.type=BaseWebViewTypeSystemNews;
                    webVC.titleText=@"消息详情";
                    urlString = [NSString stringWithFormat:@"%@?message_id=%ld&message_user_id=%ld",kNewsWebUrl,(long)message_id,(long)message_user_id];
                }
                webVC.urlStr=urlString;
                webVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:webVC animated:YES];
            }else if (type==3){  //亲友血糖
                NSInteger record_family_id=[[userInfo valueForKey:@"message_id"] integerValue];
                TCFamilyBloodDetailViewController *detailVC=[[TCFamilyBloodDetailViewController alloc] init];
                detailVC.record_family_id=record_family_id;
                detailVC.backBlock=^(){
                    
                };
                detailVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:detailVC animated:YES];
            }else if (type==4||type==5||type==6){
                TCMyMessageViewController *messageVC = [[TCMyMessageViewController alloc] init];
                messageVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:messageVC animated:YES];
            }else if (type==7){//有人赞我
                TCMyPraiseViewController *praiseMyVC = [[TCMyPraiseViewController alloc] init];
                praiseMyVC.type = 0;
                praiseMyVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:praiseMyVC animated:YES];
            }else if (type==8){//有人评论我
                TCMyCommentsViewController *commentsMyVC = [[TCMyCommentsViewController alloc] init];
                commentsMyVC.type = 0;
                commentsMyVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:commentsMyVC animated:YES];
            }else if (type==9){//有人@我
                TCLookForMyViewController *lookForMyVC = [[TCLookForMyViewController alloc] init];
                lookForMyVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:lookForMyVC animated:YES];
            }else if (type==10){ //新朋友关注
                TCNewFriendViewController *newFriendVC = [[TCNewFriendViewController alloc] init];
                newFriendVC.hidesBottomBarWhenPushed=YES;
                [controller.navigationController pushViewController:newFriendVC animated:YES];
            }else{  //
                NSString *urlString = [NSString stringWithFormat:@"%@?expert_im=%@",kExpertDetail,[userInfo objectForKey:@"f"]];
                [[TCHttpRequest  sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
                    NSDictionary *dataDic = [json objectForKey:@"result"];
                    if (kIsDictionary(dataDic)) {
                        TCExpertDetailModel *expertModel=[[TCExpertDetailModel alloc] init];
                        [expertModel setValues:dataDic];
                        
                        TCMineServiceModel *model=[[TCMineServiceModel alloc] init];
                        model.im_username=[NSUserDefaultsInfos getValueforKey:kImUserName];
                        model.im_expertname=[userInfo objectForKey:@"f"];
                        model.expert_name=expertModel.name;
                        model.head_portrait=expertModel.head_portrait;
                        model.im_groupid=[userInfo objectForKey:@"ConversationChatter"];
                        [TCHelper sharedTCHelper].expert_id=expertModel.id;
                        
                        TCServicingViewController *servicingVC=[[TCServicingViewController alloc] init];
                        servicingVC.serviceModel=model;
                        servicingVC.hidesBottomBarWhenPushed=YES;
                        [controller.navigationController pushViewController:servicingVC animated:YES];
                    }
                } failure:^(NSString *errorStr) {
                    
                }];
            }
        }else{
            TCFastLoginViewController *loginVC = [[TCFastLoginViewController alloc] init];
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:loginVC];
            [controller presentViewController:nav animated:YES completion:nil];
        }
    }
}
#pragma mark 处理血糖提醒推送
-(void)pushRecordSugarVC{
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        TCRecordSugarViewController *recordSugarVC = [TCRecordSugarViewController  new];
        recordSugarVC.hidesBottomBarWhenPushed = YES;
        [self.viewControllers[self.selectedIndex] pushViewController:recordSugarVC animated:YES];
    }else{
        TCFastLoginViewController *loginVC = [[TCFastLoginViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}




@end
