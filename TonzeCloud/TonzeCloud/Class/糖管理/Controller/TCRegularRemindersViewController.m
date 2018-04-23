//
//  TCRegularRemindersViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRegularRemindersViewController.h"
#import "TCRegularRemindersCell.h"
#import "TCEditAndAddRemindViewController.h"
#import "TCRegularRemindersModel.h"
#import "TCLocialNotificationManager.h"
#import <UserNotifications/UserNotifications.h>

@interface TCRegularRemindersViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *remindTableView;
///
@property (nonatomic ,strong) NSMutableArray *remindArray;
///
@property (nonatomic ,strong)  TCBlankView *blankView;
@end

@implementation TCRegularRemindersViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isRemindersLisReload) {
        [self loadRegularRemindersData];
        [TCHelper sharedTCHelper].isRemindersLisReload = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"定时提醒";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.rightImageName = @"ic_top_add";
    
    [self setRegularRemindersVC];
    [self loadRegularRemindersData];
    if ([self isAllowedNotification]) {
        [self checkOpenLocalNotification];
    }
}
#pragma mark======= 检测是否开启 ===
- (BOOL)isAllowedNotification
{
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIRemoteNotificationTypeNone) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark ====== 引导用户开启推送 =======
-(void)checkOpenLocalNotification{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"亲，为了方便您能及时收到提醒，需要您开启消息推送哟！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"去开启",nil];
        [alert show];
        [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
}
#pragma mark ====== Bulid UI =======

- (void)setRegularRemindersVC{
    [self.view addSubview:self.remindTableView];
}
#pragma mark ====== Request Data =======

- (void)setnotificationData{
    for (NSInteger i = 0; i < self.remindArray.count; i++) {
        TCRegularRemindersModel *reminderListModel = self.remindArray[i];
        if (reminderListModel.status == 1) {
            NSMutableArray *weekdayArr =[[TCLocialNotificationManager manager]getRepeatType:reminderListModel.repeat_type];
            for (NSInteger j = 0; j < weekdayArr.count; j++) {
                NSInteger day = [weekdayArr[j] integerValue];
                NSString *body = [[TCLocialNotificationManager manager]getReminderTypeStr:reminderListModel.reminder_type];
                [[TCLocialNotificationManager manager]setJPUSHLocationNotificationContentWithWeekday:day hour:reminderListModel.hour minute:reminderListModel.minute body:body time_reminder_id:reminderListModel.time_reminder_id];
            }
        }
    }
}
#pragma mark ====== Request  data =======
- (void)loadRegularRemindersData{
    [self.remindArray removeAllObjects];
    [[TCLocialNotificationManager manager]cleanJPUSHLocationNotificationContent]; // 清除所有通知
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:KReminderList success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in resultArray) {
                TCRegularRemindersModel *reminderListModel = [TCRegularRemindersModel new];
                [reminderListModel setValues:dic];
                [weakSelf.remindArray addObject:reminderListModel];
            }
            [weakSelf setnotificationData];// 推送消息
        }else{
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.remindTableView reloadData];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Action =======
- (void)rightButtonAction{
    [MobClick event:@"102_002001"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14-01"];
#endif
    if ([self isAllowedNotification]) {
        [self checkOpenLocalNotification];
    }else{
        if (self.remindArray.count == 10) {
            [self.view makeToast:@"亲，最多可添加10条提醒哟！" duration:1.0 position:CSToastPositionCenter];
        }else{
            TCEditAndAddRemindViewController *editAndAddRemindVC = [TCEditAndAddRemindViewController new];
            editAndAddRemindVC.remindType = AddRemind;
            [self.navigationController pushViewController:editAndAddRemindVC animated:YES];
        }
    }
}
#pragma mark ====== UITableViewDelegate && UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _remindArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *regularRemindersIdentifier  = @"regularRemindersIdentifier";
    TCRegularRemindersCell *regularRemindersCell = [tableView dequeueReusableCellWithIdentifier:regularRemindersIdentifier];
    if (!regularRemindersCell) {
        regularRemindersCell = [[TCRegularRemindersCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:regularRemindersIdentifier];
    }
    kSelfWeak;
    regularRemindersCell.switchTypeBlock = ^(BOOL isOpen) {
        TCRegularRemindersModel *reminderListModel = weakSelf.remindArray[indexPath.row];
        if (reminderListModel.status) {
            [weakSelf setRemindTypeWithRmeindMode:reminderListModel status:0];
        }else{
            [weakSelf setRemindTypeWithRmeindMode:reminderListModel status:1];
        }
    };
    [regularRemindersCell loadRegularRemindersCellData:_remindArray[indexPath.row]];
    return regularRemindersCell;
}
#pragma mark ====== 开启或关闭提醒推送 =======
- (void)setRemindTypeWithRmeindMode:(TCRegularRemindersModel *)mode status:(NSInteger )status{
    [MobClick event:@"102_002003"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14-03"];
#endif
    NSString *body = [NSString stringWithFormat:@"hour=%ld&minute=%ld&reminder_type=%@&repeat_type=%@&doSubmit=1&time_reminder_id=%ld&status=%ld",(long)mode.hour,mode.minute,mode.reminder_type,mode.repeat_type,mode.time_reminder_id,status];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReminderUpdate body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 1) {
            // 修改其按钮事件
            [weakSelf loadRegularRemindersData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"102_002002"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14-02"];
#endif
    TCEditAndAddRemindViewController *editAndAddRemindVC = [TCEditAndAddRemindViewController new];
    editAndAddRemindVC.remindType = EditRemind;
    TCRegularRemindersModel *reminderListModel = _remindArray[indexPath.row];
    editAndAddRemindVC.reminderModel = reminderListModel;
    [self.navigationController pushViewController:editAndAddRemindVC animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
#pragma mark ====== 删除单个定时提醒 =======
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCRegularRemindersModel *reminderListModel = _remindArray[indexPath.row];
    NSString *body = [NSString stringWithFormat:@"time_reminder_id=%ld",reminderListModel.time_reminder_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReminderDelete body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 1) {
            [_remindArray removeAllObjects];
            [weakSelf loadRegularRemindersData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Getter || Setter =======

- (UITableView *)remindTableView{
    if (!_remindTableView) {
        _remindTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _remindTableView.backgroundColor = [UIColor bgColor_Gray];
        _remindTableView.delegate = self;
        _remindTableView.dataSource = self;
        _remindTableView.tableFooterView = [UIView new];
        [_remindTableView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _remindTableView;
}
- (NSMutableArray *)remindArray{
    if (!_remindArray) {
        _remindArray = [NSMutableArray array];
    }
    return _remindArray;
}

- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0,  40 , kScreenWidth, kScreenHeight - 40) img:@"img_tips_no" text:@"暂无提醒"];
        _blankView.hidden = YES;
    }
    return _blankView;
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
