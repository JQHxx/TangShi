//
//  TCStepStaticsViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCStepStaticsViewController.h"
#import "TCHealthManager.h"
#import "UUChart.h"
#import "TimePickerView.h"
#import "TCDietCountView.h"

@interface TCStepStaticsViewController ()<UUChartDataSource,UITextFieldDelegate,UIActionSheetDelegate>{
    UILabel      *stepCountLabel;
    UILabel      *targetStepCountLabel;
    UILabel      *milesLabel;              //公里数
    UILabel      *caloriesLabel;           //能量
    TimePickerView   *pickerView;
    NSInteger       targetStepCount;
    NSMutableArray  *stepsArray;           //步数数组
    TCDietCountView *dietCountView;
    NSInteger       stepCount;
    
}
@property (nonatomic,strong)UIView       *stepStaticsView;   //步数
@property (nonatomic,strong)UIView       *caloriesView;
@property (nonatomic,strong)UUChart      *stepChartView;     //步数图表

@end

@implementation TCStepStaticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"步数";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    NSInteger scount=[[NSUserDefaultsInfos getValueforKey:@"kTargetStepCount"] integerValue];
    targetStepCount=scount<1000?6000:scount;
    stepsArray=[[NSMutableArray alloc] init];
    
    [self initStepView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"005-04-01" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"005-04-01" type:2];
#endif
}
#pragma mark -- UUChartDataSource
#pragma mark 横坐标标题数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart{
    return [[TCHelper sharedTCHelper] getDateFromTodayWithDays:7];    //最近一周时间
}

#pragma mark 数值数组
- (id)chartConfigAxisYValue:(UUChart *)chart{
    return stepsArray;
}

-(NSInteger)chartYValueMax:(UUChart *)chart{
    return 99000;
}

-(NSInteger)chartYMarginValue:(UUChart *)chart{
    return 1000;
}

#pragma mark --UIActionSheetDelegate (TimePickerView)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (pickerView.pickerStyle==PickerStyle_Step) {
            targetStepCount=([pickerView.locatePicker selectedRowInComponent:0]+1)*1000;
            [NSUserDefaultsInfos putKey:@"kTargetStepCount" andValue:[NSNumber numberWithInteger:targetStepCount]];
            [TCHelper sharedTCHelper].isLoadStep = YES;
            
            NSMutableAttributedString *targetAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"目标：%ld步",(long)targetStepCount]];
            [targetAttributeStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(3, targetAttributeStr.length-4)];
            targetStepCountLabel.attributedText=targetAttributeStr;
            
            NSString *high = [NSString stringWithFormat:@"%ld",stepCount];
            NSString *low = [NSString stringWithFormat:@"%ld",targetStepCount-stepCount>0?targetStepCount-stepCount:0];
            NSDictionary *dict = @{@"high":high,@"low":low};
            dietCountView.weekRecordsDict = dict;
        }
    }
}

#pragma mark -- Event Response
#pragma mark 设置目标步数
-(void)resetTargetStep:(UITapGestureRecognizer *)gesture{
    [MobClick event:@"102_002041"];
    pickerView =[[TimePickerView alloc] initWithTitle:@"步数" delegate:self];
    pickerView.pickerStyle=PickerStyle_Step;
    [pickerView.locatePicker selectRow:targetStepCount/1000-1 inComponent:0 animated:YES];
    [pickerView showInView:self.view];
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:targetStepCount/1000-1 inComponent:0];
}

#pragma mark 去同步健康
-(void)synchoriseStepMachineAction{
    //获取健康权限
    __weak typeof(self) weakSelf=self;
    [[TCHealthManager sharedTCHealthManager] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (!success) {
            MyLog(@"获取健康权限失败，error:%@",error.localizedDescription);
        }else{
            [weakSelf loadHealthStepAndDistance];
        }
        [NSUserDefaultsInfos putKey:kIsSynchoriseHealth andValue:[NSNumber numberWithBool:success]];
    }];
}

#pragma mark -- Private Methods
#pragma mark 获取健康数据
-(void)loadHealthStepAndDistance{
    //目标步数
    NSMutableAttributedString *targetAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"目标：%ld步",(long)targetStepCount]];
    [targetAttributeStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(3, targetAttributeStr.length-4)];
    targetStepCountLabel.attributedText=targetAttributeStr;
    
    __weak typeof(self) weakSelf=self;
    //今日步数
    [[TCHealthManager sharedTCHealthManager] getStepCountWithDays:1 complete:^(NSMutableArray *valuesArray, NSError *error) {
        if (!error) {
            if (kIsArray(valuesArray)&&valuesArray.count>0) {
                NSDictionary *dict=valuesArray[0];
                NSString *currentDate=[[TCHelper sharedTCHelper] getCurrentDate];
                NSNumber *value=[dict valueForKey:currentDate];
                //今日当前步数
                dispatch_sync(dispatch_get_main_queue(), ^{
                    stepCount=[value integerValue];
                    NSString *stepStr=stepCount>0?[NSString stringWithFormat:@"%ld 步",(long)stepCount]:@"0 步";
                    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:stepStr];
                    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, attributeStr.length-1)];
                    stepCountLabel.attributedText=attributeStr;
                    
                    NSString *high = [NSString stringWithFormat:@"%ld",stepCount];
                    NSString *low = [NSString stringWithFormat:@"%ld",targetStepCount-stepCount>0?targetStepCount-stepCount:0];
                    NSDictionary *dict = @{@"high":high,@"low":low};
                    dietCountView.weekRecordsDict = dict;

                    NSString *stepStr2=stepCount>0?[NSString stringWithFormat:@"%ld千卡",(long)(stepCount*0.027+0.5)]:@"0千卡";
                    NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:stepStr2];
                    [attributeStr2 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr2.length-2)];
                    caloriesLabel.attributedText=attributeStr2;
                });
            }
        }
    }];
    
    // 一周步数
    [[TCHealthManager sharedTCHealthManager] getStepCountWithDays:7 complete:^(NSMutableArray *valuesArray, NSError *error) {
        if (!error) {
            if (kIsArray(valuesArray)&&valuesArray.count>0) {
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSInteger i=valuesArray.count; i>0; i--) {
                    NSDictionary *dict=valuesArray[i-1];
                    NSString *dateStr=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:i-1];
                    NSNumber *countNum=[dict valueForKey:dateStr];
                    if ([countNum integerValue]>0) {
                        [tempArr addObject:countNum];
                    }
                }
                stepsArray=tempArr;
                
              dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.stepChartView strokeChart];
              });
            }
        }
    }];
    
    //今日距离
    [[TCHealthManager sharedTCHealthManager] getDistance:^(double value, NSError *error) {
        if (!error) {
            if (value>0.01) {
                NSInteger distance=(long)(value*1000+0.5);
                dispatch_sync(dispatch_get_main_queue(), ^{
                     NSString *stepStr1=distance>0?[NSString stringWithFormat:@"%ld米",(long)distance]:@"0米";
                    NSMutableAttributedString *attributeStr1=[[NSMutableAttributedString alloc] initWithString:stepStr1];
                    [attributeStr1 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr1.length-1)];
                    milesLabel.attributedText=attributeStr1;
                });
            }
        }
    }];
}

#pragma mark -- 初始化界面
- (void)initStepView{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 170)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    dietCountView = [[TCDietCountView alloc] initWithFrame:CGRectMake((kScreenWidth-160)/2, kNewNavHeight + 5, 160, 160)];
    dietCountView.layer.cornerRadius =80;
    [self.view addSubview:dietCountView];
    
    [self.view addSubview:self.stepStaticsView];
    [self.view addSubview:self.caloriesView];
    [self.view addSubview:self.stepChartView];
    
    BOOL isSynchoriseHealth=[[NSUserDefaultsInfos getValueforKey:kIsSynchoriseHealth] boolValue];
    if (isSynchoriseHealth) {
        [self loadHealthStepAndDistance];
    }else{
        [self synchoriseStepMachineAction];
    }
}

#pragma mark -- Getters and Setters
#pragma mark 显示步数
-(UIView *)stepStaticsView{
    if (_stepStaticsView==nil) {
        _stepStaticsView=[[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-130)/2, kNewNavHeight + 20, 130, 130)];
        _stepStaticsView.layer.cornerRadius=65;
        _stepStaticsView.backgroundColor=[UIColor whiteColor];
        
        UILabel *dayLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 140/3-20, 140-20, 20)];
        dayLabel.text=@"今天";
        dayLabel.textColor=[UIColor blackColor];
        dayLabel.font=[UIFont systemFontOfSize:14.0f];
        dayLabel.textAlignment=NSTextAlignmentCenter;
        [_stepStaticsView addSubview:dayLabel];
        
        stepCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, dayLabel.bottom+5, 140-20, 25)];
        stepCountLabel.textAlignment=NSTextAlignmentCenter;
        stepCountLabel.textColor=[UIColor lightGrayColor];
        stepCountLabel.font=[UIFont systemFontOfSize:12.0f];
        [_stepStaticsView addSubview:stepCountLabel];
        
        targetStepCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, stepCountLabel.bottom+5, 140-20, 25)];
        targetStepCountLabel.textAlignment=NSTextAlignmentCenter;
        targetStepCountLabel.textColor=[UIColor lightGrayColor];
        targetStepCountLabel.font=[UIFont systemFontOfSize:14.0f];
        [_stepStaticsView addSubview:targetStepCountLabel];
        
        targetStepCountLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTargetStep:)];
        [targetStepCountLabel addGestureRecognizer:tapGesture];
    }
    return _stepStaticsView;
}

#pragma mark 距离和能量
-(UIView *)caloriesView{
    if (_caloriesView==nil) {
        _caloriesView=[[UIView alloc] initWithFrame:CGRectMake(0, self.stepStaticsView.bottom+30, kScreenWidth, 50)];
        _caloriesView.backgroundColor=[UIColor whiteColor];
        
        milesLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth/2-1, 30)];
        milesLabel.textColor=[UIColor grayColor];
        milesLabel.textAlignment=NSTextAlignmentCenter;
        NSMutableAttributedString *attributeStr1=[[NSMutableAttributedString alloc] initWithString:@"0米"];
        [attributeStr1 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr1.length-1)];
        milesLabel.attributedText=attributeStr1;
        milesLabel.font=[UIFont systemFontOfSize:16.0f];
        [_caloriesView addSubview:milesLabel];
        
        UILabel *horline=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-1, 10, 1, 30)];
        horline.backgroundColor=[UIColor bgColor_Gray];
        [_caloriesView addSubview:horline];
        
        caloriesLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 10, kScreenWidth/2, 30)];
        caloriesLabel.textColor=[UIColor grayColor];
        caloriesLabel.textAlignment=NSTextAlignmentCenter;
        caloriesLabel.font=[UIFont systemFontOfSize:16.0f];
        caloriesLabel.text=@"0千卡";
        [_caloriesView addSubview:caloriesLabel];
        
    }
    return _caloriesView;
}

#pragma mark 步数图表
-(UUChart *)stepChartView{
    if (_stepChartView==nil) {
        _stepChartView=[[UUChart alloc] initWithFrame:CGRectMake(10, self.caloriesView.bottom+20, kScreenWidth-20, 200) dataSource:self style:UUChartStyleBar];
    }
    return _stepChartView;
}
@end
