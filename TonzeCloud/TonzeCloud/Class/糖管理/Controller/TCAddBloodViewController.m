//
//  TCAddBloodViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddBloodViewController.h"
#import "TXHRrettyRuler.h"
#import "TCMineButton.h"
#import "TCDatePickerView.h"

@interface TCAddBloodViewController ()<TXHRrettyRulerDelegate,TCDatePickerViewDelegate,UITextViewDelegate>{
    UILabel      *bloodHeightLabel;
    UILabel      *bloodLowLabel;
    NSInteger     height;
    NSInteger     low;
    UITextView   *remarkTextView;
    UILabel      *labelText;
    UILabel      *countLabel;
    TCDatePickerView   *datePickerView;
    BOOL                isEditBlood;
}
@property (nonatomic,strong)UIScrollView *rootScrollView;
@property (nonatomic,strong)UIView       *headView;
@property (nonatomic,strong)TCMineButton *timeButton;
@property (nonatomic,strong)UIView       *remarkView;
@property (nonatomic,strong)UIButton     *saveRemarkButton;
@end
@implementation TCAddBloodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.baseTitle = self.bloodModel?@"编辑血压记录":@"添加血压记录";
    self.rightImageName =self.bloodModel?@"ic_n_del":@"";
    
    [self initAddBloodView];
}

#pragma mark --UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    isEditBlood = YES;
    if (remarkTextView.text.length==0){//textview长度为0
        if ([text isEqualToString:@""]) {//判断是否为删除键
            labelText.hidden=NO;//隐藏文字
        }else{
            labelText.hidden=YES;
        }
    }else{//textview长度不为0
        if (remarkTextView.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {
                labelText.hidden=NO;
            }else{
                labelText.hidden=YES;
            }
        }else{//长度不为1时候
            labelText.hidden=YES;
        }
    }
    if (remarkTextView.text.length+text.length>100) {
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
        labelText.hidden=YES;
    }else{
        labelText.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}
#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView index:(NSInteger)index{
    if (index == 1) {
        height=rulerScrollView.rulerValue+20;
        if (self.bloodModel) {
            isEditBlood=self.bloodModel.systolic_pressure!=height;
        }else{
            isEditBlood=height!=100;
        }
        if (isEditBlood) {
            [MobClick event:@"102_002042"];
        }
        
        NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"收缩压（高压）%ldmmHg",height]];
        bloodHeightLabel.attributedText =attributeStr2;
    } else {
        low=rulerScrollView.rulerValue+20;
        if (self.bloodModel) {
            isEditBlood=self.bloodModel.diastolic_pressure!=low;
        }else{
            isEditBlood=low!=100;
        }
        if (isEditBlood) {
            [MobClick event:@"102_002043"];
        }
        NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"舒张压（低压）%ldmmHg",low]];
        bloodLowLabel.attributedText =attributeStr2;
    }
}
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    isEditBlood = YES;
    NSString *nowDataStr=[[TCHelper sharedTCHelper] getCurrentDateTime];   //今天
    NSInteger data =[[TCHelper sharedTCHelper] comSuderpareDate:dateStr withDate:nowDataStr];
    
    if (data==-1||data==0) {
        NSString *btnStr=[NSString stringWithFormat:@"%@",dateStr];
        _timeButton.contentLab.text = btnStr;
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
            NSString *body = [NSString stringWithFormat:@"blood_record_id=%ld",self.bloodModel.blood_record_id];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodDelete body:body success:^(id json) {
                [TCHelper sharedTCHelper].isRecordsReload = YES;
                [TCHelper sharedTCHelper].isLoadBloodRecord = YES;
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *errorStr) {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

            }];
        }
    }
}
#pragma mark -- Event Response
#pragma mark -- 返回
- (void)leftButtonAction{
    if (isEditBlood) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次编辑？" preferredStyle:UIAlertControllerStyleAlert];
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
#pragma mark -- 删除
- (void)rightButtonAction{
    [MobClick event:@"102_002046"];
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确认删除记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];

}
#pragma mark -- 选择时间
- (void)seletedTime{
    [MobClick event:@"102_002044"];
    NSString *timeData =self.bloodModel?[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.bloodModel.measure_time format:@"yyyy-MM-dd HH:mm"]:[[TCHelper sharedTCHelper] getCurrentDateTime];
    datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:timeData pickerType:DatePickerViewTypeDateTime];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}
#pragma mark -- 保存
- (void)saveRemarkAction:(UIButton *)button{
    [MobClick event:@"102_002045"];
    NSString *body = nil;
    NSString *url = nil;
    NSInteger data =[[TCHelper sharedTCHelper] timeSwitchTimestamp:_timeButton.contentLab.text format:@"yyyy-MM-dd HH:mm"];
    if (height<=low) {
        [self.view makeToast:@"收缩压必须大于舒张压！" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (!self.bloodModel) {
        body = [NSString stringWithFormat:@"systolic_pressure=%ld&diastolic_pressure=%ld&measure_time=%ld&remark=%@&way=1",height,low,data,remarkTextView.text];
        url = kAddBloodData;
    }else{
        body = [NSString stringWithFormat:@"systolic_pressure=%ld&diastolic_pressure=%ld&measure_time=%ld&way=1&blood_record_id=%ld&remark=%@&way=1&doSubmit=1",height,low,data,self.bloodModel.blood_record_id,remarkTextView.text];
        url = kBloodUpdata;
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        [TCHelper sharedTCHelper].isRecordsReload = YES;
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [TCHelper sharedTCHelper].isLoadBloodRecord = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        if (!self.bloodModel) {
            [self getTaskPointsWithActionType:9 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                if (isBack || clickIndex == 1001) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }]; // 获取积分
        }else{
             [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
- (void)initAddBloodView{
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.saveRemarkButton];
    
    [self.rootScrollView addSubview:self.headView];
    [self.rootScrollView addSubview:self.timeButton];
    [self.rootScrollView addSubview:self.remarkView];
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.remarkView.bottom+74);
}

#pragma mark -- Getters and Setters
#pragma mark 根滑动视图
-(UIScrollView *)rootScrollView{
    if (_rootScrollView==nil) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-50)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark -- 添加血压视图
- (UIView *)headView{
    if (_headView==nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 370)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        bloodHeightLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        bloodHeightLabel.textAlignment=NSTextAlignmentCenter;
        bloodHeightLabel.font=[UIFont systemFontOfSize:14.0f];
        bloodHeightLabel.textColor=[UIColor blackColor];
        bloodHeightLabel.text=self.bloodModel?[NSString stringWithFormat:@"收缩压（高压）%ld mmHg",self.bloodModel.systolic_pressure]:@"收缩压（高压）100 mmHg";
        [_headView addSubview:bloodHeightLabel];
        
        TXHRrettyRuler *heightRuler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0,bloodHeightLabel.bottom+10, kScreenWidth, 120)];
        heightRuler.rulerDeletate=self;
        heightRuler.height=1;
        [heightRuler showRulerScrollViewWithCount:230 average:[NSNumber numberWithDouble:1] currentValue:self.bloodModel?self.bloodModel.systolic_pressure-20:80 smallMode:YES mineCount:20];
        [_headView addSubview:heightRuler];
        
        bloodLowLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, heightRuler.bottom+20, kScreenWidth-40, 25)];
        bloodLowLabel.textAlignment=NSTextAlignmentCenter;
        bloodLowLabel.font=[UIFont systemFontOfSize:14.0f];
        bloodLowLabel.textColor=[UIColor blackColor];
        bloodLowLabel.text=self.bloodModel?[NSString stringWithFormat:@"舒张压（低压）%ld mmHg",self.bloodModel.diastolic_pressure]:@"舒张压（低压）100 mmHg";
        [_headView addSubview:bloodLowLabel];

        TXHRrettyRuler *lowRuler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0,bloodLowLabel.bottom+10, kScreenWidth, 120)];
        lowRuler.rulerDeletate=self;
        heightRuler.low=2;
        [lowRuler showRulerScrollViewWithCount:230 average:[NSNumber numberWithDouble:1] currentValue:self.bloodModel?self.bloodModel.diastolic_pressure-20:80 smallMode:YES mineCount:20];
        [_headView addSubview:lowRuler];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lowRuler.bottom, kScreenWidth, 20)];
        titleLabel.text = @"标准范围：90~140/60~80 mmHg";
        titleLabel.font =[UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor grayColor];
        [_headView addSubview:titleLabel];
        
    }
    return _headView;
}
#pragma mark -- 选择时间
- (TCMineButton *)timeButton{
    if (_timeButton==nil) {
        NSString *timeData = [[TCHelper sharedTCHelper] getCurrentDateTime];
        NSDictionary *dict = @{@"title":@"测量时间",@"content":timeData,@"image":@"ic_pub_arrow_nor"};
        _timeButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, _headView.bottom+10, kScreenWidth, 48) dict:dict];
        _timeButton.backgroundColor = [UIColor whiteColor];
        _timeButton.contentLab.text = self.bloodModel?[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.bloodModel.measure_time format:@"yyyy-MM-dd HH:mm"]:[[TCHelper sharedTCHelper] getCurrentDateTime];
        [_timeButton addTarget:self action:@selector(seletedTime) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton];
    }
    return _timeButton;
}

#pragma mark -- 备注
- (UIView *)remarkView{
    if (_remarkView==nil) {
        _remarkView = [[UIView alloc] initWithFrame:CGRectMake(0, _timeButton.bottom+10, kScreenWidth, 150)];
        _remarkView.backgroundColor = [UIColor whiteColor];
        
        remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 130)];
        remarkTextView.font = [UIFont systemFontOfSize:14];
        remarkTextView.delegate=self;
        remarkTextView.text = self.bloodModel?self.bloodModel.remark:@"";
        [_remarkView addSubview:remarkTextView];
        
        labelText=[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, kScreenWidth-30.0, 30.0)];
        labelText.text=@"请填写备注（选填";
        labelText.text= remarkTextView.text.length>0?@"":@"请填写备注（选填）";
        labelText.numberOfLines=0;
        labelText.textColor=[UIColor lightGrayColor];
        labelText.font=[UIFont systemFontOfSize:14.0];
        [remarkTextView addSubview:labelText];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(remarkTextView.width-80, remarkTextView.height-15, 70, 10)];
        countLabel.text =remarkTextView.text.length>0?[NSString stringWithFormat:@"%lu/100",(unsigned long)remarkTextView.text.length]:@"0/100";
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.font = [UIFont systemFontOfSize:12];
        [remarkTextView addSubview:countLabel];
    }
    return _remarkView;
}
#pragma mark 保存
-(UIButton *)saveRemarkButton{
    if (_saveRemarkButton==nil) {
        _saveRemarkButton=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-KTabbarSafeBottomMargin-50, kScreenWidth, 50)];
        [_saveRemarkButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveRemarkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveRemarkButton.backgroundColor=kSystemColor;
        [_saveRemarkButton addTarget:self action:@selector(saveRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveRemarkButton;
}
@end
