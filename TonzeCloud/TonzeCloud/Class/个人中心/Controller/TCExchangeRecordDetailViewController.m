//
//  ExchangeRecordsDetailVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeRecordDetailViewController.h"
#import "TCExchangeRecordsDetailCell.h"
#import "TCExchangeOrderscell.h"
#import "TCExchangeAddressCell.h"
#import "QLCoreTextManager.h"
#import "TCExchangeRecordsDetailModel.h"
#import "TCExchangeRecordsGoodsModel.h"

@interface TCExchangeRecordDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isShoworderInfo;
}
@property (nonatomic,strong) UITableView *tableView;
/// 拨打电话
@property (nonatomic ,strong) UILabel *phoneLab;
/// 标题
@property (nonatomic ,strong) NSArray *titleArray;
/// 商品信息
@property (nonatomic ,strong) TCExchangeRecordsGoodsModel *goodsModel;
///
@property (nonatomic ,strong) TCExchangeRecordsDetailModel *exchangeRecordsDetailModel;
/// 订单数据
@property (nonatomic ,strong) NSMutableArray *orderArray;

@end

@implementation TCExchangeRecordDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"兑换详情";
    _isShoworderInfo = NO;
    switch (_shipType) {
        case Shipped:
        {
            _titleArray =@[@"订单编号：",@"兑换时间：",@"订单状态：",@"物流名称：",@"运单编号:、："];
        }break;
        case NotShipped:
        {
            _titleArray =@[@"订单编号：",@"兑换时间：",@"订单状态："];
        }break;
        default:
            break;
    }
    [self setExchangeRecordsDetailUI];
    [self requestExchangeRecordsDetailData];
}
#pragma mark -- Bulid UI
- (void)setExchangeRecordsDetailUI{
    [self.view addSubview:self.tableView];
}
- (UIView *)tableFooterView{
    UIView *tableFooterView = [[UIView alloc]init];
    tableFooterView.backgroundColor = [UIColor bgColor_Gray];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    [tableFooterView addSubview:bgView];
    
    switch (self.shipType) {
        case Shipped:
        {
            tableFooterView.frame = CGRectMake(0, 0, kScreenWidth, 38 + 10);
            bgView.frame = CGRectMake(0, 10, kScreenWidth, tableFooterView.height - 10);
            
            [bgView addSubview:self.phoneLab];
        }break;
        case NotShipped:
        {
            tableFooterView.frame = CGRectMake(0, 0, kScreenWidth, 66 + 10);
            bgView.frame = CGRectMake(0, 10, kScreenWidth, tableFooterView.height - 10);
    
            UILabel *tipLab = [[UILabel alloc]initWithFrame: CGRectMake(12, 9 , kScreenWidth  - 24, 20)];
            tipLab.text = @"我们将在5-7个工作日内发货";
            tipLab.textColor = UIColorFromRGB(0x313131);
            tipLab.font = kFontWithSize(13);
            tipLab.textAlignment = NSTextAlignmentLeft;
            [bgView addSubview:tipLab];
            
            self.phoneLab.frame = CGRectMake(12, 38, kScreenWidth - 24, 20);
            [bgView addSubview:self.phoneLab];
        }break;
        default:
            break;
    }
    
    UIButton *tellPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tellPhoneBtn.frame = CGRectMake(0, 0, kScreenWidth, bgView.height);
    [tellPhoneBtn addTarget:self action:@selector(tellPhoneClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:tellPhoneBtn];
    
    return tableFooterView;
}
#pragma mark -- Request Data
- (void)requestExchangeRecordsDetailData{
    NSString *body = [NSString stringWithFormat:@"order_id=%ld",_order_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KExchangeRecordsDetail body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            weakSelf.exchangeRecordsDetailModel = [TCExchangeRecordsDetailModel new];
            [weakSelf.exchangeRecordsDetailModel setValues:resultDic];
            _isShoworderInfo = YES;
            if (weakSelf.shipType == Shipped) {
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.order_sn];
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.change_time];
                [weakSelf.orderArray addObject:@"已发货"];
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.logistics_company];
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.tracking_number];
            }else{
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.order_sn];
                [weakSelf.orderArray addObject:weakSelf.exchangeRecordsDetailModel.change_time];
                [weakSelf.orderArray addObject:@"未发货"];
            }
        }
        /// 商品信息
        NSDictionary *goodsDic = [resultDic objectForKey:@"goods"];
        if (kIsDictionary(goodsDic)) {
            weakSelf.goodsModel = [TCExchangeRecordsGoodsModel new];
            [weakSelf.goodsModel setValues:goodsDic];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Action =======
// 拨打电话
- (void)tellPhoneClick{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt:%@",@"4009004288"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark ====== UITableViewDelegate =======
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return _titleArray.count;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            NSString *addStr = [NSString stringWithFormat:@"%@%@%@%@",_exchangeRecordsDetailModel.consignee_pro,_exchangeRecordsDetailModel.consignee_city,_exchangeRecordsDetailModel.consignee_area,_exchangeRecordsDetailModel.consignee_addr];
            CGFloat addHight =[TCExchangeAddressCell tableView:tableView rowHeightForObject:addStr];
            return addHight + 60;
        }break;
        case 1:
        {
            return 90;
        }break;
        default:
            break;
    }
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, kScreenWidth, 10)];
    sectionView.backgroundColor = [UIColor bgColor_Gray];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *exchangeRecordsCellIdentifier  = @"exchangeRecordsCell";
    static NSString *exchangeOrderscellIdentifier  = @"exchangeOrderscell";
    static NSString *exchangeAddressCellIdentifier  = @"exchangeAddressCell";
    
    switch (indexPath.section) {
        case 0:
        {// 地址
            TCExchangeAddressCell *exchangeAddressCell = [tableView dequeueReusableCellWithIdentifier:exchangeAddressCellIdentifier];
            if (!exchangeAddressCell) {
                exchangeAddressCell = [[TCExchangeAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:exchangeAddressCellIdentifier];
            }
            exchangeAddressCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [exchangeAddressCell setExchangeAddressWithModel:_exchangeRecordsDetailModel];
            return exchangeAddressCell;
        }break;
        case 1:
        {// 商品详情
            TCExchangeRecordsDetailCell *exchangeRecordsCell = [tableView dequeueReusableCellWithIdentifier:exchangeRecordsCellIdentifier];
            if (!exchangeRecordsCell) {
                exchangeRecordsCell = [[TCExchangeRecordsDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:exchangeRecordsCellIdentifier];
            }
            exchangeRecordsCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [exchangeRecordsCell setExchangeRecordsDetailWithModel:_goodsModel];
            return exchangeRecordsCell;
        }break;
        default:
            break;
    }
    // 订单
    TCExchangeOrderscell *exchangeOrderscell = [tableView dequeueReusableCellWithIdentifier:exchangeOrderscellIdentifier];
    if (!exchangeOrderscell) {
        exchangeOrderscell = [[TCExchangeOrderscell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:exchangeOrderscellIdentifier];
    }
    exchangeOrderscell.selectionStyle = UITableViewCellSelectionStyleNone;
    exchangeOrderscell.titleLab.text = self.titleArray[indexPath.row];
    if (_isShoworderInfo) {
        exchangeOrderscell.contentLab.text = [NSString stringWithFormat:@"%@",self.orderArray[indexPath.row]];
    }
    return exchangeOrderscell;
}
#pragma mark ====== Getter =======

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth,kRootViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.tableFooterView = [UIView new];
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}
-(UILabel *)phoneLab{
    if (!_phoneLab) {
        _phoneLab = [[UILabel alloc]initWithFrame:CGRectMake(12, 9, kScreenWidth - 24, 20)];
        _phoneLab.textAlignment = NSTextAlignmentLeft;
        _phoneLab.textColor = UIColorFromRGB(0x313131);
        _phoneLab.font = kFontWithSize(13);
        NSString *tipStr = @"客服热线： 4009004288";
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:tipStr];
        [QLCoreTextManager setAttributedValue:attStr text:@"4009004288" font:kFontWithSize(14) color:kSystemColor];
        _phoneLab.attributedText = attStr;
    }
    return _phoneLab;
}
- (NSMutableArray *)orderArray{
    if (!_orderArray) {
        _orderArray = [NSMutableArray array];
    }
    return _orderArray;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
