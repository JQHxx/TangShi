//
//  TCMyFriendDetailViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyFriendDetailViewController.h"
#import "YBPopupMenu.h"
#import "TCSugarRemindViewController.h"
#import "TCWeekRecordView.h"
#import "TCBloodScrollView.h"
#import "TCDatePickerView.h"
#import "TCSugarModel.h"
#import "TCChartHeadView.h"

#define kCellHeight (kScreenWidth-20)/10
@interface TCMyFriendDetailViewController ()<YBPopupMenuDelegate,UITextFieldDelegate,TCDatePickerViewDelegate,BloodDataSource,UIScrollViewDelegate>{

    UIButton         *rightBtn;
    UIImageView      *headImg;
    UILabel          *nickName;
    UIImageView      *sexImg;
    UILabel          *timeLabel;
    UIButton         *bloodleftBtn;
    UIButton         *bloodrightBtn;
    NSArray               *periodEnArray;    //血糖时间段
    NSString              *startDateStr;     //开始时间
    NSString              *endDateStr;       //结束时间
    NSInteger             btnTag;
    TCDatePickerView      *datePickerView;   //日期选择器
    NSMutableArray        *dateArray;        //日期数组
    NSMutableArray        *bloodSugarData;
    NSInteger             familyID;
    UITextField           *remarkNameText;
}

@property (nonatomic ,strong)UIView            *userHeadView;
@property (nonatomic ,strong)UIView            *timeView;
@property (nonatomic ,strong)UIScrollView      *rootScrollView;
@property (nonatomic ,strong)TCWeekRecordView  *weekRecordView;
@property (nonatomic ,strong)TCChartHeadView   *chartHeadView;     //血糖记录表头
@property (nonatomic ,strong)TCBloodScrollView *chartScroll;       //血糖记录表
@end

@implementation TCMyFriendDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"亲友详情";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    dateArray=[[NSMutableArray alloc] init];
    periodEnArray=[TCHelper sharedTCHelper].sugarPeriodEnArr;
    bloodSugarData=[[NSMutableArray alloc] init];
    
    familyID=[self.familyInfo[@"id"] integerValue];
    
    [self initFriendDetailView];
    [self loadFriendDetailData];
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

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath{
    return NO;
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
    [self loadFriendDetailData];
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

#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    if (index== 0) {
#if !DEBUG
        [MobClick event:@"104_003005"];
#endif

        [self changeNickName]; 
    }else if(index==1) {
#if !DEBUG
        [MobClick event:@"104_003006"];
#endif

        TCSugarRemindViewController *sugarRemindVC = [[TCSugarRemindViewController alloc] init];
        sugarRemindVC.family_id = familyID;
        [self.navigationController pushViewController:sugarRemindVC animated:YES];
    }else{
#if !DEBUG
        [MobClick event:@"104_003007"];
#endif

        [self deleteFriend];
    }
}

#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 当点击键盘的返回键（右下角）时，执行该方法。
    [remarkNameText resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"n"])
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    //判断是否时我们想要限定的那个输入框
    if (remarkNameText == textField)
    {
        if ([toBeString length] > 8)
        {   //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:8];
            [self.view makeToast:@"不能超过8个字" duration:1.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}


#pragma mark -- Event response
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
#pragma mark -- 更多
-(void)getAddFriendDetailAction{
    
    [YBPopupMenu showRelyOnView:rightBtn titles:@[@"备注名称",@"血糖提醒",@"删除亲友"] icons:@[@"",@"",@""] menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
        popupMenu.borderWidth = 0.5;
        popupMenu.borderColor = [UIColor colorWithHexString:@"0xeeeeeee"];
        popupMenu.delegate = self;
        popupMenu.textColor = [UIColor colorWithHexString:@"0x626262"];
        popupMenu.fontSize = 14;
    }];
    
}
#pragma mark -- 修改昵称
- (void)changeNickName{

    __weak typeof(self) weakSelf=self;
    NSString *title = NSLocalizedString(@"备注名称", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入备注名称"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setDelegate:self];
        textField.delegate=self;
        remarkNameText=textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"备注名称不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8) {
            [weakSelf.view makeToast:@"不能超过8个字" duration:1.0 position:CSToastPositionCenter];
        }else{
            NSString *body = [NSString stringWithFormat:@"family_id=%ld&call=%@",familyID,alertController.textFields.firstObject.text];
          [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUpdateFamilyCall body:body success:^(id json) {
              nickName.text =alertController.textFields.firstObject.text;
              CGFloat nickWidth=[nickName.text boundingRectWithSize:CGSizeMake(kScreenWidth-headImg.right-50, 20) withTextFont:nickName.font].width;
              nickName.frame=CGRectMake(headImg.right+10, headImg.top, nickWidth, 20);
              sexImg.frame=CGRectMake(nickName.right, nickName.top-5, 30, 30);
              [TCHelper sharedTCHelper].isFriendResquest = YES;
          } failure:^(NSString *errorStr) {
              [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
          }];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 5;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];

}
#pragma mark -- 获取亲友详情
- (void)loadFriendDetailData{
    __weak typeof(self) weakSelf=self;
    dateArray=[[TCHelper sharedTCHelper] getDateFromStartDate:startDateStr toEndDate:endDateStr format:@"M/d"] ;
    
    NSString *body = [NSString stringWithFormat:@"family_id=%ld&measurement_time_begin=%ld&measurement_time_end=%ld",familyID,[[TCHelper sharedTCHelper] timeSwitchTimestamp:startDateStr format:@"yyyy-MM-dd"],[[TCHelper sharedTCHelper] timeSwitchTimestamp:endDateStr format:@"yyyy-MM-dd"]];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kloadFriendDetail body:body success:^(id json) {

        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSDictionary *blood_glucose_info = [result objectForKey:@"blood_glucose_info"];
            if (blood_glucose_info.count>0) {
                NSArray *timeArr=[blood_glucose_info allKeys];
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
                                
                                NSArray *list=[blood_glucose_info valueForKey:timeStr];     //获取对应日期的血糖记录
                                for (NSDictionary *dict in list) {
                                    TCSugarModel *sugar=[[TCSugarModel alloc] init];
                                    [sugar setValues:dict];
                                    if ([sugar.time_slot isEqualToString:periodEnStr]) {   //计算相应时间段的血糖值
                                        value=[sugar.glucose doubleValue];
                                        way = [sugar.way integerValue];
                                        NSDictionary *tempDict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:value],@"value",sugar.measurement_time,@"time",[NSNumber numberWithDouble:way],@"way", sugar.time_slot,@"period",sugar.remarks,@"remarks",nil];
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
                        
                        NSDictionary *sugarValueDict=[[NSDictionary alloc] initWithObjectsAndKeys:valueStr,@"value",sugerTypeStr,@"way",[NSNumber numberWithBool:hasMuchData],@"hasMuchData",[tempDict valueForKey:@"time"],@"measurement_time",[tempDict valueForKey:@"remarks"],@"remarks",[tempDict valueForKey:@"period"],@"time_slot", nil];
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

        }else{
            weakSelf.weekRecordView.titleLbl.text = @"最近一周血糖";
            weakSelf.weekRecordView.weekRecordsDict=[[NSDictionary alloc] init];
        }
        //绘制图表
        [weakSelf.chartScroll reloadChartView];
        self.chartScroll.frame=CGRectMake(0, self.weekRecordView.bottom, kScreenWidth, kCellHeight*(dateArray.count+2));
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.chartScroll.top+self.chartScroll.height);
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];


}
#pragma mark -- 删除亲友
- (void)deleteFriend{
    NSString *title = NSLocalizedString(@"删除亲友后，将不能查看对方血糖数据，是否继续？", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"否", nil);
    NSString *okButtonTitle = NSLocalizedString(@"是", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *body = [NSString stringWithFormat:@"family_id=%ld",familyID];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFDeleteFriend body:body success:^(id json) {
            [TCHelper sharedTCHelper].isFriendResquest = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
        
          }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 10;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 初始化界面
- (void)initFriendDetailView{

    rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, KStatusHeight, 30, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(getAddFriendDetailAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    [self.view addSubview:self.userHeadView];
    [self.view addSubview:self.timeView];
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.weekRecordView];
    [self.rootScrollView addSubview:self.chartScroll];
}

#pragma mark -- setter or getter
#pragma mark -- 亲友信息
- (UIView *)userHeadView{
    if (_userHeadView ==nil) {
        _userHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 68)];
        _userHeadView.backgroundColor=[UIColor whiteColor];
        
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
        headImg.layer.cornerRadius = 24;
        headImg.clipsToBounds=YES;
        [headImg sd_setImageWithURL:[NSURL URLWithString:[self.familyInfo objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
        [_userHeadView addSubview:headImg];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, headImg.top, kScreenWidth-headImg.right, 20)];
        nickName.font = [UIFont systemFontOfSize:15];
        nickName.text =kIsEmptyString(self.call)?[self.familyInfo objectForKey:@"nick_name"]:self.call;
        CGFloat nickWidth=[nickName.text boundingRectWithSize:CGSizeMake(kScreenWidth-headImg.right-50, 20) withTextFont:nickName.font].width;
        nickName.frame=CGRectMake(headImg.right+10, headImg.top, nickWidth, 20);
        [_userHeadView addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, nickName.top-5, 30, 30)];
        NSInteger sex=[[self.familyInfo objectForKey:@"sex"] integerValue];
        if (sex==1) {
           sexImg.image =[UIImage imageNamed:@"ic_m_male"];
        }else if (sex==2){
           sexImg.image =[UIImage imageNamed:@"ic_m_famale"];
        }
        [_userHeadView addSubview:sexImg];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, nickName.bottom+5, kScreenWidth-headImg.right, 20)];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font =[UIFont systemFontOfSize:13];
        NSString *lastTime=[self.familyInfo objectForKey:@"last_time"];
        timeLabel.text =kIsEmptyString(lastTime)?@"":[NSString stringWithFormat:@"最后更新：%@",[[TCHelper sharedTCHelper] timeWithTimeIntervalString:lastTime format:@"yyyy-MM-dd HH:mm"]];
        [_userHeadView addSubview:timeLabel];
    }
    return _userHeadView;
}
#pragma mark -- 选择时间
- (UIView *)timeView{
    if (_timeView==nil) {
        _timeView = [[UIView alloc] initWithFrame:CGRectMake(0, _userHeadView.bottom+5, kScreenWidth, 40)];
        _timeView.backgroundColor = [UIColor whiteColor];
        
        NSString *dateStr=[[TCHelper sharedTCHelper] getLastWeekDateWithDays:6];
        startDateStr=kIsEmptyString(startDateStr)?dateStr:startDateStr;
        bloodleftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2-20, 40)];
        bloodleftBtn.tag = 100;
        bloodleftBtn.backgroundColor=[UIColor whiteColor];
        bloodleftBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        bloodleftBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [bloodleftBtn setTitle:startDateStr forState:UIControlStateNormal];
        [bloodleftBtn setImage:[UIImage imageNamed:@"ic_n_date"] forState:UIControlStateNormal];
        [bloodleftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [bloodleftBtn addTarget:self action:@selector(bloodButton:) forControlEvents:UIControlEventTouchUpInside];
        [ self.timeView addSubview:bloodleftBtn];
        
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
        [self.timeView addSubview:bloodrightBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-20, 0, 40, 40)];
        label.text = @"至";
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        [self.timeView addSubview:label];
        
        UILabel *line  = [[UILabel alloc] initWithFrame:CGRectMake(0, bloodrightBtn.bottom-1, kScreenWidth, 1)];
        line.backgroundColor = kLineColor;
        [ self.timeView addSubview:line];
    }
    return _timeView;
}

-(UIScrollView *)rootScrollView{
    if (_rootScrollView==nil) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,self.timeView.bottom, kScreenWidth, kScreenHeight-self.timeView.bottom)];
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.delegate=self;
    }
    return _rootScrollView;
}

#pragma mark -- 血糖数据统计
- (TCWeekRecordView *)weekRecordView{
    if (_weekRecordView==nil) {
        _weekRecordView=[[TCWeekRecordView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 120)];
    }
    return _weekRecordView;
}

#pragma mark 血糖记录表头
-(TCChartHeadView *)chartHeadView{
    if (!_chartHeadView) {
        _chartHeadView=[[TCChartHeadView alloc] initWithFrame:CGRectMake(0, self.timeView.bottom-1, kScreenWidth, kCellHeight*2)];
    }
    return _chartHeadView;
}

#pragma mark -- 血糖记录表
- (TCBloodScrollView *)chartScroll{
    if (_chartScroll==nil) {
        _chartScroll = [[TCBloodScrollView alloc] initWithFrame:CGRectMake(0, self.weekRecordView.bottom, kScreenWidth,self.rootScrollView.height-self.weekRecordView.bottom)];
        _chartScroll.backgroundColor=[UIColor whiteColor];
        _chartScroll.dataSource = self;
    }
    return _chartScroll;
}
@end
