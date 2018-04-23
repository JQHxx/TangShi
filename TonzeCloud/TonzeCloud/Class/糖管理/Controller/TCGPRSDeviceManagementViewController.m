
//
//  TCGPRSDeviceManagementViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSDeviceManagementViewController.h"
#import "TCGPRSDeviceManagementCell.h"

@interface TCGPRSDeviceManagementViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSArray      *_titleArray;
    UITextField           *remarkNameText;
}
@property (nonatomic,strong) UITableView *deviceManagementTab;
/// 设备信息数据
@property (nonatomic ,strong) NSMutableArray *deviceInfoArray;
@end

@implementation TCGPRSDeviceManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"设备管理";
    _titleArray = @[@"设备名称",@"设备sn",@"流量过期日期"];
    [self.deviceInfoArray addObject:_deviceListModel.device_name];
    [self.deviceInfoArray addObject:_deviceListModel.sn];
    if ([_deviceListModel.valid_date integerValue] != -1) {
        [self.deviceInfoArray addObject:[[TCHelper sharedTCHelper]timeWithTimeIntervalString:_deviceListModel.valid_date format:@"yyyy年MM月"]];
    }else{
        NSString *thereAreEffectiveTip = @"未激活";
        [self.deviceInfoArray addObject:thereAreEffectiveTip];
    }
    
    [self setDeviceManagementUI];
}
#pragma mark ====== 布局UI =======
- (void)setDeviceManagementUI{
    [self.view addSubview:self.deviceManagementTab];
}
#pragma mark ====== tableHearView =======
- (UIView *)tableHearView{
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    hearView.backgroundColor = [UIColor bgColor_Gray];
    return hearView;
}
#pragma mark ====== tebleFooterView =======
- (UIView *)tebleFooterView{
    UIView *tebleFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 74)];
    
    UIButton *removeBindingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    removeBindingBtn.backgroundColor =[UIColor whiteColor];
    removeBindingBtn.frame = CGRectMake(0, 30, kScreenWidth, 44);
    [removeBindingBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
    removeBindingBtn.titleLabel.font = kFontWithSize(17);
    [removeBindingBtn setTitleColor:UIColorFromRGB(0xff6158) forState:UIControlStateNormal];
    [removeBindingBtn addTarget:self action:@selector(removeBindingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [tebleFooterView addSubview:removeBindingBtn];
    
    return tebleFooterView;
}
#pragma mark ====== 解除绑定 =======
- (void)removeBindingBtnAction{
    UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认解绑该设备吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    kSelfWeak;
    [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *body  = [NSString stringWithFormat:@"sn=%@",_deviceListModel.sn];
            [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KunbindSn body:body success:^(id json) {
                [weakSelf.view makeToast:@"解绑成功" duration:1.0 position:CSToastPositionCenter];
                [TCHelper sharedTCHelper].isLoadGPRSGlucoseMeterList = YES;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }];
    [alertView show];
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *deviceManagementIdentifier = @"deviceManagementIdentifier";
    TCGPRSDeviceManagementCell *deviceManagementCell = [tableView dequeueReusableCellWithIdentifier:deviceManagementIdentifier];
    if (!deviceManagementCell) {
        deviceManagementCell = [[TCGPRSDeviceManagementCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceManagementIdentifier];
    }
    deviceManagementCell.titleLab.text = _titleArray[indexPath.row];
    deviceManagementCell.contentLab.text = self.deviceInfoArray[indexPath.row];
    deviceManagementCell.deviceNameLab.text = self.deviceInfoArray[indexPath.row];
    deviceManagementCell.arrowIcon.hidden =  indexPath.row == 0 ? NO : YES;
    deviceManagementCell.contentLab.hidden =  indexPath.row == 0 ? YES : NO;
    deviceManagementCell.deviceNameLab.hidden = indexPath.row == 0 ? NO : YES;
    
    return deviceManagementCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 ) {
        [self changeDeviceName];
    }
}
#pragma mark ====== 修改设备名称 =======
- (void)changeDeviceName{
    NSString *title = NSLocalizedString(@"设备名称", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    kSelfWeak;
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
        NSString *groupName=nil;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"备注名称不能为空" duration:1.0 position:CSToastPositionCenter];
            return;
        }else if (toBeString.length>10) {
            [weakSelf.view makeToast:@"不能超过10个字" duration:1.0 position:CSToastPositionCenter];
            return;
        }else{
            groupName=alertController.textFields.firstObject.text;
            NSString *body = [NSString stringWithFormat:@"sn=%@&device_name=%@",_deviceListModel.sn,groupName];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KRename body:body success:^(id json) {
                [weakSelf.deviceInfoArray replaceObjectAtIndex:0 withObject:groupName];
                [weakSelf.deviceManagementTab reloadData];
                [TCHelper sharedTCHelper].isLoadGPRSGlucoseMeterList = YES;
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
#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [remarkNameText resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"n"]){
        return YES;
    }
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    //判断是否时我们想要限定的那个输入框
    if (remarkNameText == textField){
        if ([toBeString length] > 10){
            textField.text = [toBeString substringToIndex:10];
            [self.view makeToast:@"不能超过10个字" duration:1.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}
#pragma mark ====== Setter =======
- (UITableView *)deviceManagementTab{
    if (!_deviceManagementTab) {
        _deviceManagementTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _deviceManagementTab.delegate = self;
        _deviceManagementTab.dataSource = self;
        _deviceManagementTab.rowHeight = 44;
        _deviceManagementTab.backgroundColor = [UIColor bgColor_Gray];
        _deviceManagementTab.tableFooterView = [self tebleFooterView];
        _deviceManagementTab.tableHeaderView = [self tableHearView];
    }
    return _deviceManagementTab;
}
- (NSMutableArray *)deviceInfoArray{
    if (!_deviceInfoArray) {
        _deviceInfoArray = [NSMutableArray array];
    }
    return _deviceInfoArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
