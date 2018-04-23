//
//  TCAddDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddDeviceViewController.h"
#import "TCScanDeviceViewController.h"
#import "TCSetWifiLightViewController.h"
#import "TCAddDeviceTableViewCell.h"
#import "TCAddDeviceModel.h"
#import "TCMainDeviceHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface TCAddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray     *addDeviceArr;
}

@property (nonatomic,strong)UITableView *addTableView;

@end

@implementation TCAddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    addDeviceArr=[[NSMutableArray alloc] init];
    [self.view addSubview:self.addTableView];
    [self loadAddDeviceList];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15-01" type:2];
#endif
}
#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?1:addDeviceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCAddDeviceTableViewCell";
    if (indexPath.section==0) {
        UITableViewCell  *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 40, 40)];
        imgView.image=[UIImage imageNamed:@"pub_ic_sao"];
        [cell.contentView addSubview:imgView];
        
        UILabel *titleText=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, 20, kScreenWidth-imgView.right-60, 40)];
        titleText.textColor=[UIColor blackColor];
        titleText.font=[UIFont systemFontOfSize:16];
        titleText.text=@"扫二维码添加";
        [cell.contentView addSubview:titleText];
    
        return cell;
    }else{
        TCAddDeviceTableViewCell *cell=[[TCAddDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        TCAddDeviceModel *device=addDeviceArr[indexPath.row];
        cell.device=device;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section==0) {
        // 1、 获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusNotDetermined) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            TCScanDeviceViewController *scanDeviceVC=[[TCScanDeviceViewController alloc] init];
                            [self.navigationController pushViewController:scanDeviceVC animated:YES];
                        });
                        // 用户第一次同意了访问相机权限
                        MyLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                        
                    } else {
                        // 用户第一次拒绝了访问相机权限
                        MyLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
            } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"003-15-01-01"];
#endif
                [MobClick event:@"104_003019"];
                TCScanDeviceViewController *scanDeviceVC=[[TCScanDeviceViewController alloc] init];
                [self.navigationController pushViewController:scanDeviceVC animated:YES];
            } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                
            } else if (status == AVAuthorizationStatusRestricted) {
                MyLog(@"因为系统原因, 无法访问相册");
            }
        } else {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"003-15-01-02"];
#endif
        [MobClick event:@"104_003020"];
        TCAddDeviceModel *device=addDeviceArr[indexPath.row];
        [TCMainDeviceHelper sharedTCMainDeviceHelper].mainDevice=device;
        TCSetWifiLightViewController *setWifiLightVC=[[TCSetWifiLightViewController alloc] init];
        [self.navigationController pushViewController:setWifiLightVC animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 40)];
        titleLab.textColor=[UIColor blackColor];
        titleLab.font=[UIFont systemFontOfSize:14];
        titleLab.text=@"按设备类型添加";
        [headerView addSubview:titleLab];
        return headerView;
    }else{
        return nil;
    }
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section==0?80:100;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0.1:40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


#pragma mark -- Private Methods
#pragma mark 设备列表
-(void)loadAddDeviceList{
    TCAddDeviceModel *deviceModel=[[TCAddDeviceModel alloc] init];
    deviceModel.deviceName=@"云智能降糖饭煲";
    deviceModel.desc=@"可降低食物糖分约20%";
    deviceModel.wifiImage=@"img_jtfc_link";
    deviceModel.productID=LowerSuagerCooker_ProductID;
    [addDeviceArr addObject:deviceModel];
    [self.addTableView reloadData];
}

#pragma mark -- Getters and Setters
#pragma mark 添加列表
-(UITableView *)addTableView{
    if (!_addTableView) {
        _addTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _addTableView.backgroundColor=[UIColor bgColor_Gray];
        _addTableView.delegate=self;
        _addTableView.dataSource=self;
    }
    return _addTableView;
}


@end
