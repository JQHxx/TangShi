
//
//  MyIntegralDetailVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCIntegralDetailViewController.h"
#import "TCMyIntegralDetailCell.h"
#import "TCIntegralDetailModel.h"

@interface TCIntegralDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isShowDetailLabText;// 是否显示详情数据
}
@property (nonatomic ,strong) UITableView *tableView;
/// 标题
@property (nonatomic ,strong) NSArray *titleArray;
///
@property (nonatomic ,strong) TCIntegralDetailModel *integralDetailModel;

@end

@implementation TCIntegralDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"积分详情";
    _titleArray = @[@"类型:",@"时间:",@"流水号:",@"剩余积分:"];
    _isShowDetailLabText = NO;
    
    [self setMyIntegralDetailUI];
    [self requestMyIntegralDetailUIData];
}

#pragma mark -- Bulid UI

- (void)setMyIntegralDetailUI{
    [self.view addSubview:self.tableView];
}
- (UIView *)tableHerderView{
    UIView *tableHerderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    tableHerderView.backgroundColor = [UIColor whiteColor];
    UILabel *integralTypeLab = [[UILabel alloc]initWithFrame:CGRectMake( 15, 10, 200, 20)];
    integralTypeLab.textAlignment = NSTextAlignmentLeft;
    integralTypeLab.font = kFontWithSize(15);
    integralTypeLab.textColor = UIColorFromRGB(0x313131);
    [tableHerderView addSubview:integralTypeLab];
    
    if ([_userIntegralmodel.use_type integerValue] == 1) {
        integralTypeLab.text = @"入账积分";
    }else{
        integralTypeLab.text = @"出账积分";
    }
    
    // 积分
    UILabel *usePointsLab = [[UILabel alloc]initWithFrame:CGRectMake( kScreenWidth - 215, 10, 200, 30)];
    usePointsLab.textColor = UIColorFromRGB(0x313131);
    usePointsLab.font = kFontWithSize(25);
    usePointsLab.textAlignment = NSTextAlignmentRight;
    [tableHerderView addSubview:usePointsLab];
    
    NSString *textStr = [NSString stringWithFormat:@"+%@",_userIntegralmodel.use_points];
    CGSize integralTextSize = [textStr boundingRectWithSize:CGSizeMake(200, 25) withTextFont:kFontWithSize(25)];
    
    UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - integralTextSize.width - 40 , 45/2, 15, 15)];
    [tableHerderView addSubview:iconImg];
    
    usePointsLab.frame = CGRectMake(kScreenWidth - integralTextSize.width - 20, 35/2 , integralTextSize.width, 25);
    iconImg.frame = CGRectMake(kScreenWidth - integralTextSize.width - 40 , 45/2, 15, 15);
    
    
    if ([_userIntegralmodel.use_type integerValue] == 1) {
        usePointsLab.textColor = UIColorFromRGB(0xf9c92b);
        usePointsLab.text = [NSString stringWithFormat:@"+%@",_userIntegralmodel.use_points];
        iconImg.image = [UIImage imageNamed:@"yellow_integral"];
    }else{
        usePointsLab.text = [NSString stringWithFormat:@"-%@",_userIntegralmodel.use_points];
        usePointsLab.textColor = kSystemColor;
        iconImg.image = [UIImage imageNamed:@"green_integral"];
    }
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, tableHerderView.height - 0.5, kScreenWidth, 0.5)];
    len.backgroundColor = kLineColor;
    [tableHerderView addSubview:len];
    return tableHerderView;
}
#pragma mark -- Request Data
- (void)requestMyIntegralDetailUIData{
    // App版本信息
    NSString *version = [NSString getAppVersion];
    NSString *url = [NSString stringWithFormat:@"%@?task_sn=%@&app_version=%@",kIntegralDetail,_userIntegralmodel.task_sn,version];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            _isShowDetailLabText = YES;
            weakSelf.integralDetailModel = [TCIntegralDetailModel new];
            [weakSelf.integralDetailModel setValues:resultDic];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myIntegralDetailIdentifier  = @"Identifier";
    TCMyIntegralDetailCell *myIntegralDetailCell  =[tableView dequeueReusableCellWithIdentifier:myIntegralDetailIdentifier];
    if (!myIntegralDetailCell) {
        myIntegralDetailCell = [[TCMyIntegralDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIntegralDetailIdentifier];
    }
    if (_isShowDetailLabText) {
        switch (indexPath.row) {
            case 0:
            {
                if ([_userIntegralmodel.use_type integerValue] == 1) {
                    myIntegralDetailCell.detailLab.text = @"收入";
                }else{
                    myIntegralDetailCell.detailLab.text = @"支出";
                }
            }break;
            case 1:
            {
                myIntegralDetailCell.detailLab.text =_integralDetailModel.time;
            }break;
            case 2:
            {
                myIntegralDetailCell.detailLab.text =_integralDetailModel.task_sn;
            }break;
            case 3:
            {
                myIntegralDetailCell.detailLab.text =[NSString stringWithFormat:@"%@",_integralDetailModel.rest_integral];
            }break;
            default:
                break;
        }
         myIntegralDetailCell.titleLab.text = _titleArray[indexPath.row];
    }
       return myIntegralDetailCell;
}

#pragma mark ====== Getter =======
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [self tableHerderView];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
