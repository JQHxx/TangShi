//
//  TCAddFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddFriendViewController.h"
#import "TCMineButton.h"
#import "TimePickerView.h"

@interface TCAddFriendViewController ()<UITextFieldDelegate>{

    TCMineButton    *relationshipButton;
    TCMineButton    *phoneButton;
    TCMineButton    *messageButton;
    UISwitch        *messageSwitch;
    TimePickerView  *Picker;
    UITextField     *phoneField;
    BOOL             isBoolBack;
}

@property (nonatomic ,strong)UITableView *tableView;
@end

@implementation TCAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.bindingModel?@"编辑亲友":@"添加亲友";
    self.rigthTitleName = @"保存";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    isBoolBack = NO;
    [self initAddFriendView];
}
#pragma mark -- Custom Delegate
#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_Relationship) {
            isBoolBack = YES;
             NSArray *titleArray =[TCHelper sharedTCHelper].relationshipArr;
             NSString *index = [NSString stringWithFormat:@"%li",(long)[Picker.locatePicker selectedRowInComponent:0]];
            relationshipButton.contentLab.text= titleArray[[index integerValue]];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    isBoolBack=YES;
    if ([textField.text isEqualToString:@"请输入手机号码"]) {
        textField.text = @"";
    }
    if ((textField.text.length+string.length)<12) {
        return YES;
    }
    return NO;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [phoneField resignFirstResponder];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *body = [NSString stringWithFormat:@"id=%ld",self.bindingModel.family_id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kdeleteFriendRelatives body:body success:^(id json) {
            [TCHelper sharedTCHelper].isBindingFriend = YES;
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

    }
}
#pragma mark -- Event response
- (void)informationButton:(UIButton *)button{

    if (button.tag==100) {
        [phoneField resignFirstResponder];
        
        Picker =[[TimePickerView alloc]initWithTitle:@"" delegate:self];
        Picker.pickerStyle=PickerStyle_Relationship;
        [Picker pickerView:Picker.locatePicker didSelectRow:0 inComponent:0];
        [Picker showInView:self.view];
    }else if (button.tag==101){
        
    }else{
    
    }
}
#pragma mark -- 返回
- (void)leftButtonAction{
    if (!(messageSwitch.on ==self.bindingModel.is_start)) {
        isBoolBack = YES;
    }
    if (isBoolBack == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次添加编辑" preferredStyle:UIAlertControllerStyleAlert];
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
#pragma mark -- 保存
- (void)rightButtonAction{
    if (!(relationshipButton.contentLab.text.length>0)) {
        [self.view makeToast:@"请选择亲友关系" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (phoneField.text.length==0) {
        [self.view makeToast:@"请输入手机号码" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(phoneField.text)||phoneField.text.length != 11||![[phoneField.text substringToIndex:1] isEqualToString:@"1"]) {
        [self.view makeToast:@"手机号输入有误" duration:1.0 position:CSToastPositionCenter];
        return;

    }
    NSString *body = nil;
    if (self.bindingModel) {
 body = [NSString stringWithFormat:@"id=%ld&call=%@&mobile=%@&is_start=%d",(long)self.bindingModel.family_id,relationshipButton.contentLab.text,phoneField.text,messageSwitch.on==YES?1:0];
    } else {
        body = [NSString stringWithFormat:@"call=%@&mobile=%@&is_start=%d",relationshipButton.contentLab.text,phoneField.text,messageSwitch.on==YES?1:0];
    }
    kSelfWeak;
     [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddFriendRelatives body:body success:^(id json) {
        [TCHelper sharedTCHelper].isBindingFriend = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}
#pragma mark -- 删除亲友
- (void)deleteButton{
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确定删除该亲友吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
#pragma mark -- 初始化界面
- (void)initAddFriendView{
    
    NSDictionary *dict = @{@"title":@"关系",@"image":@"箭头_列表"};
    relationshipButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 48) dict:dict];
    relationshipButton.backgroundColor = [UIColor whiteColor];
    relationshipButton.tag = 100;
    [relationshipButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    relationshipButton.contentLab.text = @"请选择亲友关系";
    [self.view addSubview:relationshipButton];
    relationshipButton.contentLab.text = self.bindingModel?self.bindingModel.call:@"";

    dict = @{@"title":@"手机号码",@"image":@""};
    phoneButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, relationshipButton.bottom, kScreenWidth, 48) dict:dict];
    phoneButton.backgroundColor = [UIColor whiteColor];
    [phoneButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneButton];

    phoneField = [[UITextField alloc] initWithFrame:CGRectMake(kScreenWidth/2, 5, kScreenWidth/2-30, 38)];
    phoneField.text =self.bindingModel.family_mobile;
    phoneField.placeholder = @"请输入手机号码";
    phoneField.textAlignment = NSTextAlignmentRight;
    phoneField.textColor = [UIColor grayColor];
    phoneField.font = [UIFont systemFontOfSize:13];
    phoneField.delegate = self;
    phoneField.keyboardType = UIKeyboardTypeDecimalPad;
    [phoneButton addSubview:phoneField];
    
    dict = @{@"title":@"短信通知",@"image":@""};
    messageButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, phoneButton.bottom+30, kScreenWidth, 48) dict:dict];
    messageButton.backgroundColor = [UIColor whiteColor];
    messageButton.tag = 102;
    [messageButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageButton];
    
    messageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-60, 9, 48, 30)];
    messageSwitch.on = self.bindingModel.is_start;
    [messageButton addSubview:messageSwitch];
    
    UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, messageButton.bottom+5, kScreenWidth-20, 20)];
    porpmtLabel.text = @"当您的血糖值异常时，将免费发送短信通知此亲友（每天限6条）";
    porpmtLabel.textColor = [UIColor grayColor];
    porpmtLabel.numberOfLines = 0;
    porpmtLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:porpmtLabel];
     CGSize statusLabelSize=[porpmtLabel.text sizeWithLabelWidth:kScreenWidth-20 font:[UIFont systemFontOfSize:14]];
    porpmtLabel.frame = CGRectMake(10, messageButton.bottom+5, kScreenWidth-20, statusLabelSize.height+10);
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-265)/2, porpmtLabel.bottom+100, 261, 41)];
    deleteButton.backgroundColor = kbgBtnColor;
    deleteButton.layer.cornerRadius = 2;
    [deleteButton setTitle:@"删除亲友" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [deleteButton addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    deleteButton.hidden = self.bindingModel?NO:YES;
}
@end
