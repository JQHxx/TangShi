//
//  IntegralGoodsVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/6.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCIntegralGoodsViewController.h"
#import "IntegralGoodsAddressCell.h"
#import "TCProductDescriptionCell.h"
#import "TCShippingAddressViewController.h"
#import "TCCommodityInfoCell.h"
#import "TCGoodsDetailModel.h"
#import "TCGoodsDetailModel.h"
#import "QLCoreTextManager.h"
#import "TCGoodsDetailImgsModel.h"
#import "TCConsigneeInfoModel.h"
#import "TCExchangeSuccessViewController.h"
#import "TCFastLoginViewController.h"

@interface TCIntegralGoodsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isShowAddress;/// 是否显示收货地址
    BOOL _isTitleTwoLines;/// 商品标题两行显示
    NSString *_nameStr;
    NSString *_phoneStr;
    NSString *_addressStr;
}
/// 兑换时间
@property (nonatomic ,strong) UILabel *exchangeTimeLab;
///
@property (nonatomic ,strong) UITableView *tableView;
///
@property (nonatomic ,strong) UIButton *exchangeBtn;
///
@property (nonatomic ,strong) TCGoodsDetailModel *goodDetailModel;
/// 详情图片
@property (nonatomic ,strong) NSMutableArray *goodsDetaliImgArray;
/// 收货地址信息
@property (nonatomic ,strong) TCConsigneeInfoModel *consigneeInfoModel;
@end

@implementation TCIntegralGoodsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TCHelper sharedTCHelper].isIngralGoodsReload) {
        [self.goodsDetaliImgArray removeAllObjects];
        [self requestIntegralGoodsData];
        [TCHelper sharedTCHelper].isIngralGoodsReload = NO;
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"商品详情";
    
    _isShowAddress = NO;
    _isTitleTwoLines = NO;
    [self setIntegralGoodsUI];
    [self requestIntegralGoodsData];
}
#pragma mark -- Bulid UI

- (void)setIntegralGoodsUI{
    [self.view addSubview:self.tableView];
}
- (UIView *)tableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 180)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    _exchangeTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 54, kScreenWidth, 20)];
    _exchangeTimeLab.textAlignment = NSTextAlignmentCenter;
    _exchangeTimeLab.textColor = UIColorFromRGB(0xff9d38);
    _exchangeTimeLab.font = kFontWithSize(13);
    [footerView addSubview:_exchangeTimeLab];
    
    _exchangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _exchangeBtn.frame = CGRectMake(40, _exchangeTimeLab.bottom + 11, kScreenWidth - 80, 44);
    [_exchangeBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    [_exchangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exchangeBtn addTarget:self action:@selector(exchangeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _exchangeBtn.backgroundColor = kbgBtnColor;
    _exchangeBtn.titleLabel.font = kFontWithSize(16);
    _exchangeBtn.layer.cornerRadius = 5;
    [footerView addSubview:_exchangeBtn];
    return footerView;
}
#pragma mark -- Request Data

- (void)requestIntegralGoodsData{
    
    NSString *body = [NSString stringWithFormat:@"good_id=%ld",_good_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KGoodDetail body:body success:^(id json) {
        NSDictionary *result  = [json objectForKey:@"result"];
        NSArray *imgesArray = [result objectForKey:@"images"];
        NSInteger point = [[result objectForKey:@"point"] integerValue];
        
        if (kIsDictionary(result)) {
            weakSelf.goodDetailModel = [TCGoodsDetailModel new];
            [weakSelf.goodDetailModel setValues:result];
            
            NSString *integralStr =[NSString stringWithFormat:@"兑换结束时间：%@",weakSelf.goodDetailModel.shelf_time];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:integralStr];
            [QLCoreTextManager setAttributedValue:attStr text:@"兑换结束时间：" font:kFontWithSize(13) color:UIColorFromRGB(0x959595)];
            weakSelf.exchangeTimeLab.attributedText = attStr;
            
            // 按钮状态
            BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
            if (isLogin) {
                if (point < [weakSelf.goodDetailModel.change_points integerValue]) {
                    [weakSelf.exchangeBtn setBackgroundColor:UIColorFromRGB(0xBFBFBF)];
                    [weakSelf.exchangeBtn setTitle:@"积分不足" forState:UIControlStateNormal];
                    weakSelf.exchangeBtn.enabled = NO;
                }else if ([weakSelf.goodDetailModel.status integerValue]== 2){
                    [weakSelf.exchangeBtn setBackgroundColor:UIColorFromRGB(0xBFBFBF)];
                    [weakSelf.exchangeBtn setTitle:@"已兑完" forState:UIControlStateNormal];
                    weakSelf.exchangeBtn.enabled = NO;
                }else if ([weakSelf.goodDetailModel.status integerValue] ==3){
                    [weakSelf.exchangeBtn setBackgroundColor:UIColorFromRGB(0xBFBFBF)];
                    [weakSelf.exchangeBtn setTitle:@"兑换结束" forState:UIControlStateNormal];
                    weakSelf.exchangeBtn.enabled = NO;
                }
            }
           
            // 判断标题高度
            CGSize titleStrSize = [weakSelf.goodDetailModel.good_name boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 50) withTextFont:kFontWithSize(15)];
            if (titleStrSize.height > 18) {
                _isTitleTwoLines = YES;
            }
            // 收货地址信息
            NSDictionary *consigneeDic = [result objectForKey:@"consignee"];
            if (kIsDictionary(consigneeDic)) {
                weakSelf.consigneeInfoModel = [TCConsigneeInfoModel new];
                [weakSelf.consigneeInfoModel setValues:consigneeDic];
                if (!kIsEmptyString(weakSelf.consigneeInfoModel.consignee_name)) {
                    _isShowAddress = YES;
                    _addressStr = [NSString stringWithFormat:@"%@%@%@%@",weakSelf.consigneeInfoModel.consignee_pro,_consigneeInfoModel.consignee_city,weakSelf.consigneeInfoModel.consignee_area,weakSelf.consigneeInfoModel.consignee_addr];
                    _nameStr = weakSelf.consigneeInfoModel.consignee_name;
                    _phoneStr = weakSelf.consigneeInfoModel.consignee_phone;
                }
            }
        }
        if (kIsArray(imgesArray) && imgesArray.count > 0){
            for (NSDictionary *dic in imgesArray) {
                TCGoodsDetailImgsModel *imgsModel = [TCGoodsDetailImgsModel new];
                [imgsModel setValues:dic];
                [weakSelf.goodsDetaliImgArray addObject:imgsModel.image_url];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)exchangeGoodsGoods{
    NSString *body = [NSString stringWithFormat:@"good_id=%ld",_good_id];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KExchangeGoods body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        //        NSString *message = [json objectForKey:@"message"];
        if (status == 1) {
            
            [TCHelper sharedTCHelper].isIntegralMallRecord = YES;
            TCExchangeSuccessViewController *exchangeSuccessVC = [TCExchangeSuccessViewController new];
            [self.navigationController pushViewController:exchangeSuccessVC animated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark ====== Event =======
#pragma mark ====== 立即兑换 =======

- (void)exchangeBtnClick{
    [MobClick event:@"104_003009"];

    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        if (kIsEmptyString(_consigneeInfoModel.consignee_name)) {
            [self.view makeToast:@"请填写收货信息" duration:1.0 position:CSToastPositionCenter];
        }else{
            NSString *titleStr =[NSString stringWithFormat:@"确定使用%@积分兑换？",_goodDetailModel.change_points];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:titleStr message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            kSelfWeak;
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [weakSelf exchangeGoodsGoods];
                }
            }];
        }
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate  =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 2:
        {
            return self.goodsDetaliImgArray.count;
        }break;
        default:
            break;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (_isTitleTwoLines) {
                return 375*kScreenWidth/375 + 140;
            }else{
                return 375*kScreenWidth/375 + 140 + 10;
            }
        }break;
        case 1:
        {
            if (_isShowAddress) {
                return 38 * 2;
            }else{
                return 38;
            }
        }break;
        case 2:
        {
            return 240 *kScreenWidth/375 ;
        }break;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return 0;
        }break;
        case 1:
        {
            return 10;
        }break;
        case 2:
        {
            return 76/2;
        }break;
        default:
            break;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 76/2)];
        sectionHeaderView.backgroundColor = [UIColor bgColor_Gray];
        
        UILabel *detailsTipLab = [[UILabel alloc]initWithFrame:CGRectMake(20, (38- 15)/2,  180, 15)];
        detailsTipLab.textAlignment = NSTextAlignmentLeft;
        detailsTipLab.text = @"商品描述：";
        detailsTipLab.textColor = UIColorFromRGB(0x959595);
        detailsTipLab.font = kFontWithSize(13);
        [sectionHeaderView addSubview:detailsTipLab];
        
        return sectionHeaderView;
    }else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *productDescriptionIdentifier = @"productDescriptionIdentifier";
    static NSString *IntegralGoodsAddressIdentifier  = @"IntegralGoodsAddressIdentifier";
    static NSString *commodityInfoIdentifier  = @"commodityInfoIdentifier";
    switch (indexPath.section) {
        case 0:
        {/// 商品信息
            TCCommodityInfoCell *commodityInfoCell = [[TCCommodityInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commodityInfoIdentifier];
            commodityInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [commodityInfoCell setCellDataWithModel:_goodDetailModel];
            return commodityInfoCell;
        }break;
        case 1:
        {// 收货信息
            IntegralGoodsAddressCell *integralGoodsAddressCell = [[IntegralGoodsAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IntegralGoodsAddressIdentifier];
            integralGoodsAddressCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (_isShowAddress) {
                integralGoodsAddressCell.addressInfoLab.hidden = NO;
                integralGoodsAddressCell.nameLab.text = [NSString stringWithFormat:@"收货信息：%@",_nameStr];
                integralGoodsAddressCell.addressInfoLab.text = _addressStr;
                integralGoodsAddressCell.phoneNumberLab.text = _phoneStr;
                integralGoodsAddressCell.phoneNumberLab.textColor = UIColorFromRGB(0x313131);
                integralGoodsAddressCell.arrowImg.frame = CGRectMake(kScreenWidth - 35, (76 - 15)/2, 15, 15);
            }else{
                integralGoodsAddressCell.addressInfoLab.hidden = YES;
            }
            return integralGoodsAddressCell;
        }break;
        default:
            break;
    }
    //  商品图片
    TCProductDescriptionCell *productDescriptionCell = [tableView dequeueReusableCellWithIdentifier:productDescriptionIdentifier];
    if (!productDescriptionCell) {
        productDescriptionCell = [[TCProductDescriptionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:productDescriptionIdentifier];
    }
    if (_goodsDetaliImgArray.count > 0) {
         productDescriptionCell.imgUrl = _goodsDetaliImgArray[indexPath.row];
    }
    productDescriptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return productDescriptionCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:
        {
            [MobClick event:@"104_003008"];

            BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
            if (isLogin) {
                TCShippingAddressViewController *addressVC = [TCShippingAddressViewController new];
                kSelfWeak;
                addressVC.consigneeInfoModel = weakSelf.consigneeInfoModel;
                addressVC.addressInfo = ^(NSString *addressStr,NSString *phoneNumberStr,NSString *nameStr){
                    _nameStr = nameStr;
                    _addressStr = addressStr;
                    _phoneStr = phoneNumberStr;
                    _isShowAddress= YES;
                    [weakSelf.tableView reloadData];
                };
                [self.navigationController pushViewController:addressVC animated:YES];
            }else{
                [self fastLoginAction];
            }
        }break;
        default:
            break;
    }
}
#pragma mark ====== Getter =======

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor bgColor_Gray];
        _tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);// 偏移第一个section的默认高度
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}
- (NSMutableArray *)goodsDetaliImgArray{
    if (!_goodsDetaliImgArray) {
        _goodsDetaliImgArray = [NSMutableArray array];
    }
    return _goodsDetaliImgArray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
