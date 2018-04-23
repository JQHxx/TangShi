//
//  TCRecordSugarViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

/*
 
 凌晨      morning
 早餐前   beforeBreakfast
 早餐后   afterBreakfast
 午餐前   beforeLunch
 午餐后   afterLunch
 晚餐前   beforeDinner
 晚餐后   afterDinner
 睡前      beforeSleep
 
 */

#import "TCRecordSugarViewController.h"
#import "TCCurveViewController.h"
#import "TCRecordSugarDetailsViewController.h"
#import "TCSugarDataViewController.h"
#import "TCClickViewGroup.h"
#import "TCSetSugarView.h"
#import "TCDatePickerView.h"
#import "TCSugarButton.h"
#import "BackScrollView.h"


@interface TCRecordSugarViewController ()<TCClickViewGroupDelegate,UITextViewDelegate,TCDatePickerViewDelegate,UIAlertViewDelegate>{
    NSArray            *periodArray;
    NSMutableArray     *timeListArray;
    NSString           *periodString;
    double             sugarValue;
    NSString           *measureTime;

    UILabel            *labeltext;
    TCDatePickerView   *datePickerView;
    UILabel            *countLabel;

    BOOL               isFirstIn;
    NSInteger          intBack;
    NSString           *nowDataStr;
    NSString           *buttonString;
}

@property (nonatomic,strong)BackScrollView   *rootScrollView;
@property (nonatomic,strong)TCClickViewGroup *timeMenuView;
@property (nonatomic,strong)TCSetSugarView   *setSugarView;
@property (nonatomic,strong)UIButton         *measureButton;
@property (nonatomic,strong)UITextView       *remarkTextView;
@property (nonatomic,strong)UIButton         *saveSugarButton;
@property (nonatomic,strong)UIButton         *bgView;

@end

@implementation TCRecordSugarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=self.sugarModel?@"编辑血糖记录":@"添加血糖记录";
    
    self.rightImageName=self.sugarModel?@"ic_n_del":nil;
    
    isFirstIn=YES;
    intBack=0;
    periodArray=[TCHelper sharedTCHelper].sugarPeriodArr;
    
    [self loadCurrentInfo];
    
    [self.view insertSubview:self.rootScrollView atIndex:0];
    [self.rootScrollView addSubview:self.timeMenuView];
    [self.rootScrollView addSubview:self.setSugarView];
    [self.rootScrollView addSubview:self.measureButton];
    [self.rootScrollView addSubview:self.remarkTextView];
    [self.rootScrollView addSubview:self.saveSugarButton];
    [self.rootScrollView addSubview:self.bgView];
    self.bgView.hidden = self.way==2?NO:YES;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -- Custom Delegate
#pragma mark  ClickViewGroupDelegate
-(void)TCClickViewGroupActionWithIndex:(NSUInteger)index{
    // 设置血糖值
    intBack ++;
    periodString=[periodArray objectAtIndex:index];
    measureTime= [timeListArray objectAtIndex:index];
    if (self.sugarPeriodEn.length>0) {
        NSString *timeName = [[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:self.sugarPeriodEn];
        NSArray *timeArray = [[TCHelper sharedTCHelper] sugarPeriodArr];
        NSArray *hoursArray=@[@"00",@"06",@"09",@"12",@"14",@"17",@"19",@"22"];
        for (int i=0; i<timeArray.count; i++) {
            if ([timeArray[i] isEqualToString:timeName]) {
                NSString *timeString = [measureTime substringToIndex:10];
                buttonString = [NSString stringWithFormat:@"%@ %@:00",timeString,hoursArray[i]];
            }
        }
    }
    if (intBack==1) {
        [_measureButton setTitle:buttonString.length>0?buttonString:measureTime forState:UIControlStateNormal];
    } else {
        [_measureButton setTitle:measureTime forState:UIControlStateNormal];

    }
    self.setSugarView.periodStr=[periodArray objectAtIndex:index];
    __weak typeof(self.setSugarView) weakView=self.setSugarView;
    weakView.sugarValue=^(double value){
        sugarValue=value;
    };
}

#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    [MobClick event:@"102_002009"];

    nowDataStr=[[TCHelper sharedTCHelper] getCurrentDateTime];   //今天
    NSInteger data =[[TCHelper sharedTCHelper] comSuderpareDate:dateStr withDate:nowDataStr];

    if (data==-1||data==0) {
        intBack = 2;
        NSString *btnStr=[NSString stringWithFormat:@"%@",dateStr];
        [_measureButton setTitle:btnStr forState:UIControlStateNormal];
        measureTime=dateStr;
    } else {
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (buttonIndex==1) {
            NSString *body=[NSString stringWithFormat:@"id=%ld",(long)self.sugarModel.id];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarRecordDelete body:body success:^(id json) {
                [TCHelper sharedTCHelper].isBloodReload=YES;
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }
}

#pragma mark -- NSNotification
#pragma mark 键盘弹出
-(void)keyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void(^animation)() = ^{
        if (self.remarkTextView.bottom>keyBoardBounds.origin.y) {
            self.rootScrollView.frame=CGRectMake(0, -(self.remarkTextView.bottom+10-keyBoardBounds.origin.y), kScreenWidth, kRootViewHeight);
        }
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
    
}

#pragma mark  键盘退出
-(void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.rootScrollView.frame = CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark -- Event response
#pragma mark 设置记录时间
-(void)setSugarMeasureTimeAction:(UIButton *)sender{
    [MobClick event:@"101_002009"];

    datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:measureTime pickerType:DatePickerViewTypeDateTime];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}

#pragma mark 保存数据
-(void)saveSugarInfoAction:(UIButton *)sender{
    MyLog(@"period:%@,sugarValue:%.1f,mesuretime:%@,remarks:%@",periodString,sugarValue,buttonString.length>0?buttonString:measureTime,self.remarkTextView.text);
    if (kIsEmptyString(measureTime)) {
        [self.view makeToast:@"记录时间不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (!(sugarValue>0)) {
        [self.view makeToast:@"血糖值不能为0" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *periodEn=[[TCHelper sharedTCHelper] getPeriodEnNameForPeriod:periodString];
    NSInteger timeSp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:buttonString.length>0?buttonString:measureTime format:@"yyyy-MM-dd HH:mm"];
    NSString *body=nil;
    NSString *url=nil;
    if (self.sugarModel) {
        body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&glucose=%.1f&measurement_time=%ld&remarks=%@&way=1&id=%ld",periodEn,sugarValue,(long)timeSp,self.remarkTextView.text,(long)self.sugarModel.id];
        url=kBloodSugarRecordUpdate;
    }else{
        body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&glucose=%.1f&measurement_time=%ld&remarks=%@&way=1",periodEn,sugarValue,(long)timeSp,self.remarkTextView.text];
        url=kBloodSugarRecordAdd;
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        [TCHelper sharedTCHelper].isBloodReload=YES;
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        
        TCRecordSugarDetailsViewController *detailsVC=[[TCRecordSugarDetailsViewController alloc] init];
        detailsVC.isEditSugarRecord=self.sugarModel.id>0;
        detailsVC.isSugarData = self.sugar_data>0;
        detailsVC.sugarValue=sugarValue;
        detailsVC.timeSlotStr=periodEn;
        detailsVC.measureTimeStr=buttonString.length>0?buttonString:measureTime;
        [self.navigationController pushViewController:detailsVC animated:YES];
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 删除
-(void)rightButtonAction{
    if (self.sugarModel) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"您确定要删除该条血糖记录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 101;
        [alertView show];
    }
}

- (void)leftButtonAction{
    if (_setSugarView.isbool==YES) {
        intBack = 2;
    }
    
    if (intBack == 2) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次血糖编辑吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }


}
#pragma mark Private Methods
#pragma mark 加载当前信息
-(void)loadCurrentInfo{
    //切换对应时间段
    if (self.sugarModel) {
        periodString=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:self.sugarModel.time_slot];
        self.remarkTextView.text=self.sugarModel.remarks;
        labeltext.hidden=self.sugarModel.remarks.length>0;
        sugarValue=[self.sugarModel.glucose doubleValue];
    }else if (!kIsEmptyString(self.sugarPeriodEn)){
        periodString=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:self.sugarPeriodEn];
        self.remarkTextView.text=@"";
    }else{
        periodString=[[TCHelper sharedTCHelper] getInPeriodOfCurrentTime];
        self.remarkTextView.text=@"";
    }
    NSInteger index=[periodArray indexOfObject:periodString];
    timeListArray=[self getStartTimeListWithIndex:index];
    
    UIButton *btn;
    for (UIView *view in self.timeMenuView.subviews) {
        for (UIView *menuView in view.subviews) {
            if ([menuView isKindOfClass:[UIButton class]]&&(menuView.tag == index+100)) {
                btn = (UIButton*)menuView;
            }
        }
    }
    [self.timeMenuView tcChangeViewWithButton:btn];
    
    // 设置血糖值
    self.setSugarView.periodStr=periodString;
    __weak typeof(self.setSugarView) weakView=self.setSugarView;
    weakView.sugarValue=^(double value){
        sugarValue=value;
    };
    self.setSugarView.initValue=sugarValue;
    
}

#pragma mark -- 获取对应时间段的开始时间
-(NSMutableArray *)getStartTimeListWithIndex:(NSInteger)index{
    NSArray *hoursArray=@[@"0",@"6",@"9",@"12",@"14",@"17",@"19",@"22"];
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yyyy-MM-dd HH:mm";
    NSDate *nowDate=[NSDate date];
    for (NSInteger i=0; i<hoursArray.count; i++) {
        //比较时间值
        NSDate *date=[[TCHelper sharedTCHelper] getCustomDate:nowDate WithHour:[hoursArray[i] integerValue]];
        NSInteger hour;
        if (i==hoursArray.count-1) {
            hour=24;
        }else{
            hour=[hoursArray[i+1] integerValue];
        }
        NSDate *endDate=[[TCHelper sharedTCHelper] getCustomDate:nowDate WithHour:hour];
        if ([nowDate compare:date]==NSOrderedDescending && [nowDate compare:endDate]==NSOrderedAscending){
            date=nowDate;
        }
        
        NSString *dateStr= [formatter stringFromDate:date];
        [tempArr addObject:dateStr];
    }
    NSString *nowDateStr=[formatter stringFromDate:nowDate];
    [tempArr addObject:nowDateStr];
    
    //替换时间
    if (self.sugarModel) {
        NSString *tempDateStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.sugarModel.measurement_time format:@"yyyy-MM-dd HH:mm"];
        [tempArr replaceObjectAtIndex:index withObject:tempDateStr];
    }else if (!kIsEmptyString(self.sugarPeriodEn)){
        NSString *tempDateStr=self.sugarMeasureTime;
        [tempArr replaceObjectAtIndex:index withObject:tempDateStr];
    }
    return tempArr;
}

#pragma mark -- Getters and Setters
#pragma mark 根滚动视图
-(BackScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[BackScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    }
    return _rootScrollView;
}

#pragma mark 时间段标签栏
-(TCClickViewGroup *)timeMenuView{
    if (_timeMenuView==nil) {
        _timeMenuView=[[TCClickViewGroup alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) titles:periodArray color:kSystemColor titleColor:[UIColor clearColor]];
        _timeMenuView.viewDelegate=self;
    }
    return _timeMenuView;
}

#pragma mark 设置血糖值
-(TCSetSugarView *)setSugarView{
    if (_setSugarView==nil) {
        _setSugarView=[[TCSetSugarView alloc] initWithFrame:CGRectMake(0, self.timeMenuView.bottom, kScreenWidth, (kScreenWidth-80)/2+20)];
        _setSugarView.isHomeIn=self.isHomeIn;
        _setSugarView.way = [self.sugarModel.way isEqualToString:@"2"]?1:0;
    }
    return _setSugarView;
}

#pragma mark 设置测量时间
-(UIButton *)measureButton{
    if (_measureButton==nil) {
        _measureButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, self.setSugarView.bottom+20, 200, 30)];
        [_measureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _measureButton.titleLabel.font=[UIFont systemFontOfSize:15.0f];
        [_measureButton setImage:[UIImage imageNamed:@"ic_pub_arrow_nor"] forState:UIControlStateNormal];
        _measureButton.imageEdgeInsets=UIEdgeInsetsMake(0, 175, 0, 0);
        _measureButton.titleEdgeInsets=UIEdgeInsetsMake(0, -25, 0, 0);
        [_measureButton addTarget:self action:@selector(setSugarMeasureTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _measureButton;
}

#pragma mark 备注
-(UITextView *)remarkTextView{
    if (_remarkTextView==nil) {
        _remarkTextView=[[UITextView alloc] initWithFrame:CGRectMake(40, self.measureButton.bottom+10, kScreenWidth-80, 140)];
        _remarkTextView.layer.borderColor=kLineColor.CGColor;
        _remarkTextView.layer.borderWidth=1.0;
        _remarkTextView.layer.cornerRadius=3.0;
        _remarkTextView.font=[UIFont systemFontOfSize:14];
        _remarkTextView.delegate=self;
        
        labeltext=[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, kScreenWidth-30.0, 30.0)];
        labeltext.text=@"请填写备注（选填）";
        labeltext.numberOfLines=0;
        labeltext.textColor=[UIColor lightGrayColor];
        labeltext.font=[UIFont systemFontOfSize:13.0];
        [_remarkTextView addSubview:labeltext];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(_remarkTextView.width-80, _remarkTextView.height-15, 70, 10)];
        countLabel.text = @"0/100";
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.font = [UIFont systemFontOfSize:12];
        [_remarkTextView addSubview:countLabel];

    }
    return _remarkTextView;
}

#pragma mark 保存
-(UIButton *)saveSugarButton{
    if (_saveSugarButton==nil) {
        _saveSugarButton=[[UIButton alloc] initWithFrame:CGRectMake(40, self.remarkTextView.bottom+20, kScreenWidth-80, 40)];
        [_saveSugarButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveSugarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveSugarButton.backgroundColor=kSystemColor;
        _saveSugarButton.layer.cornerRadius=5.0;
        _saveSugarButton.clipsToBounds=YES;
        [_saveSugarButton addTarget:self action:@selector(saveSugarInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveSugarButton;
}

- (UIButton *)bgView{
    if (_bgView==nil) {
        _bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.alpha= 1;
    }
    return _bgView;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark --UITextViewDelegate
#pragma mark shouldChangeTextInRange
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    intBack = 2;

    if (_remarkTextView.text.length==0){//textview长度为0
        if ([text isEqualToString:@""]) {//判断是否为删除键
            labeltext.hidden=NO;//隐藏文字
        }else{
            labeltext.hidden=YES;
        }
    }else{//textview长度不为0
        if (_remarkTextView.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {
                labeltext.hidden=NO;
            }else{
                labeltext.hidden=YES;
            }
        }else{//长度不为1时候
            labeltext.hidden=YES;
        }
    }
    if (_remarkTextView.text.length+text.length>100) {
        return NO;
    }
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
    countLabel.text = tString;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]!= 0) {
        labeltext.hidden=YES;
    }else{
        labeltext.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}

@end
