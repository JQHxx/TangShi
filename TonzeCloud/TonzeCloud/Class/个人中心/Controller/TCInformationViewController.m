//
//  TCInformationViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInformationViewController.h"
#import "TCInstallTableViewCell.h"
#import "TCIntensityViewController.h"
#import "TimePickerView.h"
#import "TCMineButton.h"
#import "TCDatePickerView.h"
#import "TCUserModel.h"


@interface TCInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,TCIntensityDelegate,TCDatePickerViewDelegate>{
    NSArray            *_workArray;
    NSArray            *titlesArray;
    UIAlertAction      *OkBtnEnabledAction;
    TimePickerView     *Picker;
    NSString           *nowDataStr;
    
    NSArray             *cityArray;
}
@property (nonatomic,strong) TCUserModel *userModel;
@property (nonatomic,strong)UITableView *infoTableView;


@end

@implementation TCInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.baseTitle = @"基本信息";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.rigthTitleName = @"保存";
    
    titlesArray=[NSArray arrayWithObjects:@"性别",@"出生日期",@"身高",@"体重",@"BMI",@"劳动强度",nil];
    nowDataStr =[TCHelper sharedTCHelper].getCurrentDate;
    _workArray =@[@"休息状态",@"轻体力劳动",@"中体力劳动",@"重体力劳动"];
    cityArray = [[NSArray alloc] init];
    _userModel=[[TCUserModel alloc] init];
    
    [self.view addSubview:self.infoTableView];
    [self requestPersonalInfo];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-03" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-03" type:2];
#endif
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text=titlesArray[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:16.0f];
    
    cell.detailTextLabel.font=[UIFont systemFontOfSize:14.0f];
    if(indexPath.row==0){
        if ([_userModel.sex integerValue]>0&&[_userModel.sex integerValue]<3) {
            cell.detailTextLabel.text=[_userModel.sex integerValue]==1?@"男":@"女";
        }else{
            cell.detailTextLabel.text=@"请选择性别";
        }
    }else if(indexPath.row==1){
        cell.detailTextLabel.text=kIsEmptyString(_userModel.birthday)?@"请选择出生日期":_userModel.birthday;
    }else if(indexPath.row==2){
        NSInteger height=[_userModel.height integerValue];
        cell.detailTextLabel.text=height>0?[NSString stringWithFormat:@"%ldcm",(long)height]:@"请选择身高";
    }else if(indexPath.row==3){
        double weight=[_userModel.weight doubleValue];
        cell.detailTextLabel.text=weight>0.1?[NSString stringWithFormat:@"%.1fkg",weight]:@"请选择体重";
    }else if(indexPath.row==4){
        cell.accessoryType=UITableViewCellAccessoryNone;
        double bmi=0.0;
        NSInteger height=[_userModel.height integerValue];
        double  weight=[_userModel.weight doubleValue];
        if (height>0&&weight>0.01) {
            bmi= weight/(height*height)*10000;
        }
        cell.detailTextLabel.text=bmi>0.1?[NSString stringWithFormat:@"%.1f",bmi]:@"根据身高体重计算";
        cell.detailTextLabel.textColor = kbgBtnColor;
    }else if(indexPath.row==5){
        cell.detailTextLabel.text=kIsEmptyString(_userModel.labour_intensity)?@"请选择劳动强度":_userModel.labour_intensity;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row!=4) {
        NSArray *mobArr = @[@"104_002007",@"104_002008",@"104_002009",@"104_002010",@"104_002011"];
        [MobClick event:mobArr[indexPath.row>4?indexPath.row-1:indexPath.row]];
    }
    
    if (indexPath.row == 0){
        Picker =[[TimePickerView alloc]initWithTitle:@"性别" delegate:self];
        Picker.pickerStyle=PickerStyle_Sex;
        [Picker.locatePicker selectRow:([_userModel.sex integerValue]-1) inComponent:0 animated:YES];
        [Picker showInView:self.view];
        [Picker pickerView:Picker.locatePicker didSelectRow:[_userModel.sex integerValue] inComponent:0];
        
    }else if (indexPath.row ==1){
        NSString *dateStr=kIsEmptyString(_userModel.birthday)?@"1990-01-01":_userModel.birthday;
        
        TCDatePickerView *datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) birthdayValue:dateStr pickerType:DatePickerViewTypeDate title:@"出生日期"];
        datePickerView.pickerDelegate=self;
        [datePickerView datePickerViewShowInView:self.view];
        
    }else if (indexPath.row == 2){
        Picker =[[TimePickerView alloc]initWithTitle:@"身高" delegate:self];
        Picker.pickerStyle=PickerStyle_Height;
        NSInteger height = [_userModel.height integerValue];
        height = height < 30 ? 170:height;
        [Picker.locatePicker selectRow:height-50 inComponent:0 animated:YES];
        [Picker showInView:self.view];
        [Picker pickerView:Picker.locatePicker didSelectRow:height-50 inComponent:0];
    }else if (indexPath.row == 3){
        double weight=[_userModel.weight doubleValue];
        NSInteger rowValue=0;
        NSInteger rowValue2=0;
        if (weight<10.0) {
            rowValue=60;
            rowValue2=0;
        }else{
            rowValue=(NSInteger)weight;
            rowValue2=(weight-rowValue)*10;
        }
        Picker =[[TimePickerView alloc] initWithTitle:@"体重" delegate:self];
        Picker.pickerStyle=PickerStyle_Weight;
        [Picker.locatePicker selectRow:rowValue-10 inComponent:0 animated:YES];
        [Picker.locatePicker selectRow:rowValue2 inComponent:2 animated:YES];
        [Picker showInView:self.view];
        
        [Picker pickerView:Picker.locatePicker didSelectRow:rowValue-10 inComponent:0];
        [Picker pickerView:Picker.locatePicker didSelectRow:rowValue2 inComponent:2];
        
    }else if (indexPath.row == 4){
        
    }else{
        TCIntensityViewController *intensityVC = [[TCIntensityViewController alloc] init];
        intensityVC.laborIntensity=_userModel.labour_intensity;
        intensityVC.controllerDelegate = self;
        [self.navigationController pushViewController:intensityVC animated:YES];
    }
}
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    NSInteger data =[[TCHelper sharedTCHelper] compareDate:dateStr withDate:nowDataStr];
    if (data==-1||data==0) {
    _userModel.birthday=dateStr;
    [self.infoTableView reloadData];
    }else{
        [self.view makeToast:@"出生日期不能大于当前时间" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- Custom Delegate
#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_Age) {
            _userModel.birthday=[NSString stringWithFormat:@"%li",(long)[Picker.locatePicker selectedRowInComponent:0]];
        }else if (Picker.pickerStyle==PickerStyle_Height){
            NSInteger heigh=[Picker.locatePicker selectedRowInComponent:0]+50;
            _userModel.height=[NSString stringWithFormat:@"%li",(long)heigh];
        }else if (Picker.pickerStyle==PickerStyle_Sex){
            _userModel.sex=[NSString stringWithFormat:@"%ld",(long)([Picker.locatePicker selectedRowInComponent:0]+1)];
        }else if (Picker.pickerStyle==PickerStyle_Weight){
            NSInteger row1=[Picker.locatePicker selectedRowInComponent:0]+10;
            NSInteger row2=[Picker.locatePicker selectedRowInComponent:2];
            double  weight=row1+row2/10.0;
            _userModel.weight=[NSString stringWithFormat:@"%.1f",weight];
        }
        [self.infoTableView reloadData];
    }
}
#pragma mark --TCIntensityDelegate
-(void)intensityViewControllerDidSelectLaborIntensity:(NSString *)selectLabor{
    _userModel.labour_intensity=selectLabor;
    [self.infoTableView reloadData];
}

#pragma mark -- 获取个人信息数据
- (void)requestPersonalInfo{
    NSString *urlString = [NSString stringWithFormat:@"doSubmit=0"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:urlString success:^(id json) {
        NSDictionary *result =[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            [_userModel setValues:result];
            [self.infoTableView reloadData];
            // ---- 判断用户是否完善资料，完善即给积分，处理老用户判断
            NSString *birthday = [result objectForKey:@"birthday"];
            NSInteger height = [[result objectForKey:@"height"] integerValue];
            NSString *labour_intensity = [result objectForKey:@"labour_intensity"];
            NSString *sex = [result objectForKey:@"sex"];
            NSString *weight = [result objectForKey:@"weight"];
            if (!kIsEmptyString(birthday) && !kIsEmptyString(labour_intensity) && height > 0 &&  !kIsEmptyString(sex) && !kIsEmptyString(weight)) {
                [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
                [self getTaskPointsWithActionType:2 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
                }];
            }
            [TCHelper sharedTCHelper].isUserReload=YES;
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Event response
#pragma mark 返回按钮事件
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 保存个人信息
- (void)rightButtonAction{
    [MobClick event:@"104_002012"];

    NSString *weightStr=[NSString stringWithFormat:@"%.1f",[_userModel.weight doubleValue]];  //体重
    NSString *infomationString = [NSString stringWithFormat:@"sex=%@&birthday=%@&height=%@&weight=%@&labour_intensity=%@&doSubmit=1",_userModel.sex,_userModel.birthday,_userModel.height,weightStr,_userModel.labour_intensity];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:infomationString success:^(id json) {
        NSInteger hight=[_userModel.height integerValue];
        double weight=[_userModel.weight doubleValue];
        if (hight>0&&weight>0.1&&!kIsEmptyString(_userModel.labour_intensity)) {
            [[TCHelper sharedTCHelper] calculateTargetIntakeEnergyWithHeight:hight weight:weight labor:_userModel.labour_intensity];
        }
        if (hight > 0 && weight > 0.1 && !kIsEmptyString(_userModel.labour_intensity) && !kIsEmptyString(_userModel.birthday) && !kIsEmptyString(_userModel.sex)) {
            // 获取积分
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [self getTaskPointsWithActionType:2 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                if (clickIndex == 1001 || isBack) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- setters and getters
#pragma mark 个人信息
-(UITableView *)infoTableView{
    if (_infoTableView==nil) {
        _infoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 10,kScreenWidth,kRootViewHeight-10) style:UITableViewStylePlain];
        _infoTableView.dataSource=self;
        _infoTableView.delegate=self;
        _infoTableView.tableFooterView=[[UIView alloc] init];
        _infoTableView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _infoTableView;
}
@end
