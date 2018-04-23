//
//  TCEditWithAddRemindViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCEditAndAddRemindViewController.h"
#import "TCEditAndAddRemindCell.h"
#import "TimePickerView.h"
#import "TCReminderTimePickView.h"
#import "TCRemindTimeViewController.h"
#import "TCLocialNotificationManager.h"

@interface TCEditAndAddRemindViewController ()<UITableViewDelegate,UITableViewDataSource,ReminderTimePickViewDelegate>
{
    NSArray     *_reminderTypeTitleArray;
    NSString    *_remindTypeStr;   // 提醒类型
    NSString    *_repeatTimeStr;   // 重复时间
    NSString    *_repeatWeekDayStr;// 重复周期
    NSInteger    _hour;      // 当前时钟
    NSInteger    _minute;    // 当前分钟
    NSArray      *_weakDays;
}
@property (nonatomic, strong) UITableView *remindTableView;
///
@property (nonatomic ,strong) TimePickerView  *Picker;
///
@property (nonatomic ,strong) TCReminderTimePickView *reminderTimePickView;
/// 时间数据
@property (nonatomic ,strong) NSArray *pickTimeArray;
@end

@implementation TCEditAndAddRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rigthTitleName = @"保存";
    _reminderTypeTitleArray = @[@"提醒类型",@"重复方式"];
    _weakDays = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    _pickTimeArray =@[@[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"],@[@"："],@[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"]];
    switch (self.remindType) {
        case AddRemind:
        {
            self.baseTitle = @"添加提醒";
            _remindTypeStr =[[TCHelper sharedTCHelper].reminderTypeArr objectAtIndex:0];
            _repeatWeekDayStr = @"从不";
            NSString *nowTime = [TCHelper sharedTCHelper].getCurrentDateTime;
            _hour = [[nowTime substringWithRange:NSMakeRange(11, 2)] integerValue];
            _minute = [[nowTime substringWithRange:NSMakeRange(14,2)] integerValue];
            _repeatTimeStr = [NSString stringWithFormat:@"%ld:%ld",(long)_hour,(long)_minute];
            [self setEditAndAddRemindVC];
        }break;
        case EditRemind:
        {
            self.baseTitle = @"编辑提醒";
            _hour = _reminderModel.hour;
            _minute = _reminderModel.minute;
            _remindTypeStr = _reminderModel.reminder_type;
            _repeatWeekDayStr = _reminderModel.repeat_type ;
            [self setEditAndAddRemindVC];
        }break;
        case BloodSugarRemind:{
            self.baseTitle = @"添加提醒";
            _remindTypeStr =[[TCHelper sharedTCHelper].reminderTypeArr objectAtIndex:0];
            _repeatWeekDayStr = @"从不";
            NSString *time = [[TCHelper sharedTCHelper]getCurrentDateTimeMinutesLater:self.minutesLater];
            _hour = [[time substringWithRange:NSMakeRange(0, 2)] integerValue];
            _minute = [[time substringWithRange:NSMakeRange(3,2)] integerValue];
            _repeatTimeStr = [NSString stringWithFormat:@"%ld:%ld",(long)_hour,(long)_minute];
            [self setEditAndAddRemindVC];
        }break;
        default:
            break;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    switch (self.remindType) {
        case AddRemind:
        {
            [[TCHelper sharedTCHelper] loginAction:@"005-14-01" type:1];
        }break;
        case EditRemind:
        {
            [[TCHelper sharedTCHelper] loginAction:@"005-14-02" type:1];
        }break;
        default:
            break;
    }
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    switch (self.remindType) {
        case AddRemind:
        {
            [[TCHelper sharedTCHelper] loginAction:@"005-14-01" type:2];
        }break;
        case EditRemind:
        {
            [[TCHelper sharedTCHelper] loginAction:@"005-14-02" type:2];
        }break;
        default:
            break;
    }
#endif
}

#pragma mark ====== Bulid UI =======
- (void)setEditAndAddRemindVC{
    [self.view addSubview:self.remindTableView];
}
- (UIView *)tableHearView{
    UIView *headrView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
    
    headrView.backgroundColor = [UIColor bgColor_Gray];
    [self.reminderTimePickView.pickView selectRow:_hour inComponent:0 animated:YES];
    [self.reminderTimePickView.pickView selectRow:_minute inComponent:2 animated:YES];
    [self.reminderTimePickView show:headrView];
    [self.reminderTimePickView pickerView:self.reminderTimePickView.pickView didSelectRow:_hour  inComponent:0];
    [self.reminderTimePickView pickerView:self.reminderTimePickView.pickView didSelectRow:_minute inComponent:2];
    
    return headrView;
}
- (UIView *)tableViewFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , 38 + 30)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 30 ,kScreenWidth , 38);
    [deleteBtn setBackgroundColor:[UIColor whiteColor]];
    [deleteBtn setTitle:@"删除提醒" forState:UIControlStateNormal];
    [deleteBtn setTitleColor: UIColorFromRGB(0xff6158) forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = kFontWithSize(15);
    [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteBtn];
    
    return footerView;
}

#pragma mark ====== Action =======
#pragma mark ====== 保存  =========
- (void)rightButtonAction{
    [MobClick event:@"102_003004"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14-04"];
#endif
    if ([self isAllowedNotification]) {
        [self checkOpenLocalNotification];
    }else{
        if (kIsEmptyString(_repeatWeekDayStr)) {
            [self.view makeToast:@"请选择重复方式" duration:1.0 position:CSToastPositionCenter];
            return;
        }else{
            NSString *body;
            if (self.remindType == AddRemind || self.remindType == BloodSugarRemind) {
                NSArray *hourArray =_pickTimeArray[0];
                NSArray *minuteArray = _pickTimeArray[2];
                body = [NSString stringWithFormat:@"hour=%@&minute=%@&reminder_type=%@&repeat_type=%@",hourArray[_hour],minuteArray[_minute],_remindTypeStr,_repeatWeekDayStr];
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReminderAdd body:body success:^(id json) {
                    if (weakSelf.remindType == AddRemind) {
                        [TCHelper sharedTCHelper].isRemindersLisReload = YES;
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }else if (weakSelf.remindType == BloodSugarRemind){
                        NSString *tipStr =@"测量血糖时间已到，请勤记录以便更好的控糖";
                        [[TCLocialNotificationManager manager]setJPUSHLocationNotificationContentWithWeekday:0 hour:[hourArray[_hour] integerValue] minute:[minuteArray[_minute]integerValue] body:tipStr time_reminder_id:0];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }else{
                body = [NSString stringWithFormat:@"hour=%ld&minute=%ld&reminder_type=%@&repeat_type=%@&doSubmit=1&time_reminder_id=%ld",(long)_hour,_minute,_remindTypeStr,_repeatWeekDayStr,_reminderModel.time_reminder_id];
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReminderUpdate body:body success:^(id json) {
                    NSInteger status = [[json objectForKey:@"status"] integerValue];
                    if (status == 1) {
                        [TCHelper sharedTCHelper].isRemindersLisReload = YES;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }
        }
    }
}
#pragma mark ====== 返回按钮 =======
- (void)leftButtonAction{
    switch (_remindType) {
        case AddRemind:
        {
            NSString *nowTime = [TCHelper sharedTCHelper].getCurrentDateTime;
            NSInteger hour = [[nowTime substringWithRange:NSMakeRange(11, 2)] integerValue];
            NSInteger minute = [[nowTime substringWithRange:NSMakeRange(14,2)] integerValue];
            if (!kIsEmptyString(_repeatWeekDayStr) || hour != _hour || _minute != minute || ![_remindTypeStr isEqualToString:@"测量血糖"]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:confirmAction];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }break;
         case EditRemind:
        {
            if (_hour != _reminderModel.hour || _minute != _reminderModel.minute || _remindTypeStr != _reminderModel.reminder_type || _repeatWeekDayStr != _reminderModel.repeat_type ) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:confirmAction];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }break;
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}
// -- 删除
- (void)deleteClick{
    [MobClick event:@"102_003005"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14-05"];
#endif
    NSString *body = [NSString stringWithFormat:@"time_reminder_id=%ld",(long)_reminderModel.time_reminder_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReminderDelete body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 1) {
            [TCHelper sharedTCHelper].isRemindersLisReload = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== ReminderTimePickViewDelegate =======
- (void)didSelectedPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component RowText:(NSString *)text{
    [MobClick event:@"102_003001"];
    switch (component) {
        case 0:
        {
            _hour = row;
        }break;
        case 2:
        {
            _minute = row;
        }break;
        default:
            break;
    }
}
#pragma mark ====== TimePickerViewDelegate =======
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        switch (_Picker.pickerStyle ) {
            case PickerStyle_ReminderType:
            {
                NSInteger index=[_Picker.locatePicker selectedRowInComponent:0];
                _remindTypeStr = [NSString stringWithFormat:@"%@",[[TCHelper sharedTCHelper].reminderTypeArr objectAtIndex:index]];
                [_remindTableView reloadData];
            }break;
            default:
                break;
        }
    }
}
#pragma mark ====== UITableViewDelegate && UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *remindCellIdentifier  = @"remindCellIdentifier";
    TCEditAndAddRemindCell *editAndAddRemindCell = [tableView dequeueReusableCellWithIdentifier:remindCellIdentifier];
    if (!editAndAddRemindCell) {
        editAndAddRemindCell = [[TCEditAndAddRemindCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remindCellIdentifier];
    }
    editAndAddRemindCell.selectionStyle = UITableViewCellSelectionStyleNone;
    editAndAddRemindCell.titleLab.text = _reminderTypeTitleArray[indexPath.row];
    if (_remindType == BloodSugarRemind ) {
        editAndAddRemindCell.arrowImg.hidden = YES;
    }
    switch (indexPath.row) {
        case 0:
        {
            editAndAddRemindCell.contentLab.text = _remindTypeStr;
        }break;
        case 1:
        {
            editAndAddRemindCell.contentLab.text = _repeatWeekDayStr;
        }break;
        default:
            break;
    }
    return editAndAddRemindCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_remindType != BloodSugarRemind) {
        switch (indexPath.row) {
            case 0:
            {
                [MobClick event:@"102_003002"];
                _Picker =[[TimePickerView alloc]initWithTitle:@"" delegate:self];
                _Picker.pickerStyle=PickerStyle_ReminderType;
                [_Picker.locatePicker selectRow:0 inComponent:0 animated:YES];
                [_Picker showInView:self.view];
                [_Picker pickerView:_Picker.locatePicker didSelectRow:0 inComponent:0];
            }break;
            case 1:
            {
                [MobClick event:@"102_003003"];
                TCRemindTimeViewController *remindTimeVC = [TCRemindTimeViewController new];
                NSMutableArray *valueArray = [[NSMutableArray alloc] init];
                [valueArray addObjectsFromArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
                NSArray *weakArray = [[self setRepeatWeekDayStr:_repeatWeekDayStr] componentsSeparatedByString:@" "];
                for (int i=0; i<_weakDays.count; i++) {
                    for (int j=0; j<weakArray.count; j++) {
                        if ([_weakDays[i] isEqualToString:weakArray[j]]) {
                            [valueArray replaceObjectAtIndex:i withObject:@"1"];
                        }
                    }
                }
                remindTimeVC.checkImgArr = valueArray;
                kSelfWeak;
                remindTimeVC.checkImgBlock =^(NSArray *imgArr){
                    NSMutableArray *treat = [[NSMutableArray alloc] init];
                    for (int i =0; i<imgArr.count; i++) {
                        if ([imgArr[i] isEqualToString:@"1"]) {
                            [treat addObject:_weakDays[i]];
                        }
                    }
                    NSString *weakTimeStr = [treat componentsJoinedByString:@" "];
                    _repeatWeekDayStr = [self timeShowWitnRepeatimeStr:weakTimeStr];
                    [weakSelf.remindTableView reloadData];
                };
                [self.navigationController pushViewController:remindTimeVC animated:YES];
            }break;
            default:
                break;
        }
    }
}
#pragma mark ====== 时间处理 =======
- (NSString *)timeShowWitnRepeatimeStr:(NSString *)timeStr{
    NSString *weakDayStr;
    if ([timeStr isEqualToString:@"周一 周二 周三 周四 周五"]) {
        weakDayStr = @"工作日";
    }else if ([timeStr isEqualToString:@"周一 周二 周三 周四 周五 周六 周日"]){
        weakDayStr = @"每天";
    }else if([timeStr isEqualToString:@""]){
        weakDayStr = @"从不";
    }else{
        weakDayStr = timeStr;
    }
    return weakDayStr;
}
#pragma mark ====== 重复时间处理 =======
- (NSString *)setRepeatWeekDayStr:(NSString *)repeatType{
    NSString *repeatStr;
    if ([repeatType isEqualToString:@"工作日"]) {
        repeatStr = @"周一 周二 周三 周四 周五";
    }else if ([repeatType isEqualToString:@"每天"]){
        repeatStr = @"周一 周二 周三 周四 周五 周六 周日";
    }else{
        repeatStr = repeatType;
    }
    return repeatStr;
}
#pragma mark ======  Getter && Setter =======
- (UITableView *)remindTableView{
    if (!_remindTableView) {
        _remindTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _remindTableView.backgroundColor = [UIColor bgColor_Gray];
        _remindTableView.delegate = self;
        _remindTableView.dataSource = self;
        _remindTableView.rowHeight = 38;
        _remindTableView.tableHeaderView = [self tableHearView];
        _remindTableView.tableFooterView = self.remindType == EditRemind ? [self tableViewFooterView] :[UIView new];
        _remindTableView.scrollEnabled = NO;
    }
    return _remindTableView;
}
- (TCReminderTimePickView *)reminderTimePickView{
    if (!_reminderTimePickView) {
        _reminderTimePickView = [[TCReminderTimePickView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
        _reminderTimePickView.reminderDelegate = self;
        _reminderTimePickView.proTitleList = _pickTimeArray;
        _reminderTimePickView.pickView.showsSelectionIndicator = self;
    }
    return _reminderTimePickView;
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
    if (![self isAllowedNotification]) {//YES
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
