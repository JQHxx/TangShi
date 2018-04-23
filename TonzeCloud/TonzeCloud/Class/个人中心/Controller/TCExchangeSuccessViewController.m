
//
//  ExchangeSuccessVC.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeSuccessViewController.h"
#import "TCPointslMallViewController.h"
#import "TCExchangeRecordsViewController.h"

@interface TCExchangeSuccessViewController ()
/// 成功提示
@property (nonatomic, strong) UILabel *successTipLab;
/// 成功icon
@property (nonatomic ,strong) UIImageView *successIcon;
/// 去商城
@property (nonatomic ,strong) UIButton *goIntegralMallBtn;
/// 去兑换记录
@property (nonatomic ,strong) UIButton *goExchangeRecordBtn;

@end
@implementation TCExchangeSuccessViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"兑换成功";
    self.isHiddenBackBtn = YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self setExchangeSuccessVC];
}
#pragma mark -- Bulid UI
- (void)setExchangeSuccessVC{
    [self.view addSubview:self.successIcon];
    [self.view addSubview:self.successTipLab];
    [self.view addSubview:self.goExchangeRecordBtn];
    [self.view addSubview:self.goIntegralMallBtn];
}

#pragma mark ====== Event response =======
#pragma mark ====== 兑换记录 、 积分商城 =======
- (void)goBtnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 1000:
        {
            TCExchangeRecordsViewController *exchangeRecordsVC = [TCExchangeRecordsViewController new];
            exchangeRecordsVC.isExchangeSuccessLogin = YES;
            [self.navigationController pushViewController:exchangeRecordsVC animated:YES];
        }break;
         case 1001:
        {
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[TCPointslMallViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
                }
            }
        }break;
        default:
            break;
    }
}
#pragma mark ====== Getter =======
- (UIImageView *)successIcon{
    if (!_successIcon) {
        _successIcon = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 90)/2, 40 + kNewNavHeight, 90, 90)];
        _successIcon.image = [UIImage imageNamed:@"ic_finish"];
    }
    return _successIcon;
}
- (UILabel *)successTipLab{
    if (!_successTipLab) {
        _successTipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _successIcon.bottom + 36/2, kScreenWidth, 20)];
        _successTipLab.text = @"兑换成功";
        _successTipLab.textAlignment = NSTextAlignmentCenter;
        _successTipLab.textColor = UIColorFromRGB(0xff9630);
        _successTipLab.font = kFontWithSize(16);
    }
    return _successTipLab;
}
- (UIButton *)goIntegralMallBtn{
    if (!_goIntegralMallBtn) {
        _goIntegralMallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goIntegralMallBtn.frame = CGRectMake( kScreenWidth/2 + (kScreenWidth/2 - 120)/2, _successTipLab.bottom + 100, 120, 76/2);
        [_goIntegralMallBtn setTitle:@"继续兑换" forState:UIControlStateNormal];
        [_goIntegralMallBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _goIntegralMallBtn.titleLabel.font = kFontWithSize(15);
        _goIntegralMallBtn.backgroundColor = UIColorFromRGB(0xFD8137);
        _goIntegralMallBtn.layer.cornerRadius = 38/2;
        _goIntegralMallBtn.tag = 1001;
        [_goIntegralMallBtn addTarget:self action:@selector(goBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goIntegralMallBtn;
}
- (UIButton *)goExchangeRecordBtn{
    if (!_goExchangeRecordBtn) {
        _goExchangeRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goExchangeRecordBtn.frame = CGRectMake((kScreenWidth/2 - 120)/2, _successTipLab.bottom + 100, 120, 76/2);
        [_goExchangeRecordBtn setTitle:@"查看兑换记录" forState:UIControlStateNormal];
        [_goExchangeRecordBtn setTitleColor:UIColorFromRGB(0xff9630) forState:UIControlStateNormal];
        _goExchangeRecordBtn.titleLabel.font = kFontWithSize(15);
        _goExchangeRecordBtn.clipsToBounds = YES;
        _goExchangeRecordBtn.backgroundColor = [UIColor whiteColor];
        _goExchangeRecordBtn.layer.cornerRadius = 38/2;
        _goExchangeRecordBtn.layer.borderWidth = 1;
        _goExchangeRecordBtn.layer.borderColor =UIColorFromRGB(0xff9630).CGColor;
        _goExchangeRecordBtn.tag = 1000;
        [_goExchangeRecordBtn addTarget:self action:@selector(goBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goExchangeRecordBtn;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
