//
//  TCHomeSportsViewController.m
//  TonzeCloud
//
//  Created by fei on 2017/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHomeSportsViewController.h"
#import "TCStepStaticsViewController.h"
#import "TCDietIntakeView.h"
#import "TCSportsRecordsTableView.h"
#import "TCSportModel.h"
#import "TCHealthManager.h"
#import "TCHistoryRecordsViewController.h"
#import "TCRecordSportViewController.h"
#import "TCSportRecordModel.h"
#import "FDCalendar.h"
#import "HWPopTool.h"

@interface TCHomeSportsViewController ()<TCSportsRecordsTableViewDelegate,FDCalendarDelegate>{
    UIScrollView    *rootScrollView;
    NSInteger       targetStepCount;
    TCBlankView    *blankView;
    NSString       *nowDateStr;
    NSString       *seletedDateStr;
    UIView         *sportCover;
    FDCalendar     *sportCalendar;           //日历控件
}

@property (nonatomic,strong)UIButton                   *sportsTitleButton;        // 标题
@property (nonatomic,strong)TCDietIntakeView           *cosumeCaloriesView;       //消耗热量
@property (nonatomic,strong)UIButton                   *sportRecordsTitleBtn;     //运动记录标题
@property (nonatomic,strong)TCSportsRecordsTableView   *sportsRecordsTableView;   //运动记录
@property (nonatomic,strong)UIView                     *addSportsRecordView;      //记录运动

@end

@implementation TCHomeSportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightImageName = @"ic_n_time";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    targetStepCount=6000;
    
    nowDateStr=[[TCHelper sharedTCHelper] getCurrentDate];   //今天
    seletedDateStr = nowDateStr;
    [self initSportsView];
    [self getSportRecordsListWithDate:nowDateStr];          //获取运动数据
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isHomeSportsReload) {
        [self getSportRecordsListWithDate:seletedDateStr];
        [TCHelper sharedTCHelper].isHomeSportsReload=NO;
    }
    [MobClick beginLogPageView:@"运动记录"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"运动记录"];
}

#pragma mark -- CustomDelegate
-(void)sportsRecordTableView:(TCSportsRecordsTableView *)tableView didSelectStepSportModel:(TCSportModel *)stepModel{
    TCStepStaticsViewController *stepStaticsVC=[[TCStepStaticsViewController alloc] init];
    [self.navigationController pushViewController:stepStaticsVC animated:YES];
}

#pragma mark FDCalendarDelegate
-(void)calendarDidSelectDate:(NSString *)dateStr{
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        
    }];

    [MobClick event:@"102_002016"];

    NSInteger data =[[TCHelper sharedTCHelper] compareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        if ([dateStr isEqualToString:nowDateStr]) {
            self.sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
            self.sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
            [self.sportsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        }else{
            self.sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 120, 0, 0);
            self.sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -30, 0, 0);
            [self.sportsTitleButton setTitle:dateStr forState:UIControlStateNormal];
        }
        seletedDateStr=dateStr;
        [self getSportRecordsListWithDate:dateStr];
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
        
    }
}

#pragma mark -- Event Reponse
#pragma mark  运动记录
-(void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-03-02"];
#endif
    [MobClick event:@"102_002017"];
    
    TCHistoryRecordsViewController *recordVC = [[TCHistoryRecordsViewController alloc] init];
    recordVC.typeStr = @"运动";
    [self.navigationController pushViewController:recordVC animated:YES];
}

#pragma mark 选择日期（显示蒙板）
-(void)sportsTitleButtonClickForChooseTime:(UIButton *)sender{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor =[UIColor bgColor_Gray];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:seletedDateStr];
    
    sportCalendar=[[FDCalendar alloc] initWithCurrentDate:date];
    sportCalendar.calendarDelegate=self;
    [contentView addSubview:sportCalendar];
    contentView.frame = CGRectMake(20, 84, kScreenWidth-40, sportCalendar.bottom+20);
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}

#pragma mark 隐藏蒙板
-(void)makeHiddenCover{
    sportCover.alpha=0.0;
    [sportCover removeFromSuperview];
    [sportCalendar removeFromSuperview];
}

#pragma mark 添加运动记录
-(void)addSportsRecordForClickBtn:(UIButton *)sender{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-03-03"];
#endif
     [MobClick event:@"102_002018"];
    TCRecordSportViewController *sportVC=[[TCRecordSportViewController alloc] init];
    [self.navigationController pushViewController:sportVC animated:YES];
}

#pragma mark -- Pravite Methods
#pragma mark  初始化界面
-(void)initSportsView{
    //标题
    [self.view addSubview:self.sportsTitleButton];
    
    //根视图
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight - 50)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    [rootScrollView addSubview:self.cosumeCaloriesView];
    
    //饮食记录
    [rootScrollView addSubview:self.sportRecordsTitleBtn];
    [rootScrollView addSubview:self.sportsRecordsTableView];
    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0,self.sportRecordsTitleBtn.bottom+50,kScreenWidth, 200) img:@"img_tips_no" text:@"暂无运动数据"];
    [rootScrollView addSubview:blankView];
    blankView.hidden=YES;
    [self.view addSubview:self.addSportsRecordView];
    
}

#pragma mark 获取运动记录
-(void)getSportRecordsListWithDate:(NSString *)dateStr{
    NSInteger startTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"motion_bigin_time_begin=%ld&motion_bigin_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSInteger allCalories=[[result valueForKey:@"all_calories"] integerValue];
            self.cosumeCaloriesView.energyValue=allCalories;
            
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSArray *recordsArr=[result valueForKey:@"motionrecord"];
            for (NSDictionary *dict in recordsArr) {
                TCSportRecordModel *sport=[[TCSportRecordModel alloc] init];
                [sport setValues:dict];
                [tempArr addObject:sport];
            }
            blankView.hidden=tempArr.count>0;
            self.sportsRecordsTableView.sportsRecordsArray=tempArr;
            
        }else{
            self.sportsRecordsTableView.sportsRecordsArray=[[NSMutableArray alloc] init];
        }
        [self.sportsRecordsTableView reloadData];
        self.sportsRecordsTableView.frame=CGRectMake(0, self.sportsRecordsTableView.top, kScreenWidth, self.sportsRecordsTableView.contentSize.height);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, self.sportsRecordsTableView.top+self.sportsRecordsTableView.contentSize.height+64)];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Getters and Setters
#pragma mark 标题
-(UIButton *)sportsTitleButton{
    if (_sportsTitleButton==nil) {
        _sportsTitleButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, kNavHeight)];
        [_sportsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        [_sportsTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
        _sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [_sportsTitleButton setImage:[UIImage imageNamed:@"ic_n_down"] forState:UIControlStateNormal];
        [_sportsTitleButton addTarget:self action:@selector(sportsTitleButtonClickForChooseTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sportsTitleButton;
}

#pragma mark 消耗量
-(TCDietIntakeView *)cosumeCaloriesView{
    if (_cosumeCaloriesView==nil) {
        _cosumeCaloriesView=[[TCDietIntakeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170) type:TCDietIntakeViewSportsType];
    }
    return _cosumeCaloriesView;
}

#pragma mark 运动记录标题
-(UIButton *)sportRecordsTitleBtn{
    if (_sportRecordsTitleBtn==nil) {
        _sportRecordsTitleBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, self.cosumeCaloriesView.bottom+10, kScreenWidth, 40)];
        _sportRecordsTitleBtn.backgroundColor=[UIColor whiteColor];
        [_sportRecordsTitleBtn setTitle:@"运动记录" forState:UIControlStateNormal];
        [_sportRecordsTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _sportRecordsTitleBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [_sportRecordsTitleBtn setImage:[UIImage imageNamed:@"ic_n_record"] forState:UIControlStateNormal];
        _sportRecordsTitleBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _sportRecordsTitleBtn;
}

#pragma mark 运动记录
-(TCSportsRecordsTableView *)sportsRecordsTableView{
    if (_sportsRecordsTableView==nil) {
        _sportsRecordsTableView=[[TCSportsRecordsTableView alloc] initWithFrame:CGRectMake(0,self.sportRecordsTitleBtn.bottom+10 , kScreenWidth, kScreenHeight-50-self.cosumeCaloriesView.bottom) style:UITableViewStylePlain];
        _sportsRecordsTableView.viewDelegate=self;
        
    }
    return _sportsRecordsTableView;
}

#pragma mark 记录运动
-(UIView *)addSportsRecordView{
    if (_addSportsRecordView==nil) {
        _addSportsRecordView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _addSportsRecordView.backgroundColor=kSystemColor;
        
        UIButton *addSportsBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 10, 200, 30)];
         [addSportsBtn setImage:[UIImage imageNamed:@"ic_n_write"] forState:UIControlStateNormal];
        [addSportsBtn setTitle:@"记录运动" forState:UIControlStateNormal];
        [addSportsBtn addTarget:self action:@selector(addSportsRecordForClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_addSportsRecordView addSubview:addSportsBtn];
    }
    return _addSportsRecordView;
}

@end
