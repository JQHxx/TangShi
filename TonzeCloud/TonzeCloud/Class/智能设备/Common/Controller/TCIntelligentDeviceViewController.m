//
//  TCIntelligentDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCIntelligentDeviceViewController.h"
#import "TCAddDeviceViewController.h"
#import "TCLowerSugarDeviceViewController.h"
#import "DeviceTableViewCell.h"
#import "HttpRequest.h"
#import "TCMainDeviceHelper.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "NSData+Extension.h"
#import "TCLowerSuagrDetailViewController.h"
#import "AppDelegate.h"
#import "TCMessageHelper.h"
#import "TCDeviceMessageModel.h"
#import "SVProgressHUD.h"
#import "DBManager.h"

@interface TCIntelligentDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray        *deviceListArray;
    TCDeviceMessageModel  *lastMessageModel;
    
    NSTimer               *connectTimer;
    NSInteger             _keepAliveCount;
}

@property (nonatomic,strong)UITableView   *deviceTableView;
@property (nonatomic,strong)UIView        *blankView;

@end

@implementation TCIntelligentDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"智能设备";
    
    self.rightImageName=@"ic_top_add";
    
    deviceListArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.deviceTableView];
    [self.deviceTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
    
    [self loadDeviceListData];
    if (!connectTimer) {
        _keepAliveCount = 0;
        connectTimer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshDeviceConnect) userInfo:nil repeats:YES];
        
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-15" type:2];
#endif
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOnPipeData:) name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceStatusChanged:) name:kOnDeviceStateChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutNotifyCallBack) name:kLoginOutNotify object:nil];
    
    if ([TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList) {
        [self loadDeviceListData];
        [TCMainDeviceHelper sharedTCMainDeviceHelper].isReloadDeviceList=NO;
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return deviceListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DeviceTableViewCell";
    DeviceTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    TCDeviceModel *model=deviceListArray[indexPath.row];
    cell.device=model;
    return cell;
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-15-02"];
#endif
    [MobClick event:@"104_002050"];
    
    TCDeviceModel *model=deviceListArray[indexPath.row];
    NSString *stateName=[model.stateDict valueForKey:@"state"];
    
    if (model.isConnected) {
        if ([stateName isEqualToString:@"空闲"]||kIsEmptyString(stateName)) {
            TCLowerSugarDeviceViewController *lowerSugarDeviceVC=[[TCLowerSugarDeviceViewController alloc] init];
            lowerSugarDeviceVC.deviceModel=model;
            [self.navigationController pushViewController:lowerSugarDeviceVC animated:YES];
        }else{
            TCLowerSuagrDetailViewController *detailVC=[[TCLowerSuagrDetailViewController alloc] init];
            detailVC.deviceModel=model;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }else{
        TCLowerSugarDeviceViewController *lowerSugarDeviceVC=[[TCLowerSugarDeviceViewController alloc] init];
        lowerSugarDeviceVC.deviceModel=model;
        [self.navigationController pushViewController:lowerSugarDeviceVC animated:YES];
    }
    
}
#pragma mark -- NSNotification
#pragma mark 设备连接回调
-(void)deviceOnConnectDevice:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    MyLog(@"TCIntelligentDeviceViewController 设备(%@)连接回调",[device getMacAddressSimple]);
    NSNumber *result=[dict objectForKey:@"result"];
    if (result.intValue==0) {
        for (TCDeviceModel *model in deviceListArray) {
            if ([model.mac isEqualToString:[device getMacAddressSimple]]) {
                NSData *Data=[NSData nsstringToHex:@"0000000000120000"];
                MyLog(@"TCIntelligentDeviceViewController 发送查询设备(%@)状态>>：%@", device.getMacAddressSimple,[Data hexString]);
                //获取最新状态
                if (device.isWANOnline) {
                    [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
                }else{
                    [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
                }
            }
        }
    }
}

#pragma mark 接收到设备发送的数据
-(void)deviceOnPipeData:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    MyLog(@"TCIntelligentDeviceViewController mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,[recvData hexString]);
    
    ///如果是控制命令的返回就隐藏
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    if (cmd_data[0]==0x16) {
        for (TCDeviceModel *model in deviceListArray) {
            if ([model.mac isEqualToString:[device getMacAddressSimple]]) {
                [self disbindingDevice:model];
                break;
            }
        }
        return;
    }
    
    //推送处理
    TCDeviceMessageModel *model=[[TCMessageHelper sharedTCMessageHelper] getMessageForHandlerNofication:notifi];
    if (model&&![model.state isEqualToString:lastMessageModel.state]&&![model.gen_date isEqualToString:lastMessageModel.gen_date]) {
        NSString *bodyStr=nil;
        if (kIsEmptyString(model.deviceType)) {
            bodyStr=[NSString stringWithFormat:@"%@\n%@ %@",model.gen_date,model.deviceName,model.state];
        }else{
            bodyStr=[NSString stringWithFormat:@"%@\n%@/%@ %@",model.gen_date,model.deviceName,model.deviceType,model.state];
        }
        MyLog(@"notification---body:%@",bodyStr);
        lastMessageModel=model;
        [[TCMessageHelper sharedTCMessageHelper] configNotification:bodyStr withType:@"设备工作"];
        [[DBManager shareManager] insertMessage:model];
    }
    
    //跟新设备状态
    NSMutableDictionary *dic=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getStateDicWithDevice:device Data:recvData];
    if (kIsDictionary(dic)&&dic.count>0) {
        for (TCDeviceModel *model in deviceListArray) {
            if ([model.mac isEqualToString:[device getMacAddressSimple]]) {
                model.stateDict=dic;
                
                NSString *stateStr=dic[@"state"];
                
                if ([stateStr isEqualToString:@"降糖饭"]) {   //保存煮过的米种
                    NSInteger riceID=[[dic valueForKey:@"rice"] integerValue];
                    if (riceID>0) {
                        NSString *riceKey=[NSString stringWithFormat:@"%@riceId",model.mac];
                        MyLog(@"riceKey:%@,riceID:%ld",riceKey,riceID);
                        [NSUserDefaultsInfos putKey:riceKey andValue:[NSNumber numberWithInteger:riceID]];
                    }
                }
            } 
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.deviceTableView reloadData];
        });
    });
}

#pragma mark 设备状态改变
-(void)deviceStatusChanged:(NSNotification *)notifi{
    MyLog(@"TCIntelligentDeviceViewController----deviceStatusChanged");
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    for (TCDeviceModel *model in deviceListArray) {
        if ([device.getMacAddressSimple isEqualToString:model.mac]) {
            model.isConnected=device.isConnected;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.deviceTableView reloadData];
        });
    });
}

#pragma mark  退出登录
-(void)loginOutNotifyCallBack{
    MyLog(@"loginOutNotifyCallBack");
    if (self.navigationController.viewControllers.count>1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if (connectTimer) {
            [connectTimer invalidate];
            connectTimer =nil;
        }
    }
}

#pragma mark -- Event Response
#pragma mark 添加设备
-(void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-15-01"];
#endif
    [MobClick event:@"104_002049"];
    [self addNewDevice];
}

#pragma mark 返回上一页
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
    if (connectTimer) {
        [connectTimer invalidate];
        connectTimer =nil;
    }
}

#pragma mark 添加设备
- (void)addNewDeviceActionForGesture:(UITapGestureRecognizer *)sender{
    [self addNewDevice];
}

#pragma mark 添加设备
- (void)addNewDevice{
    TCAddDeviceViewController *addDeviceVC=[[TCAddDeviceViewController alloc] init];
    [self.navigationController pushViewController:addDeviceVC animated:YES];
}

#pragma mark -- Private methods
#pragma mark 获取设备列表
-(void)loadDeviceListData{
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    if (kIsDictionary(userDic)&&userDic.count>0) {
        kSelfWeak;
        [SVProgressHUD show];
        [HttpRequest getDeviceListWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
            [SVProgressHUD dismiss];
            [weakSelf.deviceTableView.mj_header endRefreshing];
            if (!err) {
                NSArray *list=[result objectForKey:@"list"];
                deviceListArray=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getDeviceListWithList:list];
                [[TCMainDeviceHelper sharedTCMainDeviceHelper] getDeviceEntityListWithDeviceList:list];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        weakSelf.blankView.hidden=deviceListArray.count>0;
                        [weakSelf.deviceTableView reloadData];
                    });
                });
                //刷新设备名称
                [weakSelf reloadDeviceName];
            }else{
                MyLog(@"getDeviceListFail--code:%ld,error:%@",err.code,err.localizedDescription);
                if (err.code==4031021) {
                    AppDelegate *appDelegate=kAppDelegate;
                    [appDelegate updateAccessToken];
                }
            }
        }];
    }
}

#pragma mark 刷新设备名称
-(void)reloadDeviceName{
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    for (TCDeviceModel *model in deviceListArray) {
        [HttpRequest getDevicePropertyWithDeviceID:[NSNumber numberWithInteger:model.device_id] withProductID:model.product_id withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
            if (result) {
                NSString *key=[model.mac stringByAppendingString:@"name"];
                NSString *name=[result objectForKey:key];
                model.deviceName=kIsEmptyString(name)?@"云智能降糖饭煲":name;
                if (!kIsEmptyString(name)) {
                    [NSUserDefaultsInfos putKey:[model.mac stringByAppendingString:@"name"] andValue:name];
                }
            }
        }];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.deviceTableView reloadData];
        });
    });
}

#pragma mark 取消设备绑定
-(void)disbindingDevice:(TCDeviceModel *)deviceModel{
    [SVProgressHUD show];
    kSelfWeak;
    NSDictionary *userDic=[NSUserDefaultsInfos getDicValueforKey:USER_DIC];
    [HttpRequest unsubscribeDeviceWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withDeviceID:[NSNumber numberWithInteger:deviceModel.device_id] didLoadData:^(id result, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            if (err.code==4001034) {
                [weakSelf loadDeviceListData];
            }else if (err.code==4031003) {
                
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertWithTitle:@"提示" Message:@"删除失败"];
                    });
                });
            }
        }else{
            NSString *message=[NSString stringWithFormat:@"对设备%@的控制权已取消",deviceModel.deviceName];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                });
            });
            [weakSelf loadDeviceListData];
        }
    }];
    
}


#pragma mark 刷新设备连接状态
-(void)refreshDeviceConnect{
    if (_keepAliveCount%2==0&&_keepAliveCount>0) {
        [self loadDeviceListData];
    }
    
    if (deviceListArray.count>0) {
        for (TCDeviceModel *device in deviceListArray) {
            DeviceEntity *deviceEntity=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getDeviceEntityWithDeviceMac:device.mac];
            if (!deviceEntity|| (deviceEntity && !deviceEntity.isConnected && !deviceEntity.isUserDisconnect)) {
                [[XLinkExportObject sharedObject] initDevice:deviceEntity];
                deviceEntity.version=2;
                [[XLinkExportObject sharedObject] connectDevice:deviceEntity andAuthKey:deviceEntity.accessKey];
            }
        }
    }
    ++_keepAliveCount;
}

#pragma mark -- Setters and Getters
-(UITableView *)deviceTableView{
    if (!_deviceTableView) {
        _deviceTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _deviceTableView.backgroundColor=[UIColor bgColor_Gray];
        _deviceTableView.dataSource=self;
        _deviceTableView.delegate=self;
        _deviceTableView.tableFooterView=[[UIView alloc] init];
        _deviceTableView.showsVerticalScrollIndicator=NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadDeviceListData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _deviceTableView.mj_header=header;
    }
    return _deviceTableView;
}

#pragma mark 空白页
-(UIView *)blankView{
    if (!_blankView) {
        _blankView=[[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2,20, 120, 120)];
        imgView.image=[UIImage imageNamed:@"ic_s_equip_none"];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        [_blankView addSubview:imgView];
        
        NSString *str=@"期待添加您的第一款设备";
        CGSize statusLabelSize =[str sizeWithLabelWidth:kScreenWidth-120 font:[UIFont systemFontOfSize:14]];
        UILabel *tipLab=[[UILabel alloc] initWithFrame:CGRectMake(60, imgView.bottom, kScreenWidth-120, statusLabelSize.height+5)];
        tipLab.textAlignment=NSTextAlignmentCenter;
        tipLab.font=[UIFont systemFontOfSize:14.0f];
        tipLab.textColor=[UIColor lightGrayColor];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ff9d38"] range:NSMakeRange(2, 2)];
        tipLab.attributedText=attributeStr;
        tipLab.userInteractionEnabled=YES;
        [_blankView addSubview:tipLab];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewDeviceActionForGesture:)];
        [tipLab addGestureRecognizer:tapGesture];
        
    }
    return _blankView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOutNotify object:nil];
    
    if (connectTimer) {
        [connectTimer invalidate];
        connectTimer =nil;
    }
}

@end
