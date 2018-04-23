 //
//  TCFilesViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFilesViewController.h"
#import "TCTreatMethodViewController.h"
#import "TCDiseasenameViewController.h"
#import "TimePickerView.h"
#import "TCMineButton.h"
#import "TCDatePickerView.h"
#import "TCSugerFilesModel.h"
#import "TCFileTableViewCell.h"

@interface TCFilesViewController ()<TreatMethodDelegate,DiseasenameDelegate,TCDatePickerViewDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>{

    NSArray         *_typeArray;
    NSArray         *_fileArray;
    NSArray         *_diseaseArray;

    UISwitch        *smokeSwitch;
    UISwitch        *alcohoSwitch;
    TimePickerView  *pickerView;
    NSString        *dietDateStr;
    TCSugerFilesModel *sugerFilesModel;


    NSArray *titleArr;
}

@property (nonatomic ,strong)UITableView *fileTabView;

@end

@implementation TCFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"糖档案";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    titleArr = @[@"糖尿病类型",@"确诊日期",@"治疗方式",@"并发症及其他疾病",@"既往病史",@"是否吸烟",@"是否喝酒",@"饮食偏好",@"过敏的食物和药物",@"控糖最大困扰",@"身体其他不适"];
    _fileArray=@[@"口服药",@"胰岛素",@"饮食控制",@"运动控制",@"中成药"];
    _typeArray =@[@"正常",@"1型糖尿病",@"2型糖尿病",@"妊娠型糖尿病",@"特殊型糖尿病",@"糖尿病前期",@"其他"];
    _diseaseArray =@[@"高血压",@"肥胖",@"视网膜病变",@"肾病",@"神经病变",@"冠心病",@"脑血管病变",@"颈动脉、双下肢动脉病变",@"脂肪肝",@"胆石症",@"胆囊炎",@"高尿酸血症",@"糖尿病足",@"周围血管病变",@"甲状腺",@"酮症酸中毒",@"尿酮"];
    dietDateStr = nil;
    
    [self.view addSubview:self.fileTabView];
    [self requestBloodFileData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-04" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-04" type:2];
#endif
}
#pragma mark -- Custom Delegate
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        if (kIsEmptyString(sugerFilesModel.diabetes_type)) {
            return 1;
        }else{
            if ([sugerFilesModel.diabetes_type isEqualToString:@"正常"]||[sugerFilesModel.diabetes_type isEqualToString:@"不确定"]||[sugerFilesModel.diabetes_type isEqualToString:@"未选择"]||[sugerFilesModel.diabetes_type isEqualToString:@"其他"]||[sugerFilesModel.diabetes_type isEqualToString:@"(null)"]) {
                return 1;
            }else{
                return 2;
            }
        }
    }else {
    
        return 2;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TCFileTableViewCell";
    TCFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[TCFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    for (UIView *cellView in cell.subviews) {
        if ([cellView isKindOfClass:[UISwitch class]]) {
            [cellView removeFromSuperview];
        }
    }
    if (indexPath.section==0) {
        cell.titleLabel.text = titleArr[indexPath.row];
        if (indexPath.row==0) {
            if (kIsEmptyString(sugerFilesModel.diabetes_type)||[sugerFilesModel.diabetes_type isEqualToString:@"(null)"]) {
                cell.contentLabel.text = sugerFilesModel.diabetes_type =  @"未选择";
            }else{
                cell.contentLabel.text=[sugerFilesModel.diabetes_type isEqualToString:@"不确定"]?@"其他":sugerFilesModel.diabetes_type;
            }
        } else {
            if (!kIsEmptyString(sugerFilesModel.diagnosis_year)) {
                if (![sugerFilesModel.diagnosis_year isEqualToString:@"(null)"]&&![sugerFilesModel.diagnosis_year isEqualToString:@"0"]) {
                    NSString *dataStr = nil;
                    if([sugerFilesModel.diagnosis_year rangeOfString:@"-"].location !=NSNotFound){
                        dataStr=sugerFilesModel.diagnosis_year;
                        
                    }else{
                        dataStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:sugerFilesModel.diagnosis_year format:@"yyyy-MM-dd"];
                    }
                    
                    cell.contentLabel.text = dataStr;
                    dietDateStr=dataStr;
                } else {
                    cell.contentLabel.text = @"未选择";
                    dietDateStr=[[TCHelper sharedTCHelper] getCurrentDate];
                }
            }else{
                cell.contentLabel.text = @"未选择";
                dietDateStr=[[TCHelper sharedTCHelper] getCurrentDate];
            }

        }
    }else if (indexPath.section==1){
        cell.titleLabel.text = titleArr[indexPath.row+2];
        if (indexPath.row==0) {
            if ( kIsEmptyString(sugerFilesModel.treatment_method)||[sugerFilesModel.treatment_method isEqualToString:@"(null)"]) {
                cell.contentLabel.text = sugerFilesModel.treatment_method = @"未选择";
            } else {
                cell.contentLabel.text =sugerFilesModel.treatment_method;
            }
        }else if (indexPath.row==1){
            if ( kIsEmptyString(sugerFilesModel.other_diseases)||[sugerFilesModel.other_diseases isEqualToString:@"(null)"]) {
                cell.contentLabel.text  = sugerFilesModel.other_diseases = @"未选择";
            } else {
                cell.contentLabel.text =sugerFilesModel.other_diseases;
            }
        }
    
    }else if (indexPath.section==2){
        cell.titleLabel.text = titleArr[indexPath.row+5];
        if (indexPath.row==0) {
            cell.contentLabel.text = @"";
            cell.accessoryType=UITableViewCellAccessoryNone;
            smokeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
            [smokeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
            smokeSwitch.tag =1001;
            [cell addSubview:smokeSwitch];
            smokeSwitch.on = [sugerFilesModel.is_smoking isEqualToString:@"1"]?YES:NO;
        }else if (indexPath.row==1){
            cell.contentLabel.text = @"";
            cell.accessoryType=UITableViewCellAccessoryNone;
            alcohoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
            [alcohoSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
            alcohoSwitch.tag =1002;
            [cell addSubview:alcohoSwitch];
            alcohoSwitch.on = [sugerFilesModel.is_drinking isEqualToString:@"1"]?YES:NO;
        }
    
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            [MobClick event:@"104_002013"];
            
            pickerView =[[TimePickerView alloc]initWithTitle:@"糖尿病类型" delegate:self];
            pickerView.pickerStyle=PickerStyle_type;
            for (int i=0; i<_typeArray.count; i++) {
                if ([sugerFilesModel.diabetes_type isEqualToString:_typeArray[i]]) {
                    [pickerView.locatePicker selectRow:i inComponent:0 animated:YES];
                }
            }
            [pickerView showInView:self.view];
        }else if (indexPath.row==1){
            [MobClick event:@"104_002014"];
            
            if (kIsEmptyString(dietDateStr)) {
                dietDateStr=[[TCHelper sharedTCHelper] getCurrentDate];
            }
            TCDatePickerView *datePickerView=[[TCDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) birthdayValue:dietDateStr pickerType:DatePickerViewTypeDate title:@"确诊日期"];
            datePickerView.pickerDelegate=self;
            [datePickerView datePickerViewShowInView:self.view];
        
        }
    }else if (indexPath.section==1){
        if (indexPath.row==0) {
            [MobClick event:@"104_002015"];
            
            NSMutableArray *valueArray = [[NSMutableArray alloc] init];
            [valueArray addObjectsFromArray:@[@"0",@"0",@"0",@"0",@"0"]];
            NSArray *array = [sugerFilesModel.treatment_method componentsSeparatedByString:@","];
            for (int i=0; i<_fileArray.count; i++) {
                for (int j=0; j<array.count; j++) {
                    if ([_fileArray[i] isEqualToString:array[j]]) {
                        [valueArray replaceObjectAtIndex:i withObject:@"1"];
                    }
                }
            }
            TCTreatMethodViewController *treatMethodVC = [[TCTreatMethodViewController alloc] init];
            treatMethodVC.imageArray = valueArray;
            treatMethodVC.delegate = self;
            [self.navigationController pushViewController:treatMethodVC animated:YES];

        }else if (indexPath.row == 1){  //并发症
            [MobClick event:@"104_002017"];
            
            NSMutableArray *valueArray = [[NSMutableArray alloc] init];
            for (int i=0; i<18; i++) {
                [valueArray addObject:@"1"];
            }
            NSArray *array = [sugerFilesModel.other_diseases componentsSeparatedByString:@","];
            for (int i=0; i<_diseaseArray.count; i++) {
                for (int j=0; j<array.count; j++) {
                    if ([_diseaseArray[i] isEqualToString:array[j]]) {
                        [valueArray replaceObjectAtIndex:i withObject:@"0"];
                    }
                }
            }
            TCDiseasenameViewController *diseasenameVC = [[TCDiseasenameViewController alloc] init];
            diseasenameVC.indexArray =valueArray;
            diseasenameVC.delegate = self;
            [self.navigationController pushViewController:diseasenameVC animated:YES];

        }
    
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==2) {
        return 25;
    }
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footView.backgroundColor = [UIColor bgColor_Gray];
    return footView;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectZero];
    if (section==2) {
        headView.frame = CGRectMake(0, 0, kScreenWidth, 25);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth/2, 25)];
        title.text = @"生活习惯";
        title.font = [UIFont systemFontOfSize: 13];
        title.textColor = [UIColor grayColor];
        [headView addSubview:title];
    }

    return headView;
}
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    dietDateStr=dateStr;
    sugerFilesModel.diagnosis_year = dietDateStr;
    [self.fileTabView reloadData];
    [self changeSugerFiles];
}

#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *typeStr=_typeArray[[pickerView.locatePicker selectedRowInComponent:0]];
        if ([typeStr isEqualToString:@"妊娠型糖尿病"]) {
            [self.view makeToast:@"性别为男，无法选择妊娠型" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        
        sugerFilesModel.diabetes_type= typeStr;
        [self.fileTabView reloadData];
        [self changeSugerFiles];
    }
}
#pragma mark -- 返回并发症
#pragma mark DiseasenameDelegate
- (void)returnDiseasename:(NSArray *)filArray{
    NSMutableArray *treat = [[NSMutableArray alloc] init];
    for (int i =0; i<filArray.count; i++) {
        if ([filArray[i] isEqualToString:@"0"]) {
            [treat addObject:_diseaseArray[i]];
        }
    }
    sugerFilesModel.other_diseases = [treat componentsJoinedByString:@","];
    [self.fileTabView reloadData];
    [self changeSugerFiles];
}
#pragma mark -- 返回治疗方式
#pragma mark TreatMethodDelegate
- (void)returnName:(NSArray *)filArray{
    NSMutableArray *treat = [[NSMutableArray alloc] init];
    for (int i =0; i<filArray.count; i++) {
        if ([filArray[i] isEqualToString:@"1"]) {
            [treat addObject:_fileArray[i]];
        }
    }
    sugerFilesModel.treatment_method =[treat componentsJoinedByString:@","];
    [self.fileTabView reloadData];
    [self changeSugerFiles];
}
#pragma mark -- Event response
#pragma mark -- 获取档案数据
- (void)requestBloodFileData{
    kSelfWeak;
    NSString *urlString = [NSString stringWithFormat:@"doSubmit=0"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddHealthFiles body:urlString success:^(id json) {
        NSDictionary *dataDic = [json objectForKey:@"result"];
        if (kIsDictionary(dataDic)) {
            sugerFilesModel = [[TCSugerFilesModel alloc] init];
            [sugerFilesModel setValues:dataDic];
            [weakSelf.fileTabView reloadData];
        }else{
            sugerFilesModel = [[TCSugerFilesModel alloc] init];
            [weakSelf.fileTabView reloadData];
        }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark --修改糖档案
- (void)changeSugerFiles{
    
    __weak typeof(self) weakSelf=self;
    NSInteger timesp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:sugerFilesModel.diagnosis_year format:@"yyyy-MM-dd"];
    NSString *dialogueTimeStr=[NSString stringWithFormat:@"%ld",(long)timesp];
    NSString *urlString = [NSString stringWithFormat:@"doSubmit=1&diabetes_type=%@&diagnosis_year=%@&treatment_method=%@&other_diseases=%@&is_drinking=%d&is_smoking=%d",
                           [sugerFilesModel.diabetes_type isEqualToString:@"未选择"]?@"":sugerFilesModel.diabetes_type,
                           [sugerFilesModel.diagnosis_year isEqualToString:@"未选择"]? dietDateStr:dialogueTimeStr,
                           [sugerFilesModel.treatment_method isEqualToString:@"未选择"]?@"":sugerFilesModel.treatment_method,
                           [sugerFilesModel.other_diseases isEqualToString:@"未选择"]?@"":sugerFilesModel.other_diseases,
                           alcohoSwitch.isOn,
                           smokeSwitch.isOn];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddHealthFiles body:urlString success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 是否有并发症及是否吸烟，是否喝酒
- (void)switchAction:(UISwitch *)Switch{
    if(Switch.tag == 1001){
        [MobClick event:@"104_002018"];
    }else{
        [MobClick event:@"104_002019"];
    }
    [self changeSugerFiles];
}

#pragma maek -- Event response
#pragma mark 返回按钮事件
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-- Custom Methods
#pragma mark 个人信息
-(UITableView *)fileTabView{
    if (_fileTabView==nil) {
        _fileTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight,kScreenWidth,kRootViewHeight) style:UITableViewStylePlain];
        _fileTabView.dataSource=self;
        _fileTabView.delegate=self;
        _fileTabView.tableFooterView=[[UIView alloc] init];
        _fileTabView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _fileTabView;
}


@end
