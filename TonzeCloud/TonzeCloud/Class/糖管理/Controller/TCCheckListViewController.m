//
//  TCCheckListViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCheckListViewController.h"
#import "TCPertainView.h"
#import "ImageViewController.h"

@interface TCCheckListViewController ()<UITextViewDelegate,TCPertainDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UITextView     *remarkTextView;
    UILabel        *textLabel;
    UILabel        *countLabel;
    NSMutableArray   *imgArray;
    NSMutableArray   *imageStrArray;    //本地图片二进制数组
    NSMutableArray   *imageIDArray;     //后台获取的图片ID数组
    NSMutableArray   *tempImageIdArr;   //删除的图片ID数组
    UIImagePickerController *ImgPicker;
    UIScrollView            *backGround;
    BOOL           isEditCheckList;
}
@property (nonatomic,strong)UIScrollView  *rootScrollView;
@property (nonatomic,strong)TCPertainView *pertainView;
@property (nonatomic,strong)UIView        *remarkView;
@property (nonatomic ,strong)UIButton     *saveCheckListButton;
@end

@implementation TCCheckListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.checkListModel?@"编辑检查单":@"添加检查单";
    self.rightImageName =self.checkListModel?@"ic_n_del":@"";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    imgArray      = [[NSMutableArray alloc] init];
    imageStrArray = [[NSMutableArray alloc] init];
    imageIDArray  = [[NSMutableArray alloc] init];
    tempImageIdArr= [[NSMutableArray alloc] init];
    
    [self initPertainView];
    [self parseCheckListImageInfo];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark--Delegate
#pragma mark UIImagePickerController
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
     UIImage *curImage=[info objectForKey:UIImagePickerControllerEditedImage];
 //   curImage=[self thumbnailWithImageWithoutScale:curImage size:CGSizeMake(kScreenWidth, kScreenWidth)];
    NSData *imageData = UIImagePNGRepresentation(curImage);
    
    //以当前时间戳作为临时image_id
    NSString *currentDateStr=[[TCHelper sharedTCHelper] getCurrentDateTimeSecond];
    NSInteger dateTmsp=[[TCHelper sharedTCHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm:ss"];
    NSString *tempImageID=[NSString stringWithFormat:@"%ld",(long)dateTmsp];
    
    NSDictionary *tempDict=[NSDictionary dictionaryWithObjectsAndKeys:tempImageID,@"image_id",@"",@"image_url",@(1),@"type",curImage,@"image",nil];
    [imgArray addObject:tempDict];
    self.pertainView.imageArray = imgArray;

    //将图片数据转化为64为加密字符串
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSDictionary *encodeDict=[NSDictionary dictionaryWithObjectsAndKeys:tempImageID,@"image_id",encodeResult,@"image_encode",nil];
    [imageStrArray addObject:encodeDict];
    
    isEditCheckList=YES;
}
#pragma mark --UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    isEditCheckList = YES;
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
    if (buttonIndex==1) {
        NSString *body = [NSString stringWithFormat:@"es_id=%ld",self.checkListModel.es_id];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kExaminationSheetDelete body:body success:^(id json) {
            [TCHelper sharedTCHelper].isRecordsReload = YES;
            [TCHelper sharedTCHelper].isExaminationRecord = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}


#pragma mark -- TCPertainDelegate
#pragma mark  查看图片
- (void)pertainViewTapActionForIndex:(NSInteger)index{
    ImageViewController *imageVc = [[ImageViewController alloc] init];
    NSMutableArray *imgArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in imgArray) {
        [imgArr addObject:[dict objectForKey:@"image_url"]];
    }
    imageVc.imageArray = imgArr;
    imageVc.index = index;
    CATransition *animation = [CATransition animation];
    animation.duration = 0.4;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    //    animation.type = @"pageCurl";//翻页效果
    animation.type = kCATransitionFade;
    //    animation.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    [self presentViewController:imageVc animated:NO completion:^{
        
    }];
}

#pragma mark 删除图片
- (void)pertainViewDeleteImageForIndex:(NSInteger)index{
    [MobClick event:@"102_002052"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除图片？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict=imgArray[index];
        NSString *imgeID=dict[@"image_id"];
        
        if ([imageIDArray containsObject:imgeID]) {   //如果删除的是从后台获取的图片
            [tempImageIdArr addObject:imgeID];
        }
        
        //匹配对应image_id
        NSDictionary *aDict=[NSDictionary new];
        for (NSDictionary *tempDict in imageStrArray) {
            NSString *tempImageID=tempDict[@"image_id"];
            if ([tempImageID isEqualToString:imgeID]) {
                aDict=tempDict;
            }
        }
        [imageStrArray removeObject:aDict];     //删除对应的图片二进制
        [imgArray removeObjectAtIndex:index];
        self.pertainView.imageArray = imgArray;
        
        isEditCheckList=YES;
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark 添加图片
-(void)pertainViewAddImageAction{
    [MobClick event:@"102_002051"];
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


#pragma mark -- Event Response
#pragma mark  保存检查单
- (void)saveCheckListAction:(UIButton *)button{
    [MobClick event:@"102_002053"];
    NSMutableArray *tempStrArray=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in imageStrArray) {
        [tempStrArray addObject:dict[@"image_encode"]];
    }
    
    NSString *params=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:tempStrArray];
    NSString *idParams=[[TCHttpRequest sharedTCHttpRequest] getValueWithParams:tempImageIdArr];
    NSString *body = nil;
    NSString *url = nil;
    if (self.checkListModel) {
        body=[NSString stringWithFormat:@"image_arr=%@&remark=%@&es_id=%ld&doSubmit=1&image_id=%@",params,remarkTextView.text,self.checkListModel.es_id,idParams];
        url =kExaminationSheetUpdata;
    } else {
        body=[NSString stringWithFormat:@"image_arr=%@&remark=%@",params,remarkTextView.text];
        url =kAddExaminationSheet;
    }
    __weak typeof(self) weakSelf=self;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            [TCHelper sharedTCHelper].isTaskListRecord = YES;
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
            [TCHelper sharedTCHelper].isRecordsReload=YES;
            [TCHelper sharedTCHelper].isExaminationRecord=YES;
            if (!self.checkListModel) {
                [weakSelf getTaskPointsWithActionType:11 isTaskList:_isTaskListLogin taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
                    if (isBack || clickIndex == 1001) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }]; // 获取积分
            }else{
                 [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];

}

#pragma mark  删除保险单纪录
- (void)rightButtonAction{
    [MobClick event:@"102_002054"];
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确认删除记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];
}

#pragma mark 返回事件
-(void)leftButtonAction{
    if (isEditCheckList) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确定放弃此次记录编辑吗" preferredStyle:UIAlertControllerStyleAlert];
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


#pragma mark -- Private Methods
#pragma mark  初始化界面
- (void)initPertainView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.pertainView];
    [self.rootScrollView addSubview:self.remarkView];
    
    [self.view addSubview:self.saveCheckListButton];

    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.remarkView.bottom+10);
}

#pragma mark 获取图片信息
-(void)parseCheckListImageInfo{
    if (self.checkListModel) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSDictionary *dict in self.checkListModel.image) {
            NSDictionary *tempDict=[NSDictionary dictionaryWithObjectsAndKeys:dict[@"image_id"],@"image_id",dict[@"image_url"],@"image_url",@(0),@"type",[UIImage imageNamed:@""],@"image",nil];
            [tempArr addObject:tempDict];
            [imageIDArray addObject:dict[@"image_id"]];    //把后台获取的图片ID添加到临时数组
        }
        imgArray = tempArr;
    }
    self.pertainView.imageArray = imgArray;
}


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

#pragma mark -- setter or getter
#pragma mark 根滑动视图
-(UIScrollView *)rootScrollView{
    if (_rootScrollView==nil) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight -50)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark -- 检查报告
- (TCPertainView *)pertainView{
    if (_pertainView==nil) {
        _pertainView = [[TCPertainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/4+45)];
        _pertainView.pertainDelegate = self;
        
    }
    return _pertainView;
}

#pragma mark -- 备注
- (UIView *)remarkView{
    if (_remarkView==nil) {
        _remarkView = [[UIView alloc] initWithFrame:CGRectMake(0,_pertainView.bottom+20, kScreenWidth, 150)];
        _remarkView.backgroundColor = [UIColor whiteColor];
        
        remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 130)];
        remarkTextView.font = [UIFont systemFontOfSize:14];
        remarkTextView.delegate=self;
        remarkTextView.text = self.checkListModel?self.checkListModel.remark:@"";
        [_remarkView addSubview:remarkTextView];
        
        textLabel=[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, kScreenWidth-30.0, 30.0)];
        textLabel.text=@"请填写备注（选填）";
        textLabel.text= remarkTextView.text.length>0?@"":@"请填写备注（选填）";
        textLabel.numberOfLines=0;
        textLabel.textColor=[UIColor lightGrayColor];
        textLabel.font=[UIFont systemFontOfSize:14.0];
        [remarkTextView addSubview:textLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(remarkTextView.width-80, remarkTextView.height-15, 70, 10)];
        NSInteger remarkNum = self.checkListModel ? self.checkListModel.remark.length : 0;
        NSString *remarKStr = [NSString stringWithFormat:@"%ld/100",remarkNum];
        countLabel.text = self.checkListModel ? remarKStr : @"0/100";
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.font = [UIFont systemFontOfSize:12];
        [remarkTextView addSubview:countLabel];
    }
    return _remarkView;
}

#pragma mark -- 保存
-(UIButton *)saveCheckListButton{
    if (_saveCheckListButton==nil) {
        _saveCheckListButton=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-KTabbarSafeBottomMargin-50, kScreenWidth, 50)];
        [_saveCheckListButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveCheckListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveCheckListButton.backgroundColor=kSystemColor;
        [_saveCheckListButton addTarget:self action:@selector(saveCheckListAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveCheckListButton;
}

@end
