//
//  TCManagerViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCManagerViewController.h"
#import "TCRecordSugarViewController.h"
#import "TCRecordDietViewController.h"
#import "TCRecordSportViewController.h"
#import "TCHistoryRecordsViewController.h"
#import "TCLoginViewController.h"
#import "TCManagerTitleView.h"
#import "TCMangerRecordView.h"
#import "TCSugarModel.h"
#import "TCSugarRecordHeadView.h"
#import "TCStepStaticsViewController.h"
#import "TCHealthManager.h"
#import "TCRegularRemindersViewController.h"
#import "TCCheckListView.h"
#import "TCFastLoginViewController.h"

@interface TCManagerViewController ()<TCManagerTitleViewDelegate,TCSugarRecordDelegate,TCCheckListRecordDelegate>{
    NSArray           *sugarTimeArray;        //血糖值时间段数据
    NSArray           *weekTimeArray;

    NSInteger        startTimeSp;   //开始时间
    NSInteger        endTimeSp;     //结束时间
    
}

@property (nonatomic,strong)UIScrollView       *rootScrollView;
@property (nonatomic,strong)TCSugarRecordHeadView *sugarAddView;
@property (nonatomic,strong)TCSugarRecordHeadView *foodAddView;
@property (nonatomic,strong)TCSugarRecordHeadView *sportAddView;
@property (nonatomic,strong)TCSugarRecordHeadView *stepAddView;
@property (nonatomic,strong)TCSugarRecordHeadView *bloodAddView;
@property (nonatomic,strong)TCSugarRecordHeadView *porteinAddView;
@property (nonatomic,strong)TCCheckListView       *checkListAddView;

@property (nonatomic,strong)UIView *centerView;
@property (nonatomic,strong)TCMangerRecordView *sugarChartView;       //今日血糖值视图
@property (nonatomic,strong)TCMangerRecordView *dietChartsView;       //周饮食摄入视图
@property (nonatomic,strong)TCMangerRecordView *sportsChartsView;     //周运动消耗视图


@end

@implementation TCManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"糖记录";
    self.isHiddenBackBtn=YES;
    self.leftImageName = @"ic_top_intime";
    
    sugarTimeArray=[TCHelper sharedTCHelper].sugarPeriodArr;
    weekTimeArray=[[TCHelper sharedTCHelper] getDateOfCurrentWeek];
    
    NSString *endDate=[[TCHelper sharedTCHelper] getCurrentDate];   //今天
    NSString *startDate=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:6];  //今天之前7天
    startTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:startDate format:@"yyyy-MM-dd"];
    endTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:endDate format:@"yyyy-MM-dd"];
    
    [self.view addSubview:self.rootScrollView];   
    [self.rootScrollView addSubview:self.sugarAddView];
    [self.rootScrollView addSubview:self.foodAddView];
    [self.rootScrollView addSubview:self.sportAddView];
    [self.rootScrollView addSubview:self.stepAddView];
    [self.rootScrollView addSubview:self.centerView];
    [self.rootScrollView addSubview:self.bloodAddView];
    [self.rootScrollView addSubview:self.porteinAddView];
    [self.rootScrollView addSubview:self.checkListAddView];
    
    [self.rootScrollView addSubview:self.sugarChartView];
    [self.rootScrollView addSubview:self.dietChartsView];
    [self.rootScrollView addSubview:self.sportsChartsView];
    
    [self.rootScrollView setContentSize:CGSizeMake(kScreenWidth, self.sportsChartsView.bottom)];
    
    [self requestAllManagerRecordsData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TCHelper sharedTCHelper].isManagerRecordReload) {
        [self requestAllManagerRecordsData];
        [TCHelper sharedTCHelper].isManagerRecordReload=NO;
    }
    
    if ([TCHelper sharedTCHelper].isBloodReload) {
        [self loadTodaySugarValue];
        [self requestRecordData];
        [TCHelper sharedTCHelper].isBloodReload=NO;
    }
    
    if ([TCHelper sharedTCHelper].isDietReload) {
        [self requestRecordData];
        [self loadWeekDietData];
        [TCHelper sharedTCHelper].isDietReload=NO;
    }
    
    if ([TCHelper sharedTCHelper].isSportsReload) {
        [self requestRecordData];
        [self loadWeekSportData];
        [TCHelper sharedTCHelper].isSportsReload=NO;
    }
    if ([TCHelper sharedTCHelper].isLoadStep) {
        [self reloadStep];
        [TCHelper sharedTCHelper].isLoadStep=NO;
    }
    if ([TCHelper sharedTCHelper].isLoadGlycosylated||[TCHelper sharedTCHelper].isLoadBloodRecord||[TCHelper sharedTCHelper].isExaminationRecord) {
        [self requestRecordData];
        [TCHelper sharedTCHelper].isLoadGlycosylated=[TCHelper sharedTCHelper].isLoadBloodRecord=[TCHelper sharedTCHelper].isExaminationRecord=NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"005" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"005" type:2];
#endif
}
#pragma mark ====== Action =======

- (void)leftButtonAction{
    [MobClick event:@"102_001002"];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-14"];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        TCRegularRemindersViewController *regulaRemindersVC = [TCRegularRemindersViewController new];
        regulaRemindersVC.hidesBottomBarWhenPushed  = YES;
        [self.navigationController pushViewController:regulaRemindersVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark -- Custom Delegate

#pragma mark TCManagerTitleViewDelegate
-(void)managerTitleViewGotHistoryData:(TCManagerTitleView *)managerTitleView{
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        NSString *titleStr=nil;
        NSString *mobTitle = nil;
        if (managerTitleView==self.sugarChartView.titleView) {
            titleStr=@"血糖";
            mobTitle = @"102_001016";
        }else if (managerTitleView==self.dietChartsView.titleView){
            titleStr=@"饮食";
            mobTitle = @"102_001017";
        }else{
            titleStr=@"运动";
            mobTitle = @"102_001018";
        }
        [MobClick event:mobTitle];

        TCHistoryRecordsViewController *historyVC=[[TCHistoryRecordsViewController alloc] init];
        historyVC.hidesBottomBarWhenPushed=YES;
        historyVC.typeStr=titleStr;
        [self.navigationController pushViewController:historyVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark --TCSugarRecordDelegate
- (void)TCSugarRecordForIndex:(NSInteger)type{
    NSArray *mobArr = @[@"102_001003",@"102_001005",@"102_001007",@"102_001009",@"102_001010",@"102_001012"];
    [MobClick event:mobArr[type-1]];

    if (type>0&&type<=4) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-0%ld",type]];
#endif
    }else if(type==5){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-08"]];
#endif
    }else if (type==6){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-10"]];
#endif
    }
    if (type==4) {
        TCStepStaticsViewController *stepVC=[[TCStepStaticsViewController alloc] init];
        stepVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:stepVC animated:YES];
    }else{
        BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
        if (isLogin) {
            if (type>4) {
                NSArray *titleArr = @[@"血压",@"糖化血红蛋白"];
                TCHistoryRecordsViewController *historyVC = [[TCHistoryRecordsViewController alloc] init];
                historyVC.typeStr = titleArr[type-5];
                historyVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:historyVC animated:YES];
            } else {
                NSArray *controllers=@[@"SugarData",@"HomeDiet",@"HomeSports"];
                NSString *className=[NSString stringWithFormat:@"%@%@%@",@"TC",controllers[type-1],@"ViewController"];
                Class aClass=NSClassFromString(className);
                BaseViewController *controller=[[aClass alloc] init];
                controller.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }else{
            [self fastLoginAction];
        }
    }
}

- (void)TCAddRecordForIndex:(NSInteger)type{
    NSArray *mobArr = @[@"102_001004",@"102_001006",@"102_001008",@"102_001009",@"102_001011",@"102_001013"];
    [MobClick event:mobArr[type-1]];

    if (type==1) {
#if !DEBUG 
        [[TCHelper sharedTCHelper] loginClick:@"005-01-01"];
#endif
    } else if (type==5){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-09"]];
#endif
    } else if (type==6){
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-11"]];
#endif
    }
    if (type==4) {
        TCStepStaticsViewController *stepVC=[[TCStepStaticsViewController alloc] init];
        stepVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:stepVC animated:YES];

    }else{
        BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
        if (isLogin) {
            NSArray *controllers=@[@"RecordSugar",@"RecordDiet",@"RecordSport",@"AddBlood",@"Pertain"];
            NSString *className=[NSString stringWithFormat:@"%@%@%@",@"TC",controllers[type>4?type-2:type-1],@"ViewController"];
            Class aClass=NSClassFromString(className);
            BaseViewController *controller=[[aClass alloc] init];
            controller.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [self fastLoginAction];
        }
    }
}
#pragma mark -- TCCheckListRecordDelegate
- (void)TCCheckListRecordForIndex:(NSInteger)type{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-12"]];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        [MobClick event:@"102_001014"];
        TCHistoryRecordsViewController *historyVC = [[TCHistoryRecordsViewController alloc] init];
        historyVC.typeStr = @"检查单";
        historyVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:historyVC animated:YES];
    }else{
        [self fastLoginAction];
    }

}
- (void)TCAddCheckListForIndex:(NSInteger)type{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"005-13"]];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        [MobClick event:@"102_001015"];
        NSString *className=[NSString stringWithFormat:@"%@%@%@",@"TC",@"CheckList",@"ViewController"];
        Class aClass=NSClassFromString(className);
        BaseViewController *controller=[[aClass alloc] init];
        controller.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
       [self fastLoginAction];
    }

}
#pragma mark -- Private Methods
#pragma mark 获取所有糖记录数据
-(void)requestAllManagerRecordsData{
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        [self loadTodaySugarValue];
        [self loadWeekDietData];
        [self loadWeekSportData];
        [self requestRecordData];
    }else{
        self.sugarAddView.num=0;
        self.sugarAddView.data=@{@"detail":@"记录血糖，轻松掌控血糖数据",@"time":@""};
        
        self.foodAddView.num=0;
        self.foodAddView.data = @{@"detail":@"记录饮食，全方位评估饮食状况",@"time":@""};
        
        self.sportAddView.num=0;
        self.sportAddView.data = @{@"detail":@"记录运动，保持良好运动习惯",@"time":@""};
        
        self.bloodAddView.num=0;
        self.bloodAddView.data = @{@"detail":@"记录血压变化，谨防并发症",@"time":@""};
        
        self.porteinAddView.num=0;
        self.porteinAddView.data = @{@"detail":@"监控数值，有效反映血糖控制情况",@"time":@""};
        
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        self.checkListAddView.imgArr = imgArray;
    }
}


#pragma mark  获取记录数据
- (void)requestRecordData{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSugarRecordList body:@"" success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        //血糖
        id bloodDict = [result objectForKey:@"bloodList"];
        if ( (kIsArray(bloodDict)&&[(NSArray *)bloodDict count]>0)||(kIsDictionary(bloodDict)&&[(NSDictionary *)bloodDict count]>0)){
            NSString *time_sort= [[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:[bloodDict objectForKey:@"time_slot"]];
            NSString *bloodStr = [NSString stringWithFormat:@"%@mmol/L %@",[bloodDict objectForKey:@"glucose"],time_sort];
            NSString *num =[bloodDict objectForKey:@"glucose"];
            _sugarAddView.num =num.length;
            _sugarAddView.data = @{@"detail":bloodStr,@"time":[bloodDict objectForKey:@"last_date"]};
        }else{
            _sugarAddView.num=0;
            _sugarAddView.data = @{@"detail":@"记录血糖，轻松掌控血糖数据",@"time":@""};
        }
        
         //饮食
        id dietDict = [result objectForKey:@"dietList"];
        if ( (kIsArray(dietDict)&&[(NSArray *)dietDict count]>0)||(kIsDictionary(dietDict)&&[(NSDictionary *)dietDict count]>0)) {
            if ([[dietDict objectForKey:@"sum_calories"] integerValue]>0) {
                NSString *dietStr = [NSString stringWithFormat:@"%@千卡",[dietDict objectForKey:@"sum_calories"]];
                NSString *num =[NSString stringWithFormat:@"%@",[dietDict objectForKey:@"sum_calories"]];
                _foodAddView.num =num.length;
                _foodAddView.data = @{@"detail":dietStr,@"time":[dietDict objectForKey:@"last_date"]};
            }
        }else{
        _foodAddView.num=0;
        _foodAddView.data = @{@"detail":@"记录饮食，全方位评估饮食状况",@"time":@""};
        }
        
         //运动
        id motionDict = [result objectForKey:@"motionList"];
        if ( (kIsArray(motionDict)&&[(NSArray *)motionDict count]>0)||(kIsDictionary(motionDict)&&[(NSDictionary *)motionDict count]>0)) {
            if ([[motionDict objectForKey:@"sum_calories"] integerValue]>0) {
                NSString *motionStr = [NSString stringWithFormat:@"%@千卡",[motionDict objectForKey:@"sum_calories"]];
                NSString *num =[NSString stringWithFormat:@"%@",[motionDict objectForKey:@"sum_calories"]];
                _sportAddView.num =num.length;
                _sportAddView.data = @{@"detail":motionStr,@"time":[motionDict objectForKey:@"last_date"]};
            }
        }else{
        _sportAddView.num=0;
        _sportAddView.data = @{@"detail":@"记录运动，保持良好运动习惯",@"time":@""};
        }
        //血压记录
        id  bloodPressuredDict = [result objectForKey:@"pressureList"];
        if ( (kIsArray(bloodPressuredDict)&&[(NSArray *)bloodPressuredDict count]>0)||(kIsDictionary(bloodPressuredDict)&&[(NSDictionary *)bloodPressuredDict count]>0)) {
            if ([[bloodPressuredDict objectForKey:@"diastolic_pressure"] floatValue]>0) {
                NSString *motionStr = [NSString stringWithFormat:@"%@/%@mmHg",[bloodPressuredDict objectForKey:@"systolic_pressure"],[bloodPressuredDict objectForKey:@"diastolic_pressure"]];
                NSString *num =[NSString stringWithFormat:@"%@",[bloodPressuredDict objectForKey:@"systolic_pressure"]];
                NSString *bloodNum =[NSString stringWithFormat:@"%@",[bloodPressuredDict objectForKey:@"diastolic_pressure"]];
                _bloodAddView.bloodNum = bloodNum.length;
                _bloodAddView.num =num.length;
                _bloodAddView.data = @{@"detail":motionStr,@"time":[bloodPressuredDict objectForKey:@"last_date"]};
            }
        }else{
            _bloodAddView.bloodNum=0;
            _bloodAddView.num=0;
            _bloodAddView.data = @{@"detail":@"记录血压变化，谨防并发症",@"time":@""};
        }

        //糖化记录
        id  glycosylatedDict = [result objectForKey:@"glycosylatedList"];
        if ( (kIsArray(glycosylatedDict)&&[(NSArray *)glycosylatedDict count]>0)||(kIsDictionary(glycosylatedDict)&&[(NSDictionary *)glycosylatedDict count]>0)) {
            if ([[glycosylatedDict objectForKey:@"measure_value"] floatValue]>0) {
                NSString *motionStr = [NSString stringWithFormat:@"%@％",[glycosylatedDict objectForKey:@"measure_value"]];
                NSString *num =[NSString stringWithFormat:@"%@",[glycosylatedDict objectForKey:@"measure_value"]];
                _porteinAddView.num =num.length;
                _porteinAddView.data = @{@"detail":motionStr,@"time":[glycosylatedDict objectForKey:@"last_date"]};
            }
        }else{
            _porteinAddView.num=0;
            _porteinAddView.data = @{@"detail":@"监控数值，有效反映血糖控制情况",@"time":@""};
        }
        //检查单记录
        id  examinationDict = [result objectForKey:@"examinationList"];
        if ( (kIsArray(examinationDict)&&[(NSArray *)examinationDict count]>0)||(kIsDictionary(examinationDict)&&[(NSDictionary *)examinationDict count]>0)) {
                NSArray *imgArr =[examinationDict objectForKey:@"image"];
                NSMutableArray *imgArray = [[NSMutableArray alloc] init];
                if (imgArr.count >0) {
                    for (int i=0; i<imgArr.count; i++) {
                        NSString *imgUrl = [imgArr[i] objectForKey:@"image_url"];
                        [imgArray addObject:imgUrl];
                    }
                    _checkListAddView.timeText =[examinationDict objectForKey:@"last_date"];
                    _checkListAddView.imgArr = imgArray;
                }
        }else{
            NSMutableArray *imgArray = [[NSMutableArray alloc] init];
            _checkListAddView.imgArr = imgArray;

        }

    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 更新步数
- (void)reloadStep{

    //步数
    NSInteger stepCount=[[NSUserDefaultsInfos getValueforKey:kStepKey] integerValue];
    NSString *stepStr=stepCount>0?[NSString stringWithFormat:@"%ld 步",(long)stepCount]:@"0 步";
    NSString *time = [TCHelper sharedTCHelper].getCurrentDate;
    _stepAddView.data = @{@"detail":stepStr,@"time":time};

}
#pragma mark 获取今日血糖值
-(void)loadTodaySugarValue{
    //今日血糖记录
    NSString *currentDate=[[TCHelper sharedTCHelper] getCurrentDate];
    NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDate format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"measurement_time_begin=%ld&measurement_time_end=%ld&output-way=1",(long)timeSp,(long)timeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            self.sugarChartView.values=result;
            [self.sugarChartView.chartView strokeChart];
        }else{
            self.sugarChartView.values=nil;
            [self.sugarChartView.chartView strokeChart];
        }
    } failure:^(NSString *errorStr) {
        self.sugarChartView.values=nil;
        [self.sugarChartView.chartView strokeChart];
    }];
}

#pragma mark 获取一周饮食摄入数据
-(void)loadWeekDietData{
    NSString *body=[NSString stringWithFormat:@"feeding_time_begin=%ld&feeding_time_end=%ld&output-way=2",(long)startTimeSp,(long)endTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDietRecordLists body:body success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        if (kIsDictionary(dict)&&dict.count>0) {
            NSDictionary *dietDict=[dict valueForKey:@"dietrecord"];
            if (kIsDictionary(dietDict)&&dietDict.count>0) {
                NSArray *timeArr=[dietDict allKeys];
                
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0; i<weekTimeArray.count; i++) {
                    NSString *dateStr=weekTimeArray[i];
                    NSInteger allCalories=0;
                    for (NSString *time in timeArr) {
                        NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:time format:@"yyyy-MM-dd"];
                        NSString *timeStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"M/d"];
                        if ([timeStr isEqualToString:dateStr]) {
                            NSArray *dietList=[dietDict valueForKey:time];
                            for (NSDictionary *dic in dietList) {
                                TCFoodRecordModel *foodModel=[[TCFoodRecordModel alloc] init];
                                [foodModel setValues:dic];
                                for (NSDictionary *dict in foodModel.ingredient) {
                                    allCalories+=[dict[@"ingredient_calories"] integerValue];
                                }
                            }
                        }
                    }
                    NSNumber *calorieNum=[NSNumber numberWithInteger:allCalories];
                    [tempArr addObject:calorieNum];
                }

                self.dietChartsView.values=tempArr;
                self.dietChartsView.yMaxValue=10000;
                self.dietChartsView.yMarginValue=500;
                [self.dietChartsView.chartView strokeChart];
            }else{
                self.dietChartsView.values=nil;
                [self.dietChartsView.chartView strokeChart];
            }
        }
    } failure:^(NSString *errorStr) {
        self.dietChartsView.values=nil;
        [self.dietChartsView.chartView strokeChart];
    }];
}

#pragma mark 获取一周运动消耗数据
-(void)loadWeekSportData{
    NSString *body=[NSString stringWithFormat:@"motion_bigin_time_begin=%ld&motion_bigin_time_end=%ld&output-way=2",(long)startTimeSp,(long)endTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        if (kIsDictionary(dict)&&dict.count>0) {
            NSDictionary *sportDict=[dict valueForKey:@"motionrecord"];
            if (kIsDictionary(sportDict)&&sportDict.count>0) {
                NSArray *timeArr=[sportDict allKeys];
                
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0; i<weekTimeArray.count; i++) {
                    NSString *dateStr=weekTimeArray[i];
                    NSInteger allCalories=0;
                    for (NSString *time in timeArr) {
                        NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:time format:@"yyyy-MM-dd"];
                        NSString *timeStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"M/d"];
                        if ([timeStr isEqualToString:dateStr]) {
                            NSArray *sportList=[sportDict valueForKey:time];
                            for (NSDictionary *dic in sportList) {
                                TCSportRecordModel *sportModel=[[TCSportRecordModel alloc] init];
                                [sportModel setValues:dic];
                                allCalories+=[sportModel.calorie integerValue];
                            }
                        }
                    }
                    NSNumber *calorieNum=[NSNumber numberWithInteger:allCalories];
                    [tempArr addObject:calorieNum];
                }

                self.sportsChartsView.values=tempArr;
                self.sportsChartsView.yMaxValue=10000;
                self.sportsChartsView.yMarginValue=250;
                [self.sportsChartsView.chartView strokeChart];
            }else{
                self.sportsChartsView.values=nil;
                [self.sportsChartsView.chartView strokeChart];
            }
        }
    } failure:^(NSString *errorStr) {
        self.sportsChartsView.values=nil;
        [self.sportsChartsView.chartView strokeChart];
    }];
}

#pragma mark -- Getters and Setters
#pragma mark 根滑动视图
-(UIScrollView *)rootScrollView{
    if (_rootScrollView==nil) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-kTabHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark 血糖
- (TCSugarRecordHeadView *)sugarAddView{
    if (_sugarAddView==nil) {
        NSDictionary *left = @{@"image":@"ic_record_xuetang",@"title":@"血糖",@"detail":@"记录血糖，轻松掌控血糖数据"};
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"记录"};

        _sugarAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _sugarAddView.backgroundColor = [UIColor whiteColor];
        _sugarAddView.type=1;
        _sugarAddView.delegate = self;
        _sugarAddView.layer.cornerRadius = 5;
    }
    return _sugarAddView;
}
#pragma mark 饮食
- (TCSugarRecordHeadView *)foodAddView{
    if (_foodAddView==nil) {
        NSDictionary *left = @{@"image":@"ic_record_yinshi",@"title":@"饮食",@"detail":@"记录饮食，全方位评估饮食状况"};
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"记录"};
        
        _foodAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, _sugarAddView.bottom+5, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _foodAddView.backgroundColor = [UIColor whiteColor];
        _foodAddView.type=2;
        _foodAddView.delegate = self;
        _foodAddView.layer.cornerRadius = 5;
    }
    return _foodAddView;
}
#pragma mark 运动
- (TCSugarRecordHeadView *)sportAddView{
    if (_sportAddView==nil) {

        NSDictionary *left = @{@"image":@"ic_record_sport",@"title":@"运动",@"detail":@"记录运动，保持良好运动习惯"};
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"记录"};
        
        _sportAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, _foodAddView.bottom+5, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _sportAddView.backgroundColor = [UIColor whiteColor];
        _sportAddView.type=3;
        _sportAddView.delegate = self;
        _sportAddView.layer.cornerRadius = 5;
    }
    return _sportAddView;
}
#pragma mark 步数
- (TCSugarRecordHeadView *)stepAddView{
    if (_stepAddView==nil) {
        NSInteger stepCount=[[NSUserDefaultsInfos getValueforKey:kStepKey] integerValue];
        NSString *nums =[NSString stringWithFormat:@"%ld",stepCount];
        NSString *stepStr=stepCount>0?[NSString stringWithFormat:@"%ld 步",(long)stepCount]:@"0 步";
        NSString *time = [TCHelper sharedTCHelper].getCurrentDate;
        NSDictionary *left = @{@"image":@"ic_record_walk",@"title":@"步数",@"detail":@"0步"};
        
        NSDictionary *right = @{@"image":@"pub_ic_right",@"title":stepCount-[stepStr integerValue]>0?@"达标":@"未达标"};
        _stepAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, _sportAddView.bottom+5, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _stepAddView.backgroundColor = [UIColor whiteColor];
        _stepAddView.type=4;
        _stepAddView.delegate = self;
        _stepAddView.layer.cornerRadius = 5;
        _stepAddView.num =nums.length;
        _stepAddView.data = @{@"detail":stepStr,@"time":time};
    }
    return _stepAddView;
}
#pragma mark -- 完善记录－轻松控糖
- (UIView *)centerView{
    if (_centerView==nil) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, _stepAddView.bottom+5, kScreenWidth, 40)];
        _centerView.backgroundColor = [UIColor bgColor_Gray];
        
        UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-160)/2,10, 160, 20)];
        centerLabel.text = @"完善记录，轻松稳糖";
        centerLabel.textColor = [UIColor grayColor];
        centerLabel.font = [UIFont systemFontOfSize:15];
        centerLabel.textAlignment = NSTextAlignmentCenter;
        [_centerView addSubview:centerLabel];
        
        UILabel *leftLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20, (kScreenWidth-160)/2-20, 1)];
        leftLineLabel.backgroundColor = [UIColor grayColor];
        [_centerView addSubview:leftLineLabel];

        UILabel *rightLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftLineLabel.right+160,20, (kScreenWidth-160)/2-20, 1)];
        rightLineLabel.backgroundColor = [UIColor grayColor];
        [_centerView addSubview:rightLineLabel];
    }
    return _centerView;
}

#pragma mark 血压
- (TCSugarRecordHeadView *)bloodAddView{
    if (_bloodAddView==nil) {
        
        NSDictionary *left = @{@"image":@"ic_record_xueya",@"title":@"血压",@"detail":@"记录血压变化，谨防并发症"};
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"记录"};
        
        _bloodAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, _centerView.bottom+5, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _bloodAddView.backgroundColor = [UIColor whiteColor];
        _bloodAddView.type=5;
        _bloodAddView.delegate = self;
        _bloodAddView.layer.cornerRadius = 5;
    }
    return _bloodAddView;
}

#pragma mark 糖化血红蛋白
- (TCSugarRecordHeadView *)porteinAddView{
    if (_porteinAddView==nil) {
        
        NSDictionary *left = @{@"image":@"ic_record_xuehong",@"title":@"糖化血红蛋白",@"detail":@"监控数值，有效反映血糖控制情况"};
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"记录"};
        
        _porteinAddView = [[TCSugarRecordHeadView alloc] initWithFrame:CGRectMake(10, _bloodAddView.bottom+5, kScreenWidth-20, 70) leftDict:left rightDict:right];
        _porteinAddView.backgroundColor = [UIColor whiteColor];
        _porteinAddView.type=6;
        _porteinAddView.delegate = self;
        _porteinAddView.layer.cornerRadius = 5;
    }
    return _porteinAddView;
}

#pragma mark 检查单
- (TCCheckListView *)checkListAddView{
    if (_checkListAddView==nil) {
        NSDictionary *right = @{@"image":@"pub_ic_add",@"title":@"添加"};
        _checkListAddView = [[TCCheckListView alloc] initWithFrame:CGRectMake(10, _porteinAddView.bottom+5, kScreenWidth-20, 90) rightCheckDict:right];
        _checkListAddView.backgroundColor = [UIColor whiteColor];
        _checkListAddView.type=7;
        _checkListAddView.delegate = self;
        _checkListAddView.layer.cornerRadius = 5;
        _checkListAddView.imgArr=[[NSArray alloc] init];
    }
    return _checkListAddView;
}

#pragma mark 今日血糖值
-(TCMangerRecordView *)sugarChartView{
    if (_sugarChartView==nil) {
        _sugarChartView=[[TCMangerRecordView alloc] initWithFrame:CGRectMake(0, self.checkListAddView.bottom+10, kScreenWidth, 250) type:0];
        _sugarChartView.titleView.delegate=self;
    }
    return _sugarChartView;
}

#pragma mark 周饮食摄入
-(TCMangerRecordView *)dietChartsView{
    if (_dietChartsView==nil) {
        _dietChartsView=[[TCMangerRecordView alloc] initWithFrame:CGRectMake(0, self.sugarChartView.bottom+10, kScreenWidth, 250) type:1];
        _dietChartsView.titleView.delegate=self;
    }
    return _dietChartsView;
}

#pragma mark 周运动消耗
-(TCMangerRecordView *)sportsChartsView{
    if (_sportsChartsView==nil) {
        _sportsChartsView=[[TCMangerRecordView alloc] initWithFrame:CGRectMake(0, self.dietChartsView.bottom+10, kScreenWidth, 250) type:2];
        _sportsChartsView.titleView.delegate=self;
    }
    return _sportsChartsView;
}

@end
