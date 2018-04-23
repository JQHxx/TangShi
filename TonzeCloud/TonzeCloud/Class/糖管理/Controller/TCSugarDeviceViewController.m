//
//  TCSugarDeviceViewController.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarDeviceViewController.h"
#import "TCSugarMeasureViewController.h"
#import "TCGPRSGlucoseMeterViewController.h"
#import "TCSugarDeviceCell.h"
#import "TCFastLoginViewController.h"

static NSString *sugarDeviceIdentifiel = @"sugarDeviceIdentifiel";

@interface TCSugarDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray     *_deviceNameArray;
    NSArray     *_deviceIconArray;
    NSArray     *_deviceInfoArray;
}
@property (nonatomic,strong) UITableView *sugarDeviceTab;

@end

@implementation TCSugarDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"血糖设备";
    [self.sugarDeviceTab registerNib:[UINib nibWithNibName:@"TCSugarDeviceCell" bundle:nil] forCellReuseIdentifier:sugarDeviceIdentifiel];
    _deviceNameArray = @[@"糖士GPRS血糖仪",@"糖士蓝牙血糖仪"];
    _deviceIconArray =@[@"pub_img_xty02",@"pub_img_xty01"];
    _deviceInfoArray = @[@"工匠制造，健康控糖",@"您的贴身血糖管家"];
    
    [self.view addSubview:self.sugarDeviceTab];
//    [self initSugarDeviceView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-05" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-05" type:2];
#endif
}
#pragma mark -- Event Response
#pragma mark 立即测量
-(void)startMeasureSugarData:(UIButton *)sender{
    [MobClick event:@"101_002010"];

    TCSugarMeasureViewController *sugarMeasureVC=[[TCSugarMeasureViewController alloc] init];
    sugarMeasureVC.isTaskListLogin = _isTaskListLogin;
    [self.navigationController pushViewController:sugarMeasureVC animated:YES];
}
#pragma mark -- Private Methods
#pragma mark 初始化血糖设备界面
-(void)initSugarDeviceView{
    UIImageView  *contentImageView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 84, kScreenWidth-40,560*(kScreenWidth-40)/750)];
    contentImageView.image=[UIImage imageNamed:@"img_xty_banner_02"];
    [self.view addSubview:contentImageView];
    
    UILabel   *contentlabel=[[UILabel alloc] initWithFrame:CGRectZero];
    contentlabel.numberOfLines=0;
    contentlabel.font=[UIFont systemFontOfSize:14];
    contentlabel.text=@"\t糖士血糖仪是由深圳天际云科技有限公司为糖友打造的精准测量血糖仪器。结合糖士app可为糖友提供血糖数据管理、分析、家人数据监控等服务，控糖也可以如此轻松。";
    CGFloat contentH=[contentlabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:contentlabel.font].height;
    contentlabel.frame=CGRectMake(15, contentImageView.bottom+15, kScreenWidth-30, contentH);
    [self.view addSubview:contentlabel];
    
    UIButton *measureBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, contentlabel.bottom+20, kScreenWidth-80, 40)];
    [measureBtn setTitle:@"立即测量" forState:UIControlStateNormal];
    [measureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    measureBtn.backgroundColor=kSystemColor;
    measureBtn.layer.cornerRadius=5;
    measureBtn.clipsToBounds=YES;
    [measureBtn addTarget:self action:@selector(startMeasureSugarData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:measureBtn];
}
#pragma mark ====== tableHerView =======
- (UIView *)tableHerView{
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    hearView.backgroundColor = [UIColor bgColor_Gray];
    return hearView;
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCSugarDeviceCell *sugarDeviceCell = [tableView dequeueReusableCellWithIdentifier:sugarDeviceIdentifiel];
    sugarDeviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sugarDeviceCell.deviceNameLab.text = _deviceNameArray[indexPath.row];
    sugarDeviceCell.deviceImgView.image = [UIImage imageNamed:_deviceIconArray[indexPath.row]];
    sugarDeviceCell.deviceInfoLab.text = _deviceInfoArray[indexPath.row];
    return sugarDeviceCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        switch (indexPath.row) {
            case 0:
            {
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-19-01"];
#endif
                [MobClick event:@"101_002028"];
                TCGPRSGlucoseMeterViewController *gprsGlucoseMeterVC = [TCGPRSGlucoseMeterViewController new];
                [self.navigationController pushViewController:gprsGlucoseMeterVC animated:YES];
            }break;
            case 1:
            {
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"004-19-02"];
#endif
                [MobClick event:@"101_002029"];
                TCSugarMeasureViewController *sugarMeasureVC=[[TCSugarMeasureViewController alloc] init];
                sugarMeasureVC.isTaskListLogin = _isTaskListLogin;
                [self.navigationController pushViewController:sugarMeasureVC animated:YES];
            }break;
            default:
                break;
        }
    }else{
       [self fastLoginAction];
    }
}
#pragma mark ====== Setter =======
- (UITableView *)sugarDeviceTab
{
    if (!_sugarDeviceTab) {
        _sugarDeviceTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _sugarDeviceTab.delegate = self;
        _sugarDeviceTab.dataSource = self;
        _sugarDeviceTab.tableFooterView = [UIView new];
        _sugarDeviceTab.tableHeaderView = [self tableHerView];
        _sugarDeviceTab.backgroundColor = [UIColor bgColor_Gray];
    }
    return  _sugarDeviceTab;
}
@end
