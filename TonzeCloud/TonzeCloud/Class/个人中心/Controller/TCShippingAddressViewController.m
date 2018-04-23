
//
//  ShippingAddressVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCShippingAddressViewController.h"
#import "TCShippingAddressCell.h"
#import "TCCityPickerView.h"

@interface TCShippingAddressViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITextField *_nameTF;
    UITextField *_phoneTF;
    UITextField *_addressTF;
    UITextField *_areaTF;
    NSString *_provinceStr; // 省份信息
    NSString *_cityStr;     // 市信息
    NSString *_townStr;        // 区镇信息
    NSString *_provincialCityStr;     // 省市区信息
}
///
@property (nonatomic ,strong) UITableView *tableView;
/// 标题数据
@property (nonatomic ,strong) NSArray *titleArray;
/// 提示文字
@property (nonatomic ,strong) NSArray *placeholderArray;
/// 地址选择
@property (nonatomic ,strong) TCCityPickerView *cityPickerView;
/// 确定按钮
@property (nonatomic ,strong) UIButton *determineBtn;
///
@property (nonatomic ,strong) UITextField *areaTF;

@end

@implementation TCShippingAddressViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"收货地址";
    
    [self setShippingAddressUI];
    [self loadData];
}
#pragma mark -- Bulid UI

- (void)setShippingAddressUI{

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.determineBtn];
}
#pragma mark -- Request Data
- (void)loadData{
    // 赋值已有收货信息
    if (!kIsEmptyString(_consigneeInfoModel.consignee_pro)) {
        _provinceStr = _consigneeInfoModel.consignee_pro;
        _cityStr = _consigneeInfoModel.consignee_city;
        _townStr = _consigneeInfoModel.consignee_area;
        _provincialCityStr = [NSString stringWithFormat:@"%@%@%@",_consigneeInfoModel.consignee_pro,_consigneeInfoModel.consignee_city,_consigneeInfoModel.consignee_area];
    }
}
- (void)saveAddress{
    NSString *body = [NSString stringWithFormat:@"consignee_name=%@&consignee_phone=%@&consignee_addr=%@&consignee_pro=%@&consignee_city=%@&consignee_area=%@&doSubmit=1",_nameTF.text,_phoneTF.text,_addressTF.text,_provinceStr,_cityStr,_townStr];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kAddConsignee body:body success:^(id json) {
        NSUInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 1) {
            [TCHelper sharedTCHelper].isIngralGoodsReload = YES;
            NSString *addressStr = [NSString stringWithFormat:@"%@%@",_areaTF.text,_addressTF.text];
            weakSelf.addressInfo (addressStr,_phoneTF.text,_nameTF.text);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Action =======
#pragma mark ====== 保存 =======

- (void)saveClick{
    if (kIsEmptyString(_nameTF.text)) {
        [self.view makeToast:@"请输入姓名" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if ([NSString isEmpty:_nameTF.text]){
            [self.view makeToast:@" 亲，姓名不能有空格" duration:0.5 position:CSToastPositionCenter];
            return;
    }else if (kIsEmptyString(_phoneTF.text)){
        [self.view makeToast:@"请输入手机号码" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (_phoneTF.text.length != 11){
        [self.view makeToast:@"请输入正确的手机号" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (![[_phoneTF.text substringToIndex:1] isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_provinceStr)){
        [self.view makeToast:@"请选择地区" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if ([NSString isEmpty:_addressTF.text]){
        [self.view makeToast:@"亲，详细地址不能有空格" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_addressTF.text)){
        [self.view makeToast:@"请输入详细地址" duration:0.5 position:CSToastPositionCenter];
        return;
    }else{// 保存收货信息
        [self saveAddress];
    }
}
#pragma mark ====== 返回按钮 =======
-(void)leftButtonAction{
    NSString *provincialCityStr = [NSString stringWithFormat:@"%@%@%@",_provinceStr,_cityStr,_townStr];
    
    if ( ![_provincialCityStr isEqualToString:provincialCityStr] || ![_addressTF.text isEqualToString:_consigneeInfoModel.consignee_addr] || ![_nameTF.text isEqualToString:_consigneeInfoModel.consignee_name] || ![_phoneTF.text isEqualToString:_consigneeInfoModel.consignee_phone]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
           [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tableViewTouchInSide{
    [self.view endEditing:YES];
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate   =======

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *shippingAddressIdentifier  = @"CellIdentifier";
    TCShippingAddressCell *addressCell = [tableView dequeueReusableCellWithIdentifier:shippingAddressIdentifier];
    if (!addressCell) {
        addressCell = [[TCShippingAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shippingAddressIdentifier];
    }
    addressCell.titleLab.text = self.titleArray[indexPath.row];
    addressCell.contentTF.placeholder =self.placeholderArray[indexPath.row];
    addressCell.contentTF.delegate = self;
    addressCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            addressCell.contentTF.text = _consigneeInfoModel.consignee_name;
            addressCell.arrowImg.hidden = YES;
            _nameTF = addressCell.contentTF;
        }break;
        case 1:
        {
            addressCell.contentTF.text = _consigneeInfoModel.consignee_phone;
            addressCell.arrowImg.hidden = YES;
            addressCell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            _phoneTF = addressCell.contentTF;
        }break;
        case 2:
        {
            if (!kIsEmptyString(_consigneeInfoModel.consignee_pro)) {
                addressCell.contentTF.text = [NSString stringWithFormat:@"%@%@%@",_consigneeInfoModel.consignee_pro,_consigneeInfoModel.consignee_city,_consigneeInfoModel.consignee_area];
            }
            addressCell.arrowImg.hidden = NO;// 箭头
            _areaTF = addressCell.contentTF;
        }break;
        case 3:
        {
            addressCell.contentTF.text = _consigneeInfoModel.consignee_addr;
            addressCell.arrowImg.hidden = YES;
            _addressTF = addressCell.contentTF;
        }break;
        default:
            break;
    }
    return addressCell;
}
#pragma mark ====== UITextFieldDelegate =======

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    TCShippingAddressCell *cell = (TCShippingAddressCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.row == 2) {
        [self.view endEditing:YES];
        
        self.cityPickerView = [[TCCityPickerView alloc]init];
        if (!kIsEmptyString(_areaTF.text)) {
            for (NSInteger i = 0; i < _cityPickerView.provinceArr.count; i++) {
                if ([_cityPickerView.provinceArr[i] isEqualToString:_consigneeInfoModel.consignee_pro]) {
                    _cityPickerView.cityArr = [self getNameforProvince:i];
                    _cityPickerView.province = _cityPickerView.provinceArr[i];
                    
                    [self.cityPickerView.cityPickerView selectRow:i inComponent:0 animated:YES];
                }
            }
            for (NSInteger i = 0; i < _cityPickerView.cityArr.count; i++) {
                if ([[_cityPickerView.cityArr[i] objectForKey:@"Name"] isEqualToString:_consigneeInfoModel.consignee_city]) {
                    _cityPickerView.townArr = [_cityPickerView.cityArr[i] objectForKey:@"Area"];
                    _cityPickerView.city = [_cityPickerView.cityArr[i] objectForKey:@"Name"];
                    
                    [self.cityPickerView.cityPickerView selectRow:i inComponent:1 animated:YES];
                }
            }
            for (NSInteger i = 0; i < _cityPickerView.townArr.count; i++) {
                if ([[_cityPickerView.townArr[i] objectForKey:@"Name"] isEqualToString:_consigneeInfoModel.consignee_area]) {
                    _cityPickerView.town =  [_cityPickerView.townArr[i] objectForKey:@"Name"];
                    [self.cityPickerView.cityPickerView selectRow:i inComponent:2 animated:YES];
                }
            }
        }
        [self.view addSubview:self.cityPickerView];
        kSelfWeak;
        _cityPickerView.config = ^(NSString *province, NSString *city, NSString *town){
            NSString *areaStr = [NSString stringWithFormat:@"%@%@%@",province,city,town];
            _provinceStr = province;
            _cityStr  = city;
            _townStr = town;
            MyLog(@"%@",areaStr);
            weakSelf.areaTF.text = kIsEmptyString(areaStr) ? @"" : areaStr;
        };
        return NO;
    }
    return YES;
}
- (NSArray *)getNameforProvince:(NSInteger)row{
    _cityPickerView.allProvinceArray = [_cityPickerView.allCityInfo[row] objectForKey:@"City"];
    NSMutableArray *tempMutArray = [NSMutableArray array];
    for (int i = 0; i < _cityPickerView.allProvinceArray.count; i++) {
        NSDictionary *dic =_cityPickerView.allProvinceArray[i];
        [tempMutArray addObject:dic];
    }
    return tempMutArray;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField == _nameTF) {
        if (string.length == 0) return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 10){
            return NO;
        }
    }else if (textField == _phoneTF){
        if (string.length == 0) return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 11){
            return NO;
        }
    }
    return YES;
}
#pragma mark ====== Getter =======

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.tableFooterView = [UIView new];
        UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTouchInSide)];
        tableViewGesture.numberOfTapsRequired = 1;
        tableViewGesture.cancelsTouchesInView = NO;//是否取消点击处的其他action
        [_tableView addGestureRecognizer:tableViewGesture];
    }
    return _tableView;
}
- (UIButton *)determineBtn{
    if (!_determineBtn) {
        _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _determineBtn.frame = CGRectMake( 40, kScreenHeight -  95 , kScreenWidth - 80, 40);
        _determineBtn.backgroundColor = kSystemColor;
        _determineBtn.titleLabel.font = kBoldFontWithSize(16);
        _determineBtn.layer.cornerRadius = 5;
        [_determineBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_determineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_determineBtn addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _determineBtn;
}
- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = @[@"收货人：",@"手机号码：",@"所在地区：",@"详细地址："];
    }
    return _titleArray;
}
- (NSArray *)placeholderArray{
    if (!_placeholderArray) {
        _placeholderArray = @[@"请输入收货人姓名",@"请输入手机号码",@"请选择所在地区",@"请输入详细地址"];
    }
    return _placeholderArray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end
