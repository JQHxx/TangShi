//
//  TCSetDailyDietViewController.m
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSetDailyDietViewController.h"
#import "TCIntensityViewController.h"
#import "TimePickerView.h"
#import "TCUserModel.h"

@interface TCSetDailyDietViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,TCIntensityDelegate>{
    TimePickerView  *pickerView;              //选择器
    NSArray         *personInfoArray;
    NSInteger       heigh;                   //身高
    double          weight;                  //体重
    NSString        *laborIntensityString;   //劳动强度
    NSArray         *laborArray;             //劳动类型列表
    TCUserModel     *userModel;
}

@property (nonatomic,strong)UITableView *infoTableView;

@end

@implementation TCSetDailyDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设置每日饮食目标";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    personInfoArray=@[@"身高",@"体重",@"劳动强度"];
    laborArray=@[@"休息状态",@"轻体力劳动",@"中体力劳动",@"重体力劳动"];
    userModel=[[TCUserModel alloc] init];
    
    [self initDailyTargetView];
    [self getUserInfoData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return personInfoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=personInfoArray[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:13.0f];
    if (indexPath.row==0) {
        cell.detailTextLabel.text=heigh==0?@"请选择身高":[NSString stringWithFormat:@"%ldcm",(long)heigh];
    }else if(indexPath.row==1){
        cell.detailTextLabel.text=weight>0.1?[NSString stringWithFormat:@"%.1fkg",weight]:@"请选择体重";
    }else{
        cell.detailTextLabel.text=kIsEmptyString(laborIntensityString)?@"请选择劳动强度":laborIntensityString;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2) {
        TCIntensityViewController *intensityVC=[[TCIntensityViewController alloc] init];
        intensityVC.controllerDelegate=self;
        intensityVC.laborIntensity=laborIntensityString;
        [self.navigationController pushViewController:intensityVC animated:YES];
    }else{
        if (indexPath.row==0) {
            heigh=heigh<50?170:heigh;
            NSInteger rowValue=heigh-50;
            pickerView =[[TimePickerView alloc] initWithTitle:@"身高" delegate:self];
            pickerView.pickerStyle=PickerStyle_Height;
            [pickerView.locatePicker selectRow:rowValue inComponent:0 animated:YES];
            [pickerView showInView:self.view];
            
            [pickerView pickerView:pickerView.locatePicker didSelectRow:rowValue inComponent:0];
        }else if(indexPath.row==1){
            NSInteger rowValue=0;
            NSInteger rowValue2=0;
            if (weight<10.0) {
                rowValue=60;
                rowValue2=0;
            }else{
                rowValue=(NSInteger)weight;
                rowValue2=(weight-rowValue)*10;
            }
            pickerView =[[TimePickerView alloc] initWithTitle:@"体重" delegate:self];
            pickerView.pickerStyle=PickerStyle_Weight;
            [pickerView.locatePicker selectRow:rowValue-10 inComponent:0 animated:YES];
            [pickerView.locatePicker selectRow:rowValue2 inComponent:2 animated:YES];
            [pickerView showInView:self.view];
            
            [pickerView pickerView:pickerView.locatePicker didSelectRow:rowValue-10 inComponent:0];
            [pickerView pickerView:pickerView.locatePicker didSelectRow:rowValue2 inComponent:2];
       
        }
    }
}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (pickerView.pickerStyle==PickerStyle_Height) {
            heigh=[pickerView.locatePicker selectedRowInComponent:0]+50;
        }else if (pickerView.pickerStyle==PickerStyle_Weight){
            NSInteger row1=[pickerView.locatePicker selectedRowInComponent:0]+10;
            NSInteger row2=[pickerView.locatePicker selectedRowInComponent:2];
            weight=row1+row2/10.0;
        }
        [self.infoTableView reloadData];
    }
}

#pragma mark -- Custom Delegate
-(void)intensityViewControllerDidSelectLaborIntensity:(NSString *)selectLabor{
    laborIntensityString=selectLabor;
    [self.infoTableView reloadData];
}

#pragma mark -- Event Response
#pragma mark 计算能量
-(void)calculateEnergy:(UIButton *)sender{
    if (heigh<50) {
        [self.view makeToast:@"请选择身高" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (weight<10.0) {
        [self.view makeToast:@"请选择体重" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(laborIntensityString)||[laborIntensityString isEqualToString:@"请选择劳动强度"]) {
        [self.view makeToast:@"请选择劳动强度" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (heigh == [userModel.height integerValue] && weight==[userModel.weight doubleValue] && [laborIntensityString isEqualToString:userModel.labour_intensity]) {
        NSString *targetEnarge = [NSUserDefaultsInfos getValueforKey:@"targetDailyEnergy"];
        NSString *titleStr = [NSString stringWithFormat:@"根据计算建议您每日饮食摄入量为%@千卡。",targetEnarge];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"计算结果" message:titleStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        NSInteger birthdayTime = [[TCHelper sharedTCHelper] timeSwitchTimestamp:userModel.birthday format:@"yyyy-MM-dd"];
        NSString *body = [NSString stringWithFormat:@"name=%@&sex=%@&birthday=%ld&height=%@&weight=%@&labour_intensity=%@&doSubmit=1",userModel.name,userModel.sex,(long)birthdayTime,[NSString stringWithFormat:@"%ld",(long)heigh],[NSString stringWithFormat:@"%.1f",weight],laborIntensityString];
        
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:body success:^(id json) {
            [[TCHelper sharedTCHelper] calculateTargetIntakeEnergyWithHeight:heigh weight:weight labor:laborIntensityString]; //设置每日目标摄入
            
            [TCHelper sharedTCHelper].isSetDietTarget=YES;
            NSString *targetEnarge = [NSUserDefaultsInfos getValueforKey:@"targetDailyEnergy"];
            NSString *titleStr = [NSString stringWithFormat:@"根据计算建议您每日饮食摄入量为%@千卡。",targetEnarge];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"计算结果" message:titleStr preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:nil];

        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark -- Pravite Methods
#pragma mark 获取个人信息
-(void)getUserInfoData{
  
     [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:@"doSubmit=0" success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            [userModel setValues:result];
            
            heigh=[userModel.height integerValue];
            weight=[userModel.weight doubleValue];
            laborIntensityString=userModel.labour_intensity;
            
            [self.infoTableView reloadData];
            
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter]; }];
}

#pragma mark 初始化界面
-(void)initDailyTargetView{
    [self.view addSubview:self.infoTableView];
    
    UILabel *descLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, self.infoTableView.bottom+20, kScreenWidth-20, 25)];
    descLabel.text=@"系统将根据您填写的信息计算饮食标准";
    descLabel.textAlignment=NSTextAlignmentCenter;
    descLabel.font=[UIFont systemFontOfSize:12.0f];
    descLabel.textColor=[UIColor lightGrayColor];
    [self.view addSubview:descLabel];
    
    UIButton *calculateButton=[[UIButton alloc] initWithFrame:CGRectMake(20, descLabel.bottom+5, kScreenWidth-40, 40)];
    [calculateButton setBackgroundColor:kSystemColor];
    calculateButton.layer.cornerRadius=3.0;
    calculateButton.clipsToBounds=YES;
    calculateButton.titleLabel.font=[UIFont systemFontOfSize:17.0f];
    [calculateButton setTitle:@"计算" forState:UIControlStateNormal];
    [calculateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [calculateButton addTarget:self action:@selector(calculateEnergy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calculateButton];
}

#pragma mark -- Getters and Setters
#pragma mark 个人数据
-(UITableView *)infoTableView{
    if (_infoTableView==nil) {
        _infoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 10, kScreenWidth, 132) style:UITableViewStylePlain];
        _infoTableView.delegate=self;
        _infoTableView.dataSource=self;
        _infoTableView.showsVerticalScrollIndicator=NO;
        _infoTableView.tableFooterView=[[UIView alloc] init];
    }
    return _infoTableView;
}
@end
