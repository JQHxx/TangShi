//
//  TCCheckInDailyViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCheckInDailyViewController.h"
#import "TCTodayMissionViewController.h"
#import "TCRuleAlertView.h"
#import "FSCalendar.h"
#import "TCMissionCompletedAlertView.h"
#import "TCPointslMallViewController.h"
#import "QLCoreTextManager.h"
#import "TCSignCoutModel.h"

@interface TCCheckInDailyViewController ()<FSCalendarDelegate,FSCalendarDataSource>
{
    UILabel     *_continuousSignInDayLab; /// 连续签到天数
    UILabel     *_alwaysCheckInDayLab;    /// 总签到天数
    NSString    *_startTime;               /// 开始时间
    NSString    *_endTime;                 /// 结束时间
}
@property (strong, nonatomic) UIScrollView *rootScrollerView;

@property (strong, nonatomic) NSCalendar *gregorian;
/// 今日签到
@property (nonatomic, strong) UIButton *signTodayBtn;
/// 更多任务
@property (nonatomic ,strong) UIButton *moreTasksBtn;
/// 签到统计
@property (nonatomic ,strong) UIView *CheckInStatisticView;
/// 日历
@property (nonatomic ,strong) FSCalendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
/// 签到日期数据源
@property (nonatomic ,strong) NSMutableArray *signCoutArray;
/// 已签到日期数据
@property (nonatomic ,strong) NSMutableArray *signDateArray;

@end

@implementation TCCheckInDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"每日签到";
    self.rigthTitleName = @"规则";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self initCheckInDailyVC];
    [self loadCheckInDailyData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-10-01" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-10-01" type:2];
#endif

}
#pragma mark ====== Bulid UI =======
- (void)initCheckInDailyVC{
    [self.view addSubview:self.rootScrollerView];
    
    [self.rootScrollerView addSubview:self.calendar];
    [self.rootScrollerView addSubview:self.CheckInStatisticView];
    [self.rootScrollerView addSubview:self.signTodayBtn];
    [self.rootScrollerView addSubview:self.moreTasksBtn];
    self.rootScrollerView.contentSize = CGSizeMake(kScreenWidth, self.moreTasksBtn.bottom+20);
    
    self.dateFormatter1 = [[NSDateFormatter alloc] init];
    self.dateFormatter1.dateFormat = @"yyyy-MM-dd";
    
    NSArray *timeArr = [ [[TCHelper sharedTCHelper]getMonthBeginAndEndWith:self.calendar.currentPage] componentsSeparatedByString:@","];
    if (timeArr.count > 1) {
        _startTime = timeArr[0];
        _endTime = timeArr[1];
    }
}
#pragma mark ====== Request Data =======
- (void)loadCheckInDailyData{
    [self.signCoutArray removeAllObjects];
    [self.signDateArray removeAllObjects];
    NSString *version = [NSString getAppVersion];
    NSString *url = [NSString stringWithFormat:@"%@?start_time=%@&end_time=%@&app_version=%@",KSignCount,_startTime,_endTime,version];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            NSString *continueSign  = [NSString stringWithFormat:@"%@ 天",[resultDic objectForKey:@"continue_sign"]];
            NSString *totalSign   = [NSString stringWithFormat:@"%@ 天",[resultDic objectForKey:@"total_sign"]];;
            // 统计数据
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:continueSign];
            [QLCoreTextManager setAttributedValue:attString artlcleText:@"天"  font:[UIFont systemFontOfSize:15] color:UIColorFromRGB(0x313131)];
            _continuousSignInDayLab.attributedText = attString;
        
            NSMutableAttributedString *attStrings = [[NSMutableAttributedString alloc] initWithString:totalSign];
            [QLCoreTextManager setAttributedValue:attStrings artlcleText:@"天" font:[UIFont systemFontOfSize:15] color:UIColorFromRGB(0x313131)];
            _alwaysCheckInDayLab.attributedText = attStrings;
            
            // 签到日期
            NSArray *dateArray = [resultDic objectForKey:@"sign_detail"];
            if (kIsArray(dateArray) && dateArray.count > 0) {
                for (NSDictionary *dic in dateArray) {
                    TCSignCoutModel *signCoutModel = [TCSignCoutModel new];
                    [signCoutModel setValues:dic];
                    [weakSelf.signCoutArray addObject:signCoutModel];
                }
                for (NSInteger i = 0; i < self.signCoutArray.count; i++) {
                    TCSignCoutModel *signCoutModel = weakSelf.signCoutArray[i];
                    if (signCoutModel.status == 1) {
                        MyLog(@"----%ld --%@",i,signCoutModel.time);
                        [self.signDateArray addObject:[[TCHelper sharedTCHelper]timeWithTimeIntervalString:signCoutModel.time]];
                        NSString *timeString = [[TCHelper sharedTCHelper]timeWithTimeIntervalString:signCoutModel.time];
                        NSString *nowTimeStr = [[TCHelper sharedTCHelper]getCurrentDate];
                        
                        if ([timeString isEqualToString:nowTimeStr]) {
                            [weakSelf.signTodayBtn setTitle:@"已签到" forState:UIControlStateNormal];
                            [weakSelf.signTodayBtn setBackgroundColor:kLineColor];
                            weakSelf.signTodayBtn.enabled = NO;
                            [TCHelper sharedTCHelper].isHomeReload=YES;
                        }
                    }
                }
                 [weakSelf.calendar reloadData];// 刷新日历列表数据
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Action =======
- (void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-10-03"];
#endif
    [MobClick event:@"101_002022"];
    TCRuleAlertView *ruleAlertView = [[TCRuleAlertView alloc]initWithTitle:@"签到规则" andWithMassage:@"1、每日可签到一次，获得2积分；\n2、连续签到7天，可额外获得10积分；\n3、连续签到15天，可额外获得30积分；\n4、连续签到28天，可额外获得80积分。" andWithTag:1000 andWithButtonTitle:@"知道了", nil];
    ruleAlertView.resultIndex = ^(NSInteger titleBtnTag, NSInteger alertViewTag){
    };
    [ruleAlertView show];
}
#pragma mark ====== 签到 =======

- (void)signClick{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-10-02"];
#endif
    [MobClick event:@"101_002023"];
    [self loadTaskPointsWithActionType:1];
}
#pragma mark ====== 获取任务积分 =======
- (void)loadTaskPointsWithActionType:(NSInteger)actionType{
    // App版本信息
    NSString *version = [NSString getAppVersion];
    NSString *body = [NSString stringWithFormat:@"action_type=%ld&app_version=%@",actionType,version];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KIntegralTask body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            NSInteger points = [[resultDic objectForKey:@"points"] integerValue];
            NSInteger clickNum = [[resultDic objectForKey:@"click_num"] integerValue];
            NSInteger sumNum = [[resultDic objectForKey:@"max_num"] integerValue];
            [weakSelf showTaskSuccessAlertViewWithPoints:points sumNum:sumNum clickNum:clickNum actionType:actionType];
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [self loadCheckInDailyData];
        }
    } failure:^(NSString *errorStr) {
        //        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)showTaskSuccessAlertViewWithPoints:(NSInteger )points sumNum:(NSInteger)sumNum clickNum:(NSInteger)clickNum actionType:(NSInteger)actionType{
    NSString *taskSuccessStr = taskSuccessStr = [[TCHelper sharedTCHelper]getTaskNameWithActionType:actionType sumNum:sumNum clickNum:clickNum points:points];
    NSString *rewardIntegralStr;
    if (actionType == 1) {
        if (points == 12) {
            rewardIntegralStr = @"已经连续签到7天，额外奖励10积分";
        }else if (points == 32){
            rewardIntegralStr = @"已经连续签到15天，额外奖励30积分";
        }else if (points == 82){
            rewardIntegralStr = @"已经连续签到28天，额外奖励80积分";
        }else{
            rewardIntegralStr = @"";
        }
    }else{
        rewardIntegralStr = @"";
    }
    BOOL isHideBonusPoints = kIsEmptyString(rewardIntegralStr) ? YES : NO;
    BOOL isHideRedeem;
    if(actionType == 4) {
        isHideRedeem = YES;
    }else{
        isHideRedeem = NO;
    }
    kSelfWeak;
    TCMissionCompletedAlertView *alertView =[[TCMissionCompletedAlertView alloc]initWithTaskSuccessStr:taskSuccessStr points:points rewardIntegralStr:rewardIntegralStr isHideBonusPoints:isHideBonusPoints isHideRedeemBtn:isHideRedeem];
    alertView.alertResultBlcok = ^(NSInteger index){
        switch (index) {
            case 1002:
            {
                TCPointslMallViewController *mallVC = [TCPointslMallViewController new];
                [weakSelf.navigationController pushViewController:mallVC animated:YES];
            }break;
            default:
                break;
        }
    };
    [alertView show];
}
#pragma mark ====== 更多任务 =======
- (void)taskClick{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-10-04"];
#endif
    [MobClick event:@"101_002024"];
    
    if (_isTaskListLogin) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        TCTodayMissionViewController *todayMissionVC = [TCTodayMissionViewController new];
        todayMissionVC.isCheckLogin = YES;
        [self.navigationController pushViewController:todayMissionVC animated:YES];
    }
}
#pragma mark ====== 日期月份切换 =======
- (void)nextClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 1000:
        {
            NSDate *currentMonth = self.calendar.currentPage;
            NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
            [self.calendar setCurrentPage:previousMonth animated:YES];
            NSArray *timeArr = [ [[TCHelper sharedTCHelper]getMonthBeginAndEndWith:previousMonth] componentsSeparatedByString:@","];
            if (timeArr.count > 1) {
                _startTime = timeArr[0];
                _endTime = timeArr[1];
            }
            [self loadCheckInDailyData];
        }break;
         case 1001:
        {
            NSDate *currentMonth = self.calendar.currentPage;
            NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
            [self.calendar setCurrentPage:nextMonth animated:YES];
            NSArray *timeArr = [ [[TCHelper sharedTCHelper]getMonthBeginAndEndWith:nextMonth] componentsSeparatedByString:@","];
            if (timeArr.count > 1) {
                _startTime = timeArr[0];
                _endTime = timeArr[1];
            }
            [self loadCheckInDailyData];
        }break;
        default:
            break;
    }
}

#pragma mark ====== FSCalendarDelegate || FSCalendarDataSource =======
/* 设置日期标题文字 */
- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今日";
    }
    return nil;
}
/*  设置图标方法 */
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date{
    NSString *dateString = [self.dateFormatter1 stringFromDate:date];
    if ([self.signDateArray containsObject:dateString]) {
        return [UIImage imageNamed:@"ic_pub_arrow"];
    }
    return nil;
}
/* 取消日期点击响应 */
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date{
    return NO;
}
#pragma mark ====== Getter || Setter =======
- (UIScrollView *)rootScrollerView{
    if (!_rootScrollerView) {
        _rootScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kNewNavHeight)];
        _rootScrollerView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _rootScrollerView;
}
- (FSCalendar *)calendar{
    if (!_calendar) {
        _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300 * kScreenWidth/375)];
        _calendar.dataSource = self;
        _calendar.delegate = self;
        _calendar.backgroundColor = [UIColor whiteColor];
        _calendar.appearance.headerMinimumDissolvedAlpha = 0; // 设置年月左右两边相邻月份的清晰度
        _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase;
        _calendar.scrollEnabled = NO;     // 设置是否可以左右滑动切换月份
        _calendar.appearance.headerDateFormat = @"yyyy年MM月";        // 设置年月显示格式
        _calendar.appearance.todayColor = kSystemColor;              // 今天选中颜色
        _calendar.appearance.titleFont = kFontWithSize(13);
        _calendar.appearance.titleSelectionColor = [UIColor blackColor];  // 选中日期颜色
        _calendar.appearance.selectionColor = [UIColor whiteColor];       // 选中状态颜色
        _calendar.appearance.headerTitleColor = kSystemColor;  // 年份标题颜色
        _calendar.appearance.weekdayTextColor = UIColorFromRGB(0x313131); // 星期颜色
        
        UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previousButton.frame = CGRectMake(0, 5, 95, 34);
        previousButton.tag = 1000;
        [previousButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
        [previousButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_calendar addSubview:previousButton];
        
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-95,5, 95, 34);
        nextButton.tag = 1001;
        [nextButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_calendar addSubview:nextButton];
    }
    return _calendar;
}
- (UIButton *)signTodayBtn{
    if (!_signTodayBtn) {
        _signTodayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _signTodayBtn.frame = CGRectMake( 55 ,_CheckInStatisticView.bottom+30 , kScreenWidth - 110, 41);
        [_signTodayBtn setTitle:@"今日签到" forState:UIControlStateNormal];
        [_signTodayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signTodayBtn setBackgroundColor:kSystemColor];
        _signTodayBtn.layer.cornerRadius = 5;
        [_signTodayBtn addTarget:self action:@selector(signClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signTodayBtn;
}
- (UIButton *)moreTasksBtn{
    if (!_moreTasksBtn) {
        _moreTasksBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreTasksBtn.frame = CGRectMake((kScreenWidth - 100)/2,_signTodayBtn.bottom+20, 100, 20);
        [_moreTasksBtn setTitle:@"更多任务" forState:UIControlStateNormal];
        [_moreTasksBtn setTitleColor:UIColorFromRGB(0x626262) forState:UIControlStateNormal];
        [_moreTasksBtn setImage:[UIImage imageNamed:@"ic_more_task"] forState:UIControlStateNormal];
        [_moreTasksBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:3];
        _moreTasksBtn.titleLabel.font = kFontWithSize(15);
        [_moreTasksBtn addTarget:self action:@selector(taskClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreTasksBtn;
}
- (UIView *)CheckInStatisticView{
    if (!_CheckInStatisticView) {
        _CheckInStatisticView = [[UIView alloc]initWithFrame:CGRectMake(0, _calendar.bottom + 20, kScreenWidth, 133)];
        _CheckInStatisticView.backgroundColor = [UIColor whiteColor];
    
        UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 20)];
        tipLab.text = @"签到统计";
        tipLab.textColor = UIColorFromRGB(0x313131);
        tipLab.font = kFontWithSize(15);
        [_CheckInStatisticView addSubview:tipLab];
        
        _continuousSignInDayLab = [[UILabel alloc]initWithFrame:CGRectMake(0, tipLab.bottom + 10, kScreenWidth/2, 30)];
        _continuousSignInDayLab.textAlignment = NSTextAlignmentCenter;
        _continuousSignInDayLab.textColor = UIColorFromRGB(0xfc992b);
        _continuousSignInDayLab.font = kFontWithSize(50);
        [_CheckInStatisticView addSubview:_continuousSignInDayLab];
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2, 21, 0.5, _CheckInStatisticView.height - 42)];
        len.backgroundColor = kLineColor;
        [_CheckInStatisticView addSubview:len];
        
        _alwaysCheckInDayLab = [[UILabel alloc]initWithFrame:CGRectMake(_continuousSignInDayLab.right, tipLab.bottom + 10, kScreenWidth/2, 30)];
        _alwaysCheckInDayLab.textAlignment = NSTextAlignmentCenter;
        _alwaysCheckInDayLab.textColor = kSystemColor;
        _alwaysCheckInDayLab.font = kFontWithSize(50);
        [_CheckInStatisticView addSubview:_alwaysCheckInDayLab];
        
        UILabel *leftTipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _CheckInStatisticView.height - 40, kScreenWidth/2, 20)];
        leftTipLab.text = @"当月连续签到天数";
        leftTipLab.textAlignment = NSTextAlignmentCenter;
        leftTipLab.textColor = UIColorFromRGB(0x959595);
        leftTipLab.font = kFontWithSize(13);
        [_CheckInStatisticView addSubview:leftTipLab];
        
        UILabel *rightTipLab = [[UILabel alloc]initWithFrame:CGRectMake(leftTipLab.right, leftTipLab.top, kScreenWidth/2, 20)];
        rightTipLab.text = @"总共签到天数";
        rightTipLab.textAlignment = NSTextAlignmentCenter;
        rightTipLab.textColor = UIColorFromRGB(0x959595);
        rightTipLab.font = kFontWithSize(13);
        [_CheckInStatisticView addSubview:rightTipLab];
    }
    return _CheckInStatisticView;
}
- (NSMutableArray *)signCoutArray{
    if (!_signCoutArray) {
        _signCoutArray = [NSMutableArray array];
    }
    return _signCoutArray;
}
- (NSMutableArray *)signDateArray{
    if (!_signDateArray) {
        _signDateArray = [NSMutableArray array];
    }
    return _signDateArray;
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
