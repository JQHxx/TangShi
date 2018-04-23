//
//  TCInstallViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInstallViewController.h"
#import "TCIdeaBackViewController.h"
#import "TCAboutUsViewController.h"
#import "TCInstallTableViewCell.h"
#import "TCFastLoginViewController.h"
#import "TCBasewebViewController.h"
#import "TCNewsNotificationViewController.h"
#import "TCMineButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Hyphenate/Hyphenate.h>
#import "XLinkExportObject.h"

@interface TCInstallViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

//  红点标记
@property (nonatomic,strong)UILabel              *badgeLbl;
@end
@implementation TCInstallViewController{
    
    UITableView *installTabView;
    NSArray         *_titleArray;
    NSArray         *_imagesArray;
    NSArray         *_classNames;
    BOOL              isLogin;
    BOOL              isFeedbackNewMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"设置";
    
    _titleArray=@[@[@"清除缓存"],@[@"消息通知"],@[@"在线客服",@"意见反馈",@"评价一下",@"关于我们"],@[@""]];
    [self initInstallView];
    isFeedbackNewMessage = YES;
    
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (isLogin) {
        [self loadNewBackMessage];
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-10" type:2];
#endif
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  isLogin?_titleArray.count:_titleArray.count-1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [_titleArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCInstallTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        float Value = [self filePath];
        NSString *dataValueStr = nil;
        if (Value>100) {
            dataValueStr = [NSString stringWithFormat:@"大于%.2fMB",Value];
        }else if (Value<1){
            dataValueStr = [NSString stringWithFormat:@"%.fKB",Value*1024];

        }else {
            dataValueStr = [NSString stringWithFormat:@"%.2fMB",Value];
        }
        cell.textLabel.text=_titleArray[indexPath.section][indexPath.row];
        
        cell.detailTextLabel.text=dataValueStr;
    } else if(indexPath.section==1||indexPath.section==2){
        if (indexPath.section==2&&indexPath.row==1) {
            [cell.contentView addSubview:self.badgeLbl];
            self.badgeLbl.hidden=isFeedbackNewMessage;
        }
       cell.textLabel.text=_titleArray[indexPath.section][indexPath.row];
    }else{
        cell.accessoryType=UITableViewCellAccessoryNone;
        
        UIButton *leaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        [leaveBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [leaveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [leaveBtn addTarget:self action:@selector(leaveButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:leaveBtn];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"003-10-01"];
#endif
        [MobClick event:@"104_002033"];
        float dataValue = [self filePath];
        NSString *dataValueStr = [NSString stringWithFormat:@"%.2fMB",dataValue];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否清除缓存" message:dataValueStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag=99;
        [alertView show];
    }else if (indexPath.section==1){
        [MobClick event:@"104_002040"];
        if (isLogin) {
            TCNewsNotificationViewController *newsNotifiVC=[[TCNewsNotificationViewController alloc] init];
            [self.navigationController pushViewController:newsNotifiVC animated:YES];
        }else{
            [self loginBtn];
        }
    }else {
        if (indexPath.row == 0) {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"003-08"];
#endif
            [MobClick event:@"104_002036"];
            NSString *urlString = [NSString stringWithFormat:@"http://www.360tj.com/ext/nutrition.html"];
            TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
            webVC.type=BaseWebViewTypeOnlineService;
            webVC.titleText=@"在线客服";
            webVC.urlStr=urlString;
            [self.navigationController pushViewController:webVC animated:YES];
        }else if (indexPath.row==1){
            [MobClick event:@"104_002037"];

            if (isLogin) {
                TCIdeaBackViewController *tcIdeaVC = [[TCIdeaBackViewController alloc] init];
                [self.navigationController pushViewController:tcIdeaVC animated:YES];
            }else{
                [self loginBtn];
            }        
        }else if (indexPath.row==2){
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"003-09"];
#endif
            [MobClick event:@"104_002038"];
            
            NSString *itunesUrl = @"itms-apps://itunes.apple.com/cn/app/id1218105131?mt=8&action=write-review";
            NSURL * url = [NSURL URLWithString:itunesUrl];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }else{
                MyLog(@"can not open");
            }
            
          // NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",@"1218105131"];
        }else{
            [MobClick event:@"104_002039"];

            TCAboutUsViewController *tcAboutVC = [[TCAboutUsViewController alloc] init];
            [self.navigationController pushViewController:tcAboutVC animated:YES];
        }
     }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0||section==1) {
        return 10;
    }else if (section==2){
        return isLogin?20:0.01;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CGFloat    footerViewH;
    if(section==0||section==1) {
        footerViewH = 10;
    }else if (section==2){
        footerViewH = isLogin? 20:0.01;
    }else{
        footerViewH = 0.01;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, footerViewH)];
    return footerView;
}

#pragma mark -- 退出登录
- (void)leaveButton{
    [MobClick event:@"104_002041"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您确定要退出登录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kLoginOutAPI body:@"" success:^(id json) {
            [NSUserDefaultsInfos removeObjectForKey:USER_DIC];
            [NSUserDefaultsInfos removeObjectForKey:USER_ID];
            
            [[XLinkExportObject sharedObject] logout]; //退出xlink
            
            [[TCHelper sharedTCHelper] loginOutForClearData];
            [TCHelper sharedTCHelper].isLogin=YES;
            // 处理糖友圈角标清除
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendGroupBadgeNumberNotification" object:[NSString stringWithFormat:@"%d",0]];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 获取最新反馈信息
- (void)loadNewBackMessage{
    
    NSString *body = [NSString stringWithFormat:@"role_type=0"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:KFeedbackNewMessage body:body success:^(id json) {
        NSInteger result = [[json objectForKey:@"result"] integerValue];
        isFeedbackNewMessage = result==0;
        [installTabView reloadData];
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 99) {
        if (buttonIndex == 1) {
            [self clearFile];
        }
    }
}

#pragma mark -- event response
#pragma mark  登录
- (void)loginBtn{
    [self fastLoginAction];
}

#pragma mark -- 清除缓存
// 显示缓存大小
-( float )filePath
{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    return [ self folderSizeAtPath :cachPath];
}
#pragma mark -- 计算单个文件的大小
- ( long long ) fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize ];
    }
    return 0 ;
}
#pragma mark -- 计算文件大小
- ( float ) folderSizeAtPath:( NSString *) folderPath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if (![manager fileExistsAtPath :folderPath]) return 0 ;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
    NSString * fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [ self fileSizeAtPath :fileAbsolutePath];
    }
    return folderSize/( 1024.0 * 1024.0 );
}

#pragma mark -- 清理缓存
- (void)clearFile{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    NSArray * files = [[ NSFileManager defaultManager ] subpathsAtPath :cachPath];
    NSLog ( @"cachpath = %@" , cachPath);
    for ( NSString * p in files) {
        NSError * error = nil ;
        NSString * path = [cachPath stringByAppendingPathComponent :p];
        if ([[ NSFileManager defaultManager ] fileExistsAtPath :path]) {
            [[ NSFileManager defaultManager ] removeItemAtPath :path error :&error];
        }
    }
    [ self performSelectorOnMainThread : @selector (clearCachSuccess) withObject : nil waitUntilDone : YES ];
    
}
#pragma mark -- 清除成功
-(void)clearCachSuccess
{
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"清除缓存成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [successAlert show];
    NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:0];//刷新
    [installTabView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
- (void) initInstallView{
    
    installTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth,kRootViewHeight) style:UITableViewStylePlain];
    installTabView.backgroundColor=[UIColor bgColor_Gray];
    installTabView.delegate=self;
    installTabView.dataSource=self;
    installTabView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:installTabView];
}
#pragma mark 红色标记
-(UILabel *)badgeLbl{
    if (_badgeLbl==nil) {
        _badgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-40, 17, 10, 10)];
        _badgeLbl.backgroundColor=[UIColor redColor];
        _badgeLbl.layer.cornerRadius=5;
        _badgeLbl.clipsToBounds=YES;
        _badgeLbl.textColor=[UIColor whiteColor];
        _badgeLbl.textAlignment=NSTextAlignmentCenter;
        _badgeLbl.font=[UIFont systemFontOfSize:10];
        _badgeLbl.hidden = YES;
    }
    return _badgeLbl;
}

@end
