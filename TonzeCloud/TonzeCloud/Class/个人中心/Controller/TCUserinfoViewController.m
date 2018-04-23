//
//  TCUserinfoViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCUserinfoViewController.h"
#import "TCUserinfoTableViewCell.h"
#import "TCPasswordViewController.h"
#import "TCMineButton.h"
#import "AppDelegate.h"
#import "BackScrollView.h"
#import <Hyphenate/Hyphenate.h>
#import <UMMobClick/MobClick.h>
#import "TCLocialNotificationManager.h"
//#import "XLinkExportObject.h"
#import "TimePickerView.h"
//#import "HttpRequest.h"
#import "TCLookCodeViewController.h"

@interface TCUserinfoViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>{

    UIImagePickerController *ImgPicker;
    UIImageView     *headImage;
    UITextField     *userTextField;
    TCMineButton    *nicknameButton;
    TCMineButton    *sexButton;
    TCMineButton    *passwordButton;
    TCMineButton    *phoneButton;
    TimePickerView  *Picker;
    UITextField      *nameTextField;
}

@property (nonatomic,strong)BackScrollView    *backScrollView;

@end
@implementation TCUserinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = @"个人信息";
    
    [self initUserinfoView];
    [self requestData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-02" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-02" type:2];
#endif
}
#pragma mark--Delegate
#pragma mark UIImagePickerController
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerEditedImage];
    curImage=[self thumbnailWithImageWithoutScale:curImage size:CGSizeMake(160, 160)];
    NSData *imageData = UIImagePNGRepresentation(curImage);
    //将图片数据转化为64为加密字符串
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *body=[NSString stringWithFormat:@"photo=%@",encodeResult];
    __weak typeof(self) weakSelf=self;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kUserUploadPhoto body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSString *imgUrl=[result valueForKey:@"image_url"];
            [NSUserDefaultsInfos putKey:kUserPhoto andValue:imgUrl];
            headImage.image = curImage;
            [TCHelper sharedTCHelper].isUserReload=YES;
            [weakSelf.view makeToast:@"图片上传成功" duration:1.0 position:CSToastPositionCenter];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isFirstResponder]) {
        
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([[TCHelper sharedTCHelper] isNineKeyBoard:string] ){
            return YES;
        }else{
            if ([[TCHelper sharedTCHelper] hasEmoji:string] || [[TCHelper sharedTCHelper] strIsContainEmojiWithStr:string]){
                return NO;
            }
        }
    }
    if ([string isEqualToString:@"n"])
    {
        return YES;
    }
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    
    return YES;
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSInteger value=[Picker.locatePicker selectedRowInComponent:0]+1;
        kSelfWeak;
        NSString *infomationString = [NSString stringWithFormat:@"sex=%ld&doSubmit=1",(long)value];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:infomationString success:^(id json) {
            weakSelf.sex=value;
            sexButton.contentLab.text=value==1?@"男":@"女";
            [TCHelper sharedTCHelper].isUserReload=YES;
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark --Response Methods
#pragma mark 生成缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
#pragma mark -- 获取个人信息
- (void)requestData{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kGetUserInfo body:@"" success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,w_48",[result objectForKey:@"photo"]];
            [ headImage sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
            NSString *nickString = [result objectForKey:@"nick_name"];
            if (kIsEmptyString(nickString)) {
                NSString *phoneStr =[[NSUserDefaultsInfos getValueforKey:@"phoneNumber"] substringFromIndex:7];
                nicknameButton.contentLab.text = [NSString stringWithFormat:@"糖友_%@",phoneStr];
            }else{
                nicknameButton.contentLab.text = [result objectForKey:@"nick_name"];
            }
            phoneButton.contentLab.text =  [result objectForKey:@"mobile"];
            
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

    }];
}
#pragma mark 上传头像
-(void)ChangeUserImg{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *cameraButtonTitle = NSLocalizedString(@"拍照", nil);
    NSString *photoButtonTitle = NSLocalizedString(@"手机相册", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ImgPicker=[[UIImagePickerController alloc]init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) //判断设备相机是否可用
        {
            ImgPicker=[[UIImagePickerController alloc]init];
            ImgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            ImgPicker.delegate=self;
            ImgPicker.allowsEditing=YES;
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:ImgPicker animated:YES completion:nil];
        }
        else{
            UIAlertView *alert2=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你的相机不可用!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert2 show];
        }
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:photoButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ImgPicker=[[UIImagePickerController alloc]init];
        ImgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        ImgPicker.delegate=self;
        ImgPicker.allowsEditing=YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:ImgPicker animated:YES completion:nil];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 修改昵称
-(void)ChangeUserName{
    NSString *title = NSLocalizedString(@"修改昵称", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入新的昵称"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
        nameTextField=textField;
       
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
    }];
    kSelfWeak;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"昵称不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8){
            [weakSelf.view makeToast:@"昵称仅支持1-8个字符" duration:1.0 position:CSToastPositionCenter];
        }else{
            NSString *body = [NSString stringWithFormat:@"nickname=%@",alertController.textFields.firstObject.text];
            [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kChangeNickName body:body success:^(id json) {
                [weakSelf.view makeToast:@"修改昵称成功" duration:1.0 position:CSToastPositionCenter];
                nicknameButton.contentLab.text = alertController.textFields.firstObject.text;
                [NSUserDefaultsInfos putKey:kNickName andValue:nicknameButton.contentLab.text];
                
                /*
                //同步昵称到云智易
                NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
                NSString *access_token=[userDic objectForKey:@"access_token"];
                NSNumber *user_id=[userDic objectForKey:@"user_id"];
                [HttpRequest modifyAccountNickname:nicknameButton.contentLab.text withUserID:user_id withAccessToken:access_token didLoadData:^(id result, NSError *err) {
                    
                }];
                 */
                
                [TCHelper sharedTCHelper].isUserReload=YES;
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

            }];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma maek -- Event response
#pragma mark -- 修改个人资料
- (void)informationButton:(UIButton*)button{
    if (button.tag == 100) {
        [MobClick event:@"104_002001"];
        [self ChangeUserImg];
    }else if (button.tag == 101){
        [MobClick event:@"104_002002"];
        [self ChangeUserName];
    }else if (button.tag == 102){
        [MobClick event:@"104_002042"];
        
        Picker =[[TimePickerView alloc]initWithTitle:@"性别" delegate:self];
        Picker.pickerStyle=PickerStyle_Sex;
        [Picker.locatePicker selectRow:(self.sex-1) inComponent:0 animated:YES];
        [Picker showInView:self.view];
        [Picker pickerView:Picker.locatePicker didSelectRow:self.sex inComponent:0];
    
    }else if (button.tag == 103){
        [MobClick event:@"104_002003"];
        TCLookCodeViewController *lookCodeVC = [[TCLookCodeViewController alloc]init];
        lookCodeVC.isChangePassWord = YES;
        [self.navigationController pushViewController:lookCodeVC animated:YES];
        
//        TCPasswordViewController *passwordVC = [[TCPasswordViewController alloc] init];
//        [self.navigationController pushViewController:passwordVC animated:YES];
    }else {
        
    }
}
#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
- (void) initUserinfoView{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    _backScrollView.backgroundColor = [UIColor bgColor_Gray];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];

    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 58)];
    headView.backgroundColor=[UIColor whiteColor];
    [self.backScrollView addSubview:headView];
    
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, (58-30)/2, kScreenWidth/2-15, 30)];
    titleLab.textColor = [UIColor colorWithHexString:@"0x313131"];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.text = @"修改头像";
    [headView addSubview:titleLab];
    
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-20-58, (headView.height - 48)/2, 48, 48)];
    headImage.clipsToBounds=YES;
    headImage.layer.cornerRadius = 24;
    [headView addSubview:headImage];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, (58-20)/2, 20, 20)];
    imgView.image = [UIImage imageNamed:@"箭头_列表"];
    [headView addSubview:imgView];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, headView.height-1,kScreenWidth-5 , 1)];
    line.backgroundColor = kbgView;
    [headView addSubview:line];
    
    UIButton *headimgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 58)];
    headimgButton.tag = 100;
    [headimgButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:headimgButton];
    

    NSDictionary *dict1 = @{@"title":@"昵称",@"image":@"箭头_列表"};
    nicknameButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, headView.bottom+10, kScreenWidth, 48) dict:dict1];
    nicknameButton.backgroundColor = [UIColor whiteColor];
    nicknameButton.tag = 101;
    [nicknameButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:nicknameButton];
    
    NSDictionary *dict2 = @{@"title":@"性别",@"image":@"箭头_列表"};
    sexButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, nicknameButton.bottom, kScreenWidth, 48) dict:dict2];
    sexButton.backgroundColor = [UIColor whiteColor];
    sexButton.tag = 102;
    if (self.sex<3&&self.sex>0) {
        sexButton.contentLab.text=self.sex==1?@"男":@"女";
    }else{
        sexButton.contentLab.text=@"";
    }
    
    [sexButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:sexButton];
    
    NSDictionary *dict3 = @{@"title":@"修改密码",@"image":@"箭头_列表"};
    passwordButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, sexButton.bottom+10, kScreenWidth, 48) dict:dict3];
    passwordButton.backgroundColor = [UIColor whiteColor];
    passwordButton.tag = 103;
    [passwordButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:passwordButton];
    
    NSDictionary *dict4 = @{@"title":@"手机号"};
    phoneButton = [[TCMineButton alloc] initWithFrame:CGRectMake(0, passwordButton.bottom, kScreenWidth, 48) dict:dict4];
    phoneButton.backgroundColor = [UIColor whiteColor];
    phoneButton.tag = 104;
    [phoneButton addTarget:self action:@selector(informationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:phoneButton];
}
@end
