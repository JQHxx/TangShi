//
//  TCCurveViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCurveViewController.h"
#import "TCClickViewGroup.h"
#import "UUChart.h"
#import "TCSugarModel.h"

@interface TCCurveViewController ()<TCClickViewGroupDelegate,UUChartDataSource>{
    NSArray          *periodArray;
    NSInteger        selectedIndex;
    NSMutableArray   *daysArray;    //日期（横坐标）
    NSMutableArray   *valuesArray;
    NSInteger        page;   //页数
    NSInteger        page_size;
}

@property (nonatomic,strong)TCClickViewGroup     *periodMenuView;
@property (nonatomic,strong)UUChart              *sugarLineChart;

@end

@implementation TCCurveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar=YES;

    periodArray=[TCHelper sharedTCHelper].sugarPeriodArr;
    valuesArray=[[NSMutableArray alloc] init];
    daysArray=[[NSMutableArray alloc] init];
    page=1;
    page_size=8;
    
    [self.view addSubview:self.periodMenuView];
    [self.view addSubview:self.sugarLineChart];
    
    [self loadCurrentPeriod];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreBloodSugarData) name:kScrollNotification object:nil];

    [MobClick beginLogPageView:@"血糖曲线"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"血糖曲线"];
}

#pragma mark -- NSNotification 
-(void)loadMoreBloodSugarData{
    page++;
    [self loadBloodSuagrVurveData];
}

#pragma mark -- UUChartDataSource
#pragma mark 横坐标
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart{
    return daysArray;
}

#pragma mark 竖坐标
-(NSArray *)chartConfigAxisYlabel:(UUChart *)chart{
    return @[@0.0,@3.5,@5.0,@6.0,@7.0,@8.0,@9.0,@10,@11,@15,@35];
}

#pragma mark 数值数组
-(id)chartConfigAxisYValue:(UUChart *)chart{
    return @[valuesArray];
}

#pragma mark 限制线
-(NSArray *)chartLimitLine:(UUChart *)chart{
    NSDictionary *dict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:periodArray[selectedIndex]];
    return [dict allValues];
}

#pragma mark --Delegate
#pragma mark  ClickViewGroupDelegate
-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index{
    selectedIndex=index;
    page=1;
    [daysArray removeAllObjects];
    [valuesArray removeAllObjects];
    [self loadBloodSuagrVurveData];
}

#pragma mark Private Methods
#pragma mark 加载当前信息
-(void)loadCurrentPeriod{
    //切换对应时间段
    NSString *currentPeriod=[[TCHelper sharedTCHelper] getInPeriodOfCurrentTime];
    NSInteger index=[periodArray indexOfObject:currentPeriod];
    selectedIndex=index;
    UIButton *btn;
    for (UIView *view in self.periodMenuView.subviews) {
        for (UIView *menuView in view.subviews) {
            if ([menuView isKindOfClass:[UIButton class]]&&(menuView.tag == index+100)) {
                btn = (UIButton*)menuView;
            }
        }
    }
    [self.periodMenuView tcChangeViewWithButton:btn];
}

#pragma mark 加载血糖数据
-(void)loadBloodSuagrVurveData{
    
    NSString *endDate=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:page*page_size-page_size];   //今天
    NSString *startDate=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:page*page_size-1];  //今天之前page_size天
    MyLog(@"startDate:%@,endDate:%@",startDate,endDate);
    
    NSInteger startTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:startDate format:@"yyyy-MM-dd"];
    NSInteger endTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:endDate format:@"yyyy-MM-dd"];
    NSString *periodEn=[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodArray[selectedIndex]]; //时间段
    
    //获取时间
    NSMutableArray *tempDateArr=[[TCHelper sharedTCHelper] getDateFromStartDate:startDate toEndDate:endDate format:@"M/d"];
    [daysArray addObjectsFromArray:tempDateArr];
    MyLog(@"tempDate:%@,days:%@",tempDateArr,daysArray);
    
    NSString *body=[NSString stringWithFormat:@"output-way=1&time_slot=%@&measurement_time_begin=%ld&measurement_time_end=%ld",periodEn,(long)startTimeSp,(long)endTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordLists body:body success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        if (kIsDictionary(dict)&&dict.count>0) {
            NSArray *list=dict[periodEn];
            for (NSInteger i=0; i<tempDateArr.count; i++) {
                NSString *dayStr=tempDateArr[i];
                double value=0.0;
                for (NSDictionary *dic in list) {
                    NSString *measureTime=dic[@"measurement_time"];
                    NSString *dateStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:measureTime format:@"M/d"];
                    if ([dayStr isEqualToString:dateStr]) {
                        value=[dic[@"glucose"] doubleValue];
                    }
                }
                NSNumber *valueNum=[NSNumber numberWithDouble:value];
                [tempArr addObject:valueNum];
            }
        }else{
            for (NSInteger i=0; i<tempDateArr.count; i++) {
                double value=0.0;
                NSNumber *valueNum=[NSNumber numberWithDouble:value];
                [tempArr addObject:valueNum];
            }
        }
        [valuesArray addObjectsFromArray:tempArr];
        [self.sugarLineChart strokeChart];
    } failure:^(NSString *errorStr) {
        valuesArray=[[NSMutableArray alloc] init];
        [self.sugarLineChart strokeChart];
    }];
}


#pragma mark Setters and Getters
#pragma mark 菜单栏
-(TCClickViewGroup *)periodMenuView{
    if (_periodMenuView==nil) {
        _periodMenuView=[[TCClickViewGroup alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) titles:periodArray color:kSystemColor titleColor:kLineColor];
        _periodMenuView.viewDelegate=self;
    }
    return _periodMenuView;
}

#pragma mark 血糖曲线
-(UUChart *)sugarLineChart{
    if (_sugarLineChart==nil) {
        _sugarLineChart=[[UUChart alloc] initWithFrame:CGRectMake(0, self.periodMenuView.bottom+10, kScreenWidth, kRootViewHeight-self.periodMenuView.bottom-30) dataSource:self style:UUChartStyleLine];
    }
    return _sugarLineChart;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kScrollNotification object:nil];
}

@end
