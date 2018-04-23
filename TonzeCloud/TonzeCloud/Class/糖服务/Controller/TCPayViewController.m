//
//  TCPayViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPayViewController.h"
#import "TCPaySuccessViewController.h"
#import "TCChooseCouponViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "TCPayButton.h"
#import "DiscountView.h"
#import "ChoosePayWayView.h"

#define kCellHeight  48

@interface TCPayViewController ()<ChoosePayWayViewDelegate>{
    NSString      *orderSn;
    
    BOOL          isWechatSelected;
}

@property (nonatomic,strong)ChoosePayWayView  *payView;
@property (nonatomic,strong)UIView            *payBottomView;

@end
@implementation TCPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"支付订单";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    
    [self.view addSubview:self.payView];
    [self.view addSubview:self.payBottomView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccessAction) name:kPaySuccessNotification object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-04-02" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-04-02" type:2];
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPaySuccessNotification object:nil];
}

#pragma mark -- CustomDelegate
#pragma mark ChoosePayWayViewDelegate
-(void)didSelectedPayWay:(NSInteger)payType{
    isWechatSelected=payType==0?NO:YES;
}

#pragma mark -- Event response
#pragma mark 立即支付
- (void)payButton{
    NSString *body=[NSString stringWithFormat:@"expert_id=%ld&type=%ld&plan_id=%ld",(long)self.expertId,(long)self.planType,(long)self.planId];
    NSString *url=isWechatSelected?kWechatPayOrder:kAlipayOrder;
    __weak typeof(self) weakSelf=self;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        [NSUserDefaultsInfos putKey:kIsShopPayed andValue:[NSNumber numberWithBool:NO]];
        if (kIsDictionary(result)&&result.count>0) {
            if (isWechatSelected) {
                PayReq* req             = [[PayReq alloc] init];
                req.openID              = [result valueForKey:@"appid"];
                req.partnerId           = [result valueForKey:@"partnerid"];
                req.prepayId            = [result valueForKey:@"prepayid"];
                req.nonceStr            = [result valueForKey:@"noncestr"];
                req.timeStamp           = [[result valueForKey:@"timestamp"] integerValue];
                req.package             = [result valueForKey:@"package"];
                req.sign                = [result valueForKey:@"sign"];
                
                [WXApi sendReq:req];
                
                orderSn=[result valueForKey:@"order_sn"];
                [NSUserDefaultsInfos putKey:kOrderSn andValue:orderSn];
            }else{
                NSString *orderStr=[result valueForKey:@"uri"];
                orderSn=[result valueForKey:@"order_sn"];
                [NSUserDefaultsInfos putKey:kOrderSn andValue:orderSn];
                MyLog(@"orderSn:%@",orderSn);
                
                [[AlipaySDK defaultService] payOrder:orderStr fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                    MyLog(@"result:%@",resultDic);
                    NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                    if (resultStatus==9000) {
                        NSString *order_sn=[NSUserDefaultsInfos getValueforKey:kOrderSn];
                        NSString *body=[NSString stringWithFormat:@"order_sn=%@",order_sn];
                        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kSyncAlipayStatus body:body success:^(id json) {
                            
                            TCPaySuccessViewController *paysuccessVC = [[TCPaySuccessViewController alloc] init];
                            paysuccessVC.order_sn=orderSn;
                            [weakSelf.navigationController pushViewController:paysuccessVC animated:YES];
                            
                            [MobClick event:@"501_001002"];
                        } failure:^(NSString *errorStr) {
                            
                        }];
                    }else if(resultStatus==6001){
                        [weakSelf.view makeToast:@"用户取消支付" duration:1.0 position:CSToastPositionCenter];
                    }else{
                        [weakSelf.view makeToast:@"订单支付失败" duration:1.0 position:CSToastPositionCenter];
                    }
                }];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- NSNotification
-(void)paySuccessAction{
    TCPaySuccessViewController *paysuccessVC = [[TCPaySuccessViewController alloc] init];
    paysuccessVC.order_sn=orderSn;
    [self.navigationController pushViewController:paysuccessVC animated:YES];
}



#pragma mark -- Setters and getters
#pragma mark 支付方式
-(ChoosePayWayView *)payView{
    if (!_payView) {
        _payView=[[ChoosePayWayView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 140)];
        _payView.delegate=self;
    }
    return _payView;
}

#pragma mark 底部视图
-(UIView *)payBottomView{
    if (!_payBottomView) {
        _payBottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _payBottomView.backgroundColor=[UIColor whiteColor];
        
        UILabel *muchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth/2 , 30)];
        muchLabel.font = [UIFont systemFontOfSize:15];
        muchLabel.textColor = [UIColor blackColor];
        NSString *tempStr=[NSString stringWithFormat:@"应付金额：%.2f元", self.payPriceAmount >0?self.payPriceAmount:self.payAmount];
        NSRange aRange=NSMakeRange(5, tempStr.length-5);
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f69b32"] range:aRange];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:aRange];
        muchLabel.attributedText=attributeStr;
        [_payBottomView addSubview:muchLabel];
        
        UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-103, 0,103, 50)];
        [payBtn setTitle:@"立即支付" forState:UIControlStateNormal];
        payBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        payBtn.backgroundColor = kbgBtnColor;
        [payBtn addTarget:self action:@selector(payButton) forControlEvents:UIControlEventTouchUpInside];
        [_payBottomView addSubview:payBtn];
    }
    return _payBottomView;
}


@end
