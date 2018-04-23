//
//  TCMissionCompletedAlertView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#define kButtonHei 32
#define kDistance 58

#define kTitleFont 40
#define kMassageFont 15
#define kBtnTitleFont  15

#import "TCMissionCompletedAlertView.h"
#import "QLCoreTextManager.h"

@interface TCMissionCompletedAlertView ()
{
    UIView *_backgraoudView;  //蒙板背景
    UIImageView *_titleImg;   // 标题图片
    UILabel *_titleLabel;     // 标题
    UILabel *_taskSuccessLab;  // 任务完成
    UILabel *_getPointsLab;    // 获得积分
    UILabel *_bonusPointsLab;  // 奖励积分
    UIView *_aletView;
}
@end

@implementation TCMissionCompletedAlertView

- (instancetype)initWithTaskSuccessStr:(NSString *)taskSuccessStr points:(NSInteger )points rewardIntegralStr:(NSString *)rewardIntegralStr isHideBonusPoints:(BOOL)isHideBonusPoints isHideRedeemBtn:(BOOL)isHideRedeemBtn{
    if (self = [super init]) {
       
        self.frame = CGRectMake(0, 0,kScreenWidth, kScreenHeight);
        //蒙板
        [_backgraoudView removeFromSuperview];
        _backgraoudView = nil;
        _backgraoudView = [[UIView alloc]init];
        _backgraoudView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _backgraoudView.backgroundColor = [UIColor blackColor];
        _backgraoudView.alpha = 0;
        [self addSubview:_backgraoudView];
        
        [UIView animateWithDuration:0.2 animations:^{
            _backgraoudView.alpha = 0.5;
        }];
        
        UIView *alertView = [[UIView alloc]init];
        alertView.backgroundColor = [UIColor whiteColor];
        alertView.frame = CGRectMake((kScreenWidth - 516/2)/2, 0, 516/2, 1000);
        alertView.layer.masksToBounds = YES; //没这句话它圆不起来
        alertView.layer.cornerRadius =5; //设置图片圆角的尺度
        [self addSubview:alertView];
        
        UIImageView *titleImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 750/2)/2 , 0 , 750/2, 316/2)];
        titleImg.image = [UIImage imageNamed:@"finish_window"];
        [self addSubview:titleImg];
        _titleImg = titleImg;
        
        CGSize taskLabelSize = [taskSuccessStr boundingRectWithSize:CGSizeMake(alertView.width, 100) withTextFont:kFontWithSize(14)];
        _taskSuccessLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, alertView.width, taskLabelSize.height)];
        _taskSuccessLab.textAlignment = NSTextAlignmentCenter;
        _taskSuccessLab.text = taskSuccessStr;
        _taskSuccessLab.numberOfLines = 0;
        _taskSuccessLab.font = kFontWithSize(15);
        _taskSuccessLab.textColor = UIColorFromRGB(0x959595);
        [alertView addSubview:_taskSuccessLab];
        
        NSString *integralStr = [NSString stringWithFormat:@"恭喜您获得%ld积分",(long)points];
        CGSize getPointsLabelSize = [integralStr boundingRectWithSize:CGSizeMake(alertView.width, 100) withTextFont:kFontWithSize(20)];
        _getPointsLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _taskSuccessLab.bottom + 38/2, alertView.width, getPointsLabelSize.height)];
        _getPointsLab.textAlignment = NSTextAlignmentCenter;
        _getPointsLab.numberOfLines = 0;
        _getPointsLab.font = kFontWithSize(20);
        _getPointsLab.textColor = UIColorFromRGB(0x313131);
        [alertView addSubview:_getPointsLab];
        NSMutableAttributedString *atts = [[NSMutableAttributedString alloc]initWithString:integralStr];
        [QLCoreTextManager setAttributedValue:atts text:[NSString stringWithFormat:@"%ld积分",(long)points] font:kFontWithSize(20) color:UIColorFromRGB(0xf9c92b)];
        _getPointsLab.attributedText = atts;
        
        if (!kIsEmptyString(rewardIntegralStr)) {
            CGSize bonusPointsLabelSize = [rewardIntegralStr boundingRectWithSize:CGSizeMake(alertView.width, 100) withTextFont:kFontWithSize(15)];
            _bonusPointsLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _getPointsLab.bottom + 10, alertView.width, bonusPointsLabelSize.height)];
            _bonusPointsLab.textAlignment = NSTextAlignmentCenter;
            _bonusPointsLab.text = rewardIntegralStr;
            _bonusPointsLab.numberOfLines = 0;
            _bonusPointsLab.hidden = isHideBonusPoints;
            _bonusPointsLab.font = kFontWithSize(13);
            _bonusPointsLab.textColor = UIColorFromRGB(0x313131);
            [alertView addSubview:_bonusPointsLab];
        }
        
        UIButton *determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (isHideBonusPoints) {
            determineBtn.frame = CGRectMake( (alertView.width - 274/2)/2, _getPointsLab.bottom + 56/2, 274/2, kButtonHei);
        }else{
            determineBtn.frame = CGRectMake( 40, _bonusPointsLab.bottom + 56/2, alertView.width - 80, kButtonHei);
        }
        [determineBtn setTitle:@"我知道了" forState:UIControlStateNormal];
        [determineBtn setBackgroundImage:[UIImage imageNamed:@"ic_green_btn"] forState:UIControlStateNormal];
        [determineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        determineBtn.titleLabel.font = kFontWithSize(16);
        determineBtn.tag = 1001;
        [determineBtn addTarget:self action:@selector(determineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        determineBtn.layer.cornerRadius = 5;
        [alertView addSubview:determineBtn];
        
        if (!isHideRedeemBtn) {
            UIButton *redeemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            redeemBtn.frame = CGRectMake(30,determineBtn.bottom + 10, alertView.width - 60, 30);
            [redeemBtn setTitle:@"积分兑换" forState:UIControlStateNormal];
            [redeemBtn setBackgroundColor:[UIColor whiteColor]];
            [redeemBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
            redeemBtn.titleLabel.font = kFontWithSize(15);
            redeemBtn.tag = 1002;
            [redeemBtn addTarget:self action:@selector(determineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [alertView addSubview:redeemBtn];
            alertView.frame = CGRectMake((kScreenWidth - 516/2)/2, 0, 516/2, CGRectGetMaxY(redeemBtn.frame)+ 10);
        }else{
            alertView.frame = CGRectMake((kScreenWidth - 516/2)/2, 0, 516/2, CGRectGetMaxY(determineBtn.frame)+ 10);
        }
        _aletView = alertView;
    }
    return self;
}
#pragma mark ====== 显示在控制器中 =======

- (void)show{
    [UIView animateWithDuration:0.5 animations:^{
        _titleImg.frame = CGRectMake((kScreenWidth - 750/2)/2 , 258/2 , 750/2, 316/2);
        _aletView.frame = CGRectMake((kScreenWidth - 516/2)/2,_titleImg.bottom - 30, 516/2, _aletView.frame.size.height);
    }];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self];
}
#pragma mark ====== Action =======
#pragma mark ====== 积分兑换跳转 =======

- (void)determineBtnClick:(UIButton *)sender{
    switch (sender.tag) {
        case 1001:
        {// 销毁视图
            kSelfWeak;
            [UIView animateWithDuration:0.5 animations:^{
                _titleImg.frame = CGRectMake((kScreenWidth - 750/2)/2 ,kScreenHeight , 750/2, 316/2);
                _aletView.frame = CGRectMake(kDistance, kScreenHeight, 518/2, _aletView.frame.size.height + 10);
            } completion:^(BOOL finished) {
                [weakSelf removeFromSuperview];
                if (self.alertResultBlcok) {
                    self.alertResultBlcok(1001);
                }
            }];
        }break;
        case 1002:
        {   // 去积分商城
            kSelfWeak;
            [UIView animateWithDuration:0.5 animations:^{
                [weakSelf removeFromSuperview];
            } completion:^(BOOL finished) {
                if (self.alertResultBlcok) {
                    self.alertResultBlcok(1002);
                }
            }];
        
        }break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
