//
//  TCPertainViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPertainViewController.h"
#import "TCMineButton.h"
#import "TXHRrettyRuler.h"
#import "TCDatePickerView.h"

@interface TCPertainViewController ()<UITextViewDelegate,TXHRrettyRulerDelegate,TCDatePickerViewDelegate>{

    UILabel      *pertainLabel;
    UITextView   *remarkTextView;
    UILabel      *textLabel;
    UILabel      *countLabel;
    
    float         pertain;
    TCDatePickerView   *datePickerView;

    BOOL         isEditPertain;

}
@property (nonatomic,strong)UIScrollView *rootScrollView;
@property (nonatomic,strong)UIView       *headView;
@property (nonatomic,strong)TCMineButton *timeButton;
@property (nonatomic,strong)UIView       *remarkView;
@property (nonatomic,strong)UIButton     *saveRemarkButton;
@end

@implementation TCPertainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.pertainModel?@"编辑糖化记录":@"添加糖化记录";
    self.rightImageName =self.pertainModel?@"ic_n_del":@"";
    self.view.backgroundColor = [UIColor bgColor_Gray];

    [self initPertainView];
}

#pragma mark --UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    isEditPertain = YES;
    if (remarkTextView.text.length==0){//textview长度为0
        if ([text isEqualToString:@""]) {//判断是否为删除键
            textLabel.hidden=NO;//隐藏文字
        }else{
            textLabel.hidden=YES;
        }
    }else{//textview长度不为0
        if (remarkTextView.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {
                textLabel.hidden=NO;
            }else{
                textLabel.hidden=YES;
            }
        }else{//长度不为1时候
            textLabel.hidden=YES;
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
        textLabel.hidden=YES;
    }else{
        textLabel.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (buttonIndex==1) {
            NSString *body = [NSString stringWithFormat:@"gh_id=%ld",self.pertainModel.gh_id];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kGlycosylatedDelete body:body success:^(id json) {
                [TCHelper sharedTCHelper].isRecordsReload = YES;
                [TCHelper sharedTCHelper].isLoadGlycosylated = YES;
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *errorStr) {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }
}
#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView index:(NSInteger)index{
    pertain=rulerScrollView.rulerValue+1.0;
    if (self.pertainModel) {
        isEditPertain=self.pertainModel.measure_value!=pertain;
    }else{
        isEditPertain=pertain!=6.0;
    }
    if (isEditPertain) {
        [MobClick event:@"102_002047"];
    }
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"糖化血红蛋白  %.1f ％",pertain]];
    pertainLabel.attributedText =attributeStr;
}
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    isEditPertain = YES;
    NSString *nowDataStr=[[TCHelper sharedTCHelper] getCurrentDateTime];   //今天
    NSInteger data =[[TCHelper sharedTCHelper] comSuderpareDate:dateStr withDate:nowDataStr];
    
    if (data==-1||data==0) {
        NSString *btnStr=[NSString stringWithFormat:@"%@",dateStr];
        _timeButton.contentLab.text = btnStr;
    } else {
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- Event response
#pragma mark -- 保存
- (void)saveRemarkAction:(UIButton *)button{
    [MobClick event:@"102_002049"];
    NSString *body = nil;
    NSString *url=nil;
    NSString  *time = [[TCHelper sharedTCHelper] getCurrentDateTime];
    NSInteger timeSort = [[TCHelper sharedTCHelper] timeSwitchTimestamp:time format:@"yyyy-MM-dd HH:mm"];
    if (!self.pertainModel) {
        body = [NSString stringWithFormat:@"measure_time=%ld&remark=%@&measure_value=%.1f",(long)timeSort,remarkTextView.text,pertain];
        url = kAddglycosylatedData;
    }else{
        body = [NSString stringWithFormat:@"measure_time=%ld&remark=%@&measure_value=%.1f&gh_id=%ld&doSubmit=1",(long)timeSort,remarkTextView.text,pertain,self.pertainModel.gh_id];
        url = kGlycosylatedUpdata;
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        [TCHelper sharedTCHelper].isLoadGlycosylated=YES;
        [TCHelper sharedTCHelper].isRecordsReload = YES;
        if (!self.pertainModel) {
            [self getTaskPointsWithActionType:10 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex ,BOOL isBack) {
                if (isBack || clickIndex == 1001) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];  // 获取积分
        }else{
           [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

    }];

}
#pragma mark -- 选择时间
- (void)seletedTime{
    [MobClick event:@"102_002048"];
    
     NSString *timeData =self.pertainModel?[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.pertainModel.measure_time format:@"yyyy-MM-dd HH:mm"]:[[TCHelper sharedTCHelper] getCurrentDateTime];
    datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:timeData pickerType:DatePickerViewTypeDateTime];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    if (isEditPertain) {
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
   [MobClick event:@"102_002050"];
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确认删除记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];


}
#pragma mark -- Custom Methon
#pragma mark -- 初始化界面
- (void)initPertainView{
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.saveRemarkButton];

    [self.rootScrollView addSubview:self.headView];
    [self.rootScrollView addSubview:self.timeButton];
    [self.rootScrollView addSubview:self.remarkView];
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.remarkView.bottom+10);
}
#pragma mark -- setter
#pragma mark 根滑动视图
-(UIScrollView *)rootScrollView{
    if (_rootScrollView==nil) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-50)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}
#pragma mark -- 添加血压视图
- (UIView *)headView{
    if (_headView==nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        pertainLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        pertainLabel.textAlignment=NSTextAlignmentCenter;
        pertainLabel.font=[UIFont systemFontOfSize:14.0f];
        pertainLabel.textColor=[UIColor blackColor];
        pertainLabel.text=@"糖化血红蛋白  5.5 ％";
        [_headView addSubview:pertainLabel];
        
        TXHRrettyRuler *heightRuler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0,pertainLabel.bottom+10, kScreenWidth, 120)];
        heightRuler.rulerDeletate=self;
        heightRuler.height=1;
        NSString *glyCurrent = [NSString stringWithFormat:@"%.1f",_pertainModel.measure_value];
        [heightRuler showRulerScrollViewWithCount:190 average:[NSNumber numberWithDouble:0.1] currentValue:self.pertainModel?[glyCurrent floatValue]-1.0:5.0 smallMode:YES mineCount:1.0];
        [_headView addSubview:heightRuler];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, heightRuler.bottom, kScreenWidth-30, 20)];
        titleLabel.text = @"标准范围：6.1~7.0 %";
        titleLabel.font =[UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor grayColor];
        [_headView addSubview:titleLabel]; 
        
    }
    return _headView;
}
#pragma mark -- 选择时间
- (TCMineButton *)timeButton{
    if (_timeButton==nil) {
        NSString *timeData =self.pertainModel?[[TCHelper sharedTCHelper] timeWithTimeIntervalString:self.pertainModel.measure_time format:@"yyyy-MM-dd HH:mm"]:[[TCHelper sharedTCHelper] getCurrentDateTime];
        NSDictionary *dict = @{@"title":@"测量时间",@"content":timeData,@"image":@"ic_pub_arrow_nor"};
        _timeButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, _headView.bottom+10, kScreenWidth, 48) dict:dict];
        _timeButton.backgroundColor = [UIColor whiteColor];
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
        remarkTextView.text = self.pertainModel?self.pertainModel.remark:@"";
        remarkTextView.delegate=self;
        [_remarkView addSubview:remarkTextView];
        
        textLabel=[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, kScreenWidth-30.0, 30.0)];
        textLabel.text= remarkTextView.text.length>0?@"":@"请填写备注（选填）";
        textLabel.numberOfLines=0;
        textLabel.textColor=[UIColor lightGrayColor];
        textLabel.font=[UIFont systemFontOfSize:14.0];
        [remarkTextView addSubview:textLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(remarkTextView.width-80, remarkTextView.height-15, 70, 10)];
        countLabel.text =kIsEmptyString(self.pertainModel.remark)?@"0/100":[NSString stringWithFormat:@"%lu/100",(unsigned long)self.pertainModel.remark.length];
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
        _saveRemarkButton=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        [_saveRemarkButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveRemarkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveRemarkButton.backgroundColor=kSystemColor;
        [_saveRemarkButton addTarget:self action:@selector(saveRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveRemarkButton;
}

@end
