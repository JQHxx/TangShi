//
//  TCTodayMissionViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTodayMissionViewController.h"
#import "QLCoreTextManager.h"
#import "TCPointslMallViewController.h"
#import "TCTodayMissionCell.h"
#import "TCIntegralTaskListModel.h"
#import "TCCheckInDailyViewController.h"
#import "TCInformationViewController.h"
#import "BaseTabBarViewController.h"
#import "AppDelegate.h"
#import "TCSugarDeviceViewController.h"
#import "TCRecordSugarViewController.h"
#import "TCRecordDietViewController.h"
#import "TCRecordSportViewController.h"
#import "TCAddBloodViewController.h"
#import "TCPertainViewController.h"
#import "TCCheckListViewController.h"
#import "TCArticleLibraryViewController.h"
#import "TCScanFriendViewController.h"
#import "TCIdeaBackViewController.h"
#import "TCReleaseDynamicViewController.h"
#import "TCInvitationFriendViewController.h"

@interface TCTodayMissionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/// 积分
@property (nonatomic ,strong) UILabel *integralLab;
/// 任务数据
@property (nonatomic ,strong) NSMutableArray *taskListArray;

@end

@implementation TCTodayMissionViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([TCHelper sharedTCHelper].isTaskListRecord){
        [self requestTodayMissionData];
        [TCHelper sharedTCHelper].isTaskListRecord = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.baseTitle = @"今日任务";
    [self setTodayMissionVC];
    [self requestTodayMissionData];
    [TCHelper sharedTCHelper].isTaskListRecord = NO;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-10-05" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-10-05" type:2];
#endif
}
#pragma mark -- Bulid UI

- (void)setTodayMissionVC{
    [self.view addSubview:self.tableView];
}
- (UIView *)tableHeaderView{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 136/2)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *todayIntegralLab = [[UILabel alloc]initWithFrame:CGRectMake(20, (headerView.height - 20)/2, 70, 20)];
    todayIntegralLab.text = @"今日获得";
    todayIntegralLab.textAlignment = NSTextAlignmentLeft;
    todayIntegralLab.font = kFontWithSize(15);
    todayIntegralLab.textColor = UIColorFromRGB(0x313131);
    [headerView addSubview:todayIntegralLab];
    
    _integralLab = [[UILabel alloc]initWithFrame:CGRectMake(todayIntegralLab.right,(headerView.height - 30)/2, kScreenWidth - 230, 30)];
    _integralLab.textColor = UIColorFromRGB(0xf9c92b);
    _integralLab.textAlignment = NSTextAlignmentLeft;
    _integralLab.font = kFontWithSize(30);
    [headerView addSubview:self.integralLab];
    
    UIButton *redeemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    redeemBtn.frame = CGRectMake(kScreenWidth - 120, (headerView.height - 24)/2,100 , 24);
    [redeemBtn setBackgroundImage:[UIImage imageNamed:@"points_replacement"] forState:UIControlStateNormal];
    [redeemBtn addTarget:self action:@selector(redeemClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:redeemBtn];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, headerView.height - 10, kScreenWidth, 10)];
    len.backgroundColor = [UIColor bgColor_Gray];
    [headerView addSubview:len];
    
    return headerView;
}
#pragma mark -- Request Data

- (void)requestTodayMissionData{
    
    [self.taskListArray removeAllObjects];
    kSelfWeak;
    // App版本信息
    NSString *version = [NSString getAppVersion];
    NSString *url = [NSString stringWithFormat:@"%@?app_version=%@",KIntegralTaskList,version];
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        // 今日获得积分
        NSInteger  todayGet =[[resultDic objectForKey:@"today_get"] integerValue];
        self.integralLab.text = [NSString stringWithFormat:@"%ld",(long)todayGet];
        
        NSArray *taskListArray = [resultDic objectForKey:@"task_list"];
        if (kIsArray(taskListArray) && taskListArray.count > 0) {
            for (NSDictionary *dic in taskListArray) {
                TCIntegralTaskListModel *taskListModel = [TCIntegralTaskListModel new];
                [taskListModel setValues:dic];
                [weakSelf.taskListArray addObject:taskListModel];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Action =======
- (void)redeemClick{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-10-06"];
#endif

    [MobClick event:@"104_002005"];
    TCPointslMallViewController *pointsMallVC = [TCPointslMallViewController new];
    [self.navigationController pushViewController:pointsMallVC animated:YES];
}

#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate   =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.taskListArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *todayMissionIdentifier  = @"Identifier";
    TCTodayMissionCell *todayMissionCell = [tableView dequeueReusableCellWithIdentifier:todayMissionIdentifier];
    if (!todayMissionCell) {
        todayMissionCell = [[TCTodayMissionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:todayMissionIdentifier];
    }
    [todayMissionCell setTodayMissionWithModel:_taskListArray[indexPath.row]];
    todayMissionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return todayMissionCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"104_002006"];

    TCIntegralTaskListModel *taskListModel = self.taskListArray[indexPath.row];
    if (taskListModel.click_num == taskListModel.sum_num && taskListModel.sum_num != 0) {
        return;
    }else{
        switch ([taskListModel.action_type integerValue]) {
            case 1:
            {// 签到
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-20"];
#endif
                if (_isCheckLogin) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                TCCheckInDailyViewController *checkInDailyVC = [TCCheckInDailyViewController new];
                    checkInDailyVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:checkInDailyVC animated:YES];
                }
            }break;
            case 2:
            {// 完善资料(先判断用户的信息是否完善，完善即给予积分，未完善进入完善页面)
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-21"];
#endif
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kGetUserInfo body:@"" success:^(id json) {
                    NSDictionary *result = [json objectForKey:@"result"];
                    if (kIsDictionary(result)) {
                        NSString *birthday = [result objectForKey:@"birthday"];
                        NSInteger height = [[result objectForKey:@"height"] integerValue];
                        NSString *labour_intensity = [result objectForKey:@"labour_intensity"];
                        NSString *sex = [result objectForKey:@"sex"];
                        NSString *weight = [result objectForKey:@"weight"];
                        if (!kIsEmptyString(birthday) && !kIsEmptyString(labour_intensity) && height > 0 &&  !kIsEmptyString(sex) && !kIsEmptyString(weight)) {
                            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
                            [self getTaskPointsWithActionType:2 isTaskList:NO taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
                                if (clickIndex == 1001 || isBack) {
                                    [self requestTodayMissionData];
                                }
                            }];
                        }else{
                            // 跳转到个人信息界面
                            TCInformationViewController *informationVC = [TCInformationViewController new];
                            informationVC.isTaskListLogin = YES;
                            [self.navigationController pushViewController:informationVC animated:YES];
                        }
                    }
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }break;
            case 3:
            {// 购买方案
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-07"];
#endif
                BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                tabbarVC.selectedIndex = 3;
                AppDelegate *appDelegate=kAppDelegate;
                appDelegate.window.rootViewController=tabbarVC;
            }break;
            case 4:
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-08"];
#endif
            case 5:
            {// 使用血糖仪 || 血糖仪测量血糖
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-09"];
#endif
                TCSugarDeviceViewController *sugarDeviceVC = [TCSugarDeviceViewController new];
                sugarDeviceVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:sugarDeviceVC animated:YES];
            }break;
            case 6:
            {// 手动记录血糖
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-10"];
#endif
                TCRecordSugarViewController *recordSugarVC = [TCRecordSugarViewController  new];
                recordSugarVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:recordSugarVC animated:YES];
            }break;
            case 7:
            {// 记录饮食
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-11"];
#endif
                TCRecordDietViewController *recordDietVC = [TCRecordDietViewController new];
                recordDietVC.isTadkListLogin = YES;
                [self.navigationController pushViewController:recordDietVC animated:YES];
            }break;
            case 8:
            {// 记录运动
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-12"];
#endif
                TCRecordSportViewController *recordSportVC = [TCRecordSportViewController new];
                recordSportVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:recordSportVC animated:YES];
            }break;
            case 9:
            {// 记录血压
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-13"];
#endif
                TCAddBloodViewController *addBolldVC = [TCAddBloodViewController new];
                addBolldVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:addBolldVC animated:YES];
            }break;
            case 10:
            {// 记录糖化血红蛋白
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-14"];
#endif
                TCPertainViewController *pertainVC = [TCPertainViewController new];
                pertainVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:pertainVC animated:YES];
            }break;
            case 11:
            {// 上传检查单
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-15"];
#endif
                TCCheckListViewController *checkListVC = [TCCheckListViewController new];
                checkListVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:checkListVC animated:YES];
            }break;
            case 12:
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-16"];
#endif
            case 13:
            {// 阅读文章 || 分享文章
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-17"];
#endif
                TCArticleLibraryViewController *articleLibaryVC = [TCArticleLibraryViewController new];
                articleLibaryVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:articleLibaryVC animated:YES];
            }break;
            case 14:
            {// 添加亲友
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-18"];
#endif
                TCScanFriendViewController *scanFriendVC = [TCScanFriendViewController new];
                scanFriendVC.isTaskListLogin = YES;
                kSelfWeak;
                scanFriendVC.scanBlock = ^(NSString *result) {
                    [weakSelf.view makeToast:result duration:1.0 position:CSToastPositionCenter];
                };
                [self.navigationController pushViewController:scanFriendVC animated:YES];
            }break;
            case 15:
            {// 提交意见反馈
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-10-19"];
#endif
                TCIdeaBackViewController  *ideaBackVC = [TCIdeaBackViewController new];
                ideaBackVC.isTaskListLogin = YES;
                [self.navigationController pushViewController:ideaBackVC animated:YES];
            }break;
            case 16:
            {// 发布动态
                TCReleaseDynamicViewController *releaseDynamicVC = [TCReleaseDynamicViewController new];
                releaseDynamicVC.isTaskListLogin = YES;
                releaseDynamicVC.isCanChooseTopic = YES;
                releaseDynamicVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:releaseDynamicVC animated:YES];
            }break;
            case 17:
            {
                // App版本信息
                NSString *version = [NSString getAppVersion];
                NSString *body = [NSString stringWithFormat:@"action_type=17&app_version=%@",version];
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KIntegralTask body:body success:^(id json) {
                    [weakSelf.view makeToast:@"注册积分已补领" duration:1.0 position:CSToastPositionCenter];
                    [weakSelf requestTodayMissionData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }break;
            case 18:
            {// 评论糖友圈或者文章
                if (taskListModel.click_num > 0) {
                    NSInteger x = arc4random() % 2;
                    if (x == 1) {
                        BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                        tabbarVC.selectedIndex = 2;
                        AppDelegate *appDelegate=kAppDelegate;
                        appDelegate.window.rootViewController=tabbarVC;
                    }else{
                        TCArticleLibraryViewController *articleLibaryVC = [TCArticleLibraryViewController new];
                        articleLibaryVC.isTaskListLogin = YES;
                        [self.navigationController pushViewController:articleLibaryVC animated:YES];
                    }
                }else{
                    BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                    tabbarVC.selectedIndex = 2;
                    AppDelegate *appDelegate=kAppDelegate;
                    appDelegate.window.rootViewController=tabbarVC;
                }
            }break;
            case 19:
            {// 邀请好友
                TCInvitationFriendViewController *invitationFriendVC = [TCInvitationFriendViewController new];
                [self.navigationController pushViewController:invitationFriendVC animated:YES];
            }break;
            default:
                break;
        }
    }
}
#pragma mark ====== Getter =======
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.tableHeaderView = [self tableHeaderView];
    }
    return _tableView;
}

- (NSMutableArray *)taskListArray{
    if (!_taskListArray) {
        _taskListArray = [NSMutableArray array];
    }
    return _taskListArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
