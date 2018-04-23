//
//  TCMyFriendViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyFriendViewController.h"
#import "TCMyFriendModel.h"
#import "TCMyFriendTableViewCell.h"
#import "YBPopupMenu.h"
#import "TCScanFriendViewController.h"
#import "TCMyQRCodeViewController.h"
#import "TCMyMessageViewController.h"
#import "TCMyFriendDetailViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TCMyFriendViewController ()<UITableViewDelegate,UITableViewDataSource,YBPopupMenuDelegate>{
    NSMutableArray    *myFriendArray;
    UIButton          *rightBtn;
    NSInteger         friendPage;
    UILabel           *badgeLbl;        //我的亲友红点标识
    UILabel           *menuBadgeLbl;        //消息红点标识
}

@property (nonatomic,strong)UITableView *myFriendTab;
@property (nonatomic,strong)UIView      *bottomView;


@end

@implementation TCMyFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的亲友";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    friendPage=1;
    myFriendArray = [[NSMutableArray alloc] init];
    
    [self initMyFriendView];
    [self loadMyFriendData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadMyFriendUnreadMessageInfo];

    if ([TCHelper sharedTCHelper].isFriendResquest == YES) {
        [myFriendArray removeAllObjects];
        [self loadMyFriendData];
        [TCHelper sharedTCHelper].isFriendResquest = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-06" type:1];
    [[TCHelper sharedTCHelper] loginAction:@"003-13-01" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003-06" type:2];
    [[TCHelper sharedTCHelper] loginAction:@"003-13-01" type:2];
#endif
}

#pragma mark --UITableViewDelegate or UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 205.5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return myFriendArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"TCMyFriendTableViewCell";
    TCMyFriendTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[TCMyFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCMyFriendModel *friendModel = myFriendArray[indexPath.row];
    [cell cellMyFriendData:friendModel];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [MobClick event:@"104_002029"];
#endif

    TCMyFriendModel *friendModel = myFriendArray[indexPath.row];
    
    for (TCMyFriendModel *model in myFriendArray) {
        if ([model.family_mobile isEqualToString:friendModel.family_mobile]) {
            model.is_read=1;
        }
    }
    [self.myFriendTab reloadData];
    
    TCMyFriendDetailViewController *friendDetail = [[TCMyFriendDetailViewController alloc] init];
    friendDetail.familyInfo=friendModel.family_info;
    friendDetail.call=friendModel.call;
    [self.navigationController pushViewController:friendDetail animated:YES];
}

#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    if (index== 0) {
#if !DEBUG
        [MobClick event:@"104_002026"];
        [[TCHelper sharedTCHelper] loginClick:@"003-13-07"];

#endif

        // 1、 获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusNotDetermined) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            TCScanFriendViewController *scanFriendVC = [[TCScanFriendViewController alloc] init];
                            [self.navigationController pushViewController:scanFriendVC animated:YES];
                        });
                        
                        NSLog(@"当前线程 - - %@", [NSThread currentThread]);
                        // 用户第一次同意了访问相机权限
                        NSLog(@"用户第一次同意了访问相机权限");
                        
                    } else {
                        
                        // 用户第一次拒绝了访问相机权限
                        NSLog(@"用户第一次拒绝了访问相机权限");
                    }
                }];
            } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
                TCScanFriendViewController *scanFriendVC = [[TCScanFriendViewController alloc] init];
                scanFriendVC.isTaskListLogin = NO;
                __weak typeof(self) weakSelf=self;
                scanFriendVC.scanBlock=^(NSString *message){
                    [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                };
                [self.navigationController pushViewController:scanFriendVC animated:YES];
            } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 糖士 - 相机] 打开相机开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                
            } else if (status == AVAuthorizationStatusRestricted) {
                NSLog(@"因为系统原因, 无法访问相册");
            }
        } else {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }else if(index==1) {
#if !DEBUG
        [MobClick event:@"104_002027"];
        [[TCHelper sharedTCHelper] loginClick:@"003-13-08"];
#endif
        TCMyQRCodeViewController *QRCodeVC = [[TCMyQRCodeViewController alloc] init];
        [self.navigationController pushViewController:QRCodeVC animated:YES];
    }else{
#if !DEBUG
        [MobClick event:@"104_002028"];
        [[TCHelper sharedTCHelper] loginClick:@"003-13-09"];
#endif
        TCMyMessageViewController *messageVC = [[TCMyMessageViewController alloc] init];
        [self.navigationController pushViewController:messageVC animated:YES];
    }
}
#pragma mark -- Event response
#pragma mark -- 更多
-(void)getAddDeviceListAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-13-06"];
#endif

    [YBPopupMenu showRelyOnView:rightBtn titles:@[@"添加亲友",@"我的二维码",@"消息"] icons:@[@"",@"",@""] menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
        popupMenu.borderWidth = 0.5;
        popupMenu.borderColor = [UIColor colorWithHexString:@"0xeeeeeee"];
        popupMenu.delegate = self;
        popupMenu.textColor = [UIColor colorWithHexString:@"0x626262"];
        popupMenu.fontSize = 14;
        
        menuBadgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(50,115, 8, 8)];
        menuBadgeLbl.backgroundColor=[UIColor redColor];
        menuBadgeLbl.layer.cornerRadius=4;
        menuBadgeLbl.clipsToBounds=YES;
        [popupMenu addSubview:menuBadgeLbl];
        menuBadgeLbl.hidden=badgeLbl.hidden;
    }];
}
#pragma mark -- 添加亲友
- (void)addFriend{

#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-13-02"];
    [MobClick event:@"104_002025"];
#endif

    TCScanFriendViewController *scanFriendVC = [[TCScanFriendViewController alloc] init];
    __weak typeof(self) weakSelf=self;
    scanFriendVC.scanBlock=^(NSString *message){
        [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    };
    [self.navigationController pushViewController:scanFriendVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark  获取最新亲友数据
-(void)loadMyFriendNewData{
    friendPage=1;
    [self loadMyFriendData];
}

#pragma mark  获取更多亲友数据
-(void)loadMyFriendMoreData{
    friendPage++;
    [self loadMyFriendData];
}

#pragma mark  获取亲友数据
- (void)loadMyFriendData{
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",(long)friendPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kloadFriendlists body:body success:^(id json) {
        NSArray *friendArray = [json objectForKey:@"result"];
        if (kIsArray(friendArray)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in friendArray) {
                TCMyFriendModel *model = [[TCMyFriendModel alloc] init];
                [model setValues:dict];
                [tempArr addObject:model];
            }
            weakSelf.myFriendTab.mj_footer.hidden=tempArr.count<20;
            if (friendPage==1) {
                weakSelf.bottomView.hidden=tempArr.count>0;
                myFriendArray=tempArr;
            }else{
                [myFriendArray addObjectsFromArray:tempArr];
            }
            [weakSelf.myFriendTab.mj_header endRefreshing];
            [weakSelf.myFriendTab.mj_footer endRefreshing];
            [weakSelf.myFriendTab reloadData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.myFriendTab.mj_header endRefreshing];
        [weakSelf.myFriendTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark 获取好友未读消息信息
-(void)loadMyFriendUnreadMessageInfo{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kMessageUnread body:nil success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            BOOL applyIsRead=[[result valueForKey:@"apply_family_poi"] boolValue];
            menuBadgeLbl.hidden=badgeLbl.hidden=applyIsRead;
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark  初始化界面
- (void)initMyFriendView{
    rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, KStatusHeight, 30, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(getAddDeviceListAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    badgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-15, 26, 8, 8)];
    badgeLbl.backgroundColor=[UIColor redColor];
    badgeLbl.layer.cornerRadius=4;
    badgeLbl.clipsToBounds=YES;
    [self.view addSubview:badgeLbl];
    badgeLbl.hidden=self.isApplyRead;
    
    [self.view addSubview:self.myFriendTab];
    [self.myFriendTab addSubview:self.bottomView];
    self.bottomView.hidden=YES;
}
#pragma mark -- setter or getter
- (UITableView *)myFriendTab{
    if (_myFriendTab==nil) {
        _myFriendTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myFriendTab.backgroundColor = [UIColor bgColor_Gray];
        _myFriendTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myFriendTab.delegate = self;
        _myFriendTab.dataSource = self;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMyFriendNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myFriendTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMyFriendMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myFriendTab.mj_footer = footer;
        footer.hidden=YES;
        
    }
    return _myFriendTab;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kRootViewHeight-200, kScreenWidth, 200)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 20)];
        titleLabel.text = @"添加亲友后，可互相查看血糖数据";
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        [_bottomView addSubview:titleLabel];
        
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, titleLabel.bottom+20, 200, 40)];
        [addButton setTitle:@"扫一扫添加亲友" forState:UIControlStateNormal];
        [addButton setBackgroundColor:kSystemColor];
        [addButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:addButton];
        
    }
    return _bottomView;
}

@end
