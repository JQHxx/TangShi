//
//  TCGPRSGlucoseMeterViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCGPRSGlucoseMeterViewController.h"
#import "TCGPRSGlucoseMeterCell.h"
#import "TCGlucoseMeterHelpViewController.h"
#import "TCBindingGlucoseMeterViewController.h"
#import "TCGPRSDeviceManagementViewController.h"
#import "TCGPRSRecordsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TCGPRSDeviceListModel.h"
#import "ShopDetailViewController.h"

static NSInteger  headViewHight  = 69;

@interface TCGPRSGlucoseMeterViewController ()<UITableViewDataSource,UITableViewDelegate,TCGlucoseMeterCellDelegate>
{
    NSInteger   _pageNum;
    NSString     *_buyUrl;// 购买链接
    NSString      *_productId;
}
@property (nonatomic,strong) UITableView *gprsGlucoseMeterTab;
/// 头部视图（绑定设备）
@property (nonatomic ,strong) UIView  *headerVeiw;
/// 设备数据
@property (nonatomic ,strong) NSMutableArray *deviceDataArray;

@end

@implementation TCGPRSGlucoseMeterViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TCHelper sharedTCHelper].isLoadGPRSGlucoseMeterList) {
        [self loadNewDeviceListData];
        [TCHelper sharedTCHelper].isLoadGPRSGlucoseMeterList = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"糖士GPRS血糖仪";
    self.rigthTitleName =@"帮助";
    
    _pageNum = 1;
    [self setGPRSGlucoseMeterVC];
    [self requestDeviceListData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-19-01" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-19-01" type:2];
#endif
}
#pragma mark ====== 布局UI =======
- (void)setGPRSGlucoseMeterVC{
    [self.view addSubview:self.headerVeiw];
    [self.view addSubview:self.gprsGlucoseMeterTab];
}
#pragma mark ====== 未绑定设备界面 =======
- (UIView *)tebleViewFooterView{
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0 , 0, kScreenWidth, 550 * kScreenWidth/375)];
    footerView.backgroundColor = [UIColor whiteColor];

    UIImageView *unDeviceImg = [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, kScreenWidth - 36, kScreenWidth - 36)];
    unDeviceImg.image = [UIImage imageNamed:@"xty02_img_banner"];
    [footerView addSubview:unDeviceImg];
    
    UIButton *godeviceStoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    godeviceStoreBtn.frame = CGRectMake(18, unDeviceImg.bottom + 18, kScreenWidth - 36, 40);
    godeviceStoreBtn.backgroundColor = kSystemColor;
    godeviceStoreBtn.layer.cornerRadius = 5;
    godeviceStoreBtn.titleLabel.font = kFontWithSize(15);
    [godeviceStoreBtn setTitle:@"购买血糖仪" forState:UIControlStateNormal];
    [godeviceStoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [godeviceStoreBtn addTarget:self action:@selector(godeviceStoreAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:godeviceStoreBtn];

    NSString *tipStr =@"首次绑定糖士账号后，测量时无需打开糖士APP，数据自动上传云端，在糖士APP随时查看数据";
    CGSize tipSize = [tipStr boundingRectWithSize:CGSizeMake(kScreenWidth - 36,100) withTextFont:kFontWithSize(15)];
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(18, godeviceStoreBtn.bottom + 18, kScreenWidth - 36, tipSize.height)];
    tipLab.numberOfLines=0 ;
    tipLab.text = tipStr;
    tipLab.textColor = UIColorFromRGB(0x666666);
    tipLab.font = kFontWithSize(15);
    [footerView addSubview:tipLab];
    
    return footerView;
}
#pragma mark ====== request Data =======
- (void)requestDeviceListData{
    kSelfWeak;
    NSString *url = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld",KGlucoseMeterlist,(long)_pageNum];
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        _buyUrl = [json objectForKey:@"buy_url"];
        _productId = [json objectForKey:@"product_id"];
        if (kIsArray(resultArray) && resultArray.count >0) {
            for (NSDictionary *dict in resultArray) {
                TCGPRSDeviceListModel *deviceListModel = [TCGPRSDeviceListModel new];
                [deviceListModel setValues:dict];
                [weakSelf.deviceDataArray addObject:deviceListModel];
            }
            weakSelf.gprsGlucoseMeterTab.tableFooterView = [UIView new];
        }else{
            weakSelf.gprsGlucoseMeterTab.tableFooterView = [self tebleViewFooterView];
        }
        [weakSelf.gprsGlucoseMeterTab reloadData];
        [weakSelf.gprsGlucoseMeterTab.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.gprsGlucoseMeterTab.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 下拉刷新 =======
- (void)loadNewDeviceListData{
    _pageNum = 1;
    [self.deviceDataArray removeAllObjects];
    [self requestDeviceListData];
}
#pragma mark ====== 帮助 =======
- (void)rightButtonAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-19-01-03"];
#endif
    [MobClick event:@"101_003029"];
    TCGlucoseMeterHelpViewController *glucoseMeterHelpVC = [TCGlucoseMeterHelpViewController new];
    [self.navigationController pushViewController:glucoseMeterHelpVC animated:YES];
}
#pragma mark ====== 绑定血糖仪 =======
- (void)bindingBtnAction{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TCBindingGlucoseMeterViewController *bindingGlucoseMeterVC = [TCBindingGlucoseMeterViewController new];
                        [self.navigationController pushViewController:bindingGlucoseMeterVC animated:YES];
                    });
                    MyLog(@"当前线程 - - %@", [NSThread currentThread]);
                    MyLog(@"用户第一次同意了访问相机权限");// 用户第一次同意了访问相机权限
                } else {// 用户第一次拒绝了访问相机权限
                    MyLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        }else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"004-19-01-01"];
#endif
            [MobClick event:@"101_003027"];
            TCBindingGlucoseMeterViewController *bindingGlucoseMeterVC = [TCBindingGlucoseMeterViewController new];
            [self.navigationController pushViewController:bindingGlucoseMeterVC animated:YES];
        }else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 糖士 - 相机] 打开相机开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }else if (status == AVAuthorizationStatusRestricted) {
            MyLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}
#pragma mark ====== 跳转血糖仪购买 =======
- (void)godeviceStoreAction{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"004-19-01-02"];
#endif
    [MobClick event:@"101_003028"];
    // 判断是否返回产品ID，如有（跳转商品详情）无（跳转淘宝）
    if (!kIsEmptyString(_productId)) {
        ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc]init];
        shopDetailVC.product_id = [_productId integerValue];
        [self.navigationController pushViewController:shopDetailVC animated:YES];
    }else{
        NSString *taobaoUrl= _buyUrl;
        if (!kIsEmptyString(taobaoUrl)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[taobaoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
}
#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceDataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 365;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *gprsGlucoseMeterIdentifier = @"gprsGlucoseMeterIdentifier";
    TCGPRSGlucoseMeterCell *gprsGlucoseMeterCell = [tableView dequeueReusableCellWithIdentifier:gprsGlucoseMeterIdentifier];
    if (!gprsGlucoseMeterCell) {
        gprsGlucoseMeterCell = [[TCGPRSGlucoseMeterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gprsGlucoseMeterIdentifier];
    }
    if (self.deviceDataArray.count > 0) {
           gprsGlucoseMeterCell.deviceListModel = self.deviceDataArray[indexPath.row];
    }
    gprsGlucoseMeterCell.delegate = self;
    return gprsGlucoseMeterCell;
}
#pragma mark ====== TCGlucoseMeterCellDelegate =======
// 设备管理
- (void)didmanagementOfEquipment:(UITableViewCell *)cell{
    TCGPRSDeviceManagementViewController *deviceManagementVC = [TCGPRSDeviceManagementViewController new];
     NSIndexPath *indexPath = [self.gprsGlucoseMeterTab indexPathForCell:cell];
    deviceManagementVC.deviceListModel = self.deviceDataArray[indexPath.row];
    [self.navigationController pushViewController:deviceManagementVC animated:YES];
}
// 测量记录
- (void)didcheckTheRecord:(UITableViewCell *)cell{
    TCGPRSRecordsViewController *recordsVC = [TCGPRSRecordsViewController new];
    NSIndexPath *indexPath = [self.gprsGlucoseMeterTab indexPathForCell:cell];
    TCGPRSDeviceListModel *deviceListModel = self.deviceDataArray[indexPath.row];
    recordsVC.sn = deviceListModel.sn;
    [self.navigationController pushViewController:recordsVC animated:YES];
}
#pragma mark ====== Setter =======
- (UITableView *)gprsGlucoseMeterTab{
    if (!_gprsGlucoseMeterTab) {
        _gprsGlucoseMeterTab = [[UITableView alloc]initWithFrame:CGRectMake(0,kNewNavHeight + headViewHight , kScreenWidth, kRootViewHeight -  headViewHight) style:UITableViewStylePlain];
        _gprsGlucoseMeterTab.delegate = self;
        _gprsGlucoseMeterTab.dataSource = self;
        _gprsGlucoseMeterTab.backgroundColor = [UIColor bgColor_Gray];
        _gprsGlucoseMeterTab.separatorStyle = UITableViewCellSeparatorStyleNone;

        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDeviceListData)];
        header.stateLabel.text =@"下拉刷新";
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _gprsGlucoseMeterTab.mj_header=header;
    }
    return _gprsGlucoseMeterTab;
}
#pragma mark ====== 绑定血糖仪 =======

-(UIView *)headerVeiw{
    if (!_headerVeiw) {
        _headerVeiw = [[UIView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, headViewHight)];
        _headerVeiw.backgroundColor = [UIColor whiteColor];
        
        UIImageView *addIcon = [[UIImageView alloc]initWithFrame:CGRectMake(18, (59 - 30)/2 , 30, 30)];
        addIcon.image = [UIImage imageNamed:@"pub_ic_sao"];
        [_headerVeiw addSubview:addIcon];
        
        UILabel *bindingGlucoseMeterLab = [[UILabel alloc]initWithFrame:CGRectMake(addIcon.right + 10, (59 - 20)/2 , 100, 20)];
        bindingGlucoseMeterLab.text =@"绑定血糖仪";
        bindingGlucoseMeterLab.textColor = UIColorFromRGB(0x313131);
        bindingGlucoseMeterLab.font = kFontWithSize(15);
        [_headerVeiw addSubview:bindingGlucoseMeterLab];
        
        UIImageView *arrowIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 31, (59 - 16)/2, 10, 16)];
        arrowIcon.image = [UIImage imageNamed:@"right_arrow"];
        [_headerVeiw addSubview:arrowIcon];
        
        UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(0, headViewHight - 10, kScreenWidth, 10)];
        lens.backgroundColor = [UIColor bgColor_Gray];
        [_headerVeiw addSubview:lens];
        
        UIButton *bindingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bindingBtn.frame = CGRectMake(0, 0, kScreenWidth, _headerVeiw.height);
        [bindingBtn addTarget:self action:@selector(bindingBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerVeiw addSubview:bindingBtn];
    }
    return _headerVeiw;
}
- (NSMutableArray *)deviceDataArray{
    if (!_deviceDataArray) {
        _deviceDataArray = [NSMutableArray array];
    }
    return _deviceDataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
