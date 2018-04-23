//
//  TCMessageDetailViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMessageDetailViewController.h"
#import "TCConnectSuccessViewController.h"
#import "TCQRcodeTimeOutViewController.h"
#import "TCMessageTableViewCell.h"
#import "TCDeviceMessageModel.h"
#import "TCDeviceShareHelper.h"
#import "TCBlankView.h"
#import "HttpRequest.h"
#import "DeviceEntity.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "DBManager.h"
#import "AppDelegate.h"

@interface TCMessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  * messageArray;
    NSString        * _invite_code;
    NSNumber        * _deviceID;
    AppDelegate     *appDelegate;
    
    NSString        *recordStr;
}

@property (nonatomic,strong)UITableView   *notiTableView;
@property (nonatomic,strong)TCBlankView   *blankView;

@end

@implementation TCMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    
    switch (self.type) {
        case MessageTypeDeviceWork:
            self.baseTitle = @"设备工作";
            recordStr = @"004-01-06-01";
            break;
        case MessageTypeDeviceShare:
            self.baseTitle = @"设备分享";
            recordStr = @"004-01-06-02";
            break;
        case MessageTypeFaultMessage:
            self.baseTitle = @"故障消息";
            recordStr = @"004-01-06-03";
            break;
            
        default:
            break;
    }
    
    messageArray=[[NSMutableArray alloc] init];
    appDelegate=kAppDelegate;
    
    [self.view addSubview:self.notiTableView];
    [self.notiTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:recordStr type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:recordStr type:2];
#endif
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessageInfo];
}

#pragma mark -- UITableViewDelegate and UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"NotiCenterCell";
    TCMessageTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[TCMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCDeviceMessageModel *message=messageArray[indexPath.row];
    [cell cellDisplayWithMessage:message type:self.type];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCDeviceMessageModel *message=messageArray[indexPath.row];
    if ([message.state isEqualToString:@"pending"]) {
        _invite_code=message.invite_code;
        if ([XL_USER_ID integerValue]==message.from_id) {
            [self showCancelShareActionSheet];
        }else{
            [self showActionSheetController];
        }
    }
}


#pragma mark -- Private methods
#pragma mark 获取消息
-(void)getMessageInfo{
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    if (self.type == MessageTypeDeviceShare) {
        //获取分享列表
        kSelfWeak;
        [SVProgressHUD show];
        [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
            [SVProgressHUD dismiss];
            if (err) {
                MyLog(@"请求失败,code:%ld,error:%@",err.code,err.localizedDescription);
                if (err.code==4031003) {
                    [appDelegate updateAccessToken];
                }
            }else{
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in result) {
                    TCDeviceMessageModel *model=[[TCDeviceMessageModel alloc] init];
                    [model setValues:dict];
                    [tempArr addObject:model];
                }
                
                [tempArr sortUsingComparator:^NSComparisonResult(TCDeviceMessageModel  *obj1, TCDeviceMessageModel  *obj2) {
                    return obj1.gen_date<obj2.gen_date;
                }];
                messageArray=tempArr;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.blankView.hidden=messageArray.count>0;
                    [weakSelf.notiTableView reloadData];
                });
                
            }
        }];
    }else{
        NSMutableArray *tempMessageArr=[NSMutableArray arrayWithArray:[[DBManager shareManager] readAllMessages]];
        [tempMessageArr sortUsingComparator:^NSComparisonResult(TCDeviceMessageModel  *obj1, TCDeviceMessageModel  *obj2) {
            NSInteger timesp1=[[TCHelper sharedTCHelper] timeSwitchTimestamp:obj1.gen_date format:@"yyyy-MM-dd HH:mm:ss"];
            NSInteger timesp2=[[TCHelper sharedTCHelper] timeSwitchTimestamp:obj2.gen_date format:@"yyyy-MM-dd HH:mm:ss"];
            return timesp1<timesp2;
        }];
        
        NSMutableArray *tempResultArr=[[NSMutableArray alloc] init];
        if (self.type==MessageTypeDeviceWork) {
            for (TCDeviceMessageModel *model in tempMessageArr) {
                if (!model.isWorkError) {
                    [tempResultArr addObject:model];
                }
            }
        }else{
            for (TCDeviceMessageModel *model in tempMessageArr) {
                if (model.isWorkError) {
                    [tempResultArr addObject:model];
                }
            }
        }
        messageArray=tempResultArr;
        self.blankView.hidden=messageArray.count>0;
        [self.notiTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}


#pragma mark 选择接受或拒绝分享
-(void)showActionSheetController{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *acceptButtonTitle = NSLocalizedString(@"接受分享", nil);
    NSString *refuseButtonTitle = NSLocalizedString(@"拒绝分享", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:acceptButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(acceptDeviceShare) withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:refuseButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(refuseDeviceShare) withObject:nil waitUntilDone:NO];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:acceptAction];
    [alertController addAction:refuseAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消分享弹出框
-(void)showCancelShareActionSheet{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *cancelShareButtonTitle = NSLocalizedString(@"取消分享", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *cancelShareAction = [UIAlertAction actionWithTitle:cancelShareButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(cancelDeviceShare) withObject:nil waitUntilDone:NO];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:cancelShareAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消分享
-(void)cancelDeviceShare{
    kSelfWeak;
    [SVProgressHUD show];
    [HttpRequest cancelShareDeviceWithAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withInviteCode:_invite_code didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            MyLog(@"请求失败,code:%ld,error:%@",err.code,err.localizedDescription);
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

#pragma mark 拒绝分享
-(void)refuseDeviceShare{
    kSelfWeak;
    [SVProgressHUD show];
    [HttpRequest denyShareWithInviteCode:_invite_code withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (!err) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            MyLog(@"请求失败,code:%ld,error:%@",err.code,err.localizedDescription);
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

#pragma mark 接受分享
-(void)acceptDeviceShare{
    kSelfWeak;
    [SVProgressHUD show];
    [HttpRequest acceptShareWithInviteCode:_invite_code withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (!err) {
            [HttpRequest getDeviceListWithUserID:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"user_id"] withAccessToken:[[NSUserDefaultsInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                if (!err) {
                    NSArray *deviceList=[result objectForKey:@"list"];
                    [weakSelf addNewDeviceFromList:deviceList];
                }else{
                    [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                }
            }];
        }else{
            [SVProgressHUD dismiss];
            dispatch_sync(dispatch_get_main_queue(), ^{
                TCQRcodeTimeOutViewController *viewController = [[TCQRcodeTimeOutViewController alloc] init];
                [weakSelf.navigationController pushViewController:viewController animated:YES];
            });
        }
    }];
}

#pragma mark 添加设备
-(void)addNewDeviceFromList:(NSArray *)deviceList{
    kSelfWeak;
    [HttpRequest getShareListWithAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (!err) {
            NSArray *tem = (NSArray *)result;
            for (NSDictionary *newsDict in tem) {
                TCDeviceMessageModel *model = [[TCDeviceMessageModel alloc] init];
                [model setValues:newsDict];
                if ([model.invite_code isEqualToString:_invite_code]) {
                    for (NSDictionary *deviceDic in deviceList) {
                        if ([deviceDic[@"id"] integerValue]==model.device_id) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            [weakSelf performSelectorOnMainThread:@selector(pushToSuccess:) withObject:newDevice waitUntilDone:YES];
                        }
                    }
                    break;
                }
            }
        }else{
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

#pragma mark 跳转到连接成功页
- (void)pushToSuccess:(DeviceEntity *)device{
    TCConnectSuccessViewController *connectSuccessVC=[[TCConnectSuccessViewController alloc] init];
    connectSuccessVC.device=device;
    [TCDeviceShareHelper saveDeviceToLocal:device];
    [self.navigationController pushViewController:connectSuccessVC animated:YES];
}

#pragma mark -- Setters
#pragma mark 消息中心
-(UITableView *)notiTableView{
    if (_notiTableView==nil) {
        _notiTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _notiTableView.dataSource=self;
        _notiTableView.delegate=self;
        _notiTableView.backgroundColor=[UIColor bgColor_Gray];
        _notiTableView.tableFooterView=[[UIView alloc] init];
        _notiTableView.showsVerticalScrollIndicator=NO;
    }
    return _notiTableView;
}

#pragma mark 暂无数据
-(TCBlankView *)blankView{
    if (!_blankView) {
        _blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0,kNavHeight+30, kScreenWidth, kRootViewHeight) img:@"暂无数据" text:@"暂无数据"];
    }
    return _blankView;
}


@end
