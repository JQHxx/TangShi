//
//  TCSugarDataViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarDataViewController.h"
#import "TCBloodDataButton.h"
#import "TCWeekRecordView.h"
#import "TCBloodScrollView.h"
#import "TCHistoryRecordsViewController.h"
#import "TCDatePickerView.h"
#import "TCSugarModel.h"
#import "TCRecordSugarViewController.h"
#import "TCCurveViewController.h"
#import "TCChartHeadView.h"
#import "TCSugarListView.h"
#import "HWPopTool.h"

#define kCellHeight (kScreenWidth-20)/10

@interface TCSugarDataViewController ()<BloodDataSource,BloodDelegate,TCDatePickerViewDelegate,UIScrollViewDelegate,TCSugarListViewDelegate>{
    TCDatePickerView      *datePickerView;   //日期选择器
    UIButton              *bloodleftBtn;      //开始时间设置按钮
    UIButton              *bloodrightBtn;     //结束时间设置按钮
    
    NSString              *startDateStr;     //开始时间
    NSString              *endDateStr;       //结束时间
    NSInteger             btnTag;
    NSArray               *periodEnArray;    //血糖时间段
    NSMutableArray        *dateArray;        //日期数组
    NSMutableArray        *bloodSugarData;    //血糖记录列表
    
    NSArray               *listArray;
    TCCurveViewController *curveVC;        //血糖曲线
}

@property (nonatomic,strong)UISegmentedControl   *titleSegmentedControl;
@property (nonatomic,strong)UIView               *datePickView;      //日期选择
@property (nonatomic,strong)UIScrollView         *rootScrollView;    //根滚动视图
@property (nonatomic,strong)TCWeekRecordView     *weekRecordView;    //血糖视图
@property (nonatomic,strong)TCChartHeadView      *chartHeadView;     //血糖记录表头
@property (nonatomic,strong)TCBloodScrollView    * chartScroll;      //血糖记录表

@end

@implementation TCSugarDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.rightImageName = @"ic_n_time";
    
    curveVC=[[TCCurveViewController alloc] init];
    periodEnArray=[TCHelper sharedTCHelper].sugarPeriodEnArr;
    dateArray=[[NSMutableArray alloc] init];
    bloodSugarData=[[NSMutableArray alloc] init];
    
    listArray=@[@"血糖数据",@"血糖曲线"];
    
    [self initBloodView];
    [self loadBloodSugarData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isBloodReload) {
        [self loadBloodSugarData];
        [TCHelper sharedTCHelper].isSportsReload=NO;
    }
    [MobClick beginLogPageView:@"血糖数据"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"血糖数据"];
}


#pragma mark --BloodDataSource,BloodDelegate
#pragma mark  行数
-(NSInteger)rowsNumOfChart{
    return dateArray.count+2;
}
#pragma mark 列数
-(NSInteger)linesNumOfChart{
    return 9;
}
#pragma mark  单元格高度
-(CGFloat)eachCellHeight{
    return kCellHeight;
}
#pragma mark  单元格字体颜色
-(UIColor *)contentColorOfEachCell:(NSIndexPath *)indexPath{
    UIColor * color = [UIColor blackColor] ;
    if(indexPath.row==0 ||indexPath.row==1){
        color = [UIColor darkGrayColor];
    }else if(indexPath.section == 0){
        color = [UIColor grayColor];
    }else{
        if (bloodSugarData.count>0) {
            NSDictionary *sugarValueDict=bloodSugarData[indexPath.row-2][indexPath.section-1];
            NSString *sugarValueStr=[sugarValueDict valueForKey:@"value"];
            if (indexPath.section == 1||indexPath.section == 3||indexPath.section == 5||indexPath.section == 7||indexPath.section == 8||indexPath.section == 9) {
                if ([sugarValueStr floatValue]<4.5) {
                    color = [UIColor colorWithHexString:@"0xffd657"];
                }else if ([sugarValueStr floatValue]>=4.5&&[sugarValueStr floatValue]<=10.0){
                    color = [UIColor greenColor];
                }else {
                    color = [UIColor redColor];
                }
            }else{
                if ([sugarValueStr floatValue]<=4.5) {
                    color = [UIColor colorWithHexString:@"0xffd657"];
                }else if ([sugarValueStr floatValue]>=4.5&&[sugarValueStr floatValue]<=7){
                    color = [UIColor greenColor];
                }else {
                    color = [UIColor redColor];
                }
            }
        }
    }
    return color;
}

#pragma mark  每个单元格的值
-(NSString *)contentOfEachCell:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        NSArray *arr=@[@"1",@"1",@"早餐",@"1",@"午餐",@"1",@"晚餐",@"1",@"1"];
        return [arr[indexPath.section] isEqualToString:@"1"]?@"":arr[indexPath.section];
    }else if (indexPath.row==1){
        NSArray *arr=@[@"日期",@"凌晨",@"前",@"后",@"前",@"后",@"前",@"后",@"睡前"];
        return arr[indexPath.section];
    }else{
        if (indexPath.section==0) {
            return dateArray[indexPath.row-2];
        }else{
            if (bloodSugarData.count>0) {
                NSDictionary *sugarValueDict=bloodSugarData[indexPath.row-2][indexPath.section-1];
                return [sugarValueDict valueForKey:@"value"];
            }else{
                return nil;
            }
        }
    }
}

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath{
    if (indexPath.row>1&&indexPath.section>0) {
        if (bloodSugarData.count>0) {
            NSDictionary *sugarValueDict=bloodSugarData[indexPath.row-2][indexPath.section-1];
            return [[sugarValueDict valueForKey:@"hasMuchData"] boolValue];
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

#pragma mark 单元格点击
-(void)chartDidClickAtIndexPath:(NSIndexPath *)indexPath{
    MyLog(@"点击了第%ld行 第%ld列",(long)indexPath.row,(long)indexPath.section);
    if (indexPath.section==0||indexPath.row==0||indexPath.row==1) {
        
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"005-01-02"];
#endif
        if (self.isHomeIn) {
            [MobClick event:@"101_002006"];
        }else{
            [MobClick event:@"102_002006"];
        }
        
        NSMutableArray *dateTempArr=[[TCHelper sharedTCHelper] getDateFromStartDate:startDateStr toEndDate:endDateStr format:@"yyyy-MM-dd"];
        NSString *dateStr=dateTempArr[indexPath.row-2];
        NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
        if (bloodSugarData.count==0) {
            
            NSArray *sugarArr=[TCHelper sharedTCHelper].sugarPeriodEnArr;
            TCRecordSugarViewController *recordSugarVC=[[TCRecordSugarViewController alloc] init];
            recordSugarVC.sugarPeriodEn = sugarArr[indexPath.section-1];
            recordSugarVC.way = 1;
            recordSugarVC.sugar_data =1;
             recordSugarVC.sugarMeasureTime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"yyyy-MM-dd HH:mm"];
            [self.navigationController pushViewController:recordSugarVC animated:YES];
        }else{
            NSArray *sugarArr=[TCHelper sharedTCHelper].sugarPeriodEnArr;
            NSInteger index=indexPath.section-1;
            if (indexPath.section==9) {
                index=7;
            }
            NSString *time_slot=sugarArr[index];
            
            NSDictionary *sugarValueDict=bloodSugarData[indexPath.row-2][index];
            double value=[[sugarValueDict valueForKey:@"value"] floatValue];
            NSInteger sugarType=[[sugarValueDict valueForKey:@"way"] integerValue];
            
            if (value>0.0) {
                BOOL hasMuchData=[[sugarValueDict valueForKey:@"hasMuchData"] boolValue];
                if (hasMuchData) {
                    
                    MyLog(@"有多条数据");
                    kSelfWeak;
                    NSString *body=[NSString stringWithFormat:@"measurement_time_begin=%ld&measurement_time_end=%ld&output-way=3&time_slot=%@",(long)timeSp,(long)timeSp,time_slot];
                    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordLists body:body success:^(id json) {
                        NSArray *result=[json objectForKey:@"result"];
                        if (kIsArray(result)&&result.count>0) {
                            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                            for (NSDictionary *dict in result) {
                                TCSugarModel *sugar=[[TCSugarModel alloc] init];
                                [sugar setValues:dict];
                                [tempArr addObject:sugar];
                            }
                            
                            //时间标题
                            NSString *period=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:time_slot];
                            NSString *timeStr= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"MM-dd"];
                            NSString *headTitleStr=[NSString stringWithFormat:@"%@ %@",timeStr,period];
                            
                            //显示弹出框
                            [weakSelf showPopupViewWithSuagrData:tempArr timeTitle:headTitleStr];
                        }
                    } failure:^(NSString *errorStr) {
                        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                    }];
                }else{
                    TCSugarModel *sugar=[[TCSugarModel alloc] init];
                    [sugar setValues:sugarValueDict];
                    sugar.glucose=[NSString stringWithFormat:@"%.1f",value];
                    
                    TCRecordSugarViewController *recordSugarVC=[[TCRecordSugarViewController alloc] init];
                    recordSugarVC.sugarModel=sugar;
                    recordSugarVC.sugar_data = 1;
                    recordSugarVC.way = sugarType;
                    [self.navigationController pushViewController:recordSugarVC animated:YES];
                }
            }else{
                TCRecordSugarViewController *recordSugarVC=[[TCRecordSugarViewController alloc] init];
                recordSugarVC.sugarPeriodEn=time_slot;
                recordSugarVC.way = sugarType;
                recordSugarVC.sugar_data = 1;
                recordSugarVC.sugarMeasureTime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"yyyy-MM-dd HH:mm"];
                [self.navigationController pushViewController:recordSugarVC animated:YES];
            }
        }
    }
}

#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    if (btnTag == 100) {
        NSInteger data =[[TCHelper sharedTCHelper] compareDate:dateStr withDate:endDateStr];
        if (data==-1||data==0) {
            startDateStr=dateStr;
            [bloodleftBtn setTitle:dateStr forState:UIControlStateNormal];
        }else{
            [self.view makeToast:@"开始时间不能大于结束时间" duration:1.0 position:CSToastPositionCenter];
        }
    } else {
        NSInteger data =[[TCHelper sharedTCHelper] compareDate:startDateStr withDate:dateStr];
        if (data==-1) {
            endDateStr=dateStr;
            [bloodrightBtn setTitle:dateStr forState:UIControlStateNormal];
        }else{
            [self.view makeToast:@"结束时间不能小于开始时间" duration:1.0 position:CSToastPositionCenter];
        }
    }
    [self loadBloodSugarData];
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat centerY=self.weekRecordView.bottom;
    CGFloat offsetY=scrollView.contentOffset.y;
    
    if (offsetY>centerY) {
        [self.view addSubview:self.chartHeadView];
    }else{
        [self.chartHeadView removeFromSuperview];
    }
}

#pragma mark TCSugarListViewDelegate
-(void)sugarListViewDidSelectModel:(TCSugarModel *)model{
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            TCRecordSugarViewController *recordSugarVC=[[TCRecordSugarViewController alloc] init];
            recordSugarVC.sugarModel=model;
            recordSugarVC.sugar_data =1;
            recordSugarVC.way = [model.way integerValue];
            [self.navigationController pushViewController:recordSugarVC animated:YES];
        });
    }];
}

#pragma mark --Event Response
#pragma mark
-(void)selectTabWithSegment:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex==0) {
        self.rootScrollView.hidden=NO;
        [curveVC.view removeFromSuperview];
    }else{
        if (self.isHomeIn) {
           [MobClick event:@"101_002004"];
        }else{
           [MobClick event:@"102_002004"];
        }

        curveVC.view.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
        [self.view addSubview:curveVC.view];
        self.rootScrollView.hidden=YES;
    }
}

#pragma mark  血糖历史纪录
- (void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"005-01-03"];
#endif
    
    if (self.isHomeIn) {
        [MobClick event:@"101_002005"];
    }else{
        [MobClick event:@"102_002005"];
    }

    TCHistoryRecordsViewController *recordVC = [[TCHistoryRecordsViewController alloc] init];
    recordVC.typeStr = @"血糖";
    [self.navigationController pushViewController:recordVC animated:YES];
}

- (void)leftButtonAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark 选择血糖数据时间
- (void)bloodButton:(UIButton *)button{
    btnTag=button.tag;
    NSString *dateStr=nil;
    if (button.tag==100) {
        dateStr=startDateStr;
    }else{
        dateStr=endDateStr;
    }
    datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) birthdayValue:dateStr pickerType:DatePickerViewTypeDate title:@""];
    datePickerView.pickerDelegate = self;
    [datePickerView datePickerViewShowInView:self.view];
}

#pragma mark -- Private Methods
#pragma mark 加载血糖数据
-(void)loadBloodSugarData{
    kSelfWeak;
    dateArray=[[TCHelper sharedTCHelper] getDateFromStartDate:startDateStr toEndDate:endDateStr format:@"M/d"] ;
    NSInteger startTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:startDateStr format:@"yyyy-MM-dd"];
    NSInteger endTimeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:endDateStr format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"measurement_time_begin=%ld&measurement_time_end=%ld&output-way=2",(long)startTimeSp,(long)endTimeSp];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (result.count>0) {
            NSArray *timeArr=[result allKeys];
            NSMutableArray *dataResultArr=[[NSMutableArray alloc] init];   //多维数组
            
            NSInteger highCount=0;
            NSInteger normalCount=0;
            NSInteger lowCount=0;
            NSMutableArray *dateTempArr=[[TCHelper sharedTCHelper] getDateFromStartDate:startDateStr toEndDate:endDateStr format:@"yyyy-MM-dd"];
            for (NSInteger i=0; i<dateArray.count; i++) {
                //日期转换（M/d->yyyy-MM-dd）
                NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:dateTempArr[i] format:@"yyyy-MM-dd"];
                NSString *atime=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)timeSp] format:@"yyyy-MM-dd"];
                
                NSMutableArray *dataTempArr=[[NSMutableArray alloc] init];   //血糖值数值数组
                
                for (NSInteger j=0; j<periodEnArray.count; j++) {
                    double value=0.0;
                    NSInteger way = 0;
                    NSMutableArray *tempValueArr=[[NSMutableArray alloc] init];
                    NSString *periodEnStr=periodEnArray[j];
                    for (NSString *timeStr in timeArr) {
                        if ([atime isEqualToString:timeStr]) {
                            NSArray *periodArr=[TCHelper sharedTCHelper].sugarPeriodArr;
                            NSString *period=periodArr[j];
                            NSDictionary *limitDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:period];
                            double maxValue=[limitDict[@"max"] doubleValue];
                            double minValue=[limitDict[@"min"] doubleValue];
                            
                            NSArray *list=[result valueForKey:timeStr];     //获取对应日期的血糖记录
                            for (NSDictionary *dict in list) {
                                TCSugarModel *sugar=[[TCSugarModel alloc] init];
                                [sugar setValues:dict];
                                if ([sugar.time_slot isEqualToString:periodEnStr]) {   //计算相应时间段的血糖值
                                    value=[sugar.glucose doubleValue];
                                    way = [sugar.way integerValue];
                                    NSDictionary *tempDict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:value],@"value",sugar.measurement_time,@"time",[NSNumber numberWithDouble:way],@"way", sugar.time_slot,@"period",sugar.remarks,@"remarks",[NSNumber numberWithInteger:sugar.id],@"id",nil];
                                    [tempValueArr addObject:tempDict];
                                    
                                    if (value>0.01) {
                                        if (value<minValue) {
                                            lowCount++;
                                        }else if (value>maxValue) {
                                            highCount++;
                                        }else{
                                            normalCount++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    [tempValueArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                        return [obj2[@"time"] compare:obj1[@"time"]]; //降序
                    }];
                    
                    
                    //血糖值
                    NSDictionary *tempDict=[tempValueArr firstObject];
                    value=[tempDict[@"value"] doubleValue];
                    NSString *valueStr=value>0.01?[NSString stringWithFormat:@"%.1f",value]:@"";
                    
                   //血糖记录方式
                    NSInteger sugarValueType=[tempDict[@"way"] integerValue];
                    NSString *sugerTypeStr=[NSString stringWithFormat:@"%ld",(long)sugarValueType];
                    
                    //该时间段是否有多条血糖数据
                    BOOL hasMuchData=tempValueArr.count>1;
                    
                    NSDictionary *sugarValueDict=[[NSDictionary alloc] initWithObjectsAndKeys:valueStr,@"value",sugerTypeStr,@"way",[NSNumber numberWithBool:hasMuchData],@"hasMuchData",[tempDict valueForKey:@"time"],@"measurement_time",[tempDict valueForKey:@"remarks"],@"remarks",[tempDict valueForKey:@"period"],@"time_slot",[tempDict valueForKey:@"id"],@"id",nil];
                    [dataTempArr addObject:sugarValueDict];
                }
                
                [dataResultArr addObject:dataTempArr];
                
            }
            bloodSugarData=dataResultArr;
            
            //血糖分析表
            weakSelf.weekRecordView.titleLbl.text = @"";
            weakSelf.weekRecordView.weekRecordsDict=@{@"high":[NSNumber numberWithInteger:highCount],
                                                  @"normal":[NSNumber numberWithInteger:normalCount],
                                                  @"low":[NSNumber numberWithInteger:lowCount]};
        }
        //绘制图表
        [weakSelf.chartScroll reloadChartView];
        weakSelf.chartScroll.frame=CGRectMake(0, self.weekRecordView.bottom, kScreenWidth, kCellHeight*(dateArray.count+2));
        weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.chartScroll.top+self.chartScroll.height);

    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  初始化血糖数据界面
- (void)initBloodView{
    [self.view addSubview:self.titleSegmentedControl];
    [self.view addSubview:self.datePickView];
    [self.view addSubview:self.rootScrollView];
    
    [self.rootScrollView addSubview:self.weekRecordView];
    [self.rootScrollView addSubview:self.chartScroll];
    
    self.weekRecordView.weekRecordsDict=[[NSDictionary alloc] init];
}

#pragma mark 显示弹出框
-(void)showPopupViewWithSuagrData:(NSMutableArray *)list timeTitle:(NSString *)timeStr{
    TCSugarListView *listView=[[TCSugarListView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-60, 60+44*5+20)];
    listView.sugarRecordList=list;
    listView.headTitleStr=timeStr;
    listView.viewDelegate=self;
    
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:listView animated:YES];
}

#pragma mark -- setters and getters
#pragma mark 标题按钮
-(UISegmentedControl *)titleSegmentedControl{
    if (!_titleSegmentedControl) {
        _titleSegmentedControl=[[UISegmentedControl alloc] initWithItems:listArray];
        _titleSegmentedControl.frame=CGRectMake((kScreenWidth-150)/2,KStatusHeight + 7, 150, 30);
        _titleSegmentedControl.selectedSegmentIndex=0;
        _titleSegmentedControl.tintColor=[UIColor whiteColor];
        [_titleSegmentedControl addTarget:self action:@selector(selectTabWithSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return _titleSegmentedControl;
}

#pragma mark 时间选择视图
-(UIView *)datePickView{
    if (!_datePickView) {
        _datePickView=[[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 41)];
        
        NSString *dateStr=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:6];
        startDateStr=kIsEmptyString(startDateStr)?dateStr:startDateStr;
        
        bloodleftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2-20, 40)];
        bloodleftBtn.tag = 100;
        bloodleftBtn.backgroundColor=[UIColor whiteColor];
        bloodleftBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        bloodleftBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [bloodleftBtn setImage:[UIImage imageNamed:@"ic_n_date"] forState:UIControlStateNormal];
        [bloodleftBtn setTitle:startDateStr forState:UIControlStateNormal];
        [bloodleftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [bloodleftBtn addTarget:self action:@selector(bloodButton:) forControlEvents:UIControlEventTouchUpInside];
        [_datePickView addSubview:bloodleftBtn];
        
        NSString *endStr=[[TCHelper sharedTCHelper] getCurrentDate];
        endDateStr=kIsEmptyString(endDateStr)?endStr:endDateStr;
        
        bloodrightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+20, 0, kScreenWidth/2-20, 40)];
        bloodrightBtn.backgroundColor=[UIColor whiteColor];
        bloodrightBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        bloodrightBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [bloodrightBtn setTitle:endDateStr forState:UIControlStateNormal];
        [bloodrightBtn setImage:[UIImage imageNamed:@"ic_n_date"] forState:UIControlStateNormal];
        bloodrightBtn.tag = 101;
        [bloodrightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [bloodrightBtn addTarget:self action:@selector(bloodButton:) forControlEvents:UIControlEventTouchUpInside];
        [_datePickView addSubview:bloodrightBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-20, 0, 40, 40)];
        label.text = @"至";
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        [_datePickView addSubview:label];
        
        UILabel *line  = [[UILabel alloc] initWithFrame:CGRectMake(0, bloodrightBtn.bottom, kScreenWidth, 1)];
        line.backgroundColor = kLineColor;
        [_datePickView addSubview:line];
    }
    return _datePickView;
}

#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.datePickView.bottom, kScreenWidth, kScreenHeight-self.datePickView.bottom)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
        _rootScrollView.delegate=self;
    }
    return _rootScrollView;
}

#pragma mark 血糖数据统计
-(TCWeekRecordView *)weekRecordView{
    if (_weekRecordView==nil) {
        _weekRecordView=[[TCWeekRecordView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        
        UILabel *bgline = [[UILabel alloc] initWithFrame:CGRectMake(0, 119, kScreenWidth, 1)];
        bgline.backgroundColor = [UIColor bgColor_Gray];
        [_weekRecordView addSubview:bgline];

    }
    return _weekRecordView;
}

#pragma mark 血糖记录表头
-(TCChartHeadView *)chartHeadView{
    if (!_chartHeadView) {
        _chartHeadView=[[TCChartHeadView alloc] initWithFrame:CGRectMake(0, self.datePickView.bottom-1, kScreenWidth, kCellHeight*2)];
    }
    return _chartHeadView;
}

#pragma mark -- 血糖记录表
-(TCBloodScrollView *)chartScroll{
    if(!_chartScroll)
    {
        _chartScroll = [[TCBloodScrollView alloc] initWithFrame:CGRectMake(0, self.weekRecordView.bottom, kScreenWidth,kScreenHeight-self.weekRecordView.bottom)];
        _chartScroll.dataSource = self;
        _chartScroll.chartDelegate = self;
        _chartScroll.backgroundColor=[UIColor whiteColor];
        
    }
    return _chartScroll;
}



@end
