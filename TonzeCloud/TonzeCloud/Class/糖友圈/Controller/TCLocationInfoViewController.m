//
//  TCLocationInfoViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLocationInfoViewController.h"
#import "TCLocation.h"
#import "TCLocationInfoCell.h"

@interface TCLocationInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL  _isLocationSuccess;    // 定位是否成功
    NSArray  *_dataArray;
    NSString *_addressStr;       // 定位信息
    NSString *_proStr;
    NSString *_cityStr;
}
@property (nonatomic, strong) UITableView *locationTableView;

@end

@implementation TCLocationInfoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadLocation];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //设置layoutMargins(iOS8之后)
    if ([self.locationTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.locationTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"所在地区";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _dataArray =@[@"定位中"];
    _isLocationSuccess = NO;
    [self setLocationInfoVC];
}
#pragma mark ====== 布局UI =======

- (void)setLocationInfoVC{
    [self.view addSubview:self.locationTableView];
}
#pragma mark ====== 定位 =======

- (void)loadLocation{
    kSelfWeak;
    [[TCLocation location] startLocationAddress:^(BOOL isSuccess, PBLocationModel *locationModel,NSInteger type) {
        if (isSuccess) {
            NSString *proStr = [locationModel.administrativeArea stringByReplacingOccurrencesOfString:@"省" withString:@""];
            NSString *cityStr = [locationModel.locality stringByReplacingOccurrencesOfString:@"市" withString:@""];
            if (!kIsEmptyString(proStr) && !kIsEmptyString(cityStr)) {
                NSString *addStr = [NSString stringWithFormat:@"%@ %@",proStr,cityStr];
                MyLog(@"定位的地址是--%@",addStr);
                _addressStr = addStr;
                _proStr = proStr;
                _cityStr = cityStr;
                _dataArray = @[@"不显示地区",addStr];
                _isLocationSuccess = YES;
                [weakSelf.locationTableView reloadData];
            }
            _isLocationSuccess = YES;
            _locationTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        }else{
            MyLog(@"定位失败");
            if (type == 1 || type == 2){
                UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
                footerView.backgroundColor = [UIColor bgColor_Gray];
                UILabel *tipTextLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, kScreenWidth - 40, 40)];
                tipTextLab.text = @"请iPhone的[设置] - [隐私] - [定位服务]中打开定位服务，并允许[糖士]使用定位服务";
                tipTextLab.textColor = UIColorFromRGB(0x959595);
                tipTextLab.font = kFontWithSize(13);
                tipTextLab.numberOfLines = 0;
                [footerView addSubview:tipTextLab];
                _locationTableView.tableFooterView = footerView;
            }
            _isLocationSuccess = NO;
            _dataArray = @[@"定位服务未开启"];
        }
    }];
}
#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isLocationSuccess) {
        return 2;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TCLocationInfoCell *locationCell = [[TCLocationInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationCell"];
    
    locationCell.titleLab.text = _dataArray[indexPath.row];
    locationCell.iconImg.hidden = _isLocationSuccess ? NO : YES;
    locationCell.iconImg.image = kIsEmptyString(_address) ? [UIImage imageNamed:@"choice"] :[UIImage imageNamed:@"not_choice"];
    if (_isLocationSuccess && !kIsEmptyString(_address) && indexPath.row == 1) {
        locationCell.iconImg.image = [UIImage imageNamed:@"choice"];
    }else if(indexPath.row == 1 ){
        locationCell.iconImg.image = [UIImage imageNamed:@"not_choice"];
    }
    return locationCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isLocationSuccess && indexPath.row == 1) {
        self.adressBlock(_proStr,_cityStr);
        
    }else{
        self.adressBlock(@"", @"");
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark ====== Getter =======

- (UITableView *)locationTableView{
    if (!_locationTableView) {
        _locationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _locationTableView.delegate = self;
        _locationTableView.dataSource = self;
        _locationTableView.tableFooterView  = [UIView new];
        _locationTableView.backgroundColor = [UIColor bgColor_Gray];
    }
    return  _locationTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
