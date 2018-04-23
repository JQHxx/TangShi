//
//  TCHomeDietViewController.m
//  TonzeCloud
//
//  Created by fei on 2017/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHomeDietViewController.h"
#import "TCDietIntakeView.h"
#import "TCDietRecordsTableView.h"
#import "TCDietModel.h"
#import "TCSetDailyDietViewController.h"
#import "TCRecommendIntakeViewController.h"
#import "TCConsumeCaloriesViewController.h"
#import "TCHistoryRecordsViewController.h"
#import "TCRecordDietViewController.h"
#import "TCFoodRecordModel.h"
#import "FDCalendar.h"
#import "HWPopTool.h"

@interface TCHomeDietViewController ()<TCDietIntakeViewDelegate,FDCalendarDelegate>{
    UIScrollView   *rootScrollView;
    UILabel        *compareIntakeLabel;      //与摄入比较
    UIButton       *getIntakeButton ;        //推荐摄入和推荐消耗
    TCBlankView    *blankView;

    BOOL           isSetTarget;              //是否设置饮食目标
    NSInteger      intakeEnergy;             //摄入量
    NSInteger      targetEnergy;             //目标摄入量
    
    NSString       *nowDateStr;
    NSString       *seletedDataStr;

    UIView         *cover;
    FDCalendar     *calendar;           //日历控件
}

@property (nonatomic,strong)UIButton                *dietTitleButton;        //标题
@property (nonatomic,strong)TCDietIntakeView        *dietIntakeView;         //饮食摄入
@property (nonatomic,strong)UIView                  *intakeOrConsumeView;    // 推荐摄入或消耗热量
@property (nonatomic,strong)UIButton                *dietRecordTitleBtn;            //饮食记录标题
@property (nonatomic,strong)TCDietRecordsTableView  *dietRecordsTableView;   //饮食记录
@property (nonatomic,strong)UIView                  *addDietRecordView;      //记录饮食

@end

@implementation TCHomeDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightImageName = @"ic_n_time";
    
    [self initDietRecordsView];
    
    nowDateStr=[[TCHelper sharedTCHelper] getCurrentDate];   //今天
    seletedDataStr = nowDateStr;
    [self loadDietDataWithDateStr:nowDateStr];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isSetDietTarget) {
        [self loadDietTargetIntakeAction];
        [self loadDietDataWithDateStr:seletedDataStr];
        [TCHelper sharedTCHelper].isSetDietTarget=NO;
    }
    if ([TCHelper sharedTCHelper].isHomeDietReload) {
        [self loadDietDataWithDateStr:seletedDataStr];
        [TCHelper sharedTCHelper].isHomeDietReload=NO;
    }
    
    [MobClick beginLogPageView:@"饮食记录"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"饮食记录"];
}


#pragma mark -- Custom Delegate
#pragma mark 设置每日饮食目标
-(void)dietIntakeViewDidSetDailyTargetIntake{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-01"];
#endif
    
    [MobClick event:@"102_002012"];
    
    TCSetDailyDietViewController *setDailyDietVC=[[TCSetDailyDietViewController alloc] init];
    [self.navigationController pushViewController:setDailyDietVC animated:YES];
}

#pragma mark FDCalendarDelegate
-(void)calendarDidSelectDate:(NSString *)dateStr{
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        
    }];
    [MobClick event:@"102_002010"];

    NSInteger data =[[TCHelper sharedTCHelper] compareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        if ([dateStr isEqualToString:nowDateStr]) {
            self.dietTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
            self.dietTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
            [self.dietTitleButton setTitle:@"今天" forState:UIControlStateNormal];
            
        }else{
            self.dietTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 120, 0, 0);
            self.dietTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -30, 0, 0);
            [self.dietTitleButton setTitle:dateStr forState:UIControlStateNormal];
        }
        seletedDataStr=dateStr;
        [self loadDietDataWithDateStr:dateStr];
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
        
    }
}
#pragma mark -- Event Reponse
#pragma mark  饮食记录
-(void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-07"];
#endif
    [MobClick event:@"102_002011"];
    
    TCHistoryRecordsViewController *recordVC = [[TCHistoryRecordsViewController alloc] init];
    recordVC.typeStr = @"饮食";
    [self.navigationController pushViewController:recordVC animated:YES];
}


#pragma mark 选择日期（显示蒙板）
-(void)dirtTitleButtonClickForChooseTime:(UIButton *)sender{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor =[UIColor bgColor_Gray];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:seletedDataStr];
    
    calendar=[[FDCalendar alloc] initWithCurrentDate:date];
    calendar.calendarDelegate=self;
    [contentView addSubview:calendar];
    contentView.frame = CGRectMake(20, 84, kScreenWidth-40, calendar.bottom+20);
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}

#pragma mark 隐藏蒙板
-(void)makeHiddenCover{
    cover.alpha=0.0;
    [cover removeFromSuperview];
    [calendar removeFromSuperview];
}

#pragma mark 推荐摄入或消耗热量
-(void)getIntakeOrConsumeAction:(UIButton *)sender{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-03"];
#endif
    if ([sender.currentTitle isEqualToString:@"推荐摄入"]) {
        [MobClick event:@"102_002013"];
        
        TCRecommendIntakeViewController *recommendIntakeVC=[[TCRecommendIntakeViewController alloc] init];
        recommendIntakeVC.restEnergy=targetEnergy;
        [self.navigationController pushViewController:recommendIntakeVC animated:YES];
    }else{
        [MobClick event:@"102_002014"];

        TCConsumeCaloriesViewController *consumeCaloriesVC=[[TCConsumeCaloriesViewController alloc] init];
        consumeCaloriesVC.surplusEnergy=intakeEnergy-targetEnergy;
        [self.navigationController pushViewController:consumeCaloriesVC animated:YES];
    }
}

#pragma mark 添加饮食记录
-(void)addDietRecordForClickBtn:(UIButton *)sender{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-02-04"];
#endif
    [MobClick event:@"102_002015"];
    
    TCRecordDietViewController *recordDietVC=[[TCRecordDietViewController alloc] init];
    [self.navigationController pushViewController:recordDietVC animated:YES];
}


#pragma mark --Pravite Methods
#pragma mark 加载数据
-(void)loadDietDataWithDateStr:(NSString *)dateStr{
    NSInteger startTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"feeding_time_begin=%ld&feeding_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kDietRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        
        //饮食摄入能量值
        intakeEnergy=[[result valueForKey:@"all_calories"] integerValue];
        self.dietIntakeView.energyValue=intakeEnergy;
        [self loadDietTargetIntakeAction];
        
        //饮食记录列表
        NSArray *dietArr=[result valueForKey:@"dietrecord"];
        if (dietArr.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *keysTempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in dietArr) {
                TCFoodRecordModel *model=[[TCFoodRecordModel alloc] init];
                [model setValues:dict];
                [keysTempArr addObject:model.time_slot];
                [tempArr addObject:model];
            }
            
            NSMutableDictionary *dietDict=[[NSMutableDictionary alloc] init];
            for (NSString *timeKey in keysTempArr) {
                NSMutableArray *mealArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0; i<tempArr.count; i++) {
                    TCFoodRecordModel *model=tempArr[i];
                    if ([model.time_slot isEqualToString:timeKey]) {
                        [mealArr addObjectsFromArray:model.ingredient];
                    }
                }
                [dietDict setObject:mealArr forKey:timeKey];
            }
            self.dietRecordsTableView.dietRecordsDict=dietDict;
        }else{
            self.dietRecordsTableView.dietRecordsDict=[[NSDictionary alloc] init];
        }
        blankView.hidden=dietArr.count>0;
        if (![dateStr isEqualToString:nowDateStr]) {
            self.intakeOrConsumeView.hidden = YES;
            self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 170);
            self.dietRecordTitleBtn.frame = CGRectMake(0, self.dietIntakeView.bottom+8, kScreenWidth, 40);
            self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietIntakeView.bottom);
            blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
        }else{
            if (!(targetEnergy>0)) {
                self.intakeOrConsumeView.hidden = YES;
                self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 200);
                self.dietRecordTitleBtn.frame = CGRectMake(0, self.dietIntakeView.bottom+10, kScreenWidth, 40);
                self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietIntakeView.bottom);
                blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
            } else {
                self.intakeOrConsumeView.hidden = NO;
                self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 200);
                self.intakeOrConsumeView.frame = CGRectMake(0, self.dietIntakeView.bottom, kScreenWidth, 40);
                self.dietRecordTitleBtn.frame = CGRectMake(0, self.intakeOrConsumeView.bottom+10, kScreenWidth, 40);
                self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietIntakeView.bottom);
                blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
            }
        }

        
        [self.dietRecordsTableView reloadData];
        self.dietRecordsTableView.frame=CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth,dietArr.count==0?0:self.dietRecordsTableView.contentSize.height);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, self.dietRecordsTableView.top+self.dietRecordsTableView.contentSize.height+64)];
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        
    }];
}

#pragma mark 获取目标摄入能量
-(void)loadDietTargetIntakeAction{
    targetEnergy=[[NSUserDefaultsInfos getValueforKey:@"targetDailyEnergy"] integerValue];
    self.dietIntakeView.targetEnergyValue=targetEnergy;
    
    if(!(targetEnergy>0)){
        self.intakeOrConsumeView.hidden=YES;
        self.dietRecordTitleBtn.frame=CGRectMake(0, self.dietIntakeView.bottom+10, kScreenWidth, 40);
    }else{
        self.intakeOrConsumeView.hidden=NO;
        self.dietRecordTitleBtn.frame=CGRectMake(0, self.intakeOrConsumeView.bottom+10, kScreenWidth, 40);
        if (intakeEnergy==targetEnergy) {
            getIntakeButton.hidden=YES;
            compareIntakeLabel.text=@"恭喜您！今日摄入已达目标";
        }else{
            getIntakeButton.hidden=NO;
            NSString *tempStr=nil;
            NSInteger loc=0;
            if (intakeEnergy<targetEnergy) {
                tempStr=[NSString stringWithFormat:@"今日摄入距离目标还差%ld千卡",(long)(targetEnergy-intakeEnergy)];
                [getIntakeButton setTitle:@"推荐摄入" forState:UIControlStateNormal];
                loc=10;
            }else{
                tempStr=[NSString stringWithFormat:@"今日摄入已超目标%ld千卡",(long)(intakeEnergy-targetEnergy)];
                [getIntakeButton setTitle:@"消耗热量" forState:UIControlStateNormal];
                loc=8;
            }
            NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
            [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(loc, attributeStr.length-loc-2)];
            compareIntakeLabel.attributedText=attributeStr;
        }
    }
}

#pragma mark 初始化界面
-(void)initDietRecordsView{
    //标题
    [self.view addSubview:self.dietTitleButton];
    
    //根视图
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-40)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
   //饮食摄入
    [rootScrollView addSubview:self.dietIntakeView];
    [rootScrollView addSubview:self.intakeOrConsumeView];
    
    //饮食记录
    [rootScrollView addSubview:self.dietRecordTitleBtn];
    [rootScrollView addSubview:self.dietRecordsTableView];
    
    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0,self.dietRecordTitleBtn.bottom-20,kScreenWidth, 200) img:@"img_tips_no" text:@"暂无饮食数据"];
    [rootScrollView addSubview:blankView];
    blankView.hidden=YES;

    //记录饮食
    [self.view addSubview:self.addDietRecordView];
}

#pragma mark -- Getters and Setters
#pragma mark 标题
-(UIButton *)dietTitleButton{
    if (_dietTitleButton==nil) {
        _dietTitleButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, kNavHeight)];
        [_dietTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dietTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        _dietTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
        _dietTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [_dietTitleButton setImage:[UIImage imageNamed:@"ic_n_down"] forState:UIControlStateNormal];
        [_dietTitleButton addTarget:self action:@selector(dirtTitleButtonClickForChooseTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dietTitleButton;
}

#pragma mark 饮食摄入
-(TCDietIntakeView *)dietIntakeView{
    if (_dietIntakeView==nil) {
        _dietIntakeView=[[TCDietIntakeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) type:TCDietIntakeViewDietType];
        _dietIntakeView.delegate=self;
    }
    return _dietIntakeView;
}

#pragma mark 推荐摄入或消耗热量
-(UIView *)intakeOrConsumeView{
    if (_intakeOrConsumeView==nil) {
        _intakeOrConsumeView=[[UIView alloc] initWithFrame:CGRectMake(0, self.dietIntakeView.bottom, kScreenWidth, 40)];
        _intakeOrConsumeView.backgroundColor=[UIColor whiteColor];
        
        compareIntakeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-100, 30)];
        compareIntakeLabel.textColor=[UIColor blackColor];
        compareIntakeLabel.font=[UIFont systemFontOfSize:13.0f];
        [_intakeOrConsumeView addSubview:compareIntakeLabel];
        
        //推荐摄入或消耗热量
        getIntakeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 5, 100, 30)];
        [getIntakeButton setTitle:@"推荐摄入" forState:UIControlStateNormal];
        [getIntakeButton setTitleColor:kSystemColor forState:UIControlStateNormal];
        [getIntakeButton setImage:[UIImage imageNamed:@"ic_pub_arrow_nor"] forState:UIControlStateNormal];
        getIntakeButton.imageEdgeInsets=UIEdgeInsetsMake(0, 80, 0, 0);
        getIntakeButton.titleEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
        getIntakeButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [getIntakeButton addTarget:self action:@selector(getIntakeOrConsumeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_intakeOrConsumeView addSubview:getIntakeButton];
    
    }
    return _intakeOrConsumeView;
}

#pragma mark 饮食记录标题
-(UIButton *)dietRecordTitleBtn{
    if(_dietRecordTitleBtn==nil){
        _dietRecordTitleBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, self.intakeOrConsumeView.bottom, kScreenWidth, 40)];
        _dietRecordTitleBtn.backgroundColor=[UIColor whiteColor];
        [_dietRecordTitleBtn setTitle:@"饮食记录" forState:UIControlStateNormal];
        [_dietRecordTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dietRecordTitleBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [_dietRecordTitleBtn setImage:[UIImage imageNamed:@"ic_n_record"] forState:UIControlStateNormal];
        _dietRecordTitleBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _dietRecordTitleBtn;
}

#pragma mark 饮食记录
-(TCDietRecordsTableView *)dietRecordsTableView{
    if (_dietRecordsTableView==nil) {
        _dietRecordsTableView=[[TCDietRecordsTableView alloc] initWithFrame:CGRectMake(0, self.dietIntakeView.bottom+50, kScreenWidth, kScreenHeight-50-self.dietIntakeView.bottom) style:UITableViewStyleGrouped];
    }
    return _dietRecordsTableView;
}

#pragma mark 记录饮食
-(UIView *)addDietRecordView{
    if (_addDietRecordView==nil) {
        _addDietRecordView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _addDietRecordView.backgroundColor=kSystemColor;
        UIButton *addDietBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 10, 200, 30)];
        [addDietBtn setImage:[UIImage imageNamed:@"ic_n_write"] forState:UIControlStateNormal];
        [addDietBtn setTitle:@" 记录饮食" forState:UIControlStateNormal];
        [addDietBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addDietBtn.titleLabel.font=[UIFont systemFontOfSize:15.0f];
        [addDietBtn addTarget:self action:@selector(addDietRecordForClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_addDietRecordView addSubview:addDietBtn];
    }
    return _addDietRecordView;
}

@end
