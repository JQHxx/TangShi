//
//  TCReleaseDynamicViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//


#import "TCReleaseDynamicViewController.h"
#import "TCRemindWithTopicCell.h"
#import "TCDynamicImageCell.h"
#import "TCChooseTopicViewController.h"
#import "TCRemindWhoSeeViewController.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "TZLocationManager.h"
#import "TCReleaseDynamicCell.h"
#import "TCLocation.h"
#import "TCUITextView.h"
#import "TCLocationInfoViewController.h"
#import "TCDynamicAddressCell.h"
// 头部视图高度
static  CGFloat const headHight = 150;

@interface TCReleaseDynamicViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIActionSheetDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,TCDynamicImageCellDelegate,TCUITextViewDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
{
    NSArray     *_remindAndTopicTitleArray;
    UILabel     *_countLabel;
    BOOL        _isSelectOriginalPhoto;
    NSString    *_topicStr;             /// 话题
    NSInteger   _topic_id;               /// 话题ID
    NSString    *_locatedAddress;       // 定位省市信息
    BOOL        _view_show;             // 是否跳转视图（解决输入@符合走两次代理）
    NSInteger   _textViewNumbeAdd;      // 文本输入框数字统计
    NSString    *_provinceStr;          // 省份
    NSString    *_cityStr;               // 市
    BOOL        _isCanRelease;
}
@property (nonatomic,strong) UITableView *releaseTab;
/// 动态文本输入框
@property (nonatomic ,strong) TCUITextView *dynamicTextView;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property (nonatomic ,strong) UILabel *countLabel;
/// 选择的图片数据
@property (nonatomic ,strong) NSMutableArray *selectedPhotos;
///
@property (nonatomic ,strong) NSMutableArray *selectedAssets;
/// @人相关数据
@property (nonatomic ,strong) NSMutableArray *atUserArray;
/// 判断所 @ 的人是否在文本中存在，删除判断
@property (nonatomic ,strong) NSMutableArray *nickNameArray;

@property (strong, nonatomic) CLLocation *location;
/// 动态文字可输入字数
@property (nonatomic, assign) NSInteger  dynamicTextNumber;

@end
@implementation TCReleaseDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"发布动态";
    self.rigthTitleName = @"发送";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _view_show = NO;
    _textViewNumbeAdd = 0;
    _provinceStr = @"";
    _cityStr = @"";
    _isCanRelease = YES;
    self.dynamicTextNumber = [TCHelper sharedTCHelper].dynamicTextNumber;
    if (!_isCanChooseTopic) {
        _topicStr = self.topicTiele;
        _topic_id = _topicId;
    }
    
    _remindAndTopicTitleArray = @[@"@ 提醒谁看",@"#  选择话题"];
    [self setReleaseDynamicVC];
    [self lookUserGagRemind];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-03" type:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-03" type:2];
}
#pragma mark ====== 布局 UI =======
- (void)setReleaseDynamicVC{
    [self.view addSubview:self.releaseTab];
}
#pragma mark ====== 动态输入区 =======
- (UIView *)tableHeaderView{
    UIView *heaerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, headHight)];
    heaerView.backgroundColor = [UIColor whiteColor];
    [heaerView addSubview:self.dynamicTextView];
    [heaerView addSubview:self.countLabel];
    return heaerView;
}
#pragma mark ====== 返回 =======
- (void)leftButtonAction{
    if (_dynamicTextView.text.length > 0 || _selectedPhotos.count > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次动态发布吗？" preferredStyle:UIAlertControllerStyleAlert];
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
#pragma mark ====== 发布 =======
- (void)rightButtonAction{
    self.rightBtnEnabled = NO;
    [[TCHelper sharedTCHelper] loginClick:@"008-03-01"];
    [MobClick event:@"105_002012"];
    [self.dynamicTextView resignFirstResponder];
    
    if (self.dynamicTextView.text.length == 0 && _selectedPhotos.count == 0 ) {
        [self.view makeToast:@"请分享点文字或图片" duration:1.0 position:CSToastPositionCenter];
        self.rightBtnEnabled = YES;
        return;
    }else if ([[self.dynamicTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0 && _selectedPhotos.count == 0){
        [self.view makeToast:@"请分享点文字或图片" duration:1.0 position:CSToastPositionCenter];
        self.rightBtnEnabled = YES;
        return;
    }else if (self.dynamicTextView.text.length > _dynamicTextNumber){
        [self.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)_dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
        self.rightBtnEnabled = YES;
        return;
    }
    // App版本信息
    NSString *version = [NSString getAppVersion];
    // 设备型号
    NSString *systemName = [UIDevice getSystemName];
    // 系统版本
    NSString *systemVersion = [UIDevice getSystemVersion];
   
    NSString *body = [NSString stringWithFormat:@"role_type=0&%@&app_version=%@&unit_type=%@&unit_system=%@",[self postDataSet],version,systemName,systemVersion];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KReleaseDynamic body:body success:^(id json) {
        [weakSelf.view makeToast:@"已成功！" duration:1.0 position:CSToastPositionCenter];
        [TCHelper sharedTCHelper].isNewDynamicRecord = YES;
        [TCHelper sharedTCHelper].isTaskListRecord = YES;
        [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
        [weakSelf getTaskPointsWithActionType:16 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {// 获取积分
            weakSelf.rightBtnEnabled = YES; 
            if (isBack || clickIndex == 1001) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    } failure:^(NSString *errorStr) {
        if (errorStr.length>=5) {
            NSString *error = [errorStr substringToIndex:5];
            if ([error isEqualToString:@"您已被禁言"]) {
                NSArray *newArray = [errorStr componentsSeparatedByString:@","];
                NSInteger time = [newArray[1] integerValue];
                NSString *gag_desc = newArray[2];
                [self IsgagAlert:time gag_desc:gag_desc];
            } else {
                weakSelf.rightBtnEnabled = YES;
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }
        }else{
            weakSelf.rightBtnEnabled = YES;
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }
    }];
}

#pragma mark ====== 请求数据处理 =======
- (NSString *)postDataSet{
    NSString *contentText = [NSString new];
    NSString *textStr;
    if (self.dynamicTextView.text.length == 0 ) {
        textStr = [NSString stringWithFormat:@"words=分享图片"];
    }else{
        NSString *emptStr =  [self.dynamicTextView.text substringFromIndex:self.dynamicTextView.text.length -1];
        NSRange range = [emptStr rangeOfString:@" "];
        if (range.location != NSNotFound) {//有空格
            self.dynamicTextView.text = [self.dynamicTextView.text substringToIndex:self.dynamicTextView.text.length - 1];
            NSString *dynamicStr = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.dynamicTextView.text, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
            textStr = [NSString stringWithFormat:@"words=%@",dynamicStr];
        }else {//没有空格
            NSString *dynamicStr = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.dynamicTextView.text, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
            textStr = [NSString stringWithFormat:@"words=%@",dynamicStr];
        }
    }
    contentText = [contentText stringByAppendingString:textStr];
    if (!kIsEmptyString(_provinceStr)) {
        NSString *addressStr = [NSString stringWithFormat:@"&province=%@&city=%@",_provinceStr,_cityStr];
        contentText = [contentText stringByAppendingString:addressStr];
    }
    if (!kIsEmptyString(_topicStr)) {
        NSString *topicStr= [NSString stringWithFormat:@"&topic=%@&topic_id=%ld",_topicStr,_topic_id];
        contentText = [contentText stringByAppendingString:topicStr];
    }
    // 判断@的数据是否删除
    NSMutableArray *atArray = [NSMutableArray array];
    NSMutableArray *atNameArray = [NSMutableArray array]; // @人踢重复
    for (NSInteger i = 0; i < self.atUserArray.count; i++) {
        if ([self.dynamicTextView.text rangeOfString:self.nickNameArray[i]].location != NSNotFound  && ![atNameArray containsObject:self.nickNameArray[i]]) {
            [atArray addObject:self.atUserArray[i]];
            [atNameArray addObject:self.nickNameArray[i]];
        }
    }
    if (atArray.count > 0) {
        NSString *atStr = [[TCHttpRequest sharedTCHttpRequest] getValueWithParams:atArray];
        NSString  *atUserStr = [NSString stringWithFormat:@"&at_user_id=%@",atStr];
        contentText = [contentText stringByAppendingString:atUserStr];
    }
    if (_selectedPhotos.count > 0) {
        NSString *params=[NSString stringWithFormat:@"&image_arr=%@",[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:[self imageDataProcessingWithImgArray:_selectedPhotos]]];
        contentText = [contentText stringByAppendingString:params];
    }
    MyLog(@"%@",contentText);
    return  contentText;
}
#pragma mark -- 查看用户禁言状态
- (void)lookUserGagRemind{
    NSString *body = [NSString stringWithFormat:@"role_type=0"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KUserGagRemind body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSInteger isgag = [[result objectForKey:@"is_gag"] integerValue];
            if (isgag==1) {
                [self IsgagAlert:[[result objectForKey:@"gag_time"] integerValue] gag_desc:[result objectForKey:@"gag_desc"]];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark ====== 图片加密处理 =======
- (NSMutableArray *)imageDataProcessingWithImgArray:(NSMutableArray *)imgArray{
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSInteger i = 0; i < imgArray.count; i++) {
        NSData *imageData = UIImagePNGRepresentation(imgArray[i]);
        //将图片数据转化为64为加密字符串
        NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        [photoArray addObject:encodeResult];
    }
    return photoArray;
}
#pragma mark ====== UIScrollViewDelegate =======
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]
    ;
}
#pragma mark ====== 滑动视图键盘降落 =======
-(BOOL)resignFirstResponder
{
    [self.dynamicTextView resignFirstResponder];
    return YES;
}
#pragma mark ====== UITableViewDelegate,UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        case 2:
        {
            return 1;
        }break;
        case 1:
        {
            return 2;
        }break;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger  photoCellHight =(kScreenWidth - 40)/4;
    switch (indexPath.section) {
        case 0:
        {
            CGFloat cellHight  = _selectedPhotos.count / 4  * photoCellHight + photoCellHight + 16;
            return cellHight;
        }break;
        case 1:
        case 2:
        {
            return 40;
        }break;
        default:
            break;
    }
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return 7;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *remindWithTopicIdentifier  = @"remindWithTopicIdentifier";
    static NSString *dynamincImgCellIdentifier  = @"dynamincImgCellIdentifier";
    static NSString *addressIdentifier  = @"addressIdentifier";
    switch (indexPath.section) {
        case 0:
        {// 图片
            TCDynamicImageCell *dynamincImgCell = [[TCDynamicImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dynamincImgCellIdentifier];
            dynamincImgCell.delegate = self;
            dynamincImgCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [dynamincImgCell cellWithImageArray:self.selectedPhotos selectedAssets:_selectedAssets];
            
            return dynamincImgCell;
        }break;
        case 1:
        {//  @ 人 && 话题
            TCRemindWithTopicCell *remindWithTopicCell =[[TCRemindWithTopicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remindWithTopicIdentifier];
            remindWithTopicCell.titleLab.text = _remindAndTopicTitleArray[indexPath.row];
            if (indexPath.row == 1  && !kIsEmptyString(_topicStr)) {
                if (!kIsEmptyString(_topicTiele)) {
                    remindWithTopicCell.arrowImg.hidden = YES;
                    remindWithTopicCell.topicLab.frame = CGRectMake(120, (40 - 20)/2, kScreenWidth - 140, 20);
                }
                remindWithTopicCell.topicLab.text = [NSString stringWithFormat:@"%@", _topicStr];
            }
            return remindWithTopicCell;
        }break;
        case 2:
        {
            TCDynamicAddressCell *addressCell =[[TCDynamicAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressIdentifier];
            addressCell.iconImg.image = !kIsEmptyString(_provinceStr) ? [UIImage imageNamed:@"address"] : [UIImage imageNamed:@"no_address"];
            addressCell.titleLab.text = kIsEmptyString(_provinceStr) ? @"所在地区" :[NSString stringWithFormat:@"%@ %@",_provinceStr,_cityStr] ;
            return addressCell;
        }break;
        default:
        {
            UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            return cell;
        }
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   [self.dynamicTextView resignFirstResponder];
    switch (indexPath.section) {
        case 1:
        {// 图片
            if (indexPath.row == 0) {
                [[TCHelper sharedTCHelper] loginClick:@"008-03-05"];
                [MobClick event:@"105_002016"];
                TCRemindWhoSeeViewController *remindWhoSeeVC = [TCRemindWhoSeeViewController new];
                kSelfWeak;
                remindWhoSeeVC.remindUsersBlock = ^(NSString *userName, NSInteger userId,NSInteger role_type_ed) {
                    if (weakSelf.dynamicTextView.text.length + userName.length + 1 <= weakSelf.dynamicTextNumber) {
                        NSDictionary *userDic = [[NSDictionary alloc]initWithObjects:@[userName,[NSNumber numberWithInteger:userId],[NSNumber numberWithInteger:role_type_ed]] forKeys:@[@"nick_name",@"user_id",@"role_type_ed"]];
                        [weakSelf.atUserArray addObject:userDic];
                        [weakSelf setTextViewAttributedStrings:[NSString stringWithFormat:@"%@ ",userName]];
                        [weakSelf.nickNameArray addObject:userName];
                    }else{
                        [weakSelf.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)weakSelf.dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
                    }
                };
                [weakSelf.navigationController pushViewController:remindWhoSeeVC animated:YES];
            }else{
                // 判断是否为话题进入
                if (_isCanChooseTopic) {
                    [[TCHelper sharedTCHelper] loginClick:@"008-03-06"];
                    [MobClick event:@"105_002017"];
                    TCChooseTopicViewController *chooseTopVC = [TCChooseTopicViewController new];
                    chooseTopVC.topicStr = _topicStr;
                    kSelfWeak;
                    chooseTopVC.topicTitleBlock = ^(NSString *tiptitleStr,NSInteger topicId) {
                        _topicStr = tiptitleStr;
                        _topic_id = topicId;
                        NSIndexPath *indexP=[NSIndexPath indexPathForRow:1 inSection:1];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
                    };
                    [weakSelf.navigationController pushViewController:chooseTopVC animated:YES];
                }
            }
        }break;
        case 2:
        {
            [[TCHelper sharedTCHelper] loginClick:@"008-03-07"];
            [MobClick event:@"105_002018"];
            kSelfWeak;
            TCLocationInfoViewController *locationVC = [TCLocationInfoViewController new];
            locationVC.address = _provinceStr;
            locationVC.adressBlock = ^(NSString *proStr, NSString *cityStr) {
                _provinceStr  = proStr;
                _cityStr = cityStr;
                
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];  //你需要更新的组数中的cell
                [weakSelf.releaseTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:locationVC animated:YES];
        }break;
        default:
            break;
    }
}
#pragma mark ====== 设置特殊文本 =======
- (void)setTextViewAttributedStrings:(NSString *)str{
    [self.dynamicTextView becomeFirstResponder];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
    [self.dynamicTextView insterSpecialTextAndGetSelectedRange:attrStr selectedRange:self.dynamicTextView.selectedRange text:self.dynamicTextView.attributedText];
}
#pragma mark ====== TCDynamicImageCellDelegate =======
#pragma mark ======== 图片预览和添加图片

- (void)didSelectImgeAction:(NSInteger)number indexRow:(NSInteger)indexRow{
    [self.dynamicTextView resignFirstResponder];
    [MobClick event:@"105_002014"];
    if (number == 1000) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [sheet showInView:self.view];
    }else{
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc]initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexRow];
        imagePickerVC.allowPickingVideo = NO;
        imagePickerVC.allowPickingGif = NO;
        imagePickerVC.allowPickingOriginalPhoto = NO;
        imagePickerVC.allowTakePicture = NO;
        imagePickerVC.maxImagesCount = 9;
        imagePickerVC.allowPreview = YES;
        // imagePickerVC.isSelectOriginalPhoto = _isSelectOriginalPhoto;
        kSelfWeak;
        [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            weakSelf.selectedPhotos = [NSMutableArray arrayWithArray:photos];
            weakSelf.selectedAssets = [NSMutableArray arrayWithArray:assets];
            _isSelectOriginalPhoto = isSelectOriginalPhoto;
            [weakSelf.releaseTab reloadData];
        }];
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}
// -- 删除图片、刷新数据
- (void)reloadTableViewWithRemovePhotoArrayIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:@"008-03-04"];
    [MobClick event:@"105_002015"];
    [_selectedPhotos removeObjectAtIndex:index];
    [_selectedAssets removeObjectAtIndex:index];
    [_releaseTab reloadData];
}
#pragma mark ====== UIActionSheetDelegate =======
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.dynamicTextView resignFirstResponder];
    [[TCHelper sharedTCHelper] loginClick:@"008-03-03"];
    if (buttonIndex == 0) {
        if (self.selectedPhotos.count == 9) {
            [self.view makeToast:@"图片最多上传9张" duration:1.0 position:CSToastPositionCenter];
        }else{
            [self takePhoto];
        }
    }else if(buttonIndex ==1){
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:9 columnNumber:4 delegate:self];
        imagePickerVC.allowPickingVideo = NO;
        imagePickerVC.allowPickingGif = NO;
        imagePickerVC.allowPickingOriginalPhoto = NO;
        imagePickerVC.selectedAssets = _selectedAssets;
        imagePickerVC.sortAscendingByModificationDate = NO;
        imagePickerVC.allowTakePicture = NO; // 相册显示拍照
        imagePickerVC.photoWidth = 500;  // 图片的宽度
        imagePickerVC.naviBgColor = kSystemColor;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}
#pragma mark ====== 调用相机 =======
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        weakSelf.location = location;
    } failureBlock:^(NSError *error) {
        weakSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        MyLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}
#pragma mark  ===   UIImagePickerController ===
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        BOOL iscropRadius = YES;
                        if (iscropRadius) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = NO;
                            imagePicker.cropRect = CGRectMake(0, (kScreenHeight - kScreenWidth)/2, kScreenWidth, kScreenWidth);
                            [self presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark ====== 拍照相片回调  =======
- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    
    [self.selectedAssets addObject:asset];
    [self.selectedPhotos addObject:image];
    [self.releaseTab reloadData];
}
#pragma mark ====== TZImagePickerControllerDelegate =======

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    MyLog(@"---- 用户点击取消");
}
#pragma mark ====== 相册图片回调 =======

-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    self.selectedPhotos = [NSMutableArray arrayWithArray:photos];
    self.selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    [_releaseTab reloadData];
}
#pragma mark ====== TCUITextViewDelegate =======
-(void)textViewDidBeginEditing:(TCUITextView *)textView{
    [MobClick event:@"105_002013"];
}
-(BOOL)textView:(TCUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (_dynamicTextView.text.length+text.length > _dynamicTextNumber) {
        [self.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)_dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}
- (void)textViewDidChangeSelection:(TCUITextView *)textView{
    
    NSString *tString = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)textView.text.length,(long)_dynamicTextNumber];
    _countLabel.text = tString;
}
#pragma mark ====== @ 他人判断 =======
- (void)textViewDidChange:(TCUITextView *)textView{
    if ([textView.text length]!= 0) {
        NSString *tString = [NSString stringWithFormat:@"%ld/%ld",(long)textView.text.length,_dynamicTextNumber];
        _countLabel.text = tString;
    }
    if (textView.text.length >= _textViewNumbeAdd) {
        // 输入文本判断
        NSString *textStr = [textView.text substringWithRange:NSMakeRange(textView.text.length - 1, 1)];
        if ([textStr isEqualToString:@"@"] ){//&& _view_show == NO
            textView.text = [textView.text substringToIndex:textView.text.length - 1];
            
            TCRemindWhoSeeViewController *remindWhoSeeVC = [TCRemindWhoSeeViewController new];
            kSelfWeak;
            remindWhoSeeVC.remindUsersBlock = ^(NSString *userName, NSInteger userId,NSInteger role_type_ed) {
                if (weakSelf.dynamicTextView.text.length + userName.length + 1 <= _dynamicTextNumber) {
                    [weakSelf setTextViewAttributedStrings:[NSString stringWithFormat:@"%@ ",userName]];
                }else{
                    [weakSelf.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)weakSelf.dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
                }
                _view_show = NO;
            };
            _view_show = YES;
            [self.navigationController pushViewController:remindWhoSeeVC animated:YES];
        }
    }
    _textViewNumbeAdd = textView.text.length;
}
#pragma mark -- 禁言
- (void)IsgagAlert:(NSInteger)time gag_desc:(NSString *)gag_desc{
    
    NSString *timeStr = [[TCHelper sharedTCHelper] dateGagtimeToRequiredString:time];
    NSString *title = [NSString stringWithFormat:@"因%@，已被禁言，离解禁还剩%@",gag_desc,timeStr];
    
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1, gag_desc.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, title.length)];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"禁言" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController setValue:alertControllerStr forKey:@"attributedMessage"];

    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ====== Getter =======
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}
- (UITableView *)releaseTab{
    if (!_releaseTab) {
        _releaseTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _releaseTab.delegate = self;
        _releaseTab.dataSource = self;
        _releaseTab.backgroundColor = [UIColor bgColor_Gray];
        _releaseTab.tableHeaderView = [self tableHeaderView];
        _releaseTab.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _releaseTab;
}
- (TCUITextView *)dynamicTextView{
    if (!_dynamicTextView) {
        _dynamicTextView = [[TCUITextView alloc]initWithFrame:CGRectMake(18, 10, kScreenWidth - 35, headHight - 40)];
        _dynamicTextView.placeHoldString = @"分享你的控糖生活...";
        _dynamicTextView.placeHoldTextFont = kFontWithSize(16);
        _dynamicTextView.placeHoldTextColor = UIColorFromRGB(0xaaaaaa);
        _dynamicTextView.myDelegate = self;
        _dynamicTextView.specialTextColor = kSystemColor;
        _dynamicTextView.font = kFontWithSize(16);
        _dynamicTextView.textColor = UIColorFromRGB(0x959595);
    }
    return _dynamicTextView;
}
- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 120, headHight - 29, 100, 15)];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.font = kFontWithSize(13);
        _countLabel.text = [NSString stringWithFormat:@"0/%ld",(long)_dynamicTextNumber];
        _countLabel.textColor = UIColorFromRGB(0x959595);
    }
    return _countLabel;
}
- (NSMutableArray *)selectedAssets{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (NSMutableArray *)selectedPhotos{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}
- (NSMutableArray *)atUserArray{
    if (!_atUserArray) {
        _atUserArray = [NSMutableArray array];
    }
    return _atUserArray;
}
- (NSMutableArray *)nickNameArray{
    if (!_nickNameArray) {
        _nickNameArray = [NSMutableArray array];
    }
    return _nickNameArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- NSNotification
#pragma mark 键盘关闭
-(void)keyboardWillHideAction:(NSNotification *)notifi{
    [[TCHelper sharedTCHelper] loginClick:@"008-03-02"];
}


@end
